import 'package:flutter/foundation.dart';

import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// Localized display name for a [RadhaCategory] id. The `label` field on
/// [RadhaCategory] stays as an English fallback (analytics / unmapped ids);
/// every UI surface resolves the visible name through this mapper.
String categoryLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'biscuits':
      return l10n.categoryBiscuits;
    case 'breakfast':
      return l10n.categoryBreakfast;
    case 'dairy':
      return l10n.categoryDairy;
    case 'beverages':
      return l10n.categoryBeverages;
    case 'staples':
      return l10n.categoryStaples;
    case 'personal-care':
      return l10n.categoryPersonalCare;
    case 'household':
      return l10n.categoryHousehold;
    case 'frozen':
      return l10n.categoryFrozen;
    default:
      return id;
  }
}

/// A retail category surfaced on the home "Shop by category" rail.
///
/// This is **static, asset-backed content** — there is no network call behind
/// the rail, so it paints on the very first frame (part of the home's
/// "feels-instant" model). Products inside a category are added later; the rail
/// itself is always available.
@immutable
class RadhaCategory {
  const RadhaCategory({
    required this.id,
    required this.label,
    required this.asset,
  });

  /// Stable slug — used for routing / analytics, never shown.
  final String id;

  /// Display name (English copy; localise via ARB when the catalog grows).
  final String label;

  /// Bundled cutout asset (a `RadhaAssets.cat*` constant).
  final String asset;
}

/// The eight launch categories, in shelf-priority order. Backed by the v3
/// cutout pack-shots the owner provided.
const List<RadhaCategory> kRadhaCategories = <RadhaCategory>[
  RadhaCategory(
    id: 'biscuits',
    label: 'Biscuits & Snacks',
    asset: RadhaAssets.catBiscuits,
  ),
  RadhaCategory(
    id: 'breakfast',
    label: 'Breakfast & Spreads',
    asset: RadhaAssets.catBreakfast,
  ),
  RadhaCategory(
    id: 'dairy',
    label: 'Dairy & Eggs',
    asset: RadhaAssets.catDairy,
  ),
  RadhaCategory(
    id: 'beverages',
    label: 'Beverages',
    asset: RadhaAssets.catBeverages,
  ),
  RadhaCategory(
    id: 'staples',
    label: 'Staples & Grains',
    asset: RadhaAssets.catStaples,
  ),
  RadhaCategory(
    id: 'personal-care',
    label: 'Personal Care',
    asset: RadhaAssets.catPersonalCare,
  ),
  RadhaCategory(
    id: 'household',
    label: 'Household',
    asset: RadhaAssets.catHousehold,
  ),
  RadhaCategory(
    id: 'frozen',
    label: 'Frozen',
    asset: RadhaAssets.catFrozen,
  ),
];
