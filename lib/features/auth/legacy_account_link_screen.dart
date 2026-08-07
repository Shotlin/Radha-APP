import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/google_sign_in_helper.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/network/error_codes.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import 'post_login_flow.dart';

class _IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(capped[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Phase 13 — legacy account link recovery. For a user who already has a
/// pre-existing phone-only RADHA account whose Google email doesn't
/// automatically match it (so `GoogleSignInScreen`'s plain sign-in would
/// otherwise land them on a brand-new, empty consumer account instead of
/// their real one).
///
/// Deliberately OTP-first, Google-second: the OTP is requested and
/// entered BEFORE triggering Google Sign-In, then both are submitted
/// together in one `verifyLegacyLink` call. This avoids a route-guard
/// bounce (sign in with Google → discover you need to prove your phone →
/// get sent back to sign in with Google again) that a Google-first design
/// would hit, while still matching the backend's single combined
/// `{mobile, otp, requestId, idToken}` verification call.
class LegacyAccountLinkScreen extends ConsumerStatefulWidget {
  const LegacyAccountLinkScreen({super.key});

  @override
  ConsumerState<LegacyAccountLinkScreen> createState() =>
      _LegacyAccountLinkScreenState();
}

enum _LinkStep { phone, otp }

class _LegacyAccountLinkScreenState
    extends ConsumerState<LegacyAccountLinkScreen> {
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();

  _LinkStep _step = _LinkStep.phone;
  String? _requestId;
  String? _errorText;
  bool _loading = false;

  String get _digits => _mobileController.text.replaceAll(RegExp(r'\D'), '');
  bool get _mobileValid =>
      _digits.length == 10 && RegExp(r'^[6-9]').hasMatch(_digits);

  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_mobileValid || _loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestLegacyLink('+91$_digits');
      if (!mounted) return;
      setState(() {
        _requestId = result.requestId;
        _step = _LinkStep.otp;
        if (result.devOtp != null) _pinController.text = result.devOtp!;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.code == ErrorCodes.notFound
          ? "We couldn't find an account for this phone number."
          : userMessageForCode(e.code, l10n: null, fallback: e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finishWithGoogle() async {
    final otp = _pinController.text;
    final requestId = _requestId;
    if (otp.length != 6 || requestId == null || _loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final router = GoRouter.of(context);
    final storage = ref.read(sessionStorageProvider);

    try {
      final pendingRaw = await storage.readPendingOnboardingSegment();
      final segment =
          pendingRaw != null ? onboardingSegmentDtoFromWire(pendingRaw) : null;
      final cameFromBusinessOnboarding = pendingRaw == 'business_owner';

      final idToken = await signInWithGoogleGetIdToken();
      final deviceId = await storage.getOrCreateDeviceId();

      await ref.read(authControllerProvider.notifier).linkLegacyAccount(
            mobile: '+91$_digits',
            otp: otp,
            requestId: requestId,
            idToken: idToken,
            deviceId: deviceId,
          );

      // Safe — see google_sign_in_screen.dart's identical call for why.
      await runPostLoginFlow(
        ref: ref,
        context: context, // ignore: use_build_context_synchronously
        router: router,
        segment: segment,
        cameFromBusinessOnboarding: cameFromBusinessOnboarding,
      );
    } on GoogleSignInCancelled {
      // User backed out of the account picker — no banner.
    } on ApiException catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() =>
          _errorText = userMessageForCode(e.code, l10n: null, fallback: e.message));
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 46,
      height: 56,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: RadhaColors.primary, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _loading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Have an account already?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _step == _LinkStep.phone
                    ? 'Enter the phone number your existing RADHA account uses. '
                        "We'll text you a code to confirm it's you."
                    : 'Enter the code we sent, then continue with Google to '
                        'link your account.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              if (_step == _LinkStep.phone) ...[
                _MobileField(
                  controller: _mobileController,
                  enabled: !_loading,
                  hasError: _errorText != null,
                ),
              ] else ...[
                Pinput(
                  length: 6,
                  controller: _pinController,
                  enabled: !_loading,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onChanged: (_) => setState(() {}),
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 16, color: cs.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              if (_step == _LinkStep.phone)
                PrimaryButton(
                  label: 'Send code',
                  expand: true,
                  loading: _loading,
                  onPressed: _mobileValid && !_loading ? _sendCode : null,
                )
              else
                PrimaryButton(
                  label: 'Continue with Google',
                  expand: true,
                  loading: _loading,
                  onPressed: _pinController.text.length == 6 && !_loading
                      ? _finishWithGoogle
                      : null,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileField extends StatelessWidget {
  const _MobileField({
    required this.controller,
    required this.enabled,
    required this.hasError,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
        border: Border.all(
          color: hasError ? cs.error : cs.outline,
          width: hasError ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: RadhaSpacing.space16),
          Text('+91',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(width: RadhaSpacing.space12),
          Container(width: 1, height: 24, color: cs.outlineVariant),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _IndianMobileFormatter(),
              ],
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '98765 43210',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space16),
        ],
      ),
    );
  }
}
