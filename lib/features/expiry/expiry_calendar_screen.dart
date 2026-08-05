// Expiry calendar (consumes the expiry-records endpoint, aggregated
// client-side by month).
//
// Monthly calendar view showing expiry status dots per day:
//   * danger red  = expired items that day,
//   * warn amber  = near-expiry,
//   * success green = safe.
//
// Below the grid, a detail list always shows real product rows (name,
// EAN, quantity, days left/overdue) — never just a count:
//   * No day selected → every record in the focused month, grouped by day.
//   * A day selected  → only that day's records.
//
// Design rules (from tokens.dart):
//   * One orange accent (#EA580C) for the selected day + today marker. The
//     status dots use functional danger/warn/success, never a second accent.
//   * Hairline-bordered surface card wrapping the calendar; legend chip row.
//   * Skeleton loader, animated day-detail panel, reduce-motion awareness.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

@immutable
class _CalendarQueryArgs {
  const _CalendarQueryArgs({required this.storeId, required this.month});

  final String storeId;
  final String month;

  @override
  bool operator ==(Object other) =>
      other is _CalendarQueryArgs &&
      other.storeId == storeId &&
      other.month == month;

  @override
  int get hashCode => Object.hash(storeId, month);
}

List<Map<String, dynamic>> _recordsToCalendarEntries(
  List<ExpiryResponse> records,
  String month,
) {
  final summaries = <DateTime, _DaySummary>{};
  for (final record in records) {
    final parsed = DateTime.tryParse(record.expiryDate);
    if (parsed == null) continue;
    final recordMonth =
        '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}';
    if (recordMonth != month) continue;
    final key = DateTime.utc(parsed.year, parsed.month, parsed.day);
    final current =
        summaries[key] ?? const _DaySummary(expired: 0, nearExpiry: 0, safe: 0);
    summaries[key] = switch (record.status) {
      'expired' => _DaySummary(
        expired: current.expired + 1,
        nearExpiry: current.nearExpiry,
        safe: current.safe,
      ),
      'red' || 'yellow' || 'near_expiry' => _DaySummary(
        expired: current.expired,
        nearExpiry: current.nearExpiry + 1,
        safe: current.safe,
      ),
      'green' || 'safe' => _DaySummary(
        expired: current.expired,
        nearExpiry: current.nearExpiry,
        safe: current.safe + 1,
      ),
      _ => current,
    };
  }
  return summaries.entries
      .map(
        (e) => <String, dynamic>{
          'date':
              '${e.key.year}-${e.key.month.toString().padLeft(2, '0')}-${e.key.day.toString().padLeft(2, '0')}',
          'expired': e.value.expired,
          'nearExpiry': e.value.nearExpiry,
          'safe': e.value.safe,
        },
      )
      .toList();
}

/// Records for [month] (`yyyy-MM`), sorted by expiry date ascending, kept
/// as full [ExpiryResponse] rows (not aggregated) — this is what the
/// detail list renders, whether or not a specific day is selected.
List<ExpiryResponse> _recordsForMonth(
  List<ExpiryResponse> records,
  String month,
) {
  final matches = records.where((record) {
    final parsed = DateTime.tryParse(record.expiryDate);
    if (parsed == null) return false;
    final recordMonth =
        '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}';
    return recordMonth == month;
  }).toList();
  matches.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  return matches;
}

/// Provider that fetches the store's expiry records once and derives both
/// the per-day dot summary and the full-detail record list for the
/// focused month client-side. The calendar endpoint was removed from the
/// backend; we derive everything from `GET /expiry-records`.
final _calendarProvider =
    FutureProvider.family<_CalendarData, _CalendarQueryArgs>((ref, args) async {
      final client = ref.watch(apiClientProvider);
      final page = await client.getExpiries(storeId: args.storeId, limit: 200);
      return _CalendarData(
        entries: _recordsToCalendarEntries(page.items, args.month),
        monthRecords: _recordsForMonth(page.items, args.month),
      );
    });

/// Bundle returned by [_calendarProvider]: the aggregated dot-marker data
/// plus the raw per-record list for the focused month, so the detail
/// list below the grid always has real product rows to render.
@immutable
class _CalendarData {
  const _CalendarData({required this.entries, required this.monthRecords});

  final List<Map<String, dynamic>> entries;
  final List<ExpiryResponse> monthRecords;
}

/// Monthly calendar view showing expiry status dots per day.
class ExpiryCalendarScreen extends ConsumerStatefulWidget {
  const ExpiryCalendarScreen({super.key});

  @override
  ConsumerState<ExpiryCalendarScreen> createState() =>
      _ExpiryCalendarScreenState();
}

class _ExpiryCalendarScreenState extends ConsumerState<ExpiryCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String get _monthKey =>
      '${_focusedDay.year}-${_focusedDay.month.toString().padLeft(2, '0')}';

  /// Parse the aggregated entries into a day-keyed summary map for rendering.
  Map<DateTime, _DaySummary> _buildDayMap(List<Map<String, dynamic>> entries) {
    final map = <DateTime, _DaySummary>{};
    for (final entry in entries) {
      final dateStr = entry['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final normalized = DateTime.utc(date.year, date.month, date.day);
      map[normalized] = _DaySummary(
        expired: (entry['expired'] as num?)?.toInt() ?? 0,
        nearExpiry: (entry['nearExpiry'] as num?)?.toInt() ?? 0,
        safe: (entry['safe'] as num?)?.toInt() ?? 0,
      );
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selectedStoreId = ref.watch(currentUserProvider)?.selectedStoreId;

    if (selectedStoreId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.expiryCalendarTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(
          child: EmptyState(
            illustration: const MorCompanion(mood: MorMood.concern, size: 104),
            title: l10n.selectStoreEmpty,
            body: l10n.selectStoreEmptyBody,
          ),
        ),
      );
    }

    final args = _CalendarQueryArgs(storeId: selectedStoreId, month: _monthKey);
    final asyncCal = ref.watch(_calendarProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.expiryCalendarTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: asyncCal.when(
          loading: () => const _CalendarSkeleton(),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(RadhaSpacing.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 40,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: RadhaSpacing.space12),
                  Text(
                    l10n.expiryCalendarLoadError,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(_calendarProvider(args)),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.tryAgain),
                  ),
                ],
              ),
            ),
          ),
          data: (calResponse) {
            final dayMap = _buildDayMap(calResponse.entries);
            final monthRecords = calResponse.monthRecords;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    RadhaSpacing.space16,
                    RadhaSpacing.space16,
                    RadhaSpacing.space16,
                    RadhaSpacing.space8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                      border: Border.all(color: scheme.outline),
                    ),
                    padding: const EdgeInsets.all(RadhaSpacing.space8),
                    child: TableCalendar<void>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                            theme.textTheme.titleMedium ?? const TextStyle(),
                        leftChevronIcon: Icon(
                          Icons.chevron_left_rounded,
                          color: scheme.onSurface,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.onSurface,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        weekendStyle: theme.textTheme.labelSmall!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        defaultTextStyle:
                            theme.textTheme.bodyMedium ?? const TextStyle(),
                        weekendTextStyle:
                            theme.textTheme.bodyMedium ?? const TextStyle(),
                        todayDecoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) {
                        setState(() {
                          _focusedDay = focused;
                          _selectedDay = null;
                        });
                      },
                      calendarBuilders: CalendarBuilders<void>(
                        markerBuilder: (context, day, _) {
                          final normalized = DateTime.utc(
                            day.year,
                            day.month,
                            day.day,
                          );
                          final summary = dayMap[normalized];
                          if (summary == null) return null;
                          return _DayDots(summary: summary);
                        },
                      ),
                    ),
                  ),
                ),
                const _Legend(),
                const Divider(height: 1),
                Expanded(
                  child: _DayDetails(
                    selectedDay: _selectedDay,
                    monthRecords: monthRecords,
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

/// Legend chip row mapping each dot colour to its meaning.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space8,
      ),
      child: Row(
        children: [
          _LegendChip(color: RadhaColors.danger, label: l10n.expired),
          const SizedBox(width: RadhaSpacing.space16),
          _LegendChip(color: RadhaColors.warning, label: l10n.expiryTabNear),
          const SizedBox(width: RadhaSpacing.space16),
          _LegendChip(color: RadhaColors.success, label: l10n.expiryTabSafe),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: RadhaSpacing.space4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Small colored dots rendered below a calendar day cell.
class _DayDots extends StatelessWidget {
  const _DayDots({required this.summary});

  final _DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];
    if (summary.expired > 0) {
      dots.add(_dot(RadhaColors.danger));
    }
    if (summary.nearExpiry > 0) {
      dots.add(_dot(RadhaColors.warning));
    }
    if (summary.safe > 0) {
      dots.add(_dot(RadhaColors.success));
    }
    if (dots.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 4,
      child: Row(mainAxisSize: MainAxisSize.min, children: dots),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Shows real product rows (name, EAN, quantity, days left/overdue) for
/// either the whole focused month (no day selected — the default view) or
/// just the selected day. Animates between states as the user taps around.
class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.selectedDay, required this.monthRecords});

  final DateTime? selectedDay;
  final List<ExpiryResponse> monthRecords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: RadhaMotion.medium,
      switchInCurve: RadhaMotion.easeOut,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: _buildContent(context, theme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    if (selectedDay == null) {
      // Default view: every record in the focused month, grouped by day.
      if (monthRecords.isEmpty) {
        return _emptyState(
          key: const ValueKey('empty-month'),
          theme: theme,
          message: l10n.expiryCalendarNoRecordsMonth,
        );
      }
      final groups = <String, List<ExpiryResponse>>{};
      for (final record in monthRecords) {
        groups.putIfAbsent(record.expiryDate, () => []).add(record);
      }
      final sortedDates = groups.keys.toList()..sort();
      return ListView(
        key: const ValueKey('month-list'),
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space16,
          RadhaSpacing.space16,
          RadhaSpacing.space16,
          RadhaSpacing.space24,
        ),
        children: [
          Text(l10n.expiryCalendarThisMonth, style: theme.textTheme.titleSmall),
          const SizedBox(height: RadhaSpacing.space12),
          for (final date in sortedDates) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: RadhaSpacing.space8,
                bottom: RadhaSpacing.space4,
              ),
              child: Text(
                _formatDisplayDate(date),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final record in groups[date]!)
              Padding(
                padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
                child: _ProductDetailRow(record: record),
              ),
          ],
        ],
      );
    }

    // A specific day is selected: only that day's records.
    final dayKey = _formatDate(selectedDay!);
    final dayRecords = monthRecords
        .where((r) => r.expiryDate.startsWith(dayKey))
        .toList();

    if (dayRecords.isEmpty) {
      return _emptyState(
        key: ValueKey('empty-$dayKey'),
        theme: theme,
        message: l10n.expiryCalendarNoRecords,
      );
    }

    return ListView(
      key: ValueKey('day-list-$dayKey'),
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space16,
        RadhaSpacing.space16,
        RadhaSpacing.space24,
      ),
      children: [
        Text(
          l10n.expiryCalendarSummaryFor(dayKey),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: RadhaSpacing.space12),
        for (final record in dayRecords)
          Padding(
            padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
            child: _ProductDetailRow(record: record),
          ),
      ],
    );
  }

  Widget _emptyState({
    required Key key,
    required ThemeData theme,
    required String message,
  }) {
    return Center(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorCompanion(mood: MorMood.guard, size: 96, semanticLabel: message),
          const SizedBox(height: RadhaSpacing.space12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// `yyyy-MM-dd...` → `yyyy-MM-dd` (group headers key on the ISO date
  /// prefix only, dropping any time-of-day component the server sends).
  String _formatDisplayDate(String isoDate) =>
      isoDate.length >= 10 ? isoDate.substring(0, 10) : isoDate;
}

/// One product row in the calendar's detail list: name, EAN, quantity, and
/// a status-colored days-left/overdue chip. This is the "proper product
/// details" view the day-tap summary was missing before.
class _ProductDetailRow extends StatelessWidget {
  const _ProductDetailRow({required this.record});

  final ExpiryResponse record;

  int? get _daysLeft {
    final d = DateTime.tryParse(record.expiryDate);
    if (d == null) return null;
    final today = DateTime.now();
    final dateOnly = DateTime(d.year, d.month, d.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.difference(todayOnly).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final days = _daysLeft;

    final (chipColor, chipLabel) = switch (days) {
      null => (scheme.onSurfaceVariant, record.status ?? '—'),
      < 0 => (RadhaColors.danger, l10n.expiryCalendarDaysOverdue(-days)),
      _ => days <= 7
          ? (RadhaColors.warning, l10n.expiryCalendarDaysLeft(days))
          : (RadhaColors.success, l10n.expiryCalendarDaysLeft(days)),
    };

    final name = (record.productName != null && record.productName!.isNotEmpty)
        ? record.productName!
        : l10n.expiryProductShort(
            record.productId.length <= 8
                ? record.productId
                : record.productId.substring(0, 8),
          );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space2),
                Text(
                  [
                    if (record.ean != null && record.ean!.isNotEmpty)
                      l10n.expiryCalendarEanLabel(record.ean!),
                    if (record.quantity != null)
                      l10n.expiryCalendarQtyLabel('${record.quantity}'),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space12,
              vertical: RadhaSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            ),
            child: Text(
              chipLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySummary {
  const _DaySummary({
    required this.expired,
    required this.nearExpiry,
    required this.safe,
  });

  final int expired;
  final int nearExpiry;
  final int safe;

  int get total => expired + nearExpiry + safe;
}

/// Skeleton shown while the month's data loads. Mirrors the card-wrapped
/// calendar grid so the load reads as the page filling in.
class _CalendarSkeleton extends StatelessWidget {
  const _CalendarSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
              border: Border.all(color: scheme.outline),
            ),
            padding: const EdgeInsets.all(RadhaSpacing.space16),
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: 140,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),
                Expanded(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    mainAxisSpacing: RadhaSpacing.space8,
                    crossAxisSpacing: RadhaSpacing.space8,
                    children: List.generate(
                      35,
                      (_) => Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
