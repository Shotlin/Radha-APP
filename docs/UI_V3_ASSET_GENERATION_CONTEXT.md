# RADHA UI V3.0 Asset Generation Context

This document is the continuation brief for generating the V3 premium asset set. Source-of-truth files inspected:

- `C:\Users\sayan\Desktop\Untitled document.txt`
- `radha_app/lib/design/app_assets.dart`
- `radha_app/pubspec.yaml`
- `radha_app/lib/design/tokens.dart`
- `radha_app/lib/design/widgets/brand_illustration.dart`
- `radha_app/lib/design/widgets/branded_image.dart`
- `radha_app/docs/UI_V2_HANDOFF.md`
- `radha_app/docs/UI_V2_EXECUTIVE_AUDIT.md`
- `radha_app/docs/UI_V2_ROUTE_MATRIX.md`

## Current Truth

- Keep every generated file under `radha_app/assets/v2/...`. The app calls these V3 assets, but the current registry and `pubspec.yaml` still use the existing `assets/v2/` root.
- `RadhaAssets` has 77 registered image paths. On this disk, 37 are present and 40 are missing.
- The user asset note lists 40 files, but the four Mor master/reference files from that note already exist locally:
  - `assets/v2/character/mor/sheet-turnaround.png`
  - `assets/v2/character/mor/sheet-expressions.png`
  - `assets/v2/character/mor/glyph.png`
  - `assets/v2/character/mor/parts/parts-sheet.png`
- Those four existing master files are substantial reference assets and should be reused as Mor canon unless a visible quality defect is found.
- The 36 production-facing files from the user note are still missing.
- The registry also references four additional missing legacy illustration constants not listed in the user note:
  - `assets/v2/illustrations/cat-set-8.png`
  - `assets/v2/illustrations/scan-frame.png`
  - `assets/v2/illustrations/spot-expiry.png`
  - `assets/v2/illustrations/spot-storehealth.png`
- Those four extra paths are not active screen consumers right now, but they are in `RadhaAssets` and in `UI_V2_HANDOFF.md`. Either generate them too or remove them from the registry in a separate cleanup. Do not leave the registry test red.

## Product And Visual Context

RADHA is a mobile-first Indian retail audit and product intelligence app. It covers product scan, health signals, expiry, EAN verification, GRN, lightweight inventory, tasks, reports, offline sync, and subscription. It is not POS, GST, ERP, or accounting.

Use the existing visual system:

- Ink: `#1C1917`
- Paper: `#FFFBF5`
- Raised paper: `#FFFFFF`
- Primary orange: `#EA580C`
- Primary deep: `#9A3412`
- Primary tint: `#FED7AA`
- Restrained teal complement: `#0F766E`
- Success: `#15803D`
- Warning: `#B45309`
- Danger: `#B91C1C`
- Festive accents only for celebration: marigold `#F59E0B`, turmeric `#FACC15`
- Typography is Plus Jakarta Sans with JetBrains Mono for numeric contexts.

Asset style must be premium, calm, practical, and culturally rooted. Avoid generic SaaS art, childish mascot art, neon glow, purple-blue gradients, cartoon clutter, fake product brands, trademarked packaging, and embedded text except for `splash-lockup.webp`.

## Mor Canon

Use the existing Mor master/reference pack as the character source:

- One crest feather.
- Five tail feathers.
- Teal only in crest and tail-eye details.
- Warm orange, cream, deep ink, and restrained teal should match the app palette.
- Mor is expressive but mature: a confident retail companion, not a children's mascot.
- Keep body proportions, beak, eye construction, crest, wing shape, and tail language consistent across every scene.

## Runtime Consumers

- `BrandIllustration` displays Mor scenes, state art, onboarding art, and health badges with `BoxFit.contain`, decode hints, semantic-label support, and a blank/fallback box on missing assets.
- `BrandedImage` displays banner and category art with `BoxFit.cover`, skeleton loading, and branded fallback tiles.
- Splash uses `RadhaAssets.morSceneSplash` with fallback to static Mor greet.
- Onboarding page 1 uses `RadhaAssets.onboardScan` at about 240 px with fallback to Mor greet.
- Home promo carousel renders 16:9 banners with a bottom ink scrim and overlaid copy. Keep the lower-left/lower-center copy zone calm and readable.
- Home category rail displays 64 x 64 square category cutouts inside 72 px tiles.
- Catalog product detail shows health insight badges at about 48 px art size inside 96 px cards.
- Subscription screen uses `RadhaAssets.paywallHero` at about 196 px with fallback to Mor guard.
- Empty/error states use state illustrations in shared `EmptyState` and `ErrorState` widgets.

## Generate First

The best continuation order is:

1. Verify Mor master references, do not regenerate unless quality defects are found.
2. Generate five Mor full scenes.
3. Generate four app state illustrations.
4. Generate four onboarding scenes.
5. Generate eight health indicator badges.
6. Generate five home/editorial/banner assets.
7. Generate eight category cutouts.
8. Generate paywall hero and splash lockup.
9. Decide whether to generate or remove the four extra legacy illustration constants.

## Missing Production Assets From The User Note

### Mor Scenes

Generate transparent or softly isolated WebP companion scenes. They must survive `BoxFit.contain` at small and medium sizes.

- `assets/v2/character/mor/scenes/hero-splash.webp`: Mor welcoming the user, calm and premium.
- `assets/v2/character/mor/scenes/hero-offline.webp`: Mor under a subtle shelter metaphor, offline resilience without panic.
- `assets/v2/character/mor/scenes/hero-win.webp`: Mor celebrating a genuinely completed action.
- `assets/v2/character/mor/scenes/search-think.webp`: Mor thinking/searching with restrained retail or data cues.
- `assets/v2/character/mor/scenes/scanning.webp`: Mor assisting barcode recognition or label analysis.

### Application States

Use square transparent or light-paper WebP compositions that work in empty/error containers.

- `assets/v2/states/no-results.webp`: no search matches, no filtered products, no healthier alternative.
- `assets/v2/states/empty-list.webp`: no saved products, tasks, shopping list items, expiry records, or notifications.
- `assets/v2/states/error-retry.webp`: recoverable API/server error, not catastrophic.
- `assets/v2/states/offline.webp`: no network, offline catalog fallback, pending sync.

### Onboarding

Use square WebP scenes, legible around 240 px in a mobile onboarding stack.

- `assets/v2/onboarding/scan.webp`: barcode scan and instant product understanding.
- `assets/v2/onboarding/health.webp`: health score plus sugar/salt/fat or ingredient awareness.
- `assets/v2/onboarding/audit.webp`: shelf checking, compliance, expiry, audit workflow.
- `assets/v2/onboarding/growth.webp`: better store operations, stock health, reports, and progress.

### Health Indicators

Generate one coherent icon family. Use transparent square WebP, readable at 40 to 64 px. Same optical size, border weight, corner language, and lighting. Orange/ink foundation; warning/success colors only where semantic.

- `assets/v2/icons/health/sugar-high.webp`
- `assets/v2/icons/health/fat-high.webp`
- `assets/v2/icons/health/sodium-high.webp`
- `assets/v2/icons/health/fiber-good.webp`
- `assets/v2/icons/health/protein-good.webp`
- `assets/v2/icons/health/additive-warning.webp`
- `assets/v2/icons/health/allergen-flag.webp`
- `assets/v2/icons/health/ultra-processed.webp`

### Home And Mission Banners

Home carousel renders 16:9. Generate high-resolution assets with a quiet lower copy-safe area for the app's scrim and overlaid text. No embedded text.

- `assets/v2/illustration/home-mission-v3.jpg`: Indian retail shelf context, daily mission, product and operational value.
- `assets/v2/illustration/home-promo-consumer-v3.jpg`: consumer scanning packaged food, product-health discovery, no visible human face required.
- `assets/v2/banners/health-mission.webp`: product health, ingredient awareness, better daily choices.
- `assets/v2/banners/expiry-mission.webp`: expiry detection, shelf inspection, waste prevention, calm urgency.
- `assets/v2/banners/festive-store-pride.webp`: Indian festive retail, clean shelves, store pride, culturally restrained.

### Category Cutouts

Generate square PNG product-category cutouts for small cards. White or transparent isolated background, no text, no logos, no trademarked packaging, consistent camera angle, consistent scale.

- `assets/v2/illustrations/cat-biscuits.png`
- `assets/v2/illustrations/cat-breakfast.png`
- `assets/v2/illustrations/cat-dairy.png`
- `assets/v2/illustrations/cat-beverages.png`
- `assets/v2/illustrations/cat-personal-care.png`
- `assets/v2/illustrations/cat-household.png`
- `assets/v2/illustrations/cat-staples.png`
- `assets/v2/illustrations/cat-frozen.png`

### Subscription And Brand

- `assets/v2/plus/paywall-hero.webp`: premium intelligence, fuller product understanding, trust and aspiration. Mor may appear in Guard or Think mode. Do not make it an aggressive sales image.
- `assets/v2/brand/splash-lockup.webp`: preserve the official RADHA symbol, Hindi wordmark `राधा`, English wordmark `RADHA`, and current hierarchy. Transparent background. No spelling or symbol redesign.

## Extra Registry Paths To Resolve

These are currently missing in `RadhaAssets` but not in the user note. Treat them as a decision point after the 36 active production assets are generated:

- `assets/v2/illustrations/cat-set-8.png`: one combined eight-category reference/contact sheet.
- `assets/v2/illustrations/scan-frame.png`: scan frame illustration.
- `assets/v2/illustrations/spot-expiry.png`: spot illustration for expiry.
- `assets/v2/illustrations/spot-storehealth.png`: spot illustration for store health.

Recommendation: if the goal is a green registry test without code cleanup, generate these four too. If the goal is the leanest app bundle, remove the unused constants and stale doc references in a separate code change.

## Acceptance Checklist

- File paths and extensions match `RadhaAssets` exactly.
- Add all new asset directories or files to `radha_app/pubspec.yaml` under `flutter: assets:`.
- No embedded text except `splash-lockup.webp`.
- No fake brand logos or trademarked packaging.
- Mor anatomy is consistent with the existing master files.
- Home banners read well under the app's bottom-up ink scrim.
- Category cutouts remain readable at 64 px.
- Health badges remain readable at 48 px and do not rely on color alone.
- Run `C:/src/flutter/bin/flutter.bat analyze --no-pub` from `radha_app/`.
- Enable or add the deferred asset-registry test once missing paths are resolved.
