# Radha App

Flutter mobile app for the RADHA product-tracking and expiry-management platform.
Repo: `github.com/Shotlin/Radha-APP`

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.44.x |
| Dart | 3.12.x |
| Java | 17 (required by AGP 9) |

Devices:
- Emulator: `Pixel_9` AVD (`emulator-5554`)
- Real device: I2217 (`10BD762MCZ0003A`) — required for camera/OCR/barcode
  verification (AVD cannot exercise live ML Kit output)

## Run

```bash
# Emulator
flutter run -d emulator-5554 \
  --dart-define=API_BASE_URL=https://radha.opslin.com

# Real device
flutter run -d 10BD762MCZ0003A \
  --dart-define=API_BASE_URL=https://radha.opslin.com
```

Dev OTP (demo accounts only): **`123456`**

## Build

```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://radha.opslin.com
```

## Tests and analysis

Run both before every commit:

```bash
flutter analyze      # must add zero new issues above baseline
flutter test         # must stay 148/148 (or more) passing
```

## Code generation

After editing any `@JsonSerializable`, `@freezed`, `@riverpod`, or `retrofit`
annotated class:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Never hand-edit `*.g.dart` or `*.freezed.dart` — they are regenerated and will
be overwritten. Never edit `lib/l10n/generated/` directly.

## Key directories

```
lib/
  core/
    auth/            Auth session, OTP login, secure storage, interceptor
    network/         ApiClient (Retrofit/Dio), DTOs, api_client.g.dart
    notifications/   PushService (Firebase FCM, graceful-degradation)
    offline/         SyncService — outbox queue, Drift, connectivity
    router/          GoRouter app_router.dart
  features/
    scan/            ScanScreen (barcode, 3-read consensus),
                     BatchScanScreen (dual ML Kit),
                     LiveLabelScannerScreen (OCR date)
    expiry/          Expiry list + 4-step create wizard
    auth/            OTP login flow
    splash/          BootstrapController (cold-start sequence)
  design/            Theme (radhaLightTheme/radhaDarkTheme), shared widgets
  l10n/              ARB files; generated/ is auto-generated — never edit
test/
  features/scan/domain/   Extractor + aggregator unit tests (must stay green)
android/
  app/
    build.gradle.kts       Razorpay namespace hack + desugar — read the comments
    libs/                  razorpay-core-1.0.15-patched.aar (vendored)
```

## Push notifications

Firebase packages are present but **not yet active** — `PushService` silently
disables itself if `google-services.json` is absent; the rest of the app runs
normally. To enable:

1. Create Firebase project at `console.firebase.google.com`
2. Add Android app: package `com.radha.radha_app`
3. Download `google-services.json` → `android/app/google-services.json`
4. Add plugin to `android/app/build.gradle.kts` plugins block:
   `id("com.google.gms.google-services")`
5. Add to `android/build.gradle` plugins block:
   `id("com.google.gms.google-services") version "4.4.2" apply false`
6. Set `FCM_SERVICE_ACCOUNT_JSON` on the EC2 server

## Razorpay build notes

The `build.gradle.kts` comment block explains the AGP 9 namespace-deduplication
fix in detail. Do not remove the vendored `libs/razorpay-core-1.0.15-patched.aar`
or the `configurations.all { exclude ... }` block — they are required.
