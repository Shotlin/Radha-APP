// Canonical mobile-side mirror of the backend error code catalog.
//
// The backend (`server/src/common/errors/error-codes.ts`) emits stable
// `EXNNN` codes alongside every error envelope. The mobile app ships its own
// mirror so screens can switch on codes without re-stringifying server
// `message` payloads — those are operator-facing and may not be localised.
//
// Only the codes the mobile UI actually branches on are listed here. The full
// server catalog has many more codes (database, external services, etc.) but
// they all collapse to the generic fallback message on the client.
//
// Numbering follows the same ranges as the server catalog for clarity.

import '../../l10n/generated/app_localizations.dart';

/// Stable error-code constants emitted by the RADHA backend.
///
/// Keep in sync with `server/src/common/errors/error-codes.ts`. Adding a new
/// code that the UI branches on requires:
///   1. A new constant here.
///   2. A new branch (and ARB key) in [userMessageForCode] / [_keyForCode].
class ErrorCodes {
  ErrorCodes._();

  // ── Generic / infrastructure (1xxx) ─────────────────────────────────
  static const String unknown = 'E1000';
  static const String internal = 'E1001';
  static const String serviceUnavailable = 'E1002';
  static const String timeout = 'E1003';

  // Generic 429 emitted by the global rate limiter (non-OTP routes).
  static const String rateLimit = 'E1004';

  // ── Validation (2xxx) ───────────────────────────────────────────────
  static const String validationError = 'E2000';

  // ── Authentication (3xxx) ───────────────────────────────────────────
  static const String authRequired = 'E3000';
  static const String invalidCredentials = 'E3001';
  static const String tokenExpired = 'E3002';

  /// OTP verification failed — wrong code.
  ///
  /// Server emits `E3005` (see backend catalog). Older specs labelled this
  /// `E3008`; the constant on the mobile side reads `otpInvalid` to match
  /// what the UI cares about regardless of the underlying number.
  static const String otpInvalid = 'E3005';

  /// OTP no longer accepted because the request expired.
  /// Server emits `E3006`.
  static const String otpExpired = 'E3006';

  /// Too many OTP requests / verification attempts in the rate-limit window.
  /// Server emits `E3007`.
  static const String otpRateLimited = 'E3007';

  /// Account temporarily locked after repeated failures.
  /// Server emits `E3008`.
  static const String accountLocked = 'E3008';

  // ── Authorization / entitlements (4xxx) ─────────────────────────────
  static const String forbidden = 'E4000';
  static const String storeAccessDenied = 'E4003';

  /// Subscription is required for this feature (paid plan / past trial).
  /// Server emits `E4005`. The mobile spec also references this slot as the
  /// "subscription required" code; we keep the canonical server number.
  static const String subscriptionRequired = 'E4005';

  /// Specific entitlement (feature flag from the user's plan) was denied.
  /// Server bucket: trial-expired / plan-limit-exceeded / payment-required
  /// all surface here from the UI's point of view, so we map the strict
  /// "trial expired" code.
  static const String entitlementDenied = 'E4006';

  // ── Resources / not found (5xxx) ────────────────────────────────────
  static const String notFound = 'E5000';

  // ── Conflicts (6xxx) ────────────────────────────────────────────────
  static const String conflict = 'E6000';
}

/// Resolves a backend error code to a user-facing localized message.
///
/// Pass an `AppLocalizations` if you have one (preferred — UI text follows
/// the user's locale). When the call site doesn't have a `BuildContext` you
/// may pass `null`; the function falls back to short English strings that
/// match what `AppLocalizationsEn` returns.
///
/// `retryAfterSeconds` is substituted into the rate-limit message when
/// known. The OTP rate-limit message uses it; other codes ignore it.
///
/// `fallback` lets callers override the generic "Something went wrong"
/// text when they have a more meaningful default (e.g. server-provided
/// message for a non-localised admin error).
String userMessageForCode(
  String? code, {
  AppLocalizations? l10n,
  int? retryAfterSeconds,
  String? fallback,
}) {
  switch (code) {
    case ErrorCodes.otpRateLimited:
    case ErrorCodes.rateLimit:
      // Both surface as 429 to the client. Treat them with the same
      // "wait n seconds" message because that's what users care about.
      final seconds = retryAfterSeconds ?? 60;
      return l10n?.errorRateLimitOtp(seconds) ??
          'Too many OTP requests. Try again in $seconds seconds.';
    case ErrorCodes.otpInvalid:
      return l10n?.errorOtpInvalid ?? 'Invalid OTP. Please try again.';
    case ErrorCodes.otpExpired:
      return l10n?.errorOtpExpired ?? 'OTP expired. Please request a new one.';
    case ErrorCodes.authRequired:
    case ErrorCodes.tokenExpired:
    case ErrorCodes.invalidCredentials:
      return l10n?.errorAuthRequired ?? 'Please sign in to continue.';
    case ErrorCodes.notFound:
      return l10n?.errorNotFound ?? 'Not found.';
    default:
      return fallback ??
          l10n?.errorGeneric ??
          'Something went wrong. Please try again.';
  }
}
