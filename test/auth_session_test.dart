import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetarium/src/core/api/auth_interceptor.dart';
import 'package:recetarium/src/core/services/local_storage_service.dart';

String _buildFakeJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256'})));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.signature';
}

class _FakeStorage implements LocalStorageService {
  String? _token;
  String? _refreshToken;

  _FakeStorage({String? token, String? refreshToken})
      : _token = token,
        _refreshToken = refreshToken;

  @override
  String? get token => _token;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<void> updateTokens({required String token, String? refreshToken}) async {
    _token = token;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRefreshManager implements TokenRefreshManager {
  final Future<String?> Function() onRefresh;
  int sessionExpiredCalls = 0;
  int refreshCalls = 0;

  _FakeRefreshManager(this.onRefresh);

  @override
  Future<String?> refreshAccessToken() {
    refreshCalls++;
    return onRefresh();
  }

  @override
  void handleSessionExpired() {
    sessionExpiredCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  _StubHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  group('JwtUtils.isTokenExpired', () {
    test('returns true for expired token', () {
      final pastExp =
          DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch ~/
              1000;
      final token = _buildFakeJwt({'sub': '123', 'exp': pastExp});
      expect(JwtUtils.isTokenExpired(token), isTrue);
    });

    test('returns false for valid non-expired token', () {
      final futureExp =
          DateTime.now().add(const Duration(minutes: 20)).millisecondsSinceEpoch ~/
              1000;
      final token = _buildFakeJwt({'sub': '123', 'exp': futureExp});
      expect(JwtUtils.isTokenExpired(token), isFalse);
    });

    test('returns true when token expires within buffer', () {
      final nearExp =
          DateTime.now().add(const Duration(seconds: 10)).millisecondsSinceEpoch ~/
              1000;
      final token = _buildFakeJwt({'sub': '123', 'exp': nearExp});
      expect(JwtUtils.isTokenExpired(token), isTrue);
    });

    test('returns true for malformed token or missing exp', () {
      expect(JwtUtils.isTokenExpired('not-a-jwt'), isTrue);
      expect(JwtUtils.isTokenExpired(_buildFakeJwt({'sub': '123'})), isTrue);
    });
  });

  group('AuthInterceptor', () {
    test('retries request with new token when 401 occurs and refresh succeeds',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final storage = _FakeStorage(token: 'expired-token');
      final refreshManager = _FakeRefreshManager(() async => 'fresh-token');

      int attempt = 0;
      dio.httpClientAdapter = _StubHttpAdapter((options) async {
        attempt++;
        if (attempt == 1) {
          expect(options.headers['Authorization'], 'Bearer expired-token');
          return ResponseBody.fromString('{"message":"Unauthorized"}', 401);
        }
        expect(options.headers['Authorization'], 'Bearer fresh-token');
        return ResponseBody.fromString('{"ok":true}', 200);
      });

      dio.interceptors.add(
        AuthInterceptor(dio, storage: storage, refreshManager: refreshManager),
      );

      final response = await dio.get('/recipes/all');
      expect(response.statusCode, 200);
      expect(attempt, 2);
      expect(refreshManager.refreshCalls, 1);
      expect(refreshManager.sessionExpiredCalls, 0);
    });

    test('triggers handleSessionExpired when 401 occurs and refresh fails',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final storage = _FakeStorage(token: 'expired-token');
      final refreshManager = _FakeRefreshManager(() async => null);

      dio.httpClientAdapter = _StubHttpAdapter((options) async {
        return ResponseBody.fromString('{"message":"Unauthorized"}', 401);
      });

      dio.interceptors.add(
        AuthInterceptor(dio, storage: storage, refreshManager: refreshManager),
      );

      await expectLater(
        () => dio.get('/recipes/all'),
        throwsA(isA<DioException>()),
      );
      expect(refreshManager.refreshCalls, 1);
      expect(refreshManager.sessionExpiredCalls, 1);
    });

    test('does not attempt refresh on excluded auth endpoints', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final storage = _FakeStorage(token: 'some-token');
      final refreshManager = _FakeRefreshManager(() async => 'fresh-token');

      dio.httpClientAdapter = _StubHttpAdapter((options) async {
        return ResponseBody.fromString('{"message":"Invalid"}', 401);
      });

      dio.interceptors.add(
        AuthInterceptor(dio, storage: storage, refreshManager: refreshManager),
      );

      await expectLater(
        () => dio.post('/auth/otp/login'),
        throwsA(isA<DioException>()),
      );
      expect(refreshManager.refreshCalls, 0);
      expect(refreshManager.sessionExpiredCalls, 0);
    });
  });
}
