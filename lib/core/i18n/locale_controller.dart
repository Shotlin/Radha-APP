// Locale controller (Task 19 — consumes BE-42).
//
// Owns the user-selected app locale. Persists the choice to secure storage
// under `user_language` so re-opens of the app remember the language. The
// router and `MaterialApp.router` watch the controller's `Locale` state and
// rebuild automatically on change — no widget-level locale plumbing needed.
//
// Wire contract for BE-42 (`PUT /api/v1/user/language`): one of `en`, `hi`,
// `ta`, `te`, `bn`, `mr`. Anything else is rejected by the controller's
// `setLocale` so we never push an unsupported value over the network.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The six languages RADHA ships with on day one. Order matches the picker
/// so the displayed list is deterministic across builds.
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('hi'),
  Locale('ta'),
  Locale('te'),
  Locale('bn'),
  Locale('mr'),
];

/// Default app locale before the user makes a choice or before the persisted
/// preference has been read.
const Locale kDefaultLocale = Locale('en');

/// Storage key used by both the controller and `SessionStorage` if it ever
/// needs to read the value back. Kept as a top-level constant so callers
/// don't have to reach into the controller's private state.
const String kUserLanguageKey = 'user_language';

/// Returns `true` when [code] is one of the six supported language subtags.
bool isSupportedLanguageCode(String code) =>
    kSupportedLocales.any((l) => l.languageCode == code);

/// Resolves an arbitrary [code] (typically read from storage or pushed from
/// the backend) to the closest supported [Locale]. Falls back to
/// [kDefaultLocale] when the code is `null`, empty, or unsupported.
Locale resolveSupportedLocale(String? code) {
  if (code == null || code.isEmpty) return kDefaultLocale;
  for (final locale in kSupportedLocales) {
    if (locale.languageCode == code) return locale;
  }
  return kDefaultLocale;
}

/// Riverpod [StateNotifier] that owns the app's current [Locale]. Rebuilds
/// `MaterialApp.router` whenever the locale changes. Persistence is async
/// but the in-memory state updates synchronously so the UI flips
/// immediately.
class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._storage) : super(kDefaultLocale) {
    // Hydrate from storage on construction. Errors are silently swallowed —
    // there's no useful recovery path beyond falling back to English, and
    // we already initialised state to the default.
    _hydrate();
  }

  final FlutterSecureStorage _storage;

  /// Set to `true` once the user has explicitly chosen a locale via
  /// [setLocaleByCode]. Guards against the late-arriving hydration callback
  /// clobbering an explicit selection if the user picks a language before
  /// the storage read finishes.
  bool _userOverridden = false;

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.read(key: kUserLanguageKey);
      // Bail if the user already picked a locale while we were waiting on
      // storage — their choice wins over whatever was persisted previously.
      if (_userOverridden || !mounted) return;
      final resolved = resolveSupportedLocale(raw);
      if (resolved != state) {
        state = resolved;
      }
    } catch (_) {
      // Secure storage can throw on cold start before keystore is ready —
      // keep the default locale and let the next read attempt succeed.
    }
  }

  /// Updates the in-memory locale and persists the language code to secure
  /// storage. Returns silently if [code] isn't one of the six supported
  /// values so callers can hand untrusted input through without a guard.
  Future<void> setLocaleByCode(String code) async {
    if (!isSupportedLanguageCode(code)) return;
    _userOverridden = true;
    final next = Locale(code);
    if (state == next) return;
    state = next;
    try {
      await _storage.write(key: kUserLanguageKey, value: code);
    } catch (_) {
      // Best-effort persistence; in-memory state has already flipped.
    }
  }

  /// Convenience overload that takes a [Locale] directly.
  Future<void> setLocale(Locale locale) => setLocaleByCode(locale.languageCode);
}

/// Riverpod handle for the [FlutterSecureStorage] instance the controller
/// persists to. Exposed as a separate provider so tests can override it
/// with an in-memory fake.
final localeStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Global handle for the locale controller. `MaterialApp.router` watches
/// this and feeds the value into its `locale` argument.
final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
      return LocaleController(ref.watch(localeStorageProvider));
    });
