// RADHA — curated launch catalog (browse-without-scan seed).
//
// A hand-curated set of real, recognisable Indian retail products bundled with
// the app so the "Shop by category → product" browse flow is populated,
// premium, and useful **offline from first launch** — before the server catalog
// (Open Food Facts import) or S3 product imagery come online.
//
// This manifest is the single source of truth shared with the backend seed
// (`server/src/modules/catalog-import` curated importer): each entry maps to one
// of the eight `kRadhaCategories` ids and carries a bundled WebP pack-shot under
// `assets/v2/products/`. `ean` is intentionally null until the backend resolves
// each product's real market barcode via OFF text-search (no guessed barcodes);
// once resolved, product detail fetches real nutrition/health by that EAN.
//
// Honesty: this layer supplies *identity + imagery* only (name/brand/category/
// pack size). It never carries health or nutrition numbers — those come from the
// real lookup pipeline, or an explicit "scan to unlock" state. See
// `product_detail_screen.dart`.

import 'package:flutter/foundation.dart';

import 'resolved_eans.g.dart';

/// One bundled launch-catalog product.
@immutable
class LaunchProduct {
  const LaunchProduct({
    required this.slug,
    required this.name,
    required this.categoryId,
    this.brand,
    this.netWeight,
    String? ean,
    this.isVeg,
  }) : _ean = ean;

  /// Stable kebab-case id; also the asset filename stem.
  final String slug;

  /// Display name (English; localise via ARB when the catalog grows).
  final String name;

  /// One of the [kRadhaCategories] ids: biscuits, breakfast, dairy, beverages,
  /// staples, personal-care, household, frozen.
  final String categoryId;

  /// Brand line shown under the name. Null for unbranded staples/produce.
  final String? brand;

  /// Pack size shown as a subtle chip (e.g. "250 g", "1 L", "6 pack").
  final String? netWeight;

  /// Real market barcode, resolved by the backend OFF importer (Phase 2).
  ///
  /// Resolution order: an explicit per-entry value (rare overrides) wins;
  /// otherwise the generated `kResolvedEans` overlay (populated by the backend
  /// seed) is consulted by `slug`. Null until the seed resolves one — the
  /// card/detail degrade honestly without it. Never a guessed barcode.
  final String? _ean;
  String? get ean => _ean ?? kResolvedEans[slug];

  /// Veg/non-veg for the "Veg only" filter. `true` veg, `false` non-veg
  /// (e.g. eggs), `null` not-applicable (non-food: soap, detergent…). The
  /// filter only ever *hides* known non-veg — it never hides unknowns.
  final bool? isVeg;

  /// Bundled pack-shot path. Declared per-file in `pubspec.yaml`.
  String get asset => 'assets/v2/products/$slug.webp';
}

/// The curated launch catalog — 29 packaged products across the 8 categories.
/// (Fresh produce from the source set is intentionally excluded: it has no
/// barcode / packaged-nutrition and no matching category.)
const List<LaunchProduct> kLaunchCatalog = <LaunchProduct>[
  // ── Biscuits & Snacks ───────────────────────────────────────────────────
  LaunchProduct(
    slug: 'parle-g-biscuits',
    name: 'Parle-G Glucose Biscuits',
    brand: 'Parle',
    netWeight: '250 g',
    categoryId: 'biscuits',
  ),
  LaunchProduct(
    slug: 'lays-classic-salted',
    name: "Lay's Classic Salted",
    brand: "Lay's",
    netWeight: '90 g',
    categoryId: 'biscuits',
  ),
  LaunchProduct(
    slug: 'haldiram-aloo-bhujia',
    name: "Haldiram's Aloo Bhujia",
    brand: "Haldiram's",
    netWeight: '200 g',
    categoryId: 'biscuits',
  ),
  // ── Breakfast & Spreads ─────────────────────────────────────────────────
  LaunchProduct(
    slug: 'cerelac',
    name: 'Nestlé Cerelac Baby Cereal',
    brand: 'Nestlé',
    netWeight: '300 g',
    categoryId: 'breakfast',
  ),
  LaunchProduct(
    slug: 'britannia-white-bread',
    name: 'Britannia White Bread',
    brand: 'Britannia',
    netWeight: '400 g',
    categoryId: 'breakfast',
  ),
  LaunchProduct(
    slug: 'multigrain-bread',
    name: 'Multigrain Bread',
    netWeight: '400 g',
    categoryId: 'breakfast',
  ),
  // ── Dairy & Eggs ────────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'amul-butter',
    name: 'Amul Butter',
    brand: 'Amul',
    netWeight: '100 g',
    categoryId: 'dairy',
  ),
  LaunchProduct(
    slug: 'amul-ghee',
    name: 'Amul Pure Ghee',
    brand: 'Amul',
    netWeight: '500 ml',
    categoryId: 'dairy',
  ),
  LaunchProduct(
    slug: 'amul-toned-milk',
    name: 'Amul Toned Milk',
    brand: 'Amul',
    netWeight: '500 ml',
    categoryId: 'dairy',
  ),
  LaunchProduct(
    slug: 'paneer',
    name: 'Fresh Paneer',
    netWeight: '200 g',
    categoryId: 'dairy',
  ),
  LaunchProduct(
    slug: 'farm-eggs',
    name: 'Farm Eggs',
    netWeight: '6 pack',
    categoryId: 'dairy',
  ),
  // ── Beverages ───────────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'coca-cola',
    name: 'Coca-Cola',
    brand: 'Coca-Cola',
    netWeight: '750 ml',
    categoryId: 'beverages',
  ),
  LaunchProduct(
    slug: 'real-mango-juice',
    name: 'Real Mango Fruit Power',
    brand: 'Real',
    netWeight: '1 L',
    categoryId: 'beverages',
  ),
  LaunchProduct(
    slug: 'tata-tea-gold',
    name: 'Tata Tea Gold',
    brand: 'Tata',
    netWeight: '250 g',
    categoryId: 'beverages',
  ),
  LaunchProduct(
    slug: 'nescafe-classic',
    name: 'Nescafé Classic Coffee',
    brand: 'Nescafé',
    netWeight: '100 g',
    categoryId: 'beverages',
  ),
  // ── Staples & Grains ────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'aashirvaad-atta',
    name: 'Aashirvaad Whole Wheat Atta',
    brand: 'Aashirvaad',
    netWeight: '5 kg',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'india-gate-basmati',
    name: 'India Gate Basmati Rice',
    brand: 'India Gate',
    netWeight: '5 kg',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'fortune-sunflower-oil',
    name: 'Fortune Sunflower Oil',
    brand: 'Fortune',
    netWeight: '1 L',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'toor-dal',
    name: 'Toor Dal (Arhar)',
    netWeight: '1 kg',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'mdh-garam-masala',
    name: 'MDH Garam Masala',
    brand: 'MDH',
    netWeight: '100 g',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'everest-turmeric',
    name: 'Everest Turmeric Powder',
    brand: 'Everest',
    netWeight: '100 g',
    categoryId: 'staples',
  ),
  LaunchProduct(
    slug: 'red-chilli-powder',
    name: 'Red Chilli Powder',
    netWeight: '200 g',
    categoryId: 'staples',
  ),
  // ── Personal Care ───────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'head-shoulders-shampoo',
    name: 'Head & Shoulders Shampoo',
    brand: 'Head & Shoulders',
    netWeight: '340 ml',
    categoryId: 'personal-care',
  ),
  LaunchProduct(
    slug: 'dove-soap',
    name: 'Dove Beauty Bar',
    brand: 'Dove',
    netWeight: '100 g',
    categoryId: 'personal-care',
  ),
  LaunchProduct(
    slug: 'pampers-diapers',
    name: 'Pampers Diapers (Medium)',
    brand: 'Pampers',
    netWeight: '20 pack',
    categoryId: 'personal-care',
  ),
  // ── Household ───────────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'surf-excel',
    name: 'Surf Excel Easy Wash',
    brand: 'Surf Excel',
    netWeight: '1.5 kg',
    categoryId: 'household',
  ),
  LaunchProduct(
    slug: 'lizol-floor-cleaner',
    name: 'Lizol Floor Cleaner',
    brand: 'Lizol',
    netWeight: '500 ml',
    categoryId: 'household',
  ),
  // ── Frozen ──────────────────────────────────────────────────────────────
  LaunchProduct(
    slug: 'amul-ice-cream-vanilla',
    name: 'Amul Vanilla Ice Cream',
    brand: 'Amul',
    netWeight: '1 L',
    categoryId: 'frozen',
  ),
  LaunchProduct(
    slug: 'aashirvaad-paratha',
    name: 'Aashirvaad Frozen Paratha',
    brand: 'Aashirvaad',
    netWeight: '5 pack',
    categoryId: 'frozen',
  ),
];

/// Launch-catalog products in a category, in manifest order. Empty when the
/// category has no curated products yet.
List<LaunchProduct> launchProductsForCategory(String categoryId) =>
    kLaunchCatalog
        .where((p) => p.categoryId == categoryId)
        .toList(growable: false);

/// Lookup by slug (used when a browse tap has no resolved EAN yet — the detail
/// screen falls back to the curated identity).
LaunchProduct? launchProductBySlug(String slug) {
  for (final p in kLaunchCatalog) {
    if (p.slug == slug) return p;
  }
  return null;
}

/// Lookup by resolved EAN (used to attach the bundled pack-shot to a server
/// catalog row, and to find curated identity from a scanned/looked-up barcode).
LaunchProduct? launchProductByEan(String ean) {
  for (final p in kLaunchCatalog) {
    if (p.ean != null && p.ean == ean) return p;
  }
  return null;
}
