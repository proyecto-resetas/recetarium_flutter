import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/notifications/data/notifications_api_service.dart';
import 'package:resetas/src/features/notifications/models/notification_model.dart';

/// Handler de nivel superior requerido por `firebase_messaging` para procesar
/// notificaciones Push cuando la aplicación está en segundo plano o terminada.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('📩 Push recibido en segundo plano: ${message.messageId}');
  } catch (_) {}
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final NotificationsApiService _apiService = NotificationsApiService();
  final LocalStorageService _storage = LocalStorageService();

  bool _initialized = false;
  bool _firebaseAvailable = false;
  bool _pushEnabled = false;
  String? _currentDeviceToken;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMsgSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  bool get isPushEnabled => _pushEnabled;
  String? get currentDeviceToken => _currentDeviceToken;

  Future<void> init({
    void Function(NotificationModel notification)? onForegroundMessage,
    void Function(String? recipeId)? onNotificationTapped,
  }) async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseAvailable = true;

      // Registrar handler oficial de segundo plano
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Opciones oficiales de presentación en primer plano (iOS / macOS / Web)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Solicitar permisos y registrar el token FCM en el backend
      await requestPermissionsAndRegisterToken();

      // Escuchar cambios o rotación del token FCM
      _tokenRefreshSub =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _currentDeviceToken = newToken;
        if (_storage.token != null && _storage.token!.isNotEmpty) {
          final platformName =
              kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();
          await _apiService.registerPushToken(newToken, platform: platformName);
        }
      });

      // Escuchar notificaciones Push cuando la app está abierta (Foreground)
      _foregroundMsgSub =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notif = _mapRemoteMessageToModel(message);
        if (notif != null) {
          onForegroundMessage?.call(notif);
        }
      });

      // Escuchar cuando el usuario toca la notificación Push desde el sistema
      _openedAppSub =
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final recipeId = message.data['recipeId']?.toString();
        onNotificationTapped?.call(recipeId);
      });
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint(
        'ℹ️ Firebase Messaging aún no tiene credenciales locales configuradas ($e). '
        'Las notificaciones operarán en tiempo real mediante WebSocket.',
      );
    }
  }

  Future<bool> requestPermissionsAndRegisterToken() async {
    if (!_firebaseAvailable) {
      return false;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _pushEnabled = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (_pushEnabled) {
        final fcmToken = await messaging.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          _currentDeviceToken = fcmToken;
          if (_storage.token != null && _storage.token!.isNotEmpty) {
            final platformName =
                kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();
            await _apiService.registerPushToken(
              fcmToken,
              platform: platformName,
            );
          }
        }
      }

      return _pushEnabled;
    } catch (e) {
      debugPrint('PushNotificationService.requestPermissions error: $e');
      return false;
    }
  }

  Future<void> unregisterCurrentDevice() async {
    if (_currentDeviceToken != null) {
      await _apiService.unregisterPushToken(_currentDeviceToken!);
      _currentDeviceToken = null;
    }
  }

  NotificationModel? _mapRemoteMessageToModel(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    if (notification == null && data.isEmpty) return null;

    return NotificationModel(
      id: (data['notificationId'] ??
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
      recipientId: (data['recipientId'] ?? '').toString(),
      senderId: data['senderId']?.toString(),
      senderUsername: data['senderUsername']?.toString(),
      type: (data['type'] ?? 'system').toString(),
      title: notification?.title ??
          data['title']?.toString() ??
          'Nueva notificación',
      message: notification?.body ?? data['message']?.toString() ?? '',
      recipeId: data['recipeId']?.toString(),
      recipeName: data['recipeName']?.toString(),
      recipeImage: notification?.android?.imageUrl ??
          notification?.apple?.imageUrl ??
          data['recipeImage']?.toString(),
      read: false,
      createdAt: message.sentTime ?? DateTime.now(),
    );
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundMsgSub?.cancel();
    _openedAppSub?.cancel();
  }
}
