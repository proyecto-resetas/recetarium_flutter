import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:resetas/models/book_recipe_model.dart';
import 'package:resetas/models/entities/auth_response.dart';
import 'package:resetas/models/entities/user.dart';
import 'package:resetas/models/image_s3_model.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/models/token_model.dart';
import 'package:resetas/models/user_model.dart';

  class RecetasAPI {
  late Dio _dio;

  RecetasAPI() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 20), // Tiempo de conexión
        receiveTimeout: const Duration(seconds: 20), // Tiempo de espera de recepción
      ),
    );
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:4000/api/v1'; 
    }

    if (Platform.isAndroid) {
      return "http://ec2-18-246-215-252.us-west-2.compute.amazonaws.com:8000/api/v1";
    } else if (Platform.isIOS) {
      return 'http://localhost:4000/api/v1'; // http://ec2-18-246-215-252.us-west-2.compute.amazonaws.com:8000/api/v1
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  Future<AuthResponse> login(User user) async {
    try {
        final response = await _dio.post(
        '/auth/login',
        data: user.toJson(),
        options: Options(
          headers: {
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
          },
        ),
      );
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
      
      final response = await _dio.post('/auth/register',
      data: user.toJson(), 
      options: Options(
          headers: {
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
          },
        ),);

      if (response.statusCode == 201) {
        final userResModel = UserResModel.fromJsonModel(response.data['user']);
        final accessToken = AccessToken(accessToken: response.data['access_token']);
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

    final response = await _dio.get(
      '/Recipes/getRecipeFilter',
      queryParameters: queryParams, // Pasa los parámetros de consulta
      options: Options(
          headers: {
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
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
      throw Exception('Error al obtener recetas');
    }
  }

  Future<RecipesModel> createRecipe(RecipesModel recipe, String token) async {
// print('api : ${recipe.steps}, ${recipe.ingredientsRecipe}, ${recipe.descriptionRecipe}, ${recipe.level}, ${recipe.price}, ${recipe.createdBy}, ${recipe.imageUrl}, ${recipe.nameRecipe},  ${recipe.category}');

    try {
      final response = await _dio.post(
        '/Recipes/CreateRecipes',
        data: recipe.toJson(),
        options: Options(
          headers: {
            'Authorization':
                'Bearer $token', // Aquí agregas el token en los headers
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 

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

      Response response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
          },
        ),
        );

      if (response.statusCode == 201) {

        return UploadImageResponse.fromJson(
            response.data); 
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }


  Future<void> processPayment(bool acceptTerms,int amount, ) async {
    if (!acceptTerms) {
      
    }

    try {
      // Simulación de obtener el token de Wompi
      final wompiResponse = await _dio.post('/payment-wompi/tokens/cards', data: {
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

        // Mostrar un mensaje de éxito
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Pago completado y producto desbloqueado')),
        // );
      }
    } catch (e) {
      // Manejar error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error al procesar el pago')),
      // );
    }
  }



  Future<UserResModel> addRecipeFavorite(userId,BookRecipe recipeFavorite) async {

    try {
      final response = await _dio.post(
        '/users/favorite-recipe/$userId',
        data: recipeFavorite.toJson(),
        options: Options(
          headers: { 
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
          },
        ),
      );
      if (response.statusCode == 201) {
        final recipesModel = UserResModel.fromJsonModel(response.data);
        return recipesModel;
      } else {
        throw Exception('create failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create failed: $e');
    }

  }

//   Future<List<RecipesModel>> getFavoriteRecipes(favoriteRecipeIds) async {
//   try {
//     final response = await Dio().post(
//       'http://<tu_api>/recipes/favorites',
//       data: {'recipeIds': favoriteRecipeIds},
//     );
//     return response.data; // Aquí podrías mapear las recetas si tienes un modelo Recipe
//   } catch (e) {
//     print('Error fetching favorite recipes: $e');
//     return [];
//   }
// }


Future<List<RecipesModel>> getFavoriteRecipes(String? userId) async {
  try {
    final response = await _dio.get(
      '/Recipes/favorites/$userId',
      options: Options(
          headers: { 
            'x-api-key':'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml', 
          },
        ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['recipes'];

      print(data);
      return data
          .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
          .toList();
    } else {
      throw Exception('Failed to fetch favorite recipes');
    }
  } catch (e) {
    print('Error fetching favorite recipes: $e');
    return [];
  }
}


}
