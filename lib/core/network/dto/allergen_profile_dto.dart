// Allergen profile DTOs — projection of `/allergens/profile/{userId}` (BE-37).
//
// Plain hand-written `fromJson`/`toJson` so the file doesn't require the
// json_serializable build step. Retrofit resolves both via reflection-free
// dispatch (it calls `Body.toJson()` and `Type.fromJson(map)` directly), so
// these contracts are sufficient for codegen on the client side.

class AllergenProfileResponse {
  const AllergenProfileResponse({
    required this.userId,
    required this.allergens,
  });

  /// User this profile belongs to.
  final String userId;

  /// Canonical allergen tags the user is sensitive to (e.g. `peanut`,
  /// `tree_nut`, `dairy`). Tags follow the BE-37 vocabulary.
  final List<String> allergens;

  /// `userId` is echoed by the backend on the update (PUT) response but
  /// omitted on the read (GET) response — tolerate its absence rather than
  /// crashing, since callers already know the userId from auth context.
  factory AllergenProfileResponse.fromJson(Map<String, dynamic> json) =>
      AllergenProfileResponse(
        userId: json['userId'] as String? ?? '',
        allergens:
            (json['allergens'] as List<dynamic>?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {'userId': userId, 'allergens': allergens};
}

class UpdateAllergenProfileDto {
  const UpdateAllergenProfileDto({required this.allergens});

  final List<String> allergens;

  Map<String, dynamic> toJson() => {'allergens': allergens};
}
