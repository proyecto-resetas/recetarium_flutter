import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:resetas/src/core/config/config.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/models/image_s3_model.dart';
import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';


class RecipesApiService {
  late final Dio _dio;
  final LocalStorageService _localStorageService = LocalStorageService();

  RecipesApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    _dio.options.headers['x-api-key'] = Config.xapikey;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['x-api-key'] ??= Config.xapikey;
          final currentAuth = options.headers['Authorization']?.toString() ?? '';
          if (currentAuth.isEmpty || currentAuth == 'Bearer null') {
            final token = _localStorageService.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Obtener todas las recetas
  Future<List<RecipesModel>> getRecipe() async {
    final response = await _dio.get('/Recipes/all');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['recipes'];
      return data
          .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
          .toList();
    } else {
      throw Exception('Error al obtener recetas');
    }
  }

  // Filtrar recetas por nombre, categoría, nivel y creador
  Future<List<RecipesModel>> getRecipesFilter(
      String? name, String? category, String? level, String? createdBy, String? token) async {
    Map<String, dynamic> queryParams = {};

    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (category != null) queryParams['category'] = category;
    if (level != null) queryParams['level'] = level;
    if (createdBy != null) queryParams['createdBy'] = createdBy;

    print('Token: $token');
    print('Query Params: $queryParams');

    final response = await _dio.get(
      '/Recipes/getRecipeFilter',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'x-api-key': Config.xapikey,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> recipesData = data['recipes'];
      return recipesData
          .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
          .toList();
    } else {
      throw Exception('Error al obtener recetas filtradas');
    }
  }

  // Crear una nueva receta
  Future<RecipesModel> createRecipe(RecipesModel recipe, String token) async {
    try {
      final response = await _dio.post(
        '/Recipes/CreateRecipes',
        data: recipe.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RecipesModel.fromJsonModel(response.data);
      } else {
        throw Exception('Error al crear receta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear receta: $e');
    }
  }

  // Eliminar una receta (exclusivo super_admin)
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      final response = await _dio.delete(
        '/Recipes/$recipeId',
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

  // Actualizar una receta existente
  Future<RecipesModel?> updateRecipe(
    String recipeId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.patch(
        '/Recipes/update/$recipeId',
        data: updateData,
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return RecipesModel.fromJsonModel(response.data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Subir imagen a S3
  Future<UploadImageResponse?> uploadImage(XFile imageFile) async {
    try {
      String uploadUrl = '/s3/upload';
      
      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
      } else {
        multipartFile = await MultipartFile.fromFile(imageFile.path);
      }

      FormData formData = FormData.fromMap({
        'file': multipartFile,
      });

      Response response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201) {
        return UploadImageResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Agregar receta a favoritos
  Future<UserResModel> addRecipeFavorite(
      String userId, BookRecipe recipeFavorite) async {
    try {
      final recipeId = recipeFavorite.idRecipe ?? userId;
      final response = await _dio.post(
        '/users/favorite-recipe/$recipeId',
        data: recipeFavorite.toJson(),
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return UserResModel.fromJsonModel(response.data);
      } else {
        throw Exception('Error al agregar a favoritos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al agregar a favoritos: $e');
    }
  }

  // Eliminar receta de favoritos
  Future<bool> removeRecipeFavorite(String recipeId) async {
    try {
      final response = await _dio.delete(
        '/users/favorite-recipe/$recipeId',
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

  // Comprar una receta y almacenarla en myPurchased del usuario autenticado
  Future<RecipesModel?> purchaseRecipe(
    String recipeId, {
    String? paymentReference,
    String? recipientEmail,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (paymentReference != null && paymentReference.isNotEmpty) {
        body['paymentReference'] = paymentReference;
      }
      if (recipientEmail != null && recipientEmail.isNotEmpty) {
        body['recipientEmail'] = recipientEmail;
      }

      final response = await _dio.post(
        '/Recipes/purchase/$recipeId',
        data: body.isEmpty ? null : body,
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['recipe'] is Map<String, dynamic>) {
          return RecipesModel.fromJsonModel(data['recipe']);
        } else if (data is Map<String, dynamic>) {
          return RecipesModel.fromJsonModel(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error al comprar receta: $e');
    }
  }

  // Obtener recetas favoritas de un usuario
  Future<List<RecipesModel>> getFavoriteRecipes([String? userId]) async {
    return getRecipesProperty(userId ?? '', type: 'favorite');
  }

  // Obtener recetas de un usuario
  Future<List<RecipesModel>> getMyRecipes([String? userId]) async {
    return getRecipesProperty(userId ?? '', type: 'myRecipes');
  }

  // Obtener recetas compradas del usuario autenticado
  Future<List<RecipesModel>> getPurchasedRecipes([String? userId]) async {
    return getRecipesProperty(userId ?? '', type: 'purchased');
  }

  // Genérico para obtener recetas por tipo (favorite, myRecipes, purchased, created)
  Future<List<RecipesModel>> getRecipesProperty(String userId,
      {required String type}) async {
    try {
      if (!['favorite', 'myRecipes', 'purchased', 'created'].contains(type)) {
        throw ArgumentError(
            'Invalid type. Must be "favorite", "myRecipes", "purchased" or "created".');
      }

      final response = await _dio.get(
        '/Recipes/my-list/$type',
        options: Options(
          headers: {
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        final List<dynamic> data = rawData is List
            ? rawData
            : (rawData is Map && rawData['recipes'] is List
                ? rawData['recipes'] as List<dynamic>
                : []);
        return data
            .whereType<Map<String, dynamic>>()
            .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
            .toList();
      } else {
        throw Exception('Error al obtener recetas por propiedad: $type');
      }
    } catch (e) {
      return [];
    }
  }

  // Procesar pago (Wompi)
  Future<void> processPayment(
    bool acceptTerms,
    int amount,
  ) async {
    try {
      // Simulación de obtener el token de Wompi
      final wompiResponse =
          await _dio.post('/payment-wompi/tokens/cards', data: {
        'number': '4111111111111111', // Tarjeta de prueba
        'exp_month': '12',
        'exp_year': '25',
        'cvc': '123',
      });

      final String paymentToken = wompiResponse.data;

      // Realizar la solicitud a tu API de NestJS
      final response = await _dio.post('/payment-wompi/payments/pay', data: {
        'amount': amount,
        'userPaymentSourceId': paymentToken,
        'destinationAccount': 'destination_account_id',
        'appAccount': 'app_account_id',
        'acceptTerms': acceptTerms, // Aceptación de términos enviada
      });

      if (response.statusCode == 200) {
        // Transacción exitosa, proceder a desbloquear el producto
        await _dio.post('/payment-wompi/payments/unlock-product', data: {
          'productId': 'product_id',
          'userId': 'user_id',
        });
      }
    } catch (e) {
      throw Exception('Error al procesar el pago: $e');
    }
  }

  // Analizar imagen para autocompletar receta
  Future<Map<String, dynamic>?> analyzeImage(XFile imageFile, String token) async {
    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
      } else {
        multipartFile = await MultipartFile.fromFile(imageFile.path);
      }

      FormData formData = FormData.fromMap({
        'image': multipartFile,
        'prompt': '', // Prompt vacío según el curl
        'provider': Config.aiProvider,
      });

      print('Form Data: $formData');

      final response = await _dio.post(
        '/Recipes/analyze-image',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(milliseconds: 600000),
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['response'];
      }
      return null;
    } catch (e) {
      print('Error al analizar imagen: $e');
      throw Exception('Error al analizar imagen: $e');
    }
  }

  // Analizar texto libre con IA para organizar y autocompletar receta
  Future<Map<String, dynamic>?> analyzeRecipeText(
    String text,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '/Recipes/analyze-text',
        data: {
          'text': text,
          'provider': Config.aiProvider,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(milliseconds: 600000),
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['response'];
      }
      return null;
    } catch (e) {
      print('Error al analizar texto con IA: $e');
      throw Exception('Error al analizar texto con IA: $e');
    }
  }

  // Obtener ingredientes y utensilios por ID de receta
  Future<Map<String, dynamic>> getIngredientsUtensils(String recipeId, String token) async {
    try {
      final response = await _dio.get(
        '/Recipes/ingredients-utensils/$recipeId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al obtener ingredientes y utensilios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getIngredientsUtensils: $e');
      rethrow;
    }
  }

  // Obtener pasos de una receta por su ID
  Future<List<dynamic>> getRecipeSteps(String recipeId, String token) async {
    try {
      print(
          '[DEBUG] Solicitando pasos: ${_dio.options.baseUrl}/steps/recipe/$recipeId');
      print(
          '[DEBUG] Headers: { Authorization: Bearer ${token.substring(0, 15)}..., x-api-key: ${Config.xapikey.substring(0, 10)}... }');

      final response = await _dio.get(
        '/steps/recipe/$recipeId',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': Config.xapikey,
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List<dynamic>;
        } else if (response.data is Map && response.data.containsKey('steps')) {
          return response.data['steps'] as List<dynamic>;
        } else {
          throw Exception(
              'Formato de respuesta inesperado: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Error al obtener los pasos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        print('[DEBUG] Error 403/4xx detalles: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      print('Error en getRecipeSteps para recipeId $recipeId: $e');
      rethrow;
    }
  }
}
