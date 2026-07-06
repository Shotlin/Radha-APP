// Allergen DTOs — projection of `/allergen/*`.

class AllergenProfileDto {
  const AllergenProfileDto({
    required this.userId,
    required this.allergens,
    this.severity,
    this.notes,
  });

  final String userId;
  final List<String> allergens;
  final String? severity;
  final String? notes;

  factory AllergenProfileDto.fromJson(Map<String, dynamic> json) =>
      AllergenProfileDto(
        userId: json['userId'] as String,
        allergens:
            (json['allergens'] as List<dynamic>?)?.cast<String>() ?? const [],
        severity: json['severity'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'allergens': allergens,
    if (severity != null) 'severity': severity,
    if (notes != null) 'notes': notes,
  };
}

class UpdateAllergenProfileRequest {
  const UpdateAllergenProfileRequest({
    required this.allergens,
    this.severity,
    this.notes,
  });

  final List<String> allergens;
  final String? severity;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'allergens': allergens,
    if (severity != null) 'severity': severity,
    if (notes != null) 'notes': notes,
  };
}

class AllergenCheckDto {
  const AllergenCheckDto({
    required this.productId,
    required this.safe,
    this.matchedAllergens,
    this.warnings,
  });

  final String productId;
  final bool safe;
  final List<String>? matchedAllergens;
  final List<String>? warnings;

  factory AllergenCheckDto.fromJson(Map<String, dynamic> json) =>
      AllergenCheckDto(
        productId: json['productId'] as String,
        safe: json['safe'] as bool,
        matchedAllergens: (json['matchedAllergens'] as List<dynamic>?)
            ?.cast<String>(),
        warnings: (json['warnings'] as List<dynamic>?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'safe': safe,
    if (matchedAllergens != null) 'matchedAllergens': matchedAllergens,
    if (warnings != null) 'warnings': warnings,
  };
}
