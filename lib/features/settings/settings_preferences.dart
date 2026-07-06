// Settings preferences (FE-32 / FE-33).
//
// Owns the lightweight client-side preferences surfaced from the Settings
// hub: notification toggles, theme mode, and text-size scaler. All three
// persist to flutter_secure_storage so the values survive app restarts.
//
// Wiring contract:
//   * `themeModeProvider`  — read by `MaterialApp.router.themeMode` in
//     `main.dart`. Watching it rebuilds the entire app shell so theme
//     swaps apply instantly without a navigation hop.
//   * `textScaleProvider`  — wrapped around `MaterialApp` via a builder
//     that injects the user's preferred scaler into `MediaQuery`.
//   * `notificationPrefsProvider` — read by FCM glue (later task) to gate
//     which channels the app subscribes to. Today the toggles only flip
//     local UI state; FCM hooks come later.
//
// All three controllers degrade gracefully when secure storage is
// unavailable (e.g. test runners without keystore) — they keep an
// in-memory fallback so the UI still works.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── Storage keys ──────────────────────────────────────────────────────────

/// Key under which the serialised [NotificationPrefs] is persisted.
const String kNotificationPrefsKey = 'settings_notification_prefs';

/// Key under which the [ThemeMode] index is persisted (`0=system`, `1=light`,
/// `2=dark`).
const String kThemeModeKey = 'settings_theme_mode';

/// Key under which the [TextScalePreference] index is persisted (`0=small`,
/// `1=standard`, `2=large`).
const String kTextScaleKey = 'settings_text_scale';

// ─── Notification prefs ────────────────────────────────────────────────────

/// User-toggleable notification channels surfaced in the Settings hub.
@immutable
class NotificationPrefs {
  const NotificationPrefs({
    this.pushEnabled = true,
    this.recallAlerts = true,
    this.weeklyDigest = false,
  });

  final bool pushEnabled;
  final bool recallAlerts;
  final bool weeklyDigest;

  NotificationPrefs copyWith({
    bool? pushEnabled,
    bool? recallAlerts,
    bool? weeklyDigest,
  }) {
    return NotificationPrefs(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      recallAlerts: recallAlerts ?? this.recallAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'pushEnabled': pushEnabled,
    'recallAlerts': recallAlerts,
    'weeklyDigest': weeklyDigest,
  };

  static NotificationPrefs fromJson(Map<String, Object?> json) {
    return NotificationPrefs(
      pushEnabled: (json['pushEnabled'] as bool?) ?? true,
      recallAlerts: (json['recallAlerts'] as bool?) ?? true,
      weeklyDigest: (json['weeklyDigest'] as bool?) ?? false,
    );
  }
}

class NotificationPrefsController extends StateNotifier<NotificationPrefs> {
  NotificationPrefsController(this._storage) : super(const NotificationPrefs()) {
    _hydrate();
  }

  final FlutterSecureStorage _storage;

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.read(key: kNotificationPrefsKey);
      if (raw == null || raw.isEmpty || !mounted) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        state = NotificationPrefs.fromJson(decoded);
      }
    } catch (_) {
      // Storage unavailable; keep the default in-memory state.
    }
  }

  Future<void> _persist() async {
    try {
      await _storage.write(
        key: kNotificationPrefsKey,
        value: jsonEncode(state.toJson()),
      );
    } catch (_) {
      // Best effort; in-memory state already updated.
    }
  }

  Future<void> setPushEnabled(bool value) async {
    state = state.copyWith(pushEnabled: value);
    await _persist();
  }

  Future<void> setRecallAlerts(bool value) async {
    state = state.copyWith(recallAlerts: value);
    await _persist();
  }

  Future<void> setWeeklyDigest(bool value) async {
    state = state.copyWith(weeklyDigest: value);
    await _persist();
  }
}

// ─── Theme mode ────────────────────────────────────────────────────────────

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._storage) : super(ThemeMode.system) {
    _hydrate();
  }

  final FlutterSecureStorage _storage;

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.read(key: kThemeModeKey);
      if (raw == null || !mounted) return;
      final idx = int.tryParse(raw);
      if (idx == null || idx < 0 || idx >= ThemeMode.values.length) return;
      state = ThemeMode.values[idx];
    } catch (_) {
      // Keep the default.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.write(key: kThemeModeKey, value: mode.index.toString());
    } catch (_) {
      // Best effort.
    }
  }
}

// ─── Text scale ────────────────────────────────────────────────────────────

/// Three discrete text-size buckets, mapped to multipliers consumed by
/// [TextScaler.linear]. Stays inside the WCAG 1.4.4 200% upper bound while
/// keeping the small bucket above the 0.85 readability floor.
enum TextScalePreference {
  small(0.9),
  standard(1.0),
  large(1.15);

  const TextScalePreference(this.scale);

  final double scale;
}

class TextScaleController extends StateNotifier<TextScalePreference> {
  TextScaleController(this._storage) : super(TextScalePreference.standard) {
    _hydrate();
  }

  final FlutterSecureStorage _storage;

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.read(key: kTextScaleKey);
      if (raw == null || !mounted) return;
      final idx = int.tryParse(raw);
      if (idx == null ||
          idx < 0 ||
          idx >= TextScalePreference.values.length) {
        return;
      }
      state = TextScalePreference.values[idx];
    } catch (_) {
      // Keep the default.
    }
  }

  Future<void> setTextScale(TextScalePreference scale) async {
    state = scale;
    try {
      await _storage.write(key: kTextScaleKey, value: scale.index.toString());
    } catch (_) {
      // Best effort.
    }
  }
}

// ─── Riverpod handles ──────────────────────────────────────────────────────

/// Shared secure-storage instance. Override in tests with an in-memory fake.
final settingsStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsController, NotificationPrefs>((
      ref,
    ) {
      return NotificationPrefsController(ref.watch(settingsStorageProvider));
    });

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
      return ThemeModeController(ref.watch(settingsStorageProvider));
    });

final textScaleProvider =
    StateNotifierProvider<TextScaleController, TextScalePreference>((ref) {
      return TextScaleController(ref.watch(settingsStorageProvider));
    });
