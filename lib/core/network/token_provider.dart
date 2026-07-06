// Task 2 owns this file. This is a stub created in parallel by Task 3 so
// secure-storage-backed auth can compile. Task 2 may extend it (e.g. add
// `readUserId` or rotate-on-401 hooks); the contract below must remain stable.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read/write contract the networking layer uses to attach `Authorization`
/// headers and rotate tokens on 401. Backed in production by
/// [SessionStorage] via `sessionStorageTokenStoreProvider`.
abstract class TokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> persistTokens({required String access, required String refresh});
  Future<void> clear();
}

/// Default [TokenStore] provider. Must be overridden in `main.dart` (or in
/// tests) — usually by `sessionStorageTokenStoreProvider` from
/// `lib/core/auth/session_storage.dart`.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  throw UnimplementedError(
    'tokenStoreProvider must be overridden — wire sessionStorageTokenStoreProvider '
    'in ProviderScope.overrides at app bootstrap.',
  );
});
