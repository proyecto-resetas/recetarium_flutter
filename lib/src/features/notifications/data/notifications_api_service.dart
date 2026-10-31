import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:resetas/src/core/config/env.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/notifications/models/notification_model.dart';

class NotificationsApiService {
  final Dio _dio = Dio();
  final LocalStorageService _storage = LocalStorageService();

  NotificationsApiService() {
    _dio.options.baseUrl = Env.apiUrlDev;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['x-api-key'] = Env.xapikey;
          return handler.next(options);
        },
      ),
    );
  }

  Future<({List<NotificationModel> notifications, int unreadCount})>
      getNotifications({int page = 1, int limit = 30}) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = (data['notifications'] as List<dynamic>? ?? []);
        final list = rawList
            .whereType<Map>()
            .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        final unread = (data['unreadCount'] as num?)?.toInt() ??
            list.where((n) => !n.read).length;
        return (notifications: list, unreadCount: unread);
      }
      return (notifications: <NotificationModel>[], unreadCount: 0);
    } catch (e) {
      debugPrint('NotificationsApiService.getNotifications error: $e');
      return (notifications: <NotificationModel>[], unreadCount: 0);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      final data = response.data;
      if (data is Map && data['unreadCount'] != null) {
        return (data['unreadCount'] as num).toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _dio.patch('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.markAsRead error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.markAllAsRead error: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.deleteNotification error: $e');
      return false;
    }
  }

  Future<bool> registerPushToken(String token, {String? platform}) async {
    try {
      await _dio.post(
        '/notifications/push-token',
        data: {
          'token': token,
          if (platform != null) 'platform': platform,
        },
      );
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.registerPushToken error: $e');
      return false;
    }
  }

  Future<bool> unregisterPushToken(String token) async {
    try {
      await _dio.delete('/notifications/push-token/$token');
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.unregisterPushToken error: $e');
      return false;
    }
  }

  Future<bool> sendTestNotification() async {
    try {
      await _dio.post('/notifications/test');
      return true;
    } catch (e) {
      debugPrint('NotificationsApiService.sendTestNotification error: $e');
      return false;
    }
  }
}
