import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/api_client.dart';

/// Handles Firebase Cloud Messaging init, permission, token registration,
/// foreground display, and notification-tap deep links.
///
/// Firebase degrades gracefully: if `google-services.json` is absent or
/// Firebase is not yet configured, [init] catches the exception and sets
/// [available] = false — the rest of the app continues normally without push.
///
/// **Manual setup required before push notifications work:**
/// 1. Create a Firebase project at console.firebase.google.com
/// 2. Add Android app with package name `com.radha.radha_app`
/// 3. Download `google-services.json` → `android/app/google-services.json`
/// 4. Apply `com.google.gms.google-services` plugin in
///    `android/app/build.gradle.kts`
/// 5. Set `FCM_SERVICE_ACCOUNT_JSON` on the server (see `cloud.md` §env)
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _available = false;
  bool _initialized = false;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool get available => _available;

  /// Call once from `main()` before `runApp()`.
  static Future<void> preInit() async {
    await instance._preInit();
  }

  Future<void> _preInit() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await Firebase.initializeApp();
      _available = true;
      await _setupLocalNotifications();
      await _configureFcm();
    } catch (_) {
      // Firebase not configured — push silently disabled.
      _available = false;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    if (Platform.isAndroid) {
      await _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel(
          'expiry_reminders',
          'Expiry Reminders',
          description: 'Alerts when tracked items are near expiry',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _configureFcm() async {
    // Request permission on iOS / Android 13+.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background message handler must be a top-level function.
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    // Foreground: show a local notification (FCM suppresses UI by default).
    FirebaseMessaging.onMessage.listen((msg) {
      final title = msg.notification?.title;
      final body = msg.notification?.body;
      if (title == null || body == null) return;
      _local.show(
        msg.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_reminders',
            'Expiry Reminders',
            channelDescription: 'Alerts when tracked items are near expiry',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: msg.data['deepLink'] as String?,
      );
    });
  }

  void _onTap(NotificationResponse response) {
    // Deep link payload is stored in `payload` by the foreground handler
    // and in data by background taps.
    final route = response.payload ?? '/expiry';
    _pendingDeepLink = route;
  }

  String? _pendingDeepLink;

  /// Call after the router is ready to consume any queued deep link.
  String? consumeDeepLink() {
    final link = _pendingDeepLink;
    _pendingDeepLink = null;
    return link;
  }

  /// Register the current FCM token with the backend. Call after login
  /// (session must be authenticated).
  Future<void> registerToken(ApiClient api) async {
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await api.registerFcmToken(RegisterFcmTokenDto(
        token: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      ));
      // Listen for token refreshes.
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        api.registerFcmToken(RegisterFcmTokenDto(
          token: newToken,
          platform: Platform.isAndroid ? 'android' : 'ios',
        )).ignore();
      });
    } catch (_) {
      // Non-fatal — push still works for this session from the server side.
    }
  }

  /// Unregister when the user logs out.
  Future<void> unregisterToken(ApiClient api) async {
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await api.unregisterFcmToken(token);
    } catch (_) {
      // Best-effort.
    }
  }
}

/// Must be top-level (not a class method) per firebase_messaging requirement.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the OS notification tray;
  // no additional processing needed in v1.
  await Firebase.initializeApp();
}
