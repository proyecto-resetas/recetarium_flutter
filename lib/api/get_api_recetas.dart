import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:resetas/models/entities/auth_response.dart';
import 'package:resetas/models/entities/user.dart';
import 'package:resetas/models/image_s3_model.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/models/token_model.dart';
import 'package:resetas/models/user_model.dart';

class RecetasAPI {
  late Dio _dio;

  RecetasAPI() {
    // Configuramos el Dio con opciones dinámicas según la plataforma
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 20), // Tiempo de conexión
        receiveTimeout:
            const Duration(seconds: 20), // Tiempo de espera de recepción
      ),
    );
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:4000/api/v1'; // URL para Flutter Web
    }

    if (Platform.isAndroid) {
      return 'http://ec2-18-246-215-252.us-west-2.compute.amazonaws.com:8000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://ec2-18-246-215-252.us-west-2.compute.amazonaws.com:8000/api/v1';
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  Future<AuthResponse> login(User user) async {
    try {
      final response = await _dio.post('/auth/login', data: user.toJson());

      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final userResModel =
              UserResModel.fromJsonModel(response.data['user']);
          final accessToken =
              AccessToken(accessToken: response.data['access_token']);
          return AuthResponse(
              accessToken: accessToken, userResModel: userResModel);
        } else {
          throw Exception("La respuesta no es del tipo esperado.");
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<AuthResponse> register(User user) async {
    try {
      
      final response = await _dio.post('/auth/register', data: user.toJson());

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
      throw Exception('Register failed: $e');
    }
  }

  Future<List<RecipesModel>> getRecipe() async {
    final response = await _dio.get('/Recipes/all');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;

      // Mapea los datos a objetos de tipo Recipes
      return data
          .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
          .toList();
    } else {
      throw Exception('Error al obtener recetas');
    }
  }

  Future<List<RecipesModel>> getRecipesFilter(
      String? category, String? level, String? createdBy) async {
    Map<String, dynamic> queryParams = {};

    // Agregar los parámetros solo si no son nulos
    if (category != null) queryParams['category'] = category;
    if (level != null) queryParams['level'] = level;
    if (createdBy != null) queryParams['createdBy'] = createdBy;

    // Realizar la petición GET con los queryParams
    final response = await _dio.get(
      '/Recipes/getRecipeFilter',
      queryParameters: queryParams, // Pasa los parámetros de consulta
    );
    if (response.statusCode == 200) {
       final data = response.data;
        final List<dynamic> recipesData = data['recipes'];
      // Mapea los datos a objetos de tipo Recipes
      return recipesData
          .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
          .toList();
    } else {
      throw Exception('Error al obtener recetas');
    }
  }

  Future<RecipesModel> createRecipe(RecipesModel recipe, String token) async {

    try {
      final response = await _dio.post(
        '/Recipes/CreateRecetas',
        data: recipe.toJson(),
        options: Options(
          headers: {
            'Authorization':
                'Bearer $token', // Aquí agregas el token en los headers
          },
        ),
      );
      if (response.statusCode == 201) {
        final recipesModel = RecipesModel.fromJsonModel(response.data);
        return recipesModel;
      } else {
        throw Exception('create failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create failed: $e');
    }
  }

  // Método para subir la imagen al servidor S3
  Future<UploadImageResponse?> uploadImage(File imageFile) async {
    try {
      String uploadUrl = '/s3/upload';
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 201) {

        return UploadImageResponse.fromJson(
            response.data); // forma de navegar en un json
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
