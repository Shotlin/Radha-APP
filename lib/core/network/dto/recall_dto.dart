// Recall DTOs — projection of `/recall-alerts/*`.

class RecallAlertDto {
  const RecallAlertDto({
    required this.id,
    required this.productId,
    required this.severity,
    required this.title,
    required this.issuedAt,
    this.description,
    this.source,
  });

  final String id;
  final String productId;

  /// `info`, `warning`, `critical`.
  final String severity;
  final String title;
  final DateTime issuedAt;
  final String? description;
  final String? source;

  factory RecallAlertDto.fromJson(Map<String, dynamic> json) => RecallAlertDto(
    id: json['id'] as String,
    productId: json['productId'] as String,
    severity: json['severity'] as String,
    title: json['title'] as String,
    issuedAt: DateTime.parse(json['issuedAt'] as String),
    description: json['description'] as String?,
    source: json['source'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'severity': severity,
    'title': title,
    'issuedAt': issuedAt.toIso8601String(),
    if (description != null) 'description': description,
    if (source != null) 'source': source,
  };
}
