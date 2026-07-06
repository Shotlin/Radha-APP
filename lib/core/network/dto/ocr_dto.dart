// OCR fallback DTOs — projection of `/image-fallback/*` (BE-45).
// On-device ML Kit is the first line; this hits the server-side Vision API
// only when device confidence is too low.

class OcrExtractedDatesDto {
  const OcrExtractedDatesDto({
    this.mfgDate,
    this.expiryDate,
    this.confidence,
    this.rawText,
  });

  final DateTime? mfgDate;
  final DateTime? expiryDate;
  final double? confidence;
  final String? rawText;

  factory OcrExtractedDatesDto.fromJson(Map<String, dynamic> json) =>
      OcrExtractedDatesDto(
        mfgDate: json['mfgDate'] == null
            ? null
            : DateTime.parse(json['mfgDate'] as String),
        expiryDate: json['expiryDate'] == null
            ? null
            : DateTime.parse(json['expiryDate'] as String),
        confidence: (json['confidence'] as num?)?.toDouble(),
        rawText: json['rawText'] as String?,
      );

  Map<String, dynamic> toJson() => {
    if (mfgDate != null) 'mfgDate': mfgDate!.toIso8601String(),
    if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
    if (confidence != null) 'confidence': confidence,
    if (rawText != null) 'rawText': rawText,
  };
}
