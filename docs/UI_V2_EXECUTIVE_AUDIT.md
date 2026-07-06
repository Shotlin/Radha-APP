# RADHA — UI v2/v3 Executive Audit

> Authored at the start of the application-wide UI migration.
> Source-of-truth: actual Dart code in `radha_app/lib/**`, verified against the
> running toolchain. Where this contradicts older docs/memory, **the code wins**
> and the conflict is logged below.

---

## 0. Material conflicts found (logged per the conflict rules)

| # | Conflict | Resolution |
|---|----------|------------|
| C1 | Every steering doc, `CLAUDE.md`, and prior memory says the Flutter root is **`apps/mobile/`**. On this disk `apps/mobile/` is an almost-empty skeleton (`lib/l10n` + `build` only); the real, complete app lives in **`radha_app/`**. | **All migration work targets `radha_app/`.** Docs that say `apps/mobile` are stale for this checkout. |
| C2 | Prior memory records a green test suite of **186 tests**. This checkout has **no `test/` directory and zero `*_test.dart` files** under `radha_app/`. | The test suite is **absent from this copy**. The migration must (re)establish `test/` and its gate from scratch. Tests are added per phase. |
| C3 | Memory references work done under `apps/mobile/assets/...`. Real bundled assets are under **`radha_app/assets/v2/`** (41 image files present). | Asset paths in `RadhaAssets` resolve against `radha_app/`. Verified present. |
| C4 | CLAUDE.md describes a `pnpm` monorepo with `server/`, `packages/`. This checkout is **mobile-only** (`radha_app/` Flutter app; `radha_dashboard/` is a separate Next.js app). No `server/` backend source is present here. | Backend contracts are treated as **fixed external truth**; this migration is mobile-UI-only and must not assume backend edits are possible here. |
| **C5** | **`RadhaAssets` references 78 asset paths; only 38 exist on disk. The entire v3 premium set is MISSING (40 files): all Mor *scenes* (`scenes/*.webp`), all state illos (`states/*.webp`), home banners (`banners/*.webp`), onboarding (`onboarding/*.webp`), illustrated health badges (`icons/health/*.webp`), paywall hero, splash lockup, and the 8 category cutouts + `illustrations/*`.** `pubspec.yaml` only declares the legacy v2 set; the v3 dirs are neither bundled nor present. | **The premium v3 visual integration cannot be completed in this copy** — the files are absent and cannot be fabricated. Screens that reference them already degrade via `BrandedImage`/`BrandIllustration` fallbacks (no crash). The structural migration (components, layout, l10n, a11y, states, nav grammar) proceeds; v3 art is wired when the files are supplied. The asset-registry test is therefore **deferred** (it would be red against 40 absent files) until the set is restored. |

---

## 1. Baseline (run before editing)

| Item | Result |
|------|--------|
| Flutter | **3.44.0** (stable) |
| Dart | **3.12.0** |
| DevTools | 2.57.0 |
| `flutter pub get` | ✅ exit 0 |
| `flutter analyze --no-pub` | ✅ **"No issues found!"** (passes `--fatal-infos`) |
| `flutter test` | ⚠️ **"Test directory \"test\" not found"** — no tests in this copy (see C2) |
| `flutter build web --release` | ⏳ not yet run (expensive; deferred to phase gates) |
| `flutter build apk --debug` | ⏳ not yet run (deferred to phase gates) |
| Dart source | 157 files, **52,542 LOC** under `lib/` |
| l10n | 6 ARB locales present (`en hi ta te bn mr`); generated under `lib/l10n/generated/` |

**Baseline verdict:** analyzer is clean → safe to begin migration. The missing test
suite is the one baseline gap; it is rebuilt incrementally (it is *added*, never
faked-green).

---

## 2. Route inventory

All routes from `lib/core/router/app_router.dart`. The full per-route matrix
(providers, endpoints, states, a11y, l10n, migration status) lives in
[`UI_V2_ROUTE_MATRIX.md`](./UI_V2_ROUTE_MATRIX.md).

**Pre-auth / public:** `/splash`, `/onboarding`, `/auth/otp`, `/auth/otp/verify`, `/select-store`

**Shell branches (StatefulShellRoute.indexedStack):** `/home`, `/scan`, `/expiry`, `/tasks`, `/profile`

**Drill-in (root navigator, bottom-nav hidden):**
`/scan/result/:ean`, `/scan/audit`, `/scan/label`, `/expiry/new`, `/expiry-calendar`,
`/tasks/create`, `/tasks/:id`, `/inventory`, `/inventory/stock-movement`,
`/inventory/low-stock-alerts`, `/grn`, `/grn/create`, `/grn/:id`, `/grn/:id/items`,
`/settings`, `/settings/language`, `/support`, `/subscription`, `/shopping-list`,
`/recall-alerts`, `/allergens`, `/referrals`, `/ingredients/:slug`,
`/alternatives/:ean`, `/saved-products`, `/catalog/search`, `/catalog/:category`,
`/catalog/product/:key`, `/digest`, `/digest/:weekIso`, `/reports`, `/ohs`

**Route guards (preserve exactly):** auth/onboarding hydration → splash gate;
unonboarded → `/onboarding`; no session → `/auth/otp`; logged-in + has stores +
none selected → `/select-store`; consumers (no stores) → straight to `/home`.
`refreshListenable` re-fires on `authControllerProvider` / `onboardingFlagControllerProvider`.

**Entitlement-gated at the router** (via `LockedFeature`): `/inventory` (`Feature.inventory`),
`/grn` (`Feature.grn`), `/recall-alerts` (`Feature.recallAlerts`), `/allergens`
(`Feature.allergenProfile`), `/reports` & `/ohs` (`Feature.advancedReports`).

---

## 3. Entitlement model

`enum Feature` (`lib/core/entitlements/entitlement_provider.dart`): `advancedReports`,
`inventory`, `grn`, `allergenProfile`, `recallAlerts`, `weeklyDigest`,
`healthyAlternatives`, `ingredientExplainer`, `bulkScan`, `multiStore`.

Gating is enforced two ways: (a) at the router via `LockedFeature` wrapper, and
(b) in-screen for partial gates (e.g. catalog product Plus deep-dive). **Both must be
preserved** when migrating any gated screen.

---

## 4. Design foundation (already strong — preserve & build on)

| Layer | File | State |
|-------|------|-------|
| Tokens | `lib/design/tokens.dart` | **Excellent.** Matches the locked visual identity exactly (palette, 4-pt spacing, radii, motion curves `cubic(0.32,0.72,0,1)`, type scale, Plus Jakarta Sans + JetBrains Mono). `kMinTouchTarget = 44`. |
| Theme | `lib/design/theme.dart` | **Mature.** Full M3 light+dark from tokens: hairline cards (no heavy shadow), 44pt buttons, filled inputs, nav-bar theme, sheets w/ drag handle, dialogs, snackbar, chips, mono helper `radhaMonoStyle()`. |
| Assets | `lib/design/app_assets.dart` | Typed `RadhaAssets` registry (Mor moods, v3 scenes, state illos, health badges, banners, onboarding, paywall). 41 files present under `assets/v2/`. |

**Finding:** color/spacing/type tokenization is effectively **complete** — `grep`
finds **0** hardcoded `Color(0x…)` in `lib/features/**`. Phase-1 token work is therefore
*small* (sweep for recurring magic spacing/duration literals only), not a rewrite.

### Existing shared components (`lib/design/widgets/`, 16 widgets ~2k LOC)
`app_text_field`, `brand_illustration`, `branded_image`, `connectivity_banner`,
`empty_state`, `error_boundary`, `error_state`, `locked_feature`, `mor_celebration`,
`mor_companion`, `primary_button`, `secondary_button`, `section_header`,
`settings_row`, `skeleton_loader`, `snackbar_host`.

**Gap vs the target system:** missing the structural primitives —
`RadhaScreenScaffold`, primary/secondary headers, **`RadhaBottomNavigation`**,
`RadhaCard`, `RadhaKpiTile`, `RadhaListRow`/`RadhaProductRow`,
`RadhaStatusChip`/`RadhaHealthChip`, `RadhaSegmentedControl`, `RadhaFilterChip`,
`RadhaSearchField`, destructive button, `RadhaBottomSheet`/`RadhaDialog`,
`RadhaPaginationFooter`, `RadhaFormSection`, `RadhaMetric`, `RadhaMorScene`,
`RadhaOfflineState`/`RadhaLockedState` (locked exists as `LockedFeature`).

These are currently re-implemented privately inside feature screens. Consolidation
(extract where ≥2 screens share grammar) is the core architectural objective.

---

## 5. Localization status

| Locale | ARB key lines* | Status |
|--------|----------------|--------|
| en (template) | 304 | source of truth |
| hi / ta / te / bn / mr | 285 each | **~19-key gap vs template** |

\* counted as quoted top-level keys incl. placeholder objects; exact missing set must be
diffed by the planned ARB-completeness test. The gap is real and must be closed.

**Bigger gap:** only **13 of 61** feature files reference `AppLocalizations` →
~48 screens still ship hardcoded English user-facing strings. This is the single
largest cross-cutting work item (touches every phase). Nav labels (`home/scan/expiry/
tasks/profile`) and many keys already exist and are translated in all 6 locales — so
localizing the shell is unblocked today.

**Rule reaffirmed:** wire values are never translated — they map to localized display
strings. Gujarati is **not** a supported locale and must not be added.

---

## 6. Accessibility status (initial scan)

- `kMinTouchTarget = 44` enforced on themed buttons; needs per-screen verification for
  custom tap targets (esp. scanner controls, chips, icon buttons).
- Header semantics, icon-only tooltips, selected-state announcement, focus traversal,
  textScale 2.0, and reduced-motion (`MediaQuery.disableAnimations`) all need a
  systematic per-phase pass — not yet audited screen-by-screen.

## 7. Generic Material icon usage

**285** `Icons.*` references across `lib/features/**`. The brand has a partial custom
glyph set (`RadhaAssets.icon*`) but it is raster/illustrative (not tintable for
active/inactive nav states). Strategy: a **unified `RadhaGlyph`/icon treatment**
(consistent optical size + active/inactive behavior) rather than mixing raster
illustrations into chrome. The bottom nav is the first conversion.

## 8. State-handling & known functional risks

- Cursor pagination + load-more-error-row preservation already implemented for
  inventory/tasks/GRN (per prior hardening). **Preserve.**
- Offline Drift queue, sync banners, connectivity banner wired into `root_shell`.
  **Preserve positioning.**
- Honest "assessment pending / scan to unlock" states already exist in catalog/product.
  **Preserve — never fabricate health/operational data.**
- **Risk:** no automated tests in this copy → regressions during migration are
  invisible until tests are rebuilt. Mitigation: rebuild the test gate early.

---

## 9. Migration plan (phases) & this-session progress

Phases 1–10 tracked in the session task list. See
[`UI_V2_ROUTE_MATRIX.md`](./UI_V2_ROUTE_MATRIX.md) for per-route status and
[`UI_V2_HANDOFF.md`](./UI_V2_HANDOFF.md) for the exact next steps while work is
in-flight.

**Done this session:** baseline recorded; audit + route matrix authored; Phase-1
batch-1 (bottom-navigation grammar + test directory established). Details in handoff.
