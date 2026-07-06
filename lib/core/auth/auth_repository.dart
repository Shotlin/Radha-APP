import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'auth_session.dart';
import 'session_storage.dart';

/// Result of `POST /auth/otp/request`. Surfaces the server-issued
/// `requestId` plus the cooldown window the OTP screen needs to render its
/// resend timer.
class OtpRequestResult {
  const OtpRequestResult({
    required this.requestId,
    required this.expiresIn,
    this.rateLimitRemaining,
    this.devOtp,
  });

  final String requestId;
  final int expiresIn;
  final int? rateLimitRemaining;

  /// Dev/test only — the OTP echoed back by a development server. Drives the
  /// debug-only autofill banner on the verify screen; null in real builds.
  final String? devOtp;
}

/// Single seam between the auth UI and the backend. Anything that needs to
/// know about tokens or `/auth/*` goes through this class. Holds no state of
/// its own — state lives in [SessionStorage] and `AuthController`.
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  }) : _api = apiClient,
       _storage = sessionStorage;

  final ApiClient _api;
  final SessionStorage _storage;

  /// Kicks off the OTP flow. The returned `requestId` must be echoed back in
  /// the subsequent `verifyOtp` call (server uses it to match the SMS).
  Future<OtpRequestResult> requestOtp(String mobile) async {
    final res = await _api.requestOtp(OtpRequestRequestDto(mobile: mobile));
    return OtpRequestResult(
      requestId: res.requestId,
      expiresIn: res.expiresIn,
      rateLimitRemaining: res.rateLimitRemaining,
      devOtp: res.devOtp,
    );
  }

  /// Completes the OTP flow. On success the full [AuthSession] is persisted
  /// to secure storage and returned. Roles and store access are pulled in via
  /// `/auth/me` so the session is complete the moment the user lands on a
  /// post-login screen.
  Future<AuthSession> verifyOtp({
    required String mobile,
    required String otp,
    required String requestId,
  }) async {
    final login = await _api.verifyOtp(
      VerifyOtpRequestDto(mobile: mobile, otp: otp, requestId: requestId),
    );
    return _completeLogin(login);
  }

  /// Email + password flow used by tenant admins. Same persistence semantics
  /// as [verifyOtp].
  Future<AuthSession> adminLogin({
    required String email,
    required String password,
  }) async {
    final login = await _api.adminLogin(
      AdminLoginRequestDto(email: email, password: password),
    );
    return _completeLogin(login);
  }

  /// Rotates the access + refresh tokens. Only the tokens are rewritten — the
  /// user, tenant, roles, and store-access on disk are left intact. Throws
  /// [UnauthorizedException] if the refresh token has been revoked.
  Future<AuthSession> refresh() async {
    final current = await _storage.readSession();
    if (current == null) {
      throw const UnauthorizedException(message: 'No session to refresh'); // l10n-ignore: internal exception, not UI copy
    }
    final res = await _api.refreshToken(
      RefreshTokenRequestDto(refreshToken: current.refreshToken),
    );
    await _storage.updateTokens(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
    );
    return current.copyWith(
      accessToken: res.accessToken,
      refreshToken: res.refreshToken,
    );
  }

  /// Best-effort server-side logout, then a hard local wipe. The local clear
  /// runs even if the server call fails so the user is never stuck with
  /// stale credentials when the network is down.
  Future<void> logout() async {
    try {
      await _api.logout();
    } on ApiException {
      // ignore: server-side rejection still allows a local wipe.
    } finally {
      await _storage.clear();
    }
  }

  /// Reads the current session from secure storage. Returns `null` if the
  /// user is signed out (no access token) or if the persisted state is
  /// incomplete.
  Future<AuthSession?> currentSession() => _storage.readSession();

  /// Cheap session-presence check for guards that only care whether the user
  /// has an access token, not what its payload is.
  Future<bool> isLoggedIn() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Updates the user's chosen store. Returns the refreshed session so
  /// callers can update Riverpod state in one shot.
  Future<AuthSession> selectStore(String storeId) async {
    final current = await _storage.readSession();
    if (current == null) {
      throw const UnauthorizedException(message: 'No session to update'); // l10n-ignore: internal exception, not UI copy
    }
    await _storage.selectStore(storeId);
    return current.copyWith(selectedStoreId: storeId);
  }

  // ─── helpers ────────────────────────────────────────────────────────────

  Future<AuthSession> _completeLogin(LoginResponse login) async {
    // Persist the access token BEFORE calling /auth/me, otherwise the auth
    // interceptor reads an empty token from storage and the server returns
    // 401. The full AuthSession is rewritten after /me returns the role and
    // store-access fields.
    await _storage.updateTokens(
      accessToken: login.accessToken,
      refreshToken: login.refreshToken,
    );

    // Pull the full role + store-access set so the session is complete.
    final me = await _api.me();
    final session = AuthSession(
      accessToken: login.accessToken,
      refreshToken: login.refreshToken,
      userId: me.user.id,
      tenantId: me.user.tenantId,
      roles: me.roles,
      stores: me.storeAccess
          .map(
            (s) => StoreAccess(
              storeId: s.storeId,
              storeName: s.storeName,
              role: s.role,
            ),
          )
          .toList(growable: false),
      // Auto-select the only available store if there's exactly one — the
      // OTP screen routes straight to /home in that case.
      selectedStoreId: me.storeAccess.length == 1
          ? me.storeAccess.first.storeId
          : null,
    );
    await _storage.writeSession(session);
    return session;
  }
}

/// Riverpod handle for the global [AuthRepository]. Tests should override
/// either this provider directly or the dependencies it composes
/// (`apiClientProvider`, `sessionStorageProvider`).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
  );
});
