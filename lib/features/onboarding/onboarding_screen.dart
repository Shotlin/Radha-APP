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

// Flow: two intro pages (welcome, capabilities), then Google sign-in. RADHA has
// a single module -- there is no Personal/Business choice any more.
const int _kPageCount = 2;
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
      // Phase 13: Google Sign-In is the primary post-onboarding entry point.
      if (mounted) context.go(AppRoute.authGoogle);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLastPage = _pageIndex == _kPageCount - 1;
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
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: <Widget>[
                    _WelcomePage(
                      screenH: h,
                      bottomInset: bottomInset,
                      isActive: _pageIndex == 0,
                    ),
                    _CapabilitiesPage(
                      screenH: h,
                      bottomInset: bottomInset,
                      isActive: _pageIndex == 1,
                    ),
                  ],
                ),

                // ── RADHA brand ────────────────────────────────────────────
                Positioned(
                  top: topPad + 16,
                  left: 24,
                  child: const HeroBrand(),
                ),

                // ── Bottom bar ─────────────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomBar(
                    pageIndex: _pageIndex,
                    pageCount: _kPageCount,
                    ctaLabel: l10n.continueLabel,
                    ctaEnabled: true,
                    loading: _submitting && isLastPage,
                    // Last page continues to Google sign-in.
                    onPressed: isLastPage
                        ? () => _finishWithSegment(OnboardingSegmentDto.businessOwner)
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
              // Ken Burns zooms up to 1.07x — decode a bit past screen size
              // so the zoomed frame never upsamples a soft/undersized bitmap.
              cacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context) *
                          1.1)
                      .round(),
              cacheHeight:
                  (MediaQuery.sizeOf(context).height *
                          MediaQuery.devicePixelRatioOf(context) *
                          1.1)
                      .round(),
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
              cacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context) *
                          1.1)
                      .round(),
              cacheHeight:
                  (MediaQuery.sizeOf(context).height *
                          MediaQuery.devicePixelRatioOf(context) *
                          1.1)
                      .round(),
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
    // Was its own transparent->solid gradient layered on top of the page's
    // own bottom scrim (which already reaches fully-solid `_kWarm` well
    // above this widget's small footprint) -- the two gradients transition
    // at different rates over different heights, so the seam between them
    // showed up as a visible grey band across the full width right above
    // the Continue button (founder feedback: reads as an ugly shadow). A
    // flat colour underneath an already-opaque background is seamless.
    return ColoredBox(
      color: _kWarm,
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
    // White-based, not `theme.colorScheme.outline` — that colour is tuned
    // for the app's normal light surfaces, and rendered a muddy grey smudge
    // against this screen's warm-orange background (founder feedback: read
    // as an ugly shadow bar above the Continue button). White matches the
    // RADHA wordmark/body text already used on this same hero background.
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
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          ),
        );
      }),
    );
  }
}
