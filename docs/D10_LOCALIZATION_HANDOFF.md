# D10 Localization Sweep — Handoff

**Date:** 2026-06-15
**Author:** Claude Code (Opus 4.8) session
**Branch:** `codex/radha-production-convergence` @ `a622bc3` (working tree, uncommitted)
**Scope of this session:** mobile D10 localization sweep (`radha_app`) + Razorpay webhook-secret wiring
**Status:** ✅ All 7 owner-named screens fully localized & analyzer-green. **Not committed** (owner reviews per-screen).

---

## 0. TL;DR

- Localized **7 mobile screens** end-to-end across **all 6 locales** (en, hi, ta, te, bn, mr) with **real, hand-written translations** — *not* English stubs.
- Added **~178 new ARB keys** (incl. 11 ICU plurals), wired every screen, regenerated `flutter gen-l10n`, and verified each screen with `flutter analyze` → **No issues found**. Final combined analyze of all 7 feature dirs + `lib/l10n` is clean.
- Wired the Razorpay **test keys + webhook secret** into `radha_backend/.env.development` (gitignored) so the owner can verify the webhook signature path.
- **Nothing is committed** — this is a clean, reviewed-per-screen stopping point. 20 files modified (7 screens, 6 ARBs, 7 generated l10n files).

---

## 1. Environment / ground truth (verified this session)

| Thing | Reality |
|---|---|
| Canonical mobile tree | **`radha_app/`** (the `apps/mobile/lib/l10n` dir is empty — do **not** edit it) |
| Real backend dir | **`radha_backend/`** (pkg `@radha/radha_backend`), *not* `server/` |
| Dev env file NestJS loads | **`.env.development`** (not `.env`) when `NODE_ENV=development` |
| l10n generator | `flutter gen-l10n` (config `radha_app/l10n.yaml`; output `lib/l10n/generated/`) |
| Locales | en (template), hi, ta, te, bn, mr |
| Flutter | 3.44.0 stable, available on PATH |

**Key discovery:** the non-English ARBs were only *partially* translated before this sweep — older atoms had real translations, but many newer keys had been appended **English-only** (locale files were ~471 keys vs en ~532; the gap is pre-existing English-fallback keys, untouched here). The "6 locales wired" claim is structurally true but **translation coverage is still partial** outside the screens swept this session.

---

## 2. ✅ What was completed

### 2.1 Razorpay webhook secret (owner-requested)
- File: `radha_backend/.env.development` (confirmed gitignored via `git check-ignore`). The three Razorpay TEST values were written into that local, gitignored file only — **variable names only are recorded here**, never the values: `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`.
- 🔐 **SECURITY:** the TEST credentials originally pasted in chat are **considered exposed and must be rotated** in the Razorpay dashboard, then re-entered into the gitignored env locally. Do not paste secret values into chat, handoffs, or any tracked file. Status only: `CONFIGURED` / `MISSING`.
- ⚠️ **Caveat the owner must confirm:** the value supplied was an API key **secret**, not a dedicated webhook secret. For real Razorpay *test webhooks* to verify, `RAZORPAY_WEBHOOK_SECRET` must equal the value configured in **Razorpay Dashboard → Settings → Webhooks** (a separate credential from the API secret). If they differ, swap it. The HMAC-SHA256 signature path lives in `radha_backend/src/integrations/razorpay/providers/razorpay-live.provider.ts`.

### 2.2 D10 screen sweep — all 7 owner-named screens (one green unit each)

| # | Screen file | New keys | Notes |
|---|---|---|---|
| 1 | `lib/features/expiry/expiry_list_screen.dart` | 18 | tabs, pills (Today/Tomorrow/`{days}d`/Soon), empty/error states |
| 2 | `lib/features/inventory/inventory_list_screen.dart` | 17 | search, action buttons, units, `{count} units`, low-stock badge |
| 3 | `lib/features/tasks/tasks_list_screen.dart` | 18 | **shared severity labels** + status mapper (kills raw-enum display) |
| 4 | `lib/features/scan/scan_screen.dart` | 24 | camera UI, web fallback, manual-entry sheet, history sheet |
| 5 | `lib/features/home/home_screen.dart` | ~55 | **ICU plurals**, Hinglish brand voice, KPIs, story banner, carousel |
| 6 | `lib/features/onboarding/onboarding_screen.dart` | 22 | 3 pages incl. 6 persona cards (text + a11y semantics) |
| 7 | `lib/features/allergen/allergen_profile_screen.dart` | 24 | 15 canonical allergen tags + plural counter |

**Total: ~178 new keys**, each present in **all 6 locale files** with genuine translations.

### 2.3 Quality decisions worth knowing
- **Reuse over duplication:** reused existing translated atoms where they fit — `add`, `tryAgain`, `expired`, `expiryTracker`, `save`, `profile`, `scanTitle`, `expiry`, `inventoryTitle`, `taskStatusOpen`, `appName`, `tagline`, `getStarted`, `continueLabel`.
- **Shared severity/status labels (tasks_list):** introduced generic `priorityHigh/Medium/Low/Urgent` and `taskStatus{Open,Pending,InProgress,Completed,Cancelled}`, resolved via top-level `_priorityLabel()` / `_statusLabel()` mappers. **No raw backend enum reaches the UI anymore** (was previously shown by capitalizing the wire string). Reuse these on any other screen showing priority/status.
- **ICU plurals (11 total):** `homeTrialDaysLeft`, `homeStoryRecall`, `homeStoryNearExpiryConsumer`, `homeStoryNearExpiryBusiness`, `homeStoryOpenTasks`, `homeStoryLowStock`, `allergenTracked` (+ the compact `{days}d`/`{count} units` placeholders). Verified generating correctly (e.g. `String homeStoryRecall(int count)`).
- **Hinglish brand voice preserved:** `homeEyebrowToday` ("AAJ KA KAAM · TODAY"), `homePromoBazaarEyebrow` ("AAJ KA BAZAAR"), `homeStoreAllGood` ("Shabaash!…") kept as brand voice in **English**, translated naturally in the other 5 locales.
- **`const` → l10n-builder refactors:** onboarding's `const _segmentChoices` became `_segmentChoices(AppLocalizations l10n)`; allergen labels resolved via a top-level `allergenLabel(l10n, option)` mapper (the `const kAllergenOptions` keeps English labels as a graceful fallback for other consumers / unmapped tags).

### 2.4 Verification performed
- `flutter gen-l10n` after every screen → clean.
- `flutter analyze <screen>` per screen → **No issues found** (×7).
- Final combined `flutter analyze` over all 7 feature dirs + `lib/l10n` → **No issues found**.
- Leftover-literal grep on `home_screen.dart` → empty.
- ⚠️ **Not run:** `flutter test` (widget tests), on-device/manual locale switching, screenshot review. Recommended before release (see §4).

---

## 3. 📁 Files changed (20, all uncommitted)

```
M  radha_app/lib/features/allergen/allergen_profile_screen.dart
M  radha_app/lib/features/expiry/expiry_list_screen.dart
M  radha_app/lib/features/home/home_screen.dart
M  radha_app/lib/features/inventory/inventory_list_screen.dart
M  radha_app/lib/features/onboarding/onboarding_screen.dart
M  radha_app/lib/features/scan/scan_screen.dart
M  radha_app/lib/features/tasks/tasks_list_screen.dart
M  radha_app/lib/l10n/app_{en,hi,ta,te,bn,mr}.arb            (6)
M  radha_app/lib/l10n/generated/app_localizations*.dart      (7, regenerated)
```
Plus `radha_backend/.env.development` (gitignored — will **not** appear in `git status`).

**Suggested commit grouping** (when owner approves): one commit for the env (or skip — it's gitignored), then either one commit per screen (matches the per-screen review cadence) or a single `feat(l10n): D10 sweep — 7 screens × 6 locales` commit. The generated `lib/l10n/generated/*` must be committed alongside the ARBs.

---

## 4. ⏭️ What remains

### 4.1 Localization (D10/D12) — still open
- **~12+ other mobile screens still hardcoded.** Not yet swept (non-exhaustive): the rest of the **scan flow** (`scan_result_screen.dart` ~1064 lines, `label_scan_screen.dart`, `label_camera_screen.dart`, `ean_audit_screen.dart`), plus auth/OTP, select-store, settings, profile, subscriptions, GRN, shopping list, referrals, support, reports, recall detail, product detail, etc. Reuse the conventions in §5.
- **`home_catalog.dart` category labels** (8 entries: "Biscuits & Snacks", "Dairy & Eggs", …) — a `const` data list, needs a keyed refactor of the data layer. Excluded from the home screen unit on purpose.
- **Date formatters** in `tasks_list_screen.dart` (`_formatDate`) and `scan` use a **hardcoded English month-abbreviation list**. Convert to locale-aware `intl.DateFormat.MMMd(localeName)` in a follow-up.
- **Shared-key consolidation:** `expiryCouldNotLoadSemantic` is now reused cross-screen as the generic "Could not load" Mor label. Rename to a neutral `commonCouldNotLoad` during a shared-label cleanup.
- **D12 accessibility pass not done:** text-scale (1.0/1.3/2.0), TalkBack, contrast, target-size, focus traversal, reduced-motion across the localized screens. ARB **placeholder parity** is satisfied for the new keys but a full parity linter hasn't been run on the whole file.

### 4.2 Dashboard D3/D4 (from the owner's original brief, not started this session)
- D3 expiry scope-type intent; D4 Playwright install + E2E; typecheck/lint/vitest/build; rollup-only reads. Lives in `radha_dashboard/`.

### 4.3 The executive re-prioritization (important context)
The owner's "Executive decision" message re-ranked priorities **away from localization-first** toward: (1) product-data & scan-result correctness, (2) Gemini production hardening + structured output + model routing, (3) scan-vs-inventory write correctness, (4) tenant encryption + privacy-safe dashboard, (5) DB indexing/queues/caching, then mobile/frontend/dashboard/release. That large program was explicitly addressed to **Codex** (the "supreme execution prompt"); **this session deliberately stayed in the localization lane the owner's first line assigned.** If the next session is Claude Code, confirm whether to continue l10n or pivot.
- Also flagged: **branch divergence** — this tree is `codex/radha-production-convergence` @ `a622bc3`, but the executive prompt names canonical `codex/radha-final-convergence` @ `53fae0b`. Reconcile before Codex runs. The `PROGRAM_STATE.json` referenced in the brief is **not present in this copy** (it lives on the canonical branch).

---

## 5. 🔧 How to resume the l10n sweep (conventions)

For each screen:
1. Read the screen; catalog every user-facing literal (incl. `Semantics` labels, tooltips, snackbars, hint/label text).
2. **Reuse** an existing translated key if one fits; otherwise add a new screen-prefixed key.
3. Add the key to **`app_en.arb`** (template) with `@`-metadata for any placeholder/plural key; then add real translations to **all 5** locale files (hi, ta, te, bn, mr) — never leave an English stub.
4. ICU plural form: `"key": "{count, plural, =1{…} other{{count} …}}"` + `@key` placeholder `{ "count": { "type": "int" } }`. Keep the plural structure identical across locales.
5. Wire the Dart: `import 'package:radha_app/l10n/generated/app_localizations.dart';`, `final l10n = AppLocalizations.of(context);`, replace literals. For `const` data lists, convert to an `(AppLocalizations l10n)` builder or a top-level mapper.
6. Verify: `flutter gen-l10n` → `flutter analyze lib/features/<area>/<screen>.dart` → expect **No issues found**.
7. Compact mono pills keep latin units (`{days}d`); brand Hinglish stays English in `en`, translated elsewhere.

**Run from:** `radha_app/` (`cd` there). Do not run watchers/dev-servers from agent tools.

---

## 6. Owner action items
1. **Confirm the webhook secret** matches the Razorpay dashboard value (§2.1), then verify the signature path.
2. **Decide commit grouping** and whether to commit now (clean stopping point).
3. **Decide next lane:** finish remaining l10n screens, pivot to the executive product-data/Gemini program (Codex), or dashboard D3/D4.
4. **Reconcile branch divergence** (§4.3) before the Codex program runs.

---
*Companion to `docs/UI_V2_HANDOFF.md`. This file documents only the D10 localization session of 2026-06-15.*
