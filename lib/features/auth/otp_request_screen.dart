import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/error_codes.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/hero_screen.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

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

class OtpRequestScreen extends ConsumerStatefulWidget {
  const OtpRequestScreen({super.key});

  @override
  ConsumerState<OtpRequestScreen> createState() => _OtpRequestScreenState();
}

class _OtpRequestScreenState extends ConsumerState<OtpRequestScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String? _errorText;
  bool _loading = false;
  bool _focused = false;

  String get _digits => _controller.text.replaceAll(RegExp(r'\D'), '');

  bool get _isValid =>
      _digits.length == 10 && RegExp(r'^[6-9]').hasMatch(_digits);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onChanged() {
    if (_errorText != null) setState(() => _errorText = null);
    setState(() {});
  }

  void _onFocusChanged() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _errorText = 'Enter a valid 10-digit mobile number');
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    try {
      final mobile = '+91$_digits';
      final result =
          await ref.read(authControllerProvider.notifier).requestOtp(mobile);
      if (!mounted) return;
      context.push(
        AppRoute.authOtpVerify,
        extra: <String, String>{
          'mobile': mobile,
          'requestId': result.requestId,
          if (result.devOtp != null) 'devOtp': result.devOtp!,
        },
      );
    } on RateLimitException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = userMessageForCode(
            ErrorCodes.otpRateLimited,
            l10n: l10n,
            retryAfterSeconds: e.retryAfter,
          ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() =>
          _errorText = userMessageForCode(e.code, l10n: l10n, fallback: e.message));
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
                // ── Image: top 62% of screen ───────────────────────────────────
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

                // ── White gradient: image fades into the form panel ────────────
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

                // ── Back button + wordmark over image ─────────────────────────
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
                    ],
                  ),
                ),

                // ── White card — rounded top corners, premium look ─────────────
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
                          'Enter your mobile number',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: cs.onSurface,
                            height: 1.15,
                            letterSpacing: -0.3,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "We'll send a 6-digit code to verify it's you.",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _PhoneField(
                          controller: _controller,
                          focusNode: _focusNode,
                          focused: _focused,
                          enabled: !_loading,
                          hasError: _errorText != null,
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 8),
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
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'Standard SMS rates may apply.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: AppLocalizations.of(context).sendOtp,
                          expand: true,
                          loading: _loading,
                          onPressed: _isValid && !_loading ? _submit : null,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'By continuing you agree to our ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms',
                                  style: TextStyle(
                                    color: RadhaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Privacy',
                                  style: TextStyle(
                                    color: RadhaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: '.'),
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

// ── Phone input on white background ──────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.enabled,
    required this.hasError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color borderColor = hasError
        ? cs.error
        : focused
            ? RadhaColors.primary
            : cs.outline;

    return AnimatedContainer(
      duration: RadhaMotion.fast,
      curve: RadhaMotion.easeOut,
      height: 56,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
        border: Border.all(
          color: borderColor,
          width: focused || hasError ? 2 : 1,
        ),
        boxShadow: focused && !hasError
            ? [
                BoxShadow(
                  color: RadhaColors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Row(
        children: [
          const SizedBox(width: RadhaSpacing.space16),
          Text(
            '+91',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Container(
            width: 1,
            height: 24,
            color: cs.outlineVariant,
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
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
