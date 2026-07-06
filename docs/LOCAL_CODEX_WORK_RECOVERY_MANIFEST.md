# Local Codex Work — Recovery Manifest (Phase 0)

Captured **before** any fetch/reset/rebase, per the sprint's Phase 0 safety rule.

## Repository identity
- **Local repo root:** `C:/Users/sayan/Downloads/RADHA_UPGRADED_PROJECT_FILES new/RADHA_UPGRADED_PROJECT_FILES`
  (the outer `…new/` wrapper is **not** a git repo).
- **Remote origin:** `https://github.com/Souvik988/RADHA_UPGRADED_PROJECT_FILES.git`
  ✅ matches the expected RADHA repository (not a stop condition).
- **Local branch:** `codex/radha-production-convergence`
- **Local HEAD:** `585c2f0ad9d31c06a15511fb94dd5035dae73ab3`
- **Working tree:** clean (`git status --short` empty) — all work is committed.

## Commit graph (local, pre-fetch)
```
* 585c2f0 (HEAD -> codex/radha-production-convergence) UI v2 foundation (nav, chip, tests, docs)
* 98209f6 Wave 0-2: convergence baseline + catalog source honesty
| * b24cbd6 (main) add            ← sibling; reachable from local `main`
|/
* ba818fd add                     ← DESTRUCTIVE: replaced monorepo tree with radha_app/ only
* bd4710b (origin/main, origin/HEAD) upgrade   ← canonical monorepo (apps/mobile + server + packages)
* 1bfecc5 Initial commit
```

## Reported commits — existence & reachability
| Commit | Exists in object DB | Reachable from | Note |
|---|---|---|---|
| `585c2f0` | ✅ | HEAD (this branch) | foundation work |
| `98209f6` | ✅ | HEAD ancestor | catalog source honesty + convergence docs |
| `b24cbd6` | ✅ | local `main` | earlier (orphaned-then-re-rooted) foundation snapshot |
| `b0d3ea4` | ✅ (unreachable) | — (dangling) | external-tool artifact ("all"); also captured by the bundle |

`git fsck --no-reflogs --unreachable`: unreachable commit `b0d3ea4`, unreachable tree
`048a9c9` — both preserved in the `--all` bundle.

## Repository nature (resolved)
This is a **clone** of origin whose **local branches contain a divergent partial export**:
`ba818fd` ("add") deleted the canonical monorepo (`apps/mobile/`, `server/`, `packages/`,
`pnpm-workspace.yaml`) and committed a standalone `radha_app/` tree (329 tracked files).
`origin/main` (`bd4710b`) still holds the **canonical monorepo** — verified:
`git ls-tree origin/main` contains `apps/mobile/pubspec.yaml`, `pnpm-workspace.yaml`,
`server/package.json`. So:

- **Canonical Flutter root = `apps/mobile/`** (on origin/main), not `radha_app/`.
- **Canonical backend root = `server/`** (on origin/main) — a backend **does** exist.
- My branch is a content-divergent line; merging it onto main would delete the monorepo.
  → Reconcile via **CASE B** (clean worktree from origin/main, port file-by-file).

> Corrects the earlier sessions' conclusion ("radha_app is canonical, no backend"): that
> was true only of this diverged local branch, never of the real remote.

## Safety artifacts (created, verified to exist)
| Artifact | Path | Size |
|---|---|---|
| Full Git bundle (`--all`, all refs incl. dangling) | `../radha-codex-local-safety.bundle` | ~496 MB |
| Working-tree patch (`git diff --binary`) | `../radha-codex-working-tree.patch` | 0 bytes (clean tree) |
| Commit patch series (`ba818fd..HEAD` = my 2 commits) | `../radha-codex-format-patches/000{1,2}-*.patch` | 2 files |

> Note: `git format-patch --root` was intentionally scoped to `ba818fd..HEAD` (my actual
> work) instead of the literal `--root`. `--root` would emit the entire history including a
> multi-hundred-MB initial commit (tracked APK binaries under `app_apks/*.apk`); the `--all`
> bundle already captures the complete history+dangling objects compactly, so it is the
> authoritative recovery artifact. Restore with: `git clone radha-codex-local-safety.bundle <dir>`.

## ⚠️ Active hazard
An external auto-commit/reset tool operates on this repo (terse "add" commits; reflog shows
`reset: moving to ba818fd` / `b24cbd6`). It can move local refs underneath in-progress work.
The bundle + patches freeze the current state regardless. Verify HEAD after each commit.
