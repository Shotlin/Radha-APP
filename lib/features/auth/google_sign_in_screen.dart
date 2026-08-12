import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/google_sign_in_helper.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/network/error_codes.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/hero_screen.dart';
import '../../design/widgets/primary_button.dart';
import 'post_login_flow.dart';

/// Phase 13 — primary login screen, replacing the OTP phone-entry screen
/// as the default `/auth` landing. Google Sign-In only; the OTP screens
/// remain reachable solely through "Sign in with your phone number
/// instead" → `LegacyAccountLinkScreen`, for pre-existing phone-only
/// accounts.
class GoogleSignInScreen extends ConsumerStatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  ConsumerState<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends ConsumerState<GoogleSignInScreen> {
  bool _loading = false;
  String? _errorText;

  Future<void> _continueWithGoogle() async {
    if (_loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final router = GoRouter.of(context);
    final storage = ref.read(sessionStorageProvider);

    try {
      // Read pending segment BEFORE signing in — same ordering rationale
      // as otp_verify_screen.dart: once the session becomes non-null the
      // router's refreshListenable can redirect mid-await.
      final pendingRaw = await storage.readPendingOnboardingSegment();
      final segment = pendingRaw != null
          ? onboardingSegmentDtoFromWire(pendingRaw)
          : null;
      final cameFromBusinessOnboarding = pendingRaw == 'business_owner';

      final idToken = await signInWithGoogleGetIdToken();
      final deviceId = await storage.getOrCreateDeviceId();

      await ref
          .read(authControllerProvider.notifier)
          .signInWithFirebase(idToken: idToken, deviceId: deviceId);

      // Safe: runPostLoginFlow only ever uses `context` behind its own
      // `context.mounted` check (post_login_flow.dart), and — like
      // otp_verify_screen.dart — must keep running (segment post, FCM
      // token registration) even if this widget is disposed by a
      // redirect that fires the instant the session becomes non-null.
      await runPostLoginFlow(
        ref: ref,
        context: context, // ignore: use_build_context_synchronously
        router: router,
        segment: segment,
        cameFromBusinessOnboarding: cameFromBusinessOnboarding,
      );
    } on GoogleSignInCancelled {
      // User backed out of the account picker — not an error, no banner.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _errorText = userMessageForCode(
          e.code,
          l10n: null,
          fallback: e.message,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorText = "Couldn't sign in with Google. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final cs = theme.colorScheme;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;

    return HeroStatusBar(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final h = constraints.maxHeight;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: h * 0.62,
                  child: Image.asset(
                    RadhaAssets.heroSignin,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  top: h * 0.46,
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
                Positioned(
                  top: topPad + 8,
                  left: 12,
                  right: 16,
                  child: Row(
                    children: [
                      if (canPop)
                        HeroBackButton(
                          onPressed: _loading ? null : () => context.pop(),
                        ),
                      const SizedBox(width: 8),
                      const HeroBrand(),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () =>
                                  context.push(AppRoute.authDeveloperBusiness),
                        icon: const Icon(
                          Icons.developer_mode_rounded,
                          size: 17,
                        ),
                        label: const Text('Admin developer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black.withValues(alpha: 0.28),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: h * 0.50,
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
                          Text(
                            'Sign in',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: RadhaColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Welcome to RADHA',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: cs.onSurface,
                              height: 1.15,
                              letterSpacing: -0.3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in with your Google account to get started.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: cs.error,
                                ),
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
                          const SizedBox(height: 28),
                          PrimaryButton(
                            label: 'Continue with Google',
                            expand: true,
                            loading: _loading,
                            onPressed: _loading ? null : _continueWithGoogle,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => context.push(AppRoute.authLegacyLink),
                              child: Text(
                                'Sign in with your phone number instead',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: RadhaColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'By continuing you agree to our ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.4,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Terms',
                                    style: TextStyle(
                                      color: RadhaColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy',
                                    style: TextStyle(
                                      color: RadhaColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
