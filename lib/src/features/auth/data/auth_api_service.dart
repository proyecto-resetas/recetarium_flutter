import 'package:dio/dio.dart';
import 'package:resetas/src/core/config/config.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/core/config/env.dart';
import 'package:resetas/src/features/auth/models/login_request_model.dart';

class AuthApiService {
  late final Dio _dio;

  AuthApiService() {
    _dio = Dio(
      BaseOptions(
        // Se usa la URL configurada en el proyecto, pero se puede sobrescribir
        // si es necesario para el puerto 3003 mencionado en el curl.
        baseUrl: Config.apiUrl, 
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
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

  // Se podría agregar también el método para reenviar el código
  Future<bool> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/otp/resend', // Ajustar según API real
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
}
