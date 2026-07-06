# RADHA — Production Convergence Audit (Wave 0)

Authoritative baseline established **from Git**, per the convergence mandate's Step 0.
Where the mandate's expectations and the repository disagree, **Git wins** (source-of-truth
priority #1) and the divergence is logged.

## Step 0 — repository ground truth (Git-verified)

| Probe | Result |
|---|---|
| Repo root | `…/RADHA_UPGRADED_PROJECT_FILES/` (the outer `…new/` wrapper is **not** a repo) |
| Branch (work) | `codex/radha-production-convergence` (created off `main`) |
| `main` history | `ba818fd add` · `bd4710b upgrade` · `1bfecc5 Initial commit` (3 commits) |
| Tracked `pubspec.yaml` | **only `radha_app/pubspec.yaml`** |
| `git ls-files apps/mobile/**` | **0** → `apps/mobile/` is untracked/empty, **NOT canonical** |
| `git ls-files radha_app/**` | **318** → canonical Flutter project |
| `git ls-files server/**` | **0** → **no backend in this repo** |
| `git ls-files -d` (tracked-but-missing) | **0** → working tree is complete vs HEAD; nothing hidden to restore |

### Divergences from the mandate's stated expectations
1. **Canonical root is `radha_app/`, not `apps/mobile/`.** Git proves it (sole tracked
   pubspec, 318 files). The mandate's "expected canonical root: apps/mobile" does not hold
   for this repository. All work targets `radha_app/`. No duplicate canonical app exists to
   reconcile — `apps/mobile/` is empty cruft and was left untouched (removing untracked
   local files is destructive and adds nothing).
2. **No `server/` backend is present or tracked.** Therefore the backend baseline
   (`pnpm install/build/eslint/test`), backend end-to-end verification (Priorities 1–3),
   and backend load tests (Wave 17) **cannot be executed in this checkout** — recorded as
   blockers, not failures. Mobile-side client truth and mocked-HTTP integration tests *are*
   executed.
3. **No web platform.** `flutter build web --release` → *"This project is not configured
   for the web."* RADHA is mobile-only; web was never scaffolded.

### Safety protocol (done)
- Safety branch `codex/radha-production-convergence` created off `main`.
- Pre-existing migration work committed as a safety checkpoint (commit on branch).
- An external auto-commit process is active on this repo (terse "add" messages); it
  checkpointed the staged work. Harmless, noted.

## Baseline commands (from `radha_app/`)

| Step | Result |
|---|---|
| Flutter / Dart | **3.44.0** / **3.12.0** (DevTools 2.57.0) |
| Node / pnpm | **N/A** — no backend in repo |
| `flutter pub get` | ✅ exit 0 |
| `flutter gen-l10n` | ✅ (driven by `l10n.yaml`; generates `lib/l10n/generated/`) |
| `dart run build_runner build --delete-conflicting-outputs` | ✅ **310 outputs in 70s**, and **produced zero git diff** (committed `.g.dart` already consistent) |
| `flutter analyze --fatal-infos` | ✅ **"No issues found!"** |
| `flutter test` | ✅ **15/15 pass** (suite was **absent from the repo**; rebuilt from zero — see below) |
| `flutter build apk --debug` | ✅ success (`app-debug.apk` built in ~135s; release arm64 artifact on disk ≈ **48.7 MB**) |
| `flutter build web --release` | ⛔ **N/A** — project not web-configured |
| `pnpm build` / `eslint` / `pnpm test` | ⛔ **N/A** — no backend |

### Test suite reality
The repo tracks **3 test files — the ones authored in this work** (`test/design/*`). There
is **no pre-existing/historical test suite** in this repository (the "186 tests" referenced
in older notes belong to a different working copy and are not in Git here, confirmed by
`git ls-files -d` = 0). The suite is being **rebuilt** per wave. Current: **15 tests**
(bottom-nav behavior + a11y, theme/token integrity, status-chip tones, **catalog source
classification: live / offline / unavailable / unresolved-category**).

### Asset registry
`RadhaAssets` references **78** paths; **38 exist on disk, 40 are absent and untracked**
(the entire v3 premium set). Per the hybrid asset strategy (Tier A/B/C), this is **not a
blocker** — Tier-B v2 assets + Tier-C branded/code fallbacks cover those surfaces. See
[`RADHA_ASSET_DECISION_MATRIX.md`](./RADHA_ASSET_DECISION_MATRIX.md) (to be filled per wave).

### Localization completeness
`app_en.arb` 304 keys; `hi/ta/te/bn/mr` 285 each (~19-key gap to diff & translate). Only
13/61 feature files use `AppLocalizations`. Wave 14 closes this; an ARB-completeness test is
deferred until the gap is closed (so it lands green).

## Environment limitations (blockers recorded, work continues)
- **No backend** → no live endpoint verification; no DB seed; no Razorpay live flow; no
  backend load tests. Client behavior is verified with **mocked HTTP / fake ApiClient**.
- **No device/emulator attached in this session** → no DevTools profile traces; performance
  work is code-level + documented hypotheses, not measured (`RADHA_PERFORMANCE_REPORT.md`
  will mark measured vs hypothesised).
- **No web platform** → web build excluded.
- **No Sentry/APM configured** → observability added as structured `developer.log`
  (PII-free) at the client; APM wiring is a backend/ops task.

## Work landed this wave-set (green)
- **Wave 0**: canonicalization + baseline (this doc).
- **Priority-1 / Wave 2 (started): catalog browse honesty.** `product_browse_providers.dart`
  no longer swallows catalog failures silently — it classifies a `CatalogSource`
  (`live` / `offline` / `unavailable`), logs PII-free structured failures
  (`radha.catalog`), and the browse screen shows an honest non-blocking banner + **Retry**
  while still serving the bundled catalog. 5 mocked tests cover the classification.
- **Shared UI**: `RadhaBottomNavigation` (replaced generic Material nav), `RadhaStatusChip`
  (supersedes 7 private chips).

See [`RADHA_FUNCTIONAL_COVERAGE_MATRIX.md`](./RADHA_FUNCTIONAL_COVERAGE_MATRIX.md) for the
per-feature client-truth classification and [`UI_V2_HANDOFF.md`](./UI_V2_HANDOFF.md) for the
ordered next steps.
