import 'package:dio/dio.dart';
import 'package:recetarium/src/core/api/auth_interceptor.dart';
import 'package:recetarium/src/core/config/config.dart';
import 'package:recetarium/src/features/user_profile/models/user.dart';
import 'package:recetarium/src/core/config/env.dart';
import 'package:recetarium/src/features/auth/models/login_request_model.dart';

class AuthApiService {
  late final Dio _dio;

  AuthApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    _dio.interceptors.add(AuthInterceptor(_dio));
  }

  Future<bool> login(LoginRequestModel loginRequestModel) async {
    try {
      final response = await _dio.post(
        '/auth/otp/login',
        data: loginRequestModel.toJson(),
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> register(User user) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: user.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': Env.xapikey,
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String code) async {
    try {
      final response = await _dio.post(
        '/auth/otp/verify',
        data: {
          'email': email,
          'code': code,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Error en verificación: ${e.response?.data}');
      }
      return null;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/otp/resend',
        data: {
          'email': email,
        },
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {
          'email': email.trim(),
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'email': email.trim(),
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
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
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(
    String userId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '/users/$userId',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getMyPermissions(String token) async {
    try {
      final response = await _dio.get(
        '/roles/my-permissions',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['permissions'] is List) {
        return (response.data['permissions'] as List)
            .map((e) => e.toString())
            .toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _dio.patch(
        '/users/$userId',
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
