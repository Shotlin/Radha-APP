# RADHA — UI v2 Migration Handoff

State at handoff: **green** (`flutter analyze` clean; `flutter test` = 10/10 pass).
Read [`UI_V2_EXECUTIVE_AUDIT.md`](./UI_V2_EXECUTIVE_AUDIT.md) and
[`UI_V2_ROUTE_MATRIX.md`](./UI_V2_ROUTE_MATRIX.md) first.

> **Work happens in `radha_app/`** (NOT `apps/mobile/` — see audit conflict C1).
> Toolchain: Flutter 3.44.0 at `C:/src/flutter/bin/flutter.bat`.

---

## Hard external blockers (cannot be solved in code)

1. **40 v3 premium assets are absent** (audit C5). Until the user drops them into
   `radha_app/assets/v2/...` and they're added to `pubspec.yaml`, every v3 reference
   degrades to a `BrandedImage`/`BrandIllustration` fallback. Restore list:
   - `assets/v2/character/mor/scenes/{hero-splash,hero-offline,hero-win,search-think,scanning}.webp`
   - `assets/v2/states/{no-results,empty-list,error-retry,offline}.webp`
   - `assets/v2/banners/{health-mission,expiry-mission,festive-store-pride}.webp`
   - `assets/v2/onboarding/{scan,health,audit,growth}.webp`
   - `assets/v2/icons/health/{sugar-high,fat-high,sodium-high,fiber-good,protein-good,additive-warning,allergen-flag,ultra-processed}.webp`
   - `assets/v2/illustrations/{cat-biscuits,cat-breakfast,cat-dairy,cat-beverages,cat-personal-care,cat-household,cat-staples,cat-frozen,cat-set-8,scan-frame,spot-expiry,spot-storehealth}.png`
   - `assets/v2/illustration/{home-mission-v3,home-promo-consumer-v3}.jpg`
   - `assets/v2/plus/paywall-hero.webp`, `assets/v2/brand/splash-lockup.webp`
   - **When restored:** add the dirs to `pubspec.yaml flutter: assets:` and enable the
     deferred **asset-registry test** (below).

2. **ARB completeness gap.** `app_en.arb` has 304 keys; the 5 other locales have 285.
   The exact missing set must be diffed and translated (real translations — no English
   placeholders, no Gujarati) **before** the ARB-completeness test can go green.

---

## Done so far

- **Phase 0 (audit + baseline):** complete. Docs written; baseline recorded.
- **Phase 1 batch 1 — nav grammar:** `RadhaBottomNavigation`
  (`lib/design/widgets/radha_bottom_navigation.dart`) replaces the generic Material
  `NavigationBar` in `lib/core/router/root_shell.dart`. Localized labels, emphasized
  Scan, soft-tint active indicator, honest badge support, a11y + reduced-motion.
- **Phase 1 batch 2 — first shared primitive:** `RadhaStatusChip`
  (`lib/design/widgets/radha_status_chip.dart`) — tonal status pill, icon-optional
  (not colour-alone), superset of all 7 private chips.
- **Test foundation established:** `test/design/` with
  `radha_bottom_navigation_test.dart`, `theme_test.dart`, `radha_status_chip_test.dart`
  (10 tests). **Pattern note:** any test that builds the theme/fonts must
  `setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false)` **and** run as
  `testWidgets` (pure `test()` throws on the unbundled font).

---

## Next steps (in order)

### Finish Phase 1 (app shell & foundation)
1. **Token sweep** — colours are already clean (0 hardcoded). Sweep `lib/features/**`
   for recurring magic *spacing/radius/duration* literals and replace with
   `RadhaSpacing`/`RadhaRadii`/`RadhaMotion`. Do **not** tokenize meaningful fixed dims
   (e.g. the scanner reticle) — document why they stay literal.
2. **Build remaining shared primitives** (extract from real usage, then migrate
   consumers, then delete the private copy — never leave both):
   | New component | Replaces / consumers |
   |---|---|
   | `RadhaScreenScaffold` + `RadhaSecondaryHeader` | 36 screens using bare `AppBar` |
   | `RadhaCard` / `RadhaPressableSurface` | 232 ad-hoc `BoxDecoration`+radius surfaces |
   | `RadhaHealthChip` | `scan_result_screen` `_HealthChip`, `product_detail_screen` `_HealthBadge` |
   | `RadhaSectionHeader` (use existing `section_header.dart`) | `digest`/`ohs_dashboard` `_SectionHeader` copies |
   | `RadhaSegmentedControl` | expiry/reports tab bars |
   | `RadhaProductRow` / `RadhaListRow` | catalog/home/saved/expiry/inventory rows |
   | `RadhaKpiTile`, `RadhaMetric` | home KPIs, OHS |
   | `RadhaDestructiveButton`, `RadhaIconButton`, `RadhaFab` | scattered inline buttons |
   | `RadhaPaginationFooter` | inventory/tasks/grn load-more footers |
   | `RadhaFormSection` | expiry/grn/task/stock-movement forms |
   3. **Status-chip consolidation** (now that `RadhaStatusChip` exists + is tested):
      migrate these in their phases — `grn_list_screen` `_StatusPill` (P6),
      `task_detail_screen` `_StatusPill` (P5), `reports_screen` `_StatusChip` (P9),
      `ean_audit_screen` `_StatusChip` (P4), `catalog/product_detail` `_Tag` (P4).
4. Standardize feedback vocabulary on the existing `snackbar_host`, `error_state`,
   `empty_state`, `skeleton_loader`, `locked_feature`; add `RadhaOfflineState`.
5. Dark-mode spot-check across migrated surfaces (theme already supports it).

### Phases 2–10
Execute per the original mandate, one coherent screen-batch at a time. After each:
`dart format` → `flutter analyze --no-pub` → `flutter test --no-pub` → update the
route matrix row. Add the per-phase tests listed in the mandate's testing strategy.

### Deferred tests to enable when unblocked
- **Asset-registry test** — parse `lib/design/app_assets.dart` for `assets/...` literals,
  assert each `File` exists. Enable after the 40 assets are restored (else red).
- **ARB-completeness test** — assert every `app_en.arb` key exists & is non-empty in
  hi/ta/te/bn/mr. Enable after the gap is closed.

---

## Validation commands (from `radha_app/`)
```
C:/src/flutter/bin/flutter.bat analyze --no-pub
C:/src/flutter/bin/flutter.bat test --no-pub
C:/src/flutter/bin/flutter.bat build apk --debug        # phase gates
C:/src/flutter/bin/flutter.bat build web --release      # phase gates
```

## Discipline reminders
Sequential only — no parallel agents on shared files (router/shell/app_assets).
Preserve all providers, routes, guards, DTOs, entitlement/role gates, scanner/OCR,
offline queue, pagination. Never fabricate health/operational data — designed honest
empty/pending/locked/unavailable states instead.
