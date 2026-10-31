import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resetas/src/features/notifications/data/notifications_api_service.dart';
import 'package:resetas/src/features/notifications/data/notifications_socket_service.dart';
import 'package:resetas/src/features/notifications/data/push_notification_service.dart';
import 'package:resetas/src/features/notifications/models/notification_model.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsApiService _apiService = NotificationsApiService();
  final NotificationsSocketService _socketService =
      NotificationsSocketService();
  final PushNotificationService _pushService = PushNotificationService();

  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isSocketConnected = false;
  String? _connectedUserId;

  // Banner flotante en vivo cuando llega una notificación por WebSocket
  NotificationModel? _activeLiveToast;
  Timer? _toastTimer;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isSocketConnected => _isSocketConnected;
  bool get isPushEnabled => _pushService.isPushEnabled;
  NotificationModel? get activeLiveToast => _activeLiveToast;

  Future<void> initializeForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      disconnect();
      return;
    }

    if (_connectedUserId == userId && _isSocketConnected) {
      return;
    }
    _connectedUserId = userId;

    await _pushService.init(
      onForegroundMessage: (pushNotification) {
        final exists =
            _notifications.any((n) => n.id == pushNotification.id);
        if (!exists) {
          _notifications.insert(0, pushNotification);
          _unreadCount = _notifications.where((n) => !n.read).length;
          _showLiveToast(pushNotification);
          notifyListeners();
        }
      },
    );
    await fetchNotifications();

    _socketService.connect(
      userId: userId,
      onNewNotification: (notification, serverUnreadCount) {
        final exists = _notifications.any((n) => n.id == notification.id);
        if (!exists) {
          _notifications.insert(0, notification);
        }
        _unreadCount =
            serverUnreadCount ?? _notifications.where((n) => !n.read).length;

        _showLiveToast(notification);
        notifyListeners();
      },
      onUnreadCountChanged: (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onConnectionChanged: (connected) {
        _isSocketConnected = connected;
        notifyListeners();
      },
    );
  }

  void _showLiveToast(NotificationModel notification) {
    _toastTimer?.cancel();
    _activeLiveToast = notification;
    notifyListeners();

    _toastTimer = Timer(const Duration(seconds: 6), () {
      _activeLiveToast = null;
      notifyListeners();
    });
  }

  void dismissLiveToast() {
    _toastTimer?.cancel();
    _activeLiveToast = null;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.getNotifications();
      _notifications
        ..clear()
        ..addAll(result.notifications);
      _unreadCount = result.unreadCount;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1 && !_notifications[idx].read) {
      _notifications[idx] = _notifications[idx].copyWith(read: true);
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    }
    await _apiService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].read) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();
    await _apiService.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _unreadCount = _notifications.where((n) => !n.read).length;
    notifyListeners();
    await _apiService.deleteNotification(notificationId);
  }

  Future<bool> enablePushNotifications() async {
    final enabled = await _pushService.requestPermissionsAndRegisterToken();
    notifyListeners();
    return enabled;
  }

  Future<bool> sendTestNotification() async {
    return _apiService.sendTestNotification();
  }

  void disconnect() {
    _toastTimer?.cancel();
    _activeLiveToast = null;
    _connectedUserId = null;
    _isSocketConnected = false;
    _socketService.disconnect();
    _pushService.unregisterCurrentDevice();
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
