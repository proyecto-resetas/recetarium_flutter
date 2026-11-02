import 'package:dio/dio.dart';
import 'package:resetas/src/core/config/config.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';

class SuperAdminApiService {
  late final Dio _dio;
  final LocalStorageService _localStorageService = LocalStorageService();

  SuperAdminApiService() {
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
          final token = _localStorageService.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _dio.get('/users/admin/dashboard-stats');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is List) {
          return raw.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final response = await _dio.patch(
        '/users/$userId/role',
        data: {'role': role},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      try {
        final fallback = await _dio.patch(
          '/users/$userId',
          data: {'role': role},
        );
        return fallback.statusCode == 200 || fallback.statusCode == 201;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/users/$userId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRoles() async {
    try {
      final response = await _dio.get(
        '/roles',
        queryParameters: {'includeInactive': 'true'},
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createRole({
    required String name,
    required String displayName,
    String? description,
    required List<String> permissions,
  }) async {
    try {
      final response = await _dio.post(
        '/roles',
        data: {
          'name': name,
          'displayName': displayName,
          if (description != null && description.isNotEmpty)
            'description': description,
          'permissions': permissions,
          'isActive': true,
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateRole(
    String roleId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/roles/$roleId', data: data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<RecipesModel>> getAllRecipes() async {
    try {
      final response = await _dio.get(
        '/Recipes/getRecipeFilter',
        queryParameters: {'page': 1, 'limit': 200},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = raw is Map && raw['recipes'] is List
            ? raw['recipes'] as List<dynamic>
            : (raw is List ? raw : []);
        return list
            .whereType<Map<String, dynamic>>()
            .map((j) => RecipesModel.fromJsonModel(j))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      final response = await _dio.delete('/Recipes/$recipeId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<RecipesModel?> updateRecipe(
    String recipeId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(
        '/Recipes/update/$recipeId',
        data: data,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return RecipesModel.fromJsonModel(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
