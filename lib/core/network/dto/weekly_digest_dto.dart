// Weekly digest DTOs — projection of `/weekly-digest/*` (BE-54).

class WeeklyDigestDto {
  const WeeklyDigestDto({
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    this.metrics,
    this.highlights,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final String summary;
  final Map<String, dynamic>? metrics;
  final List<String>? highlights;

  factory WeeklyDigestDto.fromJson(Map<String, dynamic> json) =>
      WeeklyDigestDto(
        weekStart: DateTime.parse(json['weekStart'] as String),
        weekEnd: DateTime.parse(json['weekEnd'] as String),
        summary: json['summary'] as String,
        metrics: (json['metrics'] as Map<String, dynamic>?),
        highlights: (json['highlights'] as List<dynamic>?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'weekStart': weekStart.toIso8601String(),
    'weekEnd': weekEnd.toIso8601String(),
    'summary': summary,
    if (metrics != null) 'metrics': metrics,
    if (highlights != null) 'highlights': highlights,
  };
}
