# RADHA Mobile (Flutter)

The consumer + staff + manager surface for RADHA. Talks to the NestJS backend (`server/`) via a typed Retrofit client over Dio. Built per `.kiro/specs/radha-platform-design/`.

- **Flutter** 3.44 / **Dart** 3.12
- **State**: Riverpod 2.5+
- **Navigation**: GoRouter 14+
- **HTTP**: Dio 5 + Retrofit 4 + `dio_smart_retry`
- **Offline**: Drift (SQLite) + `connectivity_plus`
- **Auth**: `flutter_secure_storage`, OTP via backend `/auth/otp/*`
- **Camera + OCR**: `mobile_scanner` 5+, `google_mlkit_text_recognition` 0.13+
- **Theme**: Material 3 + custom design tokens (Plus Jakarta Sans + JetBrains Mono, single emerald accent)

The full backlog and current state is in `.kiro/specs/radha-platform-design/tasks.md` (23 tasks, all complete in this build).

## Quick start

From the workspace root, in one terminal:

```cmd
docker compose up -d        :: Postgres 5433 + Redis 6380
pnpm install
pnpm server:dev             :: NestJS API on :3000
```

In a second terminal, launch the app on Chrome via the convenience script:

```cmd
apps\mobile\tool\start_dev.bat
```

That script verifies Docker is up, reminds you to start the backend, and runs:

```cmd
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

For Android emulator the loopback to the host is `10.0.2.2`:

```cmd
cd apps\mobile
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

For iOS simulator (macOS only) `localhost` is shared with the host.

## Folder layout

```text
apps/mobile/
  lib/
    core/                     # network, auth, router, offline, entitlements
    design/                   # tokens, theme, reusable widgets
    features/                 # one folder per task: splash, onboarding, auth, home,
                              #   scan, product, expiry, tasks, inventory, grn,
                              #   subscription, allergen, recall, shopping_list,
                              #   referrals, settings, sync
  integration_test/           # auth_flow, scan_flow, expiry_flow + harness
  test/                       # unit + widget tests (co-located by feature)
  tool/
    start_dev.bat             # Windows convenience launcher
    gen_brand.ps1             # brand-asset generator
  android/  ios/  web/  windows/   # platform projects
  pubspec.yaml
```

## Development commands (from `apps/mobile/`)

```cmd
flutter pub get                                      :: deps
flutter pub run build_runner build --delete-conflicting-outputs  :: codegen (Retrofit, Drift, Freezed, JSON)
flutter analyze --fatal-infos                        :: lint
flutter test                                         :: unit + widget tests
flutter test integration_test                        :: integration tests
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## Manual testing

End-to-end manual smoke testing is driven through two MCP servers configured at `.kiro/settings/mcp.json`:

- `mobile-mcp` — Android emulator, iOS simulator, real devices.
- `playwright` — Flutter Web in Chromium.

The full per-task checklist with exact taps and expected backend hits lives at:

> [`MOBILE_MANUAL_TEST_CHECKLIST.md`](../../MOBILE_MANUAL_TEST_CHECKLIST.md) (workspace root)

That document covers all 23 tasks with:

- Pre-flight setup (Docker, backend, Chrome / Android emulator / iOS simulator runs).
- Per-task smoke flow (what to test, expected outcome, backend endpoints hit, MCP recipe).
- MCP tool usage examples for both servers.
- Anti-slop visual verification checklist.
- Known limitations (camera in headless Chrome, push, OCR fallback).

## Automated testing

- **Unit + widget tests**: `flutter test` from `apps/mobile/`. Tests live alongside source (`*_test.dart`).
- **Integration tests**: `flutter test integration_test/` runs `auth_flow_test.dart`, `scan_flow_test.dart`, `expiry_flow_test.dart`. They use `dio_mock_adapter` so a live backend is not required.
- **Static analysis**: `flutter analyze --fatal-infos`. Current baseline is **0 issues**.

## Configuration

The single build-time knob is `API_BASE_URL`:

| Target               | Value                                  |
|----------------------|----------------------------------------|
| Chrome (web)         | `http://localhost:3000/api/v1`         |
| Android emulator     | `http://10.0.2.2:3000/api/v1`          |
| iOS simulator        | `http://localhost:3000/api/v1`         |
| Real device on LAN   | `http://<host-LAN-ip>:3000/api/v1`     |

Pass it via `--dart-define=API_BASE_URL=...` to `flutter run` or `flutter build`.

## Troubleshooting

- **App stuck on splash** — backend is not reachable. `curl http://localhost:3000/api/v1/health` should return `{"success":true,...}`. On Android emulator confirm you used `10.0.2.2`, not `localhost`.
- **OTP never arrives** — in dev mode the OTP is `123456` (`OTP_PROVIDER=dev`). Check the server logs for the `[otp.dev]` line.
- **`flutter analyze` fails** — run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Retrofit / Drift / Freezed code, then re-run analyze.
- **Drift schema errors after editing tables** — same fix: regenerate via build_runner.
- **MCP server not visible** — confirm `.kiro/settings/mcp.json` (workspace) and `~/.kiro/settings/mcp.json` (user-global) both have `mobile-mcp` and `playwright` entries with `disabled: false`.
