import 'package:flutter/foundation.dart';
import 'package:resetas/src/core/config/env.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/notifications/models/notification_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class NotificationsSocketService {
  io.Socket? _socket;
  final LocalStorageService _storage = LocalStorageService();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect({
    required String userId,
    required void Function(NotificationModel notification, int? unreadCount)
        onNewNotification,
    required void Function(int unreadCount) onUnreadCountChanged,
    required void Function(bool connected) onConnectionChanged,
  }) {
    disconnect();

    final token = _storage.token ?? '';
    final wsUrl = '${Env.apiUrlDev}/notifications';

    _socket = io.io(
      wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token, 'userId': userId})
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      onConnectionChanged(true);
      _socket!.emit('notification:subscribe', {
        'userId': userId,
        'token': token,
      });
      debugPrint('🔔 WebSocket Notificaciones conectado ($wsUrl)');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      onConnectionChanged(false);
      debugPrint('🔕 WebSocket Notificaciones desconectado');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      onConnectionChanged(false);
      debugPrint('⚠️ WebSocket Notificaciones error de conexión: $err');
    });

    _socket!.on('notification:new', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final model = NotificationModel.fromJson(map);
        final unreadCount = (map['unreadCount'] as num?)?.toInt();
        onNewNotification(model, unreadCount);
      }
    });

    _socket!.on('notification:unread-count', (data) {
      if (data is Map && data['unreadCount'] != null) {
        onUnreadCountChanged((data['unreadCount'] as num).toInt());
      }
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
  }
}
