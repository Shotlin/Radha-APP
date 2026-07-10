import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/notifications/push_service.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/network/error_codes.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/hero_screen.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.mobile,
    required this.requestId,
    this.devOtp,
  });

  final String mobile;
  final String requestId;

  /// Dev/test only — the OTP echoed back by a development server.
  /// Always null in release builds.
  final String? devOtp;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  late String _requestId;
  String? _errorText;
  bool _loading = false;
  bool _verified = false;

  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _requestId = widget.requestId;
    _startCooldown();
  }

  void _startCooldown() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  /// Masks the mobile number: +91 •••••X XXXX (last 4 visible).
  String get _maskedMobile {
    final digits = widget.mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return widget.mobile;
    final last4 = digits.substring(digits.length - 4);
    final secondLast =
        digits.length >= 5 ? digits[digits.length - 5] : '';
    return '+91 •••••$secondLast $last4';
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6) return;
    // Guard against double-submission (e.g. onCompleted + explicit call racing).
    if (_loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    // Capture router and ref-backed objects synchronously before any await.
    // verifyOtp() sets AsyncData(session) which triggers GoRouter to navigate
    // away, disposing this widget mid-flight. Pre-capturing means we can still
    // post the pending segment and navigate even after disposal.
    final router = GoRouter.of(context);
    final storage = ref.read(sessionStorageProvider);
    final api = ref.read(apiClientProvider);

    try {
      // Read pending segment before verifyOtp() — user isn't logged in yet so
      // the router won't fire a redirect during this await.
      final pendingRaw = await storage.readPendingOnboardingSegment();
      final segment =
          pendingRaw != null ? onboardingSegmentDtoFromWire(pendingRaw) : null;
      // Remember whether this was a business onboarding path BEFORE we clear it.
      final cameFromBusinessOnboarding = pendingRaw == 'business_owner';

      await ref.read(authControllerProvider.notifier).verifyOtp(
            mobile: widget.mobile,
            otp: otp,
            requestId: _requestId,
          );

      // Widget may be disposed here (GoRouter redirect after session set).
      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() => _verified = true);
      }

      // Post pending segment using pre-captured api — safe after widget disposal.
      OnboardingNextScreenDto? nextScreen;
      if (segment != null) {
        try {
          final response = await api.selectOnboardingSegment(
              SelectSegmentRequestDto(segment: segment));
          await storage.setPendingOnboardingSegment(null);
          nextScreen = response.nextScreen;
        } catch (_) {
          // Segment post failure is non-fatal; fall through to routing logic.
        }
      }

      // Phase 10: register FCM token now that we have an authenticated session.
      // Fire-and-forget — failure is non-fatal, push just won't work this session.
      PushService.instance.registerToken(api).ignore();

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Route to business activation when:
      //   a) The backend explicitly requested it, OR
      //   b) The user chose the business onboarding path AND their account has
      //      no store yet — this covers demo/new accounts where the segment
      //      endpoint is unavailable or doesn't upgrade the role automatically.
      final freshSession = ref.read(authControllerProvider).valueOrNull;
      final needsBusinessActivation =
          nextScreen == OnboardingNextScreenDto.businessActivationFlow ||
          (cameFromBusinessOnboarding &&
              (freshSession == null || freshSession.stores.isEmpty));

      if (needsBusinessActivation) {
        // Use pre-captured router so navigation works even after disposal.
        router.go(AppRoute.businessActivation);
      } else if (mounted) {
        context.go(AppRoute.home);
      }
      // else: GoRouter already navigated to home via redirect — nothing to do.
    } on RateLimitException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = userMessageForCode(
            ErrorCodes.otpRateLimited,
            l10n: l10n,
            retryAfterSeconds: e.retryAfter,
          ));
    } on ApiException catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _pinController.clear();
      final fallback = e is UnauthorizedException
          ? (l10n?.errorOtpInvalid ?? 'Invalid OTP. Please try again.')
          : e.message;
      setState(
          () => _errorText = userMessageForCode(e.code, l10n: l10n, fallback: fallback));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = userMessageForCode(null, l10n: l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    HapticFeedback.selectionClick();
    setState(() {
      _errorText = null;
      _loading = true;
    });
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(widget.mobile);
      if (!mounted) return;
      setState(() => _requestId = result.requestId);
      _startCooldown();
    } on RateLimitException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = userMessageForCode(
            ErrorCodes.otpRateLimited,
            l10n: l10n,
            retryAfterSeconds: e.retryAfter,
          ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText =
          userMessageForCode(e.code, l10n: l10n, fallback: e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = userMessageForCode(null, l10n: l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final cs = theme.colorScheme;
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

    // ── OTP pin themes — larger boxes, white background ───────────────────────
    final defaultPinTheme = PinTheme(
      width: 46,
      height: 64,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
        letterSpacing: 0,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      height: 70,
      decoration: defaultPinTheme.decoration?.copyWith(
        color: RadhaColors.primary.withValues(alpha: 0.06),
        border: Border.all(color: RadhaColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: RadhaColors.primary.withValues(alpha: 0.20),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
    );

    final submittedColor = _verified
        ? const Color(0xFF22C55E)
        : (_errorText != null ? cs.error : RadhaColors.primary);

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: submittedColor.withValues(alpha: 0.08),
        border: Border.all(color: submittedColor, width: 1.5),
      ),
    );

    return HeroStatusBar(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final h = constraints.maxHeight;
            return Stack(
              children: [
                // ── Image: top 58% ──────────────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: h * 0.58,
                  child: Image.asset(
                    RadhaAssets.heroOtpVerify,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // ── White gradient: image fades into card ───────────────────────
                Positioned(
                  top: h * 0.42,
                  left: 0,
                  right: 0,
                  height: h * 0.18,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                      ),
                    ),
                  ),
                ),

                // ── Back button + wordmark over image ───────────────────────────
                Positioned(
                  top: topPad + 8,
                  left: 12,
                  right: 16,
                  child: Row(
                    children: [
                      HeroBackButton(
                        onPressed: _loading ? null : () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const HeroBrand(),
                    ],
                  ),
                ),

                // ── White card — rounded top corners, premium look ─────────────
                Positioned(
                  top: h * 0.45,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPad + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Heading row — green check badge animates in on verify
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Enter the code',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: cs.onSurface,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            AnimatedScale(
                              scale: _verified ? 1.0 : 0.0,
                              duration: RadhaMotion.medium,
                              curve: RadhaMotion.spring,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Masked number + edit link
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Sent to $_maskedMobile',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _loading ? null : () => context.pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: RadhaColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: RadhaSpacing.space8),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child:
                                  Text(AppLocalizations.of(context).edit),
                            ),
                          ],
                        ),

                        // Dev OTP banner (debug builds only)
                        if (kDebugMode && widget.devOtp != null) ...[
                          const SizedBox(height: RadhaSpacing.space16),
                          _DevOtpBanner(
                            otp: widget.devOtp!,
                            onUse: () {
                              // Setting .text triggers Pinput's onCompleted,
                              // which calls _verify. No explicit call needed.
                              _pinController.text = widget.devOtp!;
                            },
                          ),
                        ],

                        const SizedBox(height: RadhaSpacing.space24),

                        // ── OTP input boxes ──────────────────────────────────────
                        Pinput(
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          length: 6,
                          enabled: !_loading,
                          autofocus: true,
                          isCursorAnimationEnabled: false,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          onCompleted: _verify,
                          keyboardType: TextInputType.number,
                          separatorBuilder: (_) =>
                              const SizedBox(width: 6),
                          cursor: Container(
                            width: 2,
                            height: 28,
                            decoration: BoxDecoration(
                              color: RadhaColors.primary,
                              borderRadius: BorderRadius.circular(
                                  RadhaRadii.radiusFull),
                            ),
                          ),
                        ),

                        if (_errorText != null) ...[
                          const SizedBox(height: RadhaSpacing.space12),
                          Row(
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 16, color: cs.error),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _errorText!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: RadhaSpacing.space20),

                        _ResendRow(
                          seconds: _resendSeconds,
                          enabled: !_loading && _resendSeconds <= 0,
                          onResend: _resend,
                        ),

                        const SizedBox(height: RadhaSpacing.space24),

                        PrimaryButton(
                          label: AppLocalizations.of(context).verifyOtp,
                          expand: true,
                          loading: _loading,
                          onPressed: _loading
                              ? null
                              : () {
                                  final text = _pinController.text;
                                  if (text.length == 6) {
                                    _verify(text);
                                  } else {
                                    _pinFocusNode.requestFocus();
                                  }
                                },
                        ),

                        const SizedBox(height: RadhaSpacing.space12),
                        Center(
                          child: Text(
                            'Your number stays private.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Dev OTP banner (debug mode, white background) ─────────────────────────────

class _DevOtpBanner extends StatelessWidget {
  const _DevOtpBanner({required this.otp, required this.onUse});

  final String otp;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.complement.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: RadhaColors.complement.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report_outlined,
              size: 18, color: RadhaColors.complement),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'DEV · OTP ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                ),
                children: [
                  TextSpan(
                    text: otp,
                    style: radhaMonoStyle(
                      fontSize: 14,
                      weight: FontWeight.w700,
                      color: RadhaColors.complement,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onUse,
            style: TextButton.styleFrom(
              foregroundColor: RadhaColors.complement,
              padding:
                  const EdgeInsets.symmetric(horizontal: RadhaSpacing.space8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(AppLocalizations.of(context).otpUseCode),
          ),
        ],
      ),
    );
  }
}

// ── Resend row (white background) ─────────────────────────────────────────────

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.seconds,
    required this.enabled,
    required this.onResend,
  });

  final int seconds;
  final bool enabled;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (seconds > 0) {
      return Text(
        'Resend OTP (${seconds}s)',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return TextButton(
      onPressed: enabled ? onResend : null,
      style: TextButton.styleFrom(
        foregroundColor: RadhaColors.primary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: Text(AppLocalizations.of(context).resendOtp),
    );
  }
}
