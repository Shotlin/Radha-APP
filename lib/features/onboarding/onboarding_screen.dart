// Onboarding flow (Task 6 — consumes BE-34).
//
// Three-page swipeable intro shown to first-time users before authentication.
//
//   * Page 1 — Welcome      : store-owner illustration + brand value prop.
//   * Page 2 — Capabilities : scan-in-aisle illustration + 3 capability rows.
//   * Page 3 — Segment      : persona image-card 2×3 selection grid.
//
// Visual design (Bakaloo-style full-bleed + Ken Burns):
//   Each page is a Stack:
//     [0] Full-bleed hero — Ken Burns slow zoom gives life to static images.
//     [1] Gradient scrim fades illustration to warm cream (_kWarm).
//     [2] Animated content — tagline + headline slide/fade in on page focus.
//   A frosted bottom bar (gradient → _kWarm) overlays all pages seamlessly.
//   The RADHA wordmark floats over the illustration; fades out on page 3.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session_storage.dart';
import '../../core/network/dto/onboarding_dto.dart';
import '../../core/onboarding/onboarding_flag_controller.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/hero_screen.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

// Flow: page 0 = split selector (always first), pages 1-2 = business onboarding
// (only reached when the user taps "Continue as Business" on page 0).
// "Continue as Personal" on page 0 exits onboarding immediately.
const int _kPageCount = 3;
const int _kSegmentPageIndex = 0;
const double _kBottomBarBaseHeight = 104.0;

// RADHA brand warm ivory — used everywhere instead of stark white.
const Color _kWarm = Color(0xFFFFF8F3);

// ── Root screen ───────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int next) {
    if (next == _pageIndex) return;
    setState(() => _pageIndex = next);
  }

  Future<void> _advance() async {
    if (_pageIndex >= _kPageCount - 1) return;
    await _pageController.nextPage(
      duration: RadhaMotion.medium,
      curve: RadhaMotion.easeOut,
    );
  }

  Future<void> _finishWithSegment(OnboardingSegmentDto segment) async {
    if (_submitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    try {
      final storage = ref.read(sessionStorageProvider);
      await storage.setPendingOnboardingSegment(segment.wireValue);
      await ref.read(onboardingFlagControllerProvider.notifier).markComplete();
      if (mounted) context.go(AppRoute.authOtp);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSegmentPage = _pageIndex == _kSegmentPageIndex; // page 0
    final isLastPage = _pageIndex == _kPageCount - 1;       // page 2
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom + _kBottomBarBaseHeight;

    return HeroStatusBar(
      child: Scaffold(
        backgroundColor: _kWarm,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final h = constraints.maxHeight;
            final topPad = mq.padding.top;

            return Stack(
              children: [
                // ── Swipeable pages ─────────────────────────────────────
                // Page 0: Personal/Business split selector — always first.
                // Pages 1-2: Business-specific onboarding — only reached
                // when the user taps "Continue as Business" on page 0.
                // Personal path exits directly from page 0 to OTP.
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  // Lock swipe on the split page — CTAs are the only exit.
                  physics: isSegmentPage
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  children: <Widget>[
                    _SplitSegmentPage(
                      onSelectPersonal: () => _finishWithSegment(
                          OnboardingSegmentDto.personal),
                      // Business: advance to page 1 (welcome hero).
                      onSelectBusiness: _advance,
                      loading: _submitting,
                      isActive: isSegmentPage,
                    ),
                    _WelcomePage(
                      screenH: h,
                      bottomInset: bottomInset,
                      isActive: _pageIndex == 1,
                    ),
                    _CapabilitiesPage(
                      screenH: h,
                      bottomInset: bottomInset,
                      isActive: _pageIndex == 2,
                    ),
                  ],
                ),

                // ── RADHA brand — shown only on business onboarding pages ──
                Positioned(
                  top: topPad + 16,
                  left: 24,
                  child: AnimatedOpacity(
                    opacity: isSegmentPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: const HeroBrand(),
                  ),
                ),

                // ── Bottom bar — hidden on split page (panels have own CTAs)
                if (!isSegmentPage)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomBar(
                      // Show 2-step progress for the 2 business pages (1 & 2).
                      pageIndex: _pageIndex - 1,
                      pageCount: 2,
                      ctaLabel: l10n.continueLabel,
                      ctaEnabled: true,
                      loading: _submitting && isLastPage,
                      // Last business page finishes with businessOwner segment.
                      onPressed: isLastPage
                          ? () => _finishWithSegment(
                              OnboardingSegmentDto.businessOwner)
                          : _advance,
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

// ── Page 1 — Welcome ─────────────────────────────────────────────────────────

class _WelcomePage extends StatefulWidget {
  const _WelcomePage({
    required this.screenH,
    required this.bottomInset,
    required this.isActive,
  });

  final double screenH;
  final double bottomInset;
  final bool isActive;

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with TickerProviderStateMixin {
  // Ken Burns — slow zoom that loops, gives life to the static illustration.
  late final AnimationController _kb;
  // Content entrance — tagline then headline slide up and fade in.
  late final AnimationController _cx;

  @override
  void initState() {
    super.initState();
    _kb = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _cx = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.isActive) {
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (mounted) _cx.forward();
      });
    }
  }

  @override
  void didUpdateWidget(_WelcomePage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _cx.reset();
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _cx.forward();
      });
    }
  }

  @override
  void dispose() {
    _kb.dispose();
    _cx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Tagline enters first, headline slightly offset.
    final taglineFade = CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    final taglineRise = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    ));

    final headlineFade = CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );
    final headlineRise = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.15, 0.80, curve: Curves.easeOutCubic),
    ));

    return Stack(
      children: [
        // Ken Burns hero
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _kb,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _kb.value * 0.07,
              alignment: Alignment.topCenter,
              child: child,
            ),
            child: Image.asset(
              RadhaAssets.heroOnboardingWelcome,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const ColoredBox(color: _kWarm),
            ),
          ),
        ),

        // Gradient scrim — transparent → warm cream (feels brand-native)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.30, 0.48, 0.62, 0.72],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  _kWarm.withValues(alpha: 0.55),
                  _kWarm.withValues(alpha: 0.92),
                  _kWarm,
                ],
              ),
            ),
          ),
        ),

        // Content — inside the warm gradient zone
        Positioned(
          top: widget.screenH * 0.59,
          left: 24,
          right: 24,
          bottom: widget.bottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tagline
              FadeTransition(
                opacity: taglineFade,
                child: SlideTransition(
                  position: taglineRise,
                  child: Text(
                    l10n.tagline,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Headline
              FadeTransition(
                opacity: headlineFade,
                child: SlideTransition(
                  position: headlineRise,
                  child: Text(
                    l10n.onboardingWelcomeValue,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.22,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page 2 — Capabilities ────────────────────────────────────────────────────

class _CapabilitiesPage extends StatefulWidget {
  const _CapabilitiesPage({
    required this.screenH,
    required this.bottomInset,
    required this.isActive,
  });

  final double screenH;
  final double bottomInset;
  final bool isActive;

  @override
  State<_CapabilitiesPage> createState() => _CapabilitiesPageState();
}

class _CapabilitiesPageState extends State<_CapabilitiesPage>
    with TickerProviderStateMixin {
  late final AnimationController _kb;
  late final AnimationController _cx;

  @override
  void initState() {
    super.initState();
    _kb = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _cx = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(_CapabilitiesPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _cx.reset();
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _cx.forward();
      });
    }
  }

  @override
  void dispose() {
    _kb.dispose();
    _cx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PageView keeps stale widget refs for off-screen pages, so didUpdateWidget
    // may not fire. Kick the animation here if we're active but haven't started.
    if (widget.isActive && _cx.status == AnimationStatus.dismissed) {
      Future<void>.microtask(() {
        if (mounted) _cx.forward();
      });
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final titleFade = CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );
    final titleRise = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cx,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
    ));

    // Capability rows stagger: 0→0.55, 0.18→0.73, 0.36→0.91
    Animation<double> rowFade(double start) => CurvedAnimation(
          parent: _cx,
          curve: Interval(start, (start + 0.55).clamp(0, 1.0),
              curve: Curves.easeOut),
        );
    Animation<Offset> rowRise(double start) =>
        Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cx,
            curve: Interval(start, (start + 0.65).clamp(0, 1.0),
                curve: Curves.easeOutCubic),
          ),
        );

    return Stack(
      children: [
        // Ken Burns hero
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _kb,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _kb.value * 0.07,
              alignment: Alignment.topCenter,
              child: child,
            ),
            child: Image.asset(
              RadhaAssets.heroOnboardingCapabilities,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const ColoredBox(color: _kWarm),
            ),
          ),
        ),

        // Gradient scrim
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.30, 0.48, 0.62, 0.72],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  _kWarm.withValues(alpha: 0.55),
                  _kWarm.withValues(alpha: 0.92),
                  _kWarm,
                ],
              ),
            ),
          ),
        ),

        // Animated content — bottom: 0 so Column always has room; bottom bar gradient overlays it
        Positioned(
          top: widget.screenH * 0.50,
          left: 24,
          right: 24,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              FadeTransition(
                opacity: titleFade,
                child: SlideTransition(
                  position: titleRise,
                  child: Text(
                    l10n.onboardingCapabilitiesTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Row 1
              FadeTransition(
                opacity: rowFade(0.18),
                child: SlideTransition(
                  position: rowRise(0.18),
                  child: _CapabilityRow(
                    icon: Icons.qr_code_scanner_outlined,
                    title: l10n.onboardingCapScanTitle,
                    subtitle: l10n.onboardingCapScanBody,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Row 2
              FadeTransition(
                opacity: rowFade(0.30),
                child: SlideTransition(
                  position: rowRise(0.30),
                  child: _CapabilityRow(
                    icon: Icons.event_outlined,
                    title: l10n.onboardingCapExpiryTitle,
                    subtitle: l10n.onboardingCapExpiryBody,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Row 3
              FadeTransition(
                opacity: rowFade(0.42),
                child: SlideTransition(
                  position: rowRise(0.42),
                  child: _CapabilityRow(
                    icon: Icons.checklist_outlined,
                    title: l10n.onboardingCapAuditTitle,
                    subtitle: l10n.onboardingCapAuditBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: RadhaSpacing.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page 3 — Personal / Business split ───────────────────────────────────────
//
// Full-screen two-panel split: warm orange Personal (top) / deep navy
// Business (bottom), separated by an organic wave divider. Each panel
// has an embedded CTA — no external "Get started" button is needed.

class _SplitSegmentPage extends StatefulWidget {
  const _SplitSegmentPage({
    required this.onSelectPersonal,
    required this.onSelectBusiness,
    required this.loading,
    required this.isActive,
  });

  final VoidCallback onSelectPersonal;
  final VoidCallback onSelectBusiness;
  final bool loading;
  final bool isActive;

  @override
  State<_SplitSegmentPage> createState() => _SplitSegmentPageState();
}

class _SplitSegmentPageState extends State<_SplitSegmentPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  // Slow shared zoom for both panel photos — the "cinematic" breathing loop.
  late final AnimationController _kb;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _kb = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    if (widget.isActive) {
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _entrance.forward();
      });
    }
  }

  @override
  void didUpdateWidget(_SplitSegmentPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _entrance.reset();
      Future<void>.delayed(const Duration(milliseconds: 60), () {
        if (mounted) _entrance.forward();
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _kb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;

    final fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
    );
    final riseTop = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.80, curve: Curves.easeOutCubic),
    ));
    final riseBottom = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.10, 0.90, curve: Curves.easeOutCubic),
    ));

    // Personal occupies 50 % of screen height.
    // The wave clip extends 64 px past the split so the curve has room.
    // Content in the personal panel is pinned at bottom: 130 to stay
    // fully above the topmost point of the S-curve.
    final splitH = (screenH * 0.50).roundToDouble();
    const waveOverlap = 64.0;
    // The business panel must NOT be sized to the full screen — doing so
    // makes BoxFit.cover scale the photo against the wrong (much taller)
    // aspect ratio, over-zooming the subject and cropping away headroom.
    // It only needs to start a little above the split, just enough to
    // stay behind the highest point of the wave's curve.
    final businessTop = splitH - 80.0;

    return Stack(
      children: [
        // ── Business panel (behind the wave) ──────────────────────────
        Positioned(
          top: businessTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: riseBottom,
              child: _BusinessPanel(
                onTap: widget.loading ? null : widget.onSelectBusiness,
                kb: _kb,
              ),
            ),
          ),
        ),

        // ── Personal panel (wave-clipped bottom edge, in front) ────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: splitH + waveOverlap,
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: riseTop,
              child: ClipPath(
                clipper: const _BottomWaveClipper(),
                child: _PersonalPanel(
                  onTap: widget.loading ? null : widget.onSelectPersonal,
                  kb: _kb,
                ),
              ),
            ),
          ),
        ),

        // ── Amber wave highlight — warm golden stroke at the seam ─────
        // IgnorePointer: this is a purely decorative overlay painted on top
        // of both panels — without it, RenderCustomPaint's hit-test claims
        // the touch before it ever reaches the CTAs underneath, even though
        // the painter draws nothing hit-test-relevant (this was the root
        // cause of the Personal/Business buttons being completely untappable).
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: splitH + waveOverlap,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: fade,
              child: CustomPaint(
                painter: const _WaveStrokePainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Organic S-curve wave at the bottom of the personal panel.
// The path occupies [0, height] and the wave spans the final
// `_waveH` pixels, creating a smooth organic divide.
class _BottomWaveClipper extends CustomClipper<Path> {
  const _BottomWaveClipper();

  static const double _waveH = 80.0;

  @override
  Path getClip(Size size) {
    final waveTop = size.height - _waveH;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, waveTop + _waveH * 0.30)
      ..cubicTo(
        size.width * 0.72, waveTop + _waveH * 0.30,
        size.width * 0.55, waveTop - _waveH * 0.55,
        size.width * 0.38, waveTop + _waveH * 0.12,
      )
      ..cubicTo(
        size.width * 0.20, waveTop + _waveH * 0.74,
        size.width * 0.10, waveTop + _waveH * 0.90,
        0, waveTop + _waveH * 0.62,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Warm amber stroke drawn on top of the wave seam. Mirrors the same two cubic
// bezier segments used by _BottomWaveClipper so the stroke sits exactly on the
// clip boundary and gives the split a premium golden-light highlight.
class _WaveStrokePainter extends CustomPainter {
  const _WaveStrokePainter();

  static const double _waveH = 80.0;

  @override
  void paint(Canvas canvas, Size size) {
    final waveTop = size.height - _waveH;

    final path = Path()
      ..moveTo(size.width, waveTop + _waveH * 0.30)
      ..cubicTo(
        size.width * 0.72, waveTop + _waveH * 0.30,
        size.width * 0.55, waveTop - _waveH * 0.55,
        size.width * 0.38, waveTop + _waveH * 0.12,
      )
      ..cubicTo(
        size.width * 0.20, waveTop + _waveH * 0.74,
        size.width * 0.10, waveTop + _waveH * 0.90,
        0, waveTop + _waveH * 0.62,
      );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: const [
          Color(0xFFE8870A),
          Color(0xFFCC6C08),
          Color(0xFFAA5504),
        ],
      ).createShader(
        Rect.fromLTWH(0, waveTop - _waveH, size.width, _waveH * 2),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveStrokePainter old) => false;
}

// ── Personal panel ─────────────────────────────────────────────────────────────

class _PersonalPanel extends StatelessWidget {
  const _PersonalPanel({required this.onTap, required this.kb});

  final VoidCallback? onTap;
  final Animation<double> kb;

  static const _orange = Color(0xFFD94F10);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Orange base — visible only if the asset fails to load.
        const ColoredBox(color: _orange),

        // Photo with a light warm grade — kept subtle so the aisle stays sharp
        // and true-to-life instead of muddied by a heavy colour cast.
        // BoxFit.cover fills the panel edge-to-edge; topCenter keeps the
        // subject's face in frame when the photo is cropped. A slow Ken Burns
        // zoom (shared with the business panel) gives the still photo life.
        SizedBox.expand(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              1.05,  0.02, -0.02, 0,  4,  // R: gentle warm lift
              0.00,  1.00,  0.00, 0,  2,  // G: neutral
             -0.02,  0.00,  0.96, 0, -3,  // B: gentle cool cut
              0.00,  0.00,  0.00, 1,  0,  // A: unchanged
            ]),
            child: AnimatedBuilder(
              animation: kb,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + kb.value * 0.05,
                alignment: Alignment.topCenter,
                child: child,
              ),
              child: Image.asset(
                RadhaAssets.segPersonal,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // Content scrim — photo stays crystal-clear well past half the panel;
        // warm orange builds only behind the lower text area for legibility.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.48, 0.64, 0.82, 1.0],
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0x301A0400),
                Color(0x951A0400),
                Color(0xE0200600),
              ],
            ),
          ),
        ),

        // Content — pinned 130 px from bottom so it sits entirely above
        // the wave's topmost control point (~50 % split − 44 px).
        Positioned(
          left: 28,
          right: 100,
          bottom: 130,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Personal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your everyday needs with a simple, personalized experience.',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              _PanelCta(
                label: 'Continue as Personal',
                color: _orange,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Business panel ─────────────────────────────────────────────────────────────

class _BusinessPanel extends StatelessWidget {
  const _BusinessPanel({required this.onTap, required this.kb});

  final VoidCallback? onTap;
  final Animation<double> kb;

  static const _navy = Color(0xFF0D2B6E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Navy base — visible only if the asset fails to load.
        const ColoredBox(color: _navy),

        // Photo with a light cool grade — kept subtle for clarity. topCenter
        // alignment keeps the business owner's face prominent when cover crops.
        SizedBox.expand(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.98, 0.00, 0.00, 0, 0,   // R: slight reduction (cooler feel)
              0.00, 1.00, 0.00, 0, 0,   // G: neutral
              0.02, 0.02, 1.03, 0, 6,   // B: gentle cool lift
              0.00, 0.00, 0.00, 1, 0,   // A: unchanged
            ]),
            child: AnimatedBuilder(
              animation: kb,
              // Base zoom of 1.18 (on top of the Ken Burns oscillation) crops
              // in from the bottom/sides — this panel's box is taller than
              // its visible area (so the wave's curve always has photo behind
              // it), which otherwise reveals too much counter clutter below
              // the subject. Anchoring at topCenter keeps the headroom above
              // his head intact while the extra crop hides the lower mess.
              builder: (_, child) => Transform.scale(
                scale: 1.18 + kb.value * 0.05,
                alignment: Alignment.topCenter,
                child: child,
              ),
              child: Image.asset(
                RadhaAssets.segBusiness,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // Scrim: stays fully transparent through the face area, then builds to
        // deep navy over the counter clutter so it recedes behind the text/CTA.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.16, 0.32, 0.55, 1.0],
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0x70001038),
                Color(0xD8001038),
                Color(0xF5001540),
              ],
            ),
          ),
        ),

        // Content — anchored to bottom-left within the lower half
        Positioned(
          left: 28,
          right: 100,
          bottom: 44,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3C8A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_center_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Business',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your business, customers, operations, and growth from one place.',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _PanelCta(
                label: 'Continue as Business',
                color: const Color(0xFF1B4FD8),
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Panel CTA button ───────────────────────────────────────────────────────────

class _PanelCta extends StatefulWidget {
  const _PanelCta({
    required this.label,
    required this.color,
    required this.onTap,
    this.showBorder = false,
  });

  final String label;
  final Color color;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  State<_PanelCta> createState() => _PanelCtaState();
}

class _PanelCtaState extends State<_PanelCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(28),
              border: widget.showBorder
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.5,
                    )
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar — frosted gradient ─────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.pageIndex,
    required this.pageCount,
    required this.ctaLabel,
    required this.ctaEnabled,
    required this.loading,
    required this.onPressed,
  });

  final int pageIndex;
  final int pageCount;
  final String ctaLabel;
  final bool ctaEnabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.18, 0.40, 0.65, 1.0],
          colors: [
            Colors.transparent,
            Colors.transparent,
            _kWarm.withValues(alpha: 0.55),
            _kWarm.withValues(alpha: 0.92),
            _kWarm,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PageDots(pageIndex: pageIndex, pageCount: pageCount),
              const SizedBox(height: 12),
              PrimaryButton(
                label: ctaLabel,
                onPressed: ctaEnabled ? onPressed : null,
                loading: loading,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page dots ─────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.pageIndex, required this.pageCount});

  final int pageIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(pageCount, (i) {
        final isActive = i == pageIndex;
        return AnimatedContainer(
          duration: RadhaMotion.fast,
          curve: RadhaMotion.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 7,
          width: isActive ? 22 : 7,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          ),
        );
      }),
    );
  }
}
