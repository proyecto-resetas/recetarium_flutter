import 'package:dio/dio.dart';
import 'package:resetas/src/core/config/config.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/features/auth/models/auth_response.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
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
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
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

  Future<AuthResponse> register(User user) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data:  user.toJson() ,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': Env.xapikey,
          },
        ),
      );
      if (response.statusCode == 201) {
        final userResModel = UserResModel.fromJsonModel(response.data['user']);
        final accessToken =
            AccessToken(accessToken: response.data['access_token']);
        return AuthResponse(
            accessToken: accessToken, userResModel: userResModel);
      } else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
      }
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
          },
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
