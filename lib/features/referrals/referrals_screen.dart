// Referrals screen (Task 19 — consumes BE-43).
//
// Surfaces the signed-in user's referral programme:
//   * Hero card with the referral code rendered in JetBrains Mono and a
//     copy-to-clipboard affordance.
//   * Native share button (uses `share_plus`).
//   * Compact stats row — invitees count and rewards earned (₹).
//   * "Redeem code" form — text field + button calling `POST /referrals/redeem`.
//
// Design rules (from tokens.dart):
//   * Single orange accent (#EA580C — `RadhaColors.primary`).
//   * 44pt+ touch targets; no emoji; Plus Jakarta Sans via theme.
//   * Monospace ONLY for tabular numerics and the referral code itself.
//   * Staggered entrance, tactile copy/share feedback + haptics, and
//     reduce-motion awareness, matching the rest of the app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/misc_dto.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/error_state.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// FutureProvider wrapping `GET /api/v1/referrals/me` (BE-43). Refreshable
/// via `ref.invalidate(referralStatsProvider)` from pull-to-refresh.
final referralStatsProvider = FutureProvider<ReferralStatsResponse>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  return api.getReferralStats();
});

class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(referralStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.referrals,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(referralStatsProvider.future),
          child: statsAsync.when(
            loading: () => const _LoadingShell(),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                ErrorState(
                  title: l10n.referralsLoadError,
                  onRetry: () => ref.invalidate(referralStatsProvider),
                ),
              ],
            ),
            data: (stats) => _ReferralsBody(stats: stats),
          ),
        ),
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double h, {double? w, double radius = RadhaRadii.radiusMd}) =>
        Container(
          width: w ?? double.infinity,
          height: h,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      children: [
        Container(
          padding: const EdgeInsets.all(RadhaSpacing.space24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              block(12, w: 120, radius: RadhaRadii.radiusSm),
              const SizedBox(height: RadhaSpacing.space16),
              block(32, w: 200),
              const SizedBox(height: RadhaSpacing.space16),
              block(kMinTouchTarget),
            ],
          ),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        Row(
          children: [
            Expanded(child: block(84)),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(child: block(84)),
          ],
        ),
      ],
    );
  }
}

class _ReferralsBody extends ConsumerWidget {
  const _ReferralsBody({required this.stats});

  final ReferralStatsResponse stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      children: [
        _StaggerIn(
          index: 0,
          reduceMotion: reduceMotion,
          child: _ReferralHeroCard(code: stats.referralCode),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        _StaggerIn(
          index: 1,
          reduceMotion: reduceMotion,
          child: _StatsRow(
            inviteeCount: stats.inviteeCount,
            rewardsEarned: stats.rewardsEarned,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space24),
        _StaggerIn(
          index: 2,
          reduceMotion: reduceMotion,
          child: const _RedeemSection(),
        ),
      ],
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────

class _ReferralHeroCard extends StatelessWidget {
  const _ReferralHeroCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).yourReferralCode,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: radhaMonoStyle(
                      fontSize: 28,
                      weight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                _IconAction(
                  icon: Icons.copy_outlined,
                  tooltip: AppLocalizations.of(context).referralsCopyCode,
                  onPressed: () => _copyCode(context, code),
                ),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: AppLocalizations.of(context).referralsShareInvite,
                icon: Icons.share_outlined,
                expand: true,
                onPressed: () => _shareCode(
                  AppLocalizations.of(context).referralsShareText(code),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).referralsCodeCopied)),
    );
  }

  Future<void> _shareCode(String message) async {
    HapticFeedback.lightImpact();
    await Share.share(message);
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: kMinTouchTarget,
        height: kMinTouchTarget,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.inviteeCount, required this.rewardsEarned});

  final int inviteeCount;
  final num rewardsEarned;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: AppLocalizations.of(context).invitees,
            value: inviteeCount.toString(),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space12),
        Expanded(
          child: _StatTile(
            label: AppLocalizations.of(context).rewardsEarned,
            value: '₹${_formatAmount(rewardsEarned)}',
          ),
        ),
      ],
    );
  }

  /// Renders the rewards amount with no decimals when whole, otherwise a
  /// stable two-decimal representation. Avoids `intl.NumberFormat` here
  /// because the referral total is small and locale-independent.
  String _formatAmount(num value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              value,
              style: radhaMonoStyle(
                fontSize: 22,
                weight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Redeem section ───────────────────────────────────────────────────────

class _RedeemSection extends ConsumerStatefulWidget {
  const _RedeemSection();

  @override
  ConsumerState<_RedeemSection> createState() => _RedeemSectionState();
}

class _RedeemSectionState extends ConsumerState<_RedeemSection> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(
        () => _error = AppLocalizations.of(context).enterReferralCode,
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.redeemReferral(RedeemReferralDto(code: code));
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _controller.clear();
      // Refresh stats so the invitee/reward counters update.
      ref.invalidate(referralStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).referralsCodeRedeemed),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = AppLocalizations.of(context).referralsRedeemError,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.redeemCode,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space4),
        Text(
          l10n.referralsRedeemSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        TextField(
          controller: _controller,
          enabled: !_submitting,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          enableSuggestions: false,
          style: radhaMonoStyle(
            fontSize: 16,
            weight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: l10n.enterReferralCode,
            errorText: _error,
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: l10n.referralsRedeem,
            icon: Icons.redeem_outlined,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ),
      ],
    );
  }
}

// ─── Entrance ──────────────────────────────────────────────────────────────

/// Staggered fade + rise used for the screen's primary blocks. Honours the
/// platform reduce-motion flag by rendering the child immediately.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({
    required this.index,
    required this.reduceMotion,
    required this.child,
  });

  final int index;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: RadhaMotion.slow,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: RadhaMotion.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: RadhaMotion.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      Future<void>.delayed(
        Duration(milliseconds: 70 * widget.index),
        () {
          if (mounted) _c.forward();
        },
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
