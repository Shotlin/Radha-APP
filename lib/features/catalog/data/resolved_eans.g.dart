// GENERATED — do not edit by hand.
//
// Maps a curated launch-catalog product `slug` to the **real** market barcode
// resolved by the backend Open Food Facts seed
// (`server/src/db/import-curated-catalog.ts`), applied by
// `apps/mobile/tool/apply_resolved_eans.dart`.
//
// Honesty contract: every entry was resolved from a real OFF row at seed time —
// none are guessed. Unresolved products are absent (app shows "scan to unlock").

const Map<String, String> kResolvedEans = <String, String>{
  'amul-ghee': '8901262030366',
  'britannia-white-bread': '8901063342354',
};
