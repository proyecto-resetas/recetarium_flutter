import 'dart:io';
import 'package:dio/dio.dart';
import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/auth/models/auth_response.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/features/recipes/models/image_s3_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';
import 'package:resetas/src/core/config/config.dart';
import 'package:resetas/src/core/config/env.dart';

class RecetasAPI {
  late Dio _dio;

  RecetasAPI() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiUrl,
        connectTimeout: const Duration(seconds: 20), // Tiempo de conexión
        receiveTimeout:
            const Duration(seconds: 20), // Tiempo de espera de recepción
      ),
    );
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
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
          },
        ),
      );

      if (response.statusCode == 201) {
        return UploadImageResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> processPayment(
    bool acceptTerms,
    int amount,
  ) async {
    if (!acceptTerms) {}

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

  Future<UserResModel> addRecipeFavorite(
      userId, BookRecipe recipeFavorite) async {
    try {
      final response = await _dio.post(
        '/users/favorite-recipe/$userId',
        data: recipeFavorite.toJson(),
        options: Options(
          headers: {
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
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
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['recipes'];

        return data
            .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
            .toList();
      } else {
        throw Exception('Failed to fetch favorite recipes');
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<RecipesModel>> getMyRecipes(String? userId) async {
    try {
      final response = await _dio.get(
        '/Recipes/myRecipes/$userId',
        options: Options(
          headers: {
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['recipes'];

        return data
            .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
            .toList();
      } else {
        throw Exception('Failed to fetch favorite recipes');
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<RecipesModel>> getRecipesProperty(String? userId,
      {required String type}) async {
    try {
      // Validar el tipo
      if (!['favorite', 'myRecipes'].contains(type)) {
        throw ArgumentError(
            'Invalid type. Must be "favorites" or "myRecipes".');
      }

      final response = await _dio.get(
        '/Recipes/$type/$userId',
        options: Options(
          headers: {
            'x-api-key':
                'x.uacy4l2knh2.hsjnw35vhk.3udy8c89vy.a6oxghein6.gm6hg53awvu.virjogetkb1.8bez89e9sad.9u4kt3knze.yx5lqbjp098.i7t0g37kf54.fditkdcnddi.ja4icepi5ql.8geu3htan3.o3pwsdbbtul.61yqkytbi7e.vjledpha2ps.lcuhb6dvgre.9zcggs7r64.nmh4t4zi939.qab0w10s97r.0wo967t98ks.l73gubhot90.8eo3iuqo4xmq.0wr752lq48b.ac04pybb0aq.rxjvhwjs42.22hn76mhen8.ijq76jg5j7t.9vi97lnijcm.scme31lml',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['recipes'];
        return data
            .map((recipeJson) => RecipesModel.fromJsonModel(recipeJson))
            .toList();
      } else {
        throw Exception('Failed to fetch $type recipes');
      }
    } catch (e) {
      return [];
    }
  }
}
