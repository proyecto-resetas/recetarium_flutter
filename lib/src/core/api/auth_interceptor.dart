import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:recetarium/src/core/config/config.dart';
import 'package:recetarium/src/core/services/local_storage_service.dart';

/// Utilidades para inspeccionar tokens JWT sin dependencias externas.
class JwtUtils {
  JwtUtils._();

  /// Retorna `true` si el JWT está expirado (o expirará dentro de [buffer]),
  /// o si el token tiene un formato inválido.
  static bool isTokenExpired(
    String token, {
    Duration buffer = const Duration(seconds: 30),
  }) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final normalized = base64Url.normalize(parts[1]);
      final decodedBytes = base64Url.decode(normalized);
      final decodedMap = jsonDecode(utf8.decode(decodedBytes));

      if (decodedMap is Map && decodedMap['exp'] is num) {
        final expSeconds = (decodedMap['exp'] as num).toInt();
        final expDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
        return DateTime.now().isAfter(expDate.subtract(buffer));
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}

/// Coordina la renovación de tokens de acceso evitando llamadas concurrentes
/// duplicadas a `/auth/refresh` y notificando cuando la sesión caduca.
class TokenRefreshManager {
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();
  factory TokenRefreshManager() => _instance;
  TokenRefreshManager._internal();

  final LocalStorageService _storage = LocalStorageService();
  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: Config.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<String?>? _ongoingRefresh;

  /// Callback invocado cuando se obtiene un nuevo `access_token`.
  void Function(String newAccessToken)? onTokenRefreshed;

  /// Callback invocado cuando el `refresh_token` falla o ha expirado.
  VoidCallback? onSessionExpired;

  /// Renueva el `access_token` usando el `refresh_token` guardado en Hive.
  /// Si ya hay una renovación en curso, espera y reutiliza su resultado.
  Future<String?> refreshAccessToken() async {
    if (_ongoingRefresh != null) {
      return await _ongoingRefresh;
    }

    _ongoingRefresh = _performRefresh();
    try {
      return await _ongoingRefresh;
    } finally {
      _ongoingRefresh = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storage.updateTokens(
            token: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );
          onTokenRefreshed?.call(newAccessToken);
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      debugPrint('TokenRefreshManager: error renovando token: $e');
      return null;
    }
  }

  /// Notifica que la sesión ya no es válida y el usuario debe reautenticarse.
  void handleSessionExpired() {
    onSessionExpired?.call();
  }
}

/// Interceptor compartido de Dio que adjunta headers de autenticación
/// y renueva automáticamente el `access_token` ante respuestas HTTP 401.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final LocalStorageService _storage;
  final TokenRefreshManager _refreshManager;

  static const _retriedKey = '_retriedAfterRefresh';
  static const _authExcludedPaths = <String>[
    '/auth/otp/login',
    '/auth/otp/verify',
    '/auth/otp/resend',
    '/auth/refresh',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/logout',
  ];

  AuthInterceptor(
    this._dio, {
    LocalStorageService? storage,
    TokenRefreshManager? refreshManager,
  })  : _storage = storage ?? LocalStorageService(),
        _refreshManager = refreshManager ?? TokenRefreshManager();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['x-api-key'] ??= Config.xapikey;
    final currentAuth = options.headers['Authorization']?.toString() ?? '';
    if (currentAuth.isEmpty || currentAuth == 'Bearer null') {
      final token = _storage.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;
    final isExcluded = _authExcludedPaths.any((p) => path.contains(p));
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (isExcluded || alreadyRetried) {
      if (!isExcluded && alreadyRetried) {
        _refreshManager.handleSessionExpired();
      }
      return handler.next(err);
    }

    final newToken = await _refreshManager.refreshAccessToken();
    if (newToken == null || newToken.isEmpty) {
      _refreshManager.handleSessionExpired();
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    requestOptions.extra[_retriedKey] = true;
    requestOptions.headers['Authorization'] = 'Bearer $newToken';

    try {
      final retryResponse = await _dio.fetch(requestOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      if (retryErr.response?.statusCode == 401) {
        _refreshManager.handleSessionExpired();
      }
      return handler.next(retryErr);
    }
  }
}
