import 'dart:io';
import 'package:dio/dio.dart';
import 'package:resetas/models/entities/recipes.dart';
import 'package:resetas/models/entities/token.dart';
import 'package:resetas/models/entities/user.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/models/user_model.dart';

class RecetasAPI {
  late Dio _dio;

RecetasAPI() {
    // Configuramos el Dio con opciones dinámicas según la plataforma
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(), // Determina la URL base según la plataforma
        connectTimeout: const Duration(seconds: 10), // Tiempo de conexión
        receiveTimeout: const Duration(seconds: 10), // Tiempo de espera de recepción
      ),
    );
  }

    String _getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api/v1'; // Android (localhost -> 10.0.2.2)
    } else if (Platform.isIOS) {
      return 'http://localhost:4000/api/v1'; // iOS (localhost)
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  Future<AccessToken> login(User user) async {
    try {
      final response = await _dio.post('/auth/login', data: user.toJson());

      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final userResModel = UserResModel.fromJsonModel(response.data);
          return userResModel.toTokenEntity();
        } else {
          throw Exception("La respuesta no es del tipo esperado.");
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores, puede ser un print o logging.
      throw Exception('Login failed: $e');
    }
  }

  Future<AccessToken> register(User user) async {
    try {
      final response = await _dio.post('/auth/register', data: user.toJson());

      if (response.statusCode == 201) {
        final userResModel = UserResModel.fromJsonModel(response.data);
        return userResModel.toTokenEntity();
      }else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }

    } catch (e) {
      throw Exception('Register failed: $e');

    }
  }

   Future<Recipes> getResetas() async {
    try {
    final response = await _dio.get('/recetas');

      if (response.statusCode == 200) {
        final recipeModel = RecipesModel.fromJsonModel(response.data);
        return recipeModel.toRecipesEntity();
      }else {
        throw Exception('Register failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }
}


