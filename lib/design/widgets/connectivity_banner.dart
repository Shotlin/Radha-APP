// Connectivity banner.
//
// 32px sticky strip rendered just above the bottom navigation bar inside
// `RootShell`. Watches [connectivityProvider] (lib/core/connectivity/) and:
//
//   * renders nothing while online (no vertical real estate stolen during
//     the happy path),
//   * shows a rose strip with a cloud-off icon and the copy
//     "Offline — your work is being saved" while disconnected.
//
// Why rose (danger token) and not amber (warning token):
//   * The amber sync banner already lives at the top of the shell to surface
//     the pending-write queue depth. Reusing amber here would conflate two
//     distinct states (network missing vs writes in flight). Rose is the
//     reserved, deliberately-different colour so users can distinguish
//     "no network" from "we're still catching up".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../tokens.dart';

/// Thin strip surfacing the device's offline state.
///
/// Embed at the bottom of the shell column, right above the
/// `NavigationBar`, so it never displaces tappable destinations.
///
/// Carries a scaled-down beat of the Character Bible's "offline shelter"
/// moment (§6.2): a gentle warm pulse behind the offline indicator conveys
/// "your work is held safe", not alarm. The full Mor-shelter hero belongs on
/// a dedicated offline surface; within this 32 px strip the pulse is the
/// faithful, real-estate-appropriate expression. The pulse is opacity-only and
/// suppressed under `MediaQuery.disableAnimations`.
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  /// Banner height. Mirrors `SyncStatusBanner.height` for visual rhythm.
  static const double height = 32.0;

  /// Copy used when offline. Kept as a constant so tests can match exactly.
  static const String offlineMessage = 'Offline — your work is being saved';

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse(bool show) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (show && !reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResults = ref.watch(connectivityProvider);
    final results = asyncResults.valueOrNull;

    // While the stream hasn't emitted yet, render nothing — we'd rather
    // briefly omit a banner than flash an incorrect "Offline" state.
    if (results == null) {
      _syncPulse(false);
      return const SizedBox.shrink();
    }
    if (!isOffline(results)) {
      _syncPulse(false);
      return const SizedBox.shrink();
    }

    _syncPulse(true);

    return Material(
      color: RadhaColors.danger.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ConnectivityBanner.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warm shelter pulse behind the offline glyph — Mor's "your work
              // is safe" reassurance, scaled to the strip. Opacity-only.
              _ShelterGlow(
                pulse: _pulse,
                child: const Icon(
                  Icons.cloud_off_outlined,
                  size: 16,
                  color: RadhaColors.danger,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              Flexible(
                child: Text(
                  ConnectivityBanner.offlineMessage,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RadhaColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft warm halo that breathes behind the offline glyph. Decorative; the
/// glyph + text already carry the state, so this is excluded from semantics
/// and disabled under reduce-motion (the controller simply never runs).
class _ShelterGlow extends StatelessWidget {
  const _ShelterGlow({required this.pulse, required this.child});

  final Animation<double> pulse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, glyph) {
        final t = Curves.easeInOut.transform(pulse.value);
        return Container(
          padding: const EdgeInsets.all(RadhaSpacing.space4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RadhaColors.festiveMarigold.withValues(
              alpha: 0.10 + 0.14 * t,
            ),
          ),
          child: glyph,
        );
      },
      child: ExcludeSemantics(child: child),
    );
  }
}
