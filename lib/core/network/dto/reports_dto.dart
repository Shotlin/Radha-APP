// Reports + Dashboard DTOs.
//
// Mirrors the BE-20 / BE-21 surface that backs the FE-30 (Reports
// & Exports) and FE-26 (OHS Dashboard) screens. The backend
// contracts live at:
//
//   * GET    /api/v1/reports                       — list summaries
//   * POST   /api/v1/reports/generate              — kick off a job
//   * POST   /api/v1/reports/export                — ad-hoc export
//   * POST   /api/v1/reports/:id/export            — re-export an existing report
//   * GET    /api/v1/reports/:id/download/:format  — presigned URL by format
//   * POST   /api/v1/reports/schedule              — create scheduled
//   * GET    /api/v1/reports/scheduled             — list schedules
//   * POST   /api/v1/reports/scheduled/:id/pause   — pause schedule
//   * POST   /api/v1/reports/scheduled/:id/resume  — resume schedule
//   * DELETE /api/v1/reports/scheduled/:id         — cancel schedule
//   * GET    /api/v1/dashboard/summary             — live OHS rollup
//
// Conversions are hand-written (no `json_serializable` codegen) so the
// only generator that has to fire when this file changes is Retrofit's
// `api_client.g.dart`. Every `fromJson` is tolerant of missing or
// alternately-cased keys because the backend evolves the wire shape over
// time.

library;

// ─── Shared helpers ────────────────────────────────────────────────────

DateTime? _parseIso(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

// ─── Reports listing ──────────────────────────────────────────────────

/// Single row returned by `GET /api/v1/reports`.
///
/// The server emits `ReportSummary` from `report.types.ts` — fields
/// that aren't stable in the V1 contract (e.g. `summary` JSON blob)
/// are intentionally exposed as a tolerant `Map`.
class ReportSummary {
  const ReportSummary({
    required this.reportId,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    this.rowCount,
    this.errorMessage,
    this.durationMs,
    this.expiresAt,
    this.summary = const <String, dynamic>{},
  });

  /// Stable UUID. Matches `report.id` server-side.
  final String reportId;

  /// Display title.
  final String title;

  /// Report kind — `expiry-summary`, `audit-trail`, etc.
  final String type;

  /// Lifecycle status — `pending`, `generating`, `completed`, `failed`,
  /// `expired`, `cancelled`.
  final String status;

  /// When the request was queued.
  final DateTime createdAt;

  /// Row count. `null` while the job is still running.
  final int? rowCount;

  /// Last error message if the job failed.
  final String? errorMessage;

  /// Wall-clock duration the job took.
  final int? durationMs;

  /// When the artefacts in S3 stop being downloadable.
  final DateTime? expiresAt;

  /// Free-form KPI block surfaced by some generators.
  final Map<String, dynamic> summary;

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final created = _parseIso(json['createdAt']) ?? DateTime.now().toUtc();
    return ReportSummary(
      reportId: _asString(json['reportId'] ?? json['id']),
      title: _asString(json['title']),
      type: _asString(json['type']),
      status: _asString(json['status'], fallback: 'pending'),
      createdAt: created,
      rowCount: json['rowCount'] is num
          ? (json['rowCount'] as num).toInt()
          : null,
      errorMessage: json['errorMessage'] as String?,
      durationMs: json['durationMs'] is num
          ? (json['durationMs'] as num).toInt()
          : null,
      expiresAt: _parseIso(json['expiresAt']),
      summary: (json['summary'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }
}

/// Wrapper for `GET /reports` so we can evolve to a paginated shape later
/// without breaking callers. Today the backend returns a bare list — the
/// factory accepts both shapes (`List` or `{items: [...]}`). Kept for
/// forward-compatibility; Retrofit returns the raw list directly.
class ReportListResponse {
  const ReportListResponse({required this.reports});

  final List<ReportSummary> reports;

  factory ReportListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ReportListResponse(
        reports: json
            .whereType<Map>()
            .map((m) => ReportSummary.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false),
      );
    }
    if (json is Map) {
      final items = (json['items'] as List?) ?? const <dynamic>[];
      return ReportListResponse(
        reports: items
            .whereType<Map>()
            .map((m) => ReportSummary.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false),
      );
    }
    return const ReportListResponse(reports: <ReportSummary>[]);
  }
}

// ─── Generate a report ────────────────────────────────────────────────

/// Closed date range used by the generate / dashboard endpoints. ISO-8601
/// strings — the server coerces to `Date`.
class DateRangeDto {
  const DateRangeDto({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      };
}

/// Request body for `POST /api/v1/reports/generate`.
class GenerateReportRequestDto {
  const GenerateReportRequestDto({
    required this.type,
    required this.formats,
    required this.dateRange,
    this.storeIds,
    this.filters,
    this.title,
    this.includeCharts = false,
  });

  final String type;
  final List<String> formats;
  final DateRangeDto dateRange;
  final List<String>? storeIds;
  final Map<String, dynamic>? filters;
  final String? title;
  final bool includeCharts;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'formats': formats,
        'dateRange': dateRange.toJson(),
        if (storeIds != null) 'storeIds': storeIds,
        if (filters != null) 'filters': filters,
        if (title != null) 'title': title,
        'includeCharts': includeCharts,
      };
}

/// Response from `POST /api/v1/reports/generate`. The backend returns
/// `{ reportId, status, estimatedDurationSeconds, formats }`.
class GenerateReportResponseDto {
  const GenerateReportResponseDto({
    required this.reportId,
    required this.status,
    required this.formats,
    this.estimatedDurationSeconds,
  });

  final String reportId;
  final String status;
  final List<String> formats;
  final int? estimatedDurationSeconds;

  factory GenerateReportResponseDto.fromJson(Map<String, dynamic> json) {
    return GenerateReportResponseDto(
      reportId: _asString(json['reportId'] ?? json['id']),
      status: _asString(json['status'], fallback: 'pending'),
      formats: ((json['formats'] as List?) ?? const <dynamic>[])
          .map((e) => _asString(e))
          .toList(growable: false),
      estimatedDurationSeconds: json['estimatedDurationSeconds'] is num
          ? (json['estimatedDurationSeconds'] as num).toInt()
          : null,
    );
  }
}

// ─── Export an existing report ────────────────────────────────────────

/// Request body for `POST /api/v1/reports/:id/export`.
class ExportRequestDto {
  const ExportRequestDto({required this.formats});

  final List<String> formats;

  Map<String, dynamic> toJson() => <String, dynamic>{'formats': formats};
}

/// Single artefact returned in the `files[]` array of an export response.
class ExportFile {
  const ExportFile({
    required this.id,
    required this.format,
    required this.fileName,
    required this.sizeBytes,
    this.expiresAt,
  });

  final String id;
  final String format;
  final String fileName;
  final int sizeBytes;
  final DateTime? expiresAt;

  factory ExportFile.fromJson(Map<String, dynamic> json) => ExportFile(
        id: _asString(json['id']),
        format: _asString(json['format']),
        fileName: _asString(json['fileName']),
        sizeBytes: _asInt(json['sizeBytes']),
        expiresAt: _parseIso(json['expiresAt']),
      );
}

/// Response from `POST /api/v1/reports/:id/export`.
class ExportResponseDto {
  const ExportResponseDto({
    required this.reportId,
    required this.files,
    this.totalSizeBytes,
    this.durationMs,
  });

  final String reportId;
  final List<ExportFile> files;
  final int? totalSizeBytes;
  final int? durationMs;

  factory ExportResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['files'] as List?) ?? const <dynamic>[];
    return ExportResponseDto(
      reportId: _asString(json['reportId']),
      files: raw
          .whereType<Map>()
          .map((m) => ExportFile.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      totalSizeBytes: json['totalSizeBytes'] is num
          ? (json['totalSizeBytes'] as num).toInt()
          : null,
      durationMs: json['durationMs'] is num
          ? (json['durationMs'] as num).toInt()
          : null,
    );
  }
}

/// Response from `GET /api/v1/reports/:id/download/:format`.
class ReportDownloadUrlResponse {
  const ReportDownloadUrlResponse({
    required this.url,
    required this.fileName,
    required this.expiresAt,
  });

  final String url;
  final String fileName;
  final DateTime expiresAt;

  factory ReportDownloadUrlResponse.fromJson(Map<String, dynamic> json) {
    return ReportDownloadUrlResponse(
      url: _asString(json['url']),
      fileName: _asString(json['fileName']),
      expiresAt: _parseIso(json['expiresAt']) ?? DateTime.now().toUtc(),
    );
  }
}

// ─── Scheduled reports ────────────────────────────────────────────────

/// Single row from `GET /api/v1/reports/scheduled`. Fields not consumed
/// by the screen (e.g. `recipients`, `parameters`) are intentionally
/// elided — the row is opaque enough that we don't need to round-trip it.
class ScheduledReport {
  const ScheduledReport({
    required this.id,
    required this.title,
    required this.type,
    required this.frequency,
    required this.status,
    this.dayOfWeek,
    this.dayOfMonth,
    this.hourOfDay,
    this.lastRunAt,
    this.nextRunAt,
  });

  /// UUID.
  final String id;
  final String title;

  /// Report type — same enum as `ReportSummary.type`.
  final String type;

  /// `daily`, `weekly`, `monthly`.
  final String frequency;

  /// `active`, `paused`, `cancelled`.
  final String status;

  /// 0=Sunday..6=Saturday — only set on weekly schedules.
  final int? dayOfWeek;

  /// 1..28 — only set on monthly schedules.
  final int? dayOfMonth;

  /// 0..23 in tenant timezone.
  final int? hourOfDay;

  final DateTime? lastRunAt;
  final DateTime? nextRunAt;

  /// Convenience — true when the schedule was paused.
  bool get paused => status == 'paused';

  /// True when the schedule was cancelled (kept in history but no longer
  /// firing). The screen filters these out so cancelled schedules don't
  /// clutter the list.
  bool get cancelled => status == 'cancelled';

  factory ScheduledReport.fromJson(Map<String, dynamic> json) {
    return ScheduledReport(
      id: _asString(json['id']),
      title: _asString(json['title']),
      type: _asString(json['type']),
      frequency: _asString(json['frequency'], fallback: 'weekly'),
      status: _asString(json['status'], fallback: 'active'),
      dayOfWeek: json['dayOfWeek'] is num
          ? (json['dayOfWeek'] as num).toInt()
          : null,
      dayOfMonth: json['dayOfMonth'] is num
          ? (json['dayOfMonth'] as num).toInt()
          : null,
      hourOfDay: json['hourOfDay'] is num
          ? (json['hourOfDay'] as num).toInt()
          : null,
      lastRunAt: _parseIso(json['lastRunAt']),
      nextRunAt: _parseIso(json['nextRunAt']),
    );
  }
}

/// Wrapper for the schedule list endpoint. Tolerates both bare-list and
/// `{items: [...]}` envelopes for forward compatibility.
class ScheduledReportListResponse {
  const ScheduledReportListResponse({required this.schedules});

  final List<ScheduledReport> schedules;

  factory ScheduledReportListResponse.fromJson(dynamic json) {
    final raw = json is List
        ? json
        : (json is Map ? (json['items'] as List? ?? const <dynamic>[]) : const <dynamic>[]);
    return ScheduledReportListResponse(
      schedules: raw
          .whereType<Map>()
          .map((m) => ScheduledReport.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

/// Body for `POST /api/v1/reports/schedule`. The server validates the
/// nested `parameters` block against the same schema as the generate
/// endpoint, so we re-use [GenerateReportRequestDto].
class CreateScheduleRequestDto {
  const CreateScheduleRequestDto({
    required this.title,
    required this.type,
    required this.frequency,
    required this.parameters,
    this.dayOfWeek,
    this.dayOfMonth,
    this.hourOfDay = 9,
    this.recipients = const <String>[],
  });

  final String title;
  final String type;

  /// `daily` | `weekly` | `monthly`.
  final String frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int hourOfDay;
  final List<String> recipients;
  final GenerateReportRequestDto parameters;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'type': type,
        'frequency': frequency,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
        if (dayOfMonth != null) 'dayOfMonth': dayOfMonth,
        'hourOfDay': hourOfDay,
        'recipients': recipients,
        'parameters': parameters.toJson(),
      };
}

// ─── Dashboard / OHS summary ──────────────────────────────────────────

/// Single point in the `trends[]` array of the dashboard response.
class DashboardTrendPoint {
  const DashboardTrendPoint({
    required this.date,
    required this.scans,
    required this.expiryAdded,
    required this.tasksCompleted,
  });

  /// `YYYY-MM-DD`.
  final String date;
  final int scans;
  final int expiryAdded;
  final int tasksCompleted;

  factory DashboardTrendPoint.fromJson(Map<String, dynamic> json) {
    return DashboardTrendPoint(
      date: _asString(json['date']),
      scans: _asInt(json['scans']),
      expiryAdded: _asInt(json['expiryAdded']),
      tasksCompleted: _asInt(json['tasksCompleted']),
    );
  }
}

/// Counts grouped by traffic-light status — drives the "Inventory hygiene"
/// dimension of the OHS score.
class DashboardExpiry {
  const DashboardExpiry({
    required this.green,
    required this.yellow,
    required this.red,
    required this.expired,
    this.unknown = 0,
  });

  final int green;
  final int yellow;
  final int red;
  final int expired;
  final int unknown;

  /// Convenience: total expiry records the dashboard saw in range.
  int get total => green + yellow + red + expired + unknown;

  factory DashboardExpiry.fromJson(Map<String, dynamic> json) =>
      DashboardExpiry(
        green: _asInt(json['green']),
        yellow: _asInt(json['yellow']),
        red: _asInt(json['red']),
        expired: _asInt(json['expired']),
        unknown: _asInt(json['unknown']),
      );

  static const DashboardExpiry empty = DashboardExpiry(
    green: 0,
    yellow: 0,
    red: 0,
    expired: 0,
  );
}

/// Aggregate counters from the dashboard response.
class DashboardTotals {
  const DashboardTotals({
    required this.scans,
    required this.sessionsCompleted,
    required this.expiryRecords,
    required this.activeAlerts,
    required this.tasksCompleted,
    required this.tasksOverdue,
  });

  final int scans;
  final int sessionsCompleted;
  final int expiryRecords;
  final int activeAlerts;
  final int tasksCompleted;
  final int tasksOverdue;

  factory DashboardTotals.fromJson(Map<String, dynamic> json) =>
      DashboardTotals(
        scans: _asInt(json['scans']),
        sessionsCompleted: _asInt(json['sessionsCompleted']),
        expiryRecords: _asInt(json['expiryRecords']),
        activeAlerts: _asInt(json['activeAlerts']),
        tasksCompleted: _asInt(json['tasksCompleted']),
        tasksOverdue: _asInt(json['tasksOverdue']),
      );

  static const DashboardTotals empty = DashboardTotals(
    scans: 0,
    sessionsCompleted: 0,
    expiryRecords: 0,
    activeAlerts: 0,
    tasksCompleted: 0,
    tasksOverdue: 0,
  );
}

/// Scan-match diagnostic block. `matchRate` is a 0..1 float on the wire.
class DashboardScanHealth {
  const DashboardScanHealth({
    required this.matched,
    required this.unmatched,
    required this.matchRate,
  });

  final int matched;
  final int unmatched;
  final double matchRate;

  factory DashboardScanHealth.fromJson(Map<String, dynamic> json) =>
      DashboardScanHealth(
        matched: _asInt(json['matched']),
        unmatched: _asInt(json['unmatched']),
        matchRate: _asDouble(json['matchRate']),
      );

  static const DashboardScanHealth empty = DashboardScanHealth(
    matched: 0,
    unmatched: 0,
    matchRate: 0,
  );
}

/// Wire response for `GET /api/v1/dashboard/summary`.
///
/// Field-for-field mirror of the BE-20 `DashboardSummary` shape. The OHS
/// score and per-dimension breakdowns the FE-26 screen renders are
/// _derived_ — see [OhsSnapshot] below — because the V1 server does not
/// emit them yet. As the backend evolves we'll surface the canonical
/// values here without changing the consuming UI.
class DashboardSummaryResponse {
  const DashboardSummaryResponse({
    required this.storeId,
    required this.totals,
    required this.expiry,
    required this.scanHealth,
    required this.trends,
    this.generatedAt,
  });

  final String storeId;
  final DashboardTotals totals;
  final DashboardExpiry expiry;
  final DashboardScanHealth scanHealth;
  final List<DashboardTrendPoint> trends;
  final DateTime? generatedAt;

  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryResponse(
      storeId: _asString(json['storeId']),
      totals: json['totals'] is Map
          ? DashboardTotals.fromJson(
              (json['totals'] as Map).cast<String, dynamic>(),
            )
          : DashboardTotals.empty,
      expiry: json['expiry'] is Map
          ? DashboardExpiry.fromJson(
              (json['expiry'] as Map).cast<String, dynamic>(),
            )
          : DashboardExpiry.empty,
      scanHealth: json['scanHealth'] is Map
          ? DashboardScanHealth.fromJson(
              (json['scanHealth'] as Map).cast<String, dynamic>(),
            )
          : DashboardScanHealth.empty,
      trends: ((json['trends'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((m) => DashboardTrendPoint.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      generatedAt: _parseIso(json['generatedAt']),
    );
  }
}

// ─── OHS view-model (client-side derivation) ──────────────────────────

/// Single dimension on the OHS bento grid.
class OhsBreakdown {
  const OhsBreakdown({required this.category, required this.score});

  final String category;

  /// 0..100 integer score. Capped client-side so we never paint > 100
  /// or < 0 even if the source counters drift.
  final int score;
}

/// A single bar on the 7-day trend chart.
class OhsTrendBar {
  const OhsTrendBar({required this.date, required this.score});

  /// `YYYY-MM-DD`.
  final String date;
  final int score;
}

/// Friendly client-side projection consumed by the OHS dashboard screen.
///
/// The fields below match the FE-26 spec one-to-one: a headline score, a
/// dimension breakdown, callable counters for the action-items list, and
/// a 7-bar trend. Each is derived deterministically from the raw
/// [DashboardSummaryResponse] so the screen never has to inspect the
/// wire payload directly.
class OhsSnapshot {
  const OhsSnapshot({
    required this.ohsScore,
    required this.breakdown,
    required this.scansThisWeek,
    required this.expiryAlertsActive,
    required this.lowStockCount,
    required this.weekOverWeekDelta,
    required this.trend,
  });

  /// 0..100. Weighted blend of the three dimension scores.
  final int ohsScore;
  final List<OhsBreakdown> breakdown;
  final int scansThisWeek;
  final int expiryAlertsActive;
  final int lowStockCount;

  /// Difference between this week's score and last week's score, in
  /// absolute points. `null` when the request range is too short to
  /// derive a comparison (e.g. first run on a new account).
  final int? weekOverWeekDelta;

  /// Ordered list of trend bars for the last 7 days. May contain fewer
  /// than 7 entries when the server response is short.
  final List<OhsTrendBar> trend;

  /// True when every counter is zero — used to show the empty state on
  /// the OHS screen instead of a sea of zeroes.
  bool get isEmpty =>
      scansThisWeek == 0 &&
      expiryAlertsActive == 0 &&
      lowStockCount == 0 &&
      breakdown.every((b) => b.score == 0);

  /// How many priority-action rows the dashboard will show. Mirrors the
  /// condition list in `_ActionItems` — kept in sync there.
  int get actionCount =>
      (expiryAlertsActive > 0 ? 1 : 0) + (lowStockCount > 0 ? 1 : 0) + 1;

  /// Build from the wire DTO. Pure function — doesn't touch I/O.
  factory OhsSnapshot.fromDashboard(DashboardSummaryResponse src) {
    // ── Compliance: % of tasks completed on time. The server gives us
    //    `tasksCompleted` and `tasksOverdue`; if there were no tasks at
    //    all we treat it as 100 (nothing was missed) so a quiet store
    //    doesn't get punished.
    final taskTotal = src.totals.tasksCompleted + src.totals.tasksOverdue;
    final compliance = taskTotal == 0
        ? 100
        : ((src.totals.tasksCompleted / taskTotal) * 100).round();

    // ── Inventory hygiene: 1 - (red+expired)/total expiry records.
    final expiryTotal = src.expiry.total;
    final inventoryHygiene = expiryTotal == 0
        ? 100
        : (((expiryTotal - src.expiry.red - src.expiry.expired) / expiryTotal) *
                100)
            .round();

    // ── Audit completion: scan match-rate as a percentage. Already a
    //    0..1 float on the wire.
    final auditCompletion = (src.scanHealth.matchRate * 100)
        .round()
        .clamp(0, 100);

    // ── Headline score: equal-weight blend of the three dimensions.
    //    Equal-weight is the V1 contract — once the backend ships a
    //    canonical OHS we'll just consume that field directly.
    final headline =
        ((compliance + inventoryHygiene + auditCompletion) / 3).round();

    // ── Last 7 days of trend data.
    final last7 = src.trends.length <= 7
        ? src.trends
        : src.trends.sublist(src.trends.length - 7);

    // Per-day score: scan-volume normalised against the busiest day.
    final maxScans = last7.fold<int>(
      0,
      (acc, p) => p.scans > acc ? p.scans : acc,
    );
    final trendBars = last7
        .map(
          (p) => OhsTrendBar(
            date: p.date,
            score: maxScans == 0
                ? 0
                : ((p.scans / maxScans) * 100).round().clamp(0, 100),
          ),
        )
        .toList(growable: false);

    // ── Week-over-week delta: average of the most-recent 7 vs the prior
    //    7 trend points, when at least 8 are available.
    int? wow;
    if (src.trends.length >= 8) {
      final recent = src.trends.sublist(src.trends.length - 7);
      final priorEnd = src.trends.length - 7;
      final priorStart =
          priorEnd - 7 < 0 ? 0 : priorEnd - 7;
      final prior = src.trends.sublist(priorStart, priorEnd);
      final recentAvg = recent.isEmpty
          ? 0
          : recent.fold<int>(0, (a, b) => a + b.scans) / recent.length;
      final priorAvg = prior.isEmpty
          ? 0
          : prior.fold<int>(0, (a, b) => a + b.scans) / prior.length;
      // Map scan volume delta back into a 0..100 score-points scale via
      // the same maxScans normalisation we used for the bars.
      if (maxScans > 0) {
        wow = (((recentAvg - priorAvg) / maxScans) * 100).round();
      }
    }

    return OhsSnapshot(
      ohsScore: headline.clamp(0, 100),
      breakdown: <OhsBreakdown>[
        OhsBreakdown(
          category: 'compliance',
          score: compliance.clamp(0, 100),
        ),
        OhsBreakdown(
          category: 'inventoryHygiene',
          score: inventoryHygiene.clamp(0, 100),
        ),
        OhsBreakdown(
          category: 'auditCompletion',
          score: auditCompletion.clamp(0, 100),
        ),
      ],
      scansThisWeek: src.totals.scans,
      expiryAlertsActive: src.totals.activeAlerts,
      // The V1 dashboard contract doesn't carry a low-stock counter so we
      // approximate using `red + expired` expiry rows — a reasonable
      // proxy and clearly documented as such in the FE-26 handoff. When
      // the backend grows a `lowStockCount` we'll consume it directly.
      lowStockCount: src.expiry.red + src.expiry.expired,
      weekOverWeekDelta: wow,
      trend: trendBars,
    );
  }
}
