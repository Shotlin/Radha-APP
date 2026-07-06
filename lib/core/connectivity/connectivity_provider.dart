// Connectivity provider.
//
// Single Riverpod handle the UI layer can watch to learn whether the device
// is reachable. Backed by `connectivity_plus`.
//
// Why a dedicated provider:
//   * `SyncBootstrap` (lib/core/offline/sync_service.dart) already listens
//     to the same plugin internally so it can re-drain the queue on
//     online → offline → online transitions, but its subscription is
//     one-shot for side effects and not exposed to widgets.
//   * The connectivity banner (lib/design/widgets/connectivity_banner.dart)
//     and any future "you're offline" affordances need a stream they can
//     observe with `ref.watch`. This provider is that surface.
//
// Behaviour:
//   * Emits the current `List<ConnectivityResult>` immediately so consumers
//     don't sit in `AsyncLoading` while the platform settles.
//   * Subscribes to `onConnectivityChanged` and yields each transition.
//   * When the underlying plugin throws (e.g. test runners without a
//     platform binding), falls back to an empty result list which the
//     consumers treat as "offline" — fail-closed by design.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the live connectivity result list from `connectivity_plus`.
///
/// Consumers should call [isOffline] on the emitted value rather than
/// reading the list directly so that "no result" and "result list contains
/// only `none`" both round-trip to the same offline verdict.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  // Initial probe — emit a synchronous-ish first value so the UI can render
  // an answer on the very first frame. If the probe fails, treat as offline.
  try {
    final initial = await Connectivity().checkConnectivity();
    yield initial;
  } catch (_) {
    yield const <ConnectivityResult>[];
  }

  // Subscribe to ongoing transitions. The plugin emits a fresh value on
  // every connectivity change.
  try {
    yield* Connectivity().onConnectivityChanged;
  } catch (_) {
    // Platform binding unavailable (e.g. unit tests without a fake plugin).
    // The initial value above is the best we can offer.
  }
});

/// Returns `true` when the supplied list represents an offline device.
///
/// `connectivity_plus` 6.x emits a list because a device may report multiple
/// active radios at once (Wi-Fi + cellular). We're offline only when every
/// entry is `ConnectivityResult.none` (or the list is empty).
bool isOffline(List<ConnectivityResult> results) {
  if (results.isEmpty) return true;
  return results.every((r) => r == ConnectivityResult.none);
}
