import 'package:flutter/material.dart';
import 'package:recetarium/src/features/admin/data/super_admin_api_service.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';

class SuperAdminProvider extends ChangeNotifier {
  final SuperAdminApiService _api = SuperAdminApiService();

  bool _isLoading = false;
  int _totalUsers = 0;
  int _totalChefs = 0;
  int _totalRegularUsers = 0;
  int _totalSuperAdmins = 0;
  int _totalRecipes = 0;
  int _totalSalesCount = 0;
  int _totalGiftsCount = 0;
  num _totalRevenue = 0;

  List<RecipesModel> _recipes = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _permissions = [];
  List<Map<String, dynamic>> _transactions = [];

  bool get isLoading => _isLoading;
  int get totalUsers => _totalUsers;
  int get totalChefs => _totalChefs;
  int get totalRegularUsers => _totalRegularUsers;
  int get totalSuperAdmins => _totalSuperAdmins;
  int get totalRecipes => _totalRecipes;
  int get totalSalesCount => _totalSalesCount;
  int get totalGiftsCount => _totalGiftsCount;
  num get totalRevenue => _totalRevenue;

  List<RecipesModel> get recipes => _recipes;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get roles => _roles;
  List<Map<String, dynamic>> get permissions => _permissions;
  List<Map<String, dynamic>> get transactions => _transactions;

  static const List<Map<String, dynamic>> _fallbackPermissions = [
    {
      '_id': 'perm_recipes_read',
      'key': 'recipes:read',
      'name': 'Ver catálogo de recetas',
      'module': 'recipes',
      'description': 'Permite listar, filtrar y consultar recetas e ingredientes.',
      'isActive': true,
    },
    {
      '_id': 'perm_recipes_create',
      'key': 'recipes:create',
      'name': 'Crear y publicar recetas',
      'module': 'recipes',
      'description': 'Permite crear nuevas recetas y usar IA.',
      'isActive': true,
    },
    {
      '_id': 'perm_recipes_update',
      'key': 'recipes:update',
      'name': 'Actualizar recetas',
      'module': 'recipes',
      'description': 'Permite editar recetas creadas por el chef.',
      'isActive': true,
    },
    {
      '_id': 'perm_recipes_delete',
      'key': 'recipes:delete',
      'name': 'Eliminar recetas',
      'module': 'recipes',
      'description': 'Permite eliminar recetas del catálogo.',
      'isActive': true,
    },
    {
      '_id': 'perm_steps_read',
      'key': 'steps:read',
      'name': 'Ver pasos de recetas desbloqueadas',
      'module': 'steps',
      'description': 'Permite consultar el paso a paso de recetas compradas o propias.',
      'isActive': true,
    },
    {
      '_id': 'perm_steps_create',
      'key': 'steps:create',
      'name': 'Crear pasos de preparación',
      'module': 'steps',
      'description': 'Permite registrar pasos dentro de una receta.',
      'isActive': true,
    },
    {
      '_id': 'perm_steps_update',
      'key': 'steps:update',
      'name': 'Editar pasos de preparación',
      'module': 'steps',
      'description': 'Permite actualizar los pasos de una receta propia.',
      'isActive': true,
    },
    {
      '_id': 'perm_users_read',
      'key': 'users:read',
      'name': 'Consultar datos de usuario',
      'module': 'users',
      'description': 'Permite consultar información del perfil de usuario.',
      'isActive': true,
    },
    {
      '_id': 'perm_users_update',
      'key': 'users:update',
      'name': 'Actualizar datos de usuario',
      'module': 'users',
      'description': 'Permite actualizar datos personales, bancarios y de facturación.',
      'isActive': true,
    },
    {
      '_id': 'perm_profile_read',
      'key': 'profile:read',
      'name': 'Ver mi perfil',
      'module': 'profile',
      'description': 'Permite visualizar la sección Mi Perfil.',
      'isActive': true,
    },
    {
      '_id': 'perm_profile_update',
      'key': 'profile:update',
      'name': 'Editar mi perfil',
      'module': 'profile',
      'description': 'Permite editar datos personales, cuenta bancaria y facturación.',
      'isActive': true,
    },
    {
      '_id': 'perm_s3_upload',
      'key': 's3:upload',
      'name': 'Subir imágenes a S3',
      'module': 's3',
      'description': 'Permite subir fotos de perfil, portadas e imágenes de pasos.',
      'isActive': true,
    },
    {
      '_id': 'perm_roles_all',
      'key': 'roles:*',
      'name': 'Control total de roles y permisos',
      'module': 'roles',
      'description': 'Acceso completo a la configuración RBAC.',
      'isActive': true,
    },
    {
      '_id': 'perm_wildcard',
      'key': '*',
      'name': 'Super Administrador (Acceso Total)',
      'module': 'system',
      'description': 'Otorga todos los permisos del sistema.',
      'isActive': true,
    },
  ];

  static const List<Map<String, dynamic>> _fallbackRoles = [
    {
      '_id': 'role_user',
      'name': 'user',
      'displayName': 'Usuario (Comprador)',
      'description': 'Explora, guarda favoritos y compra recetas paso a paso.',
      'isActive': true,
      'permissions': [
        'recipes:read',
        'recipes:read:own',
        'steps:read',
        'profile:read',
        'profile:update',
      ],
    },
    {
      '_id': 'role_admin',
      'name': 'admin',
      'displayName': 'Chef (Creador)',
      'description': 'Crea, publica y gestiona sus propias recetas en Recetarium.',
      'isActive': true,
      'permissions': [
        'recipes:read',
        'recipes:create',
        'recipes:update',
        'steps:read',
        'steps:create',
        'steps:update',
        'users:read',
        'profile:read',
        'profile:update',
      ],
    },
    {
      '_id': 'role_super_admin',
      'name': 'super_admin',
      'displayName': 'Super Administrador',
      'description': 'Control total de usuarios, recetas, roles, permisos y ventas.',
      'isActive': true,
      'permissions': [
        'recipes:*',
        'users:*',
        'roles:*',
        'profile:*',
        '*',
      ],
    },
  ];

  Future<void> loadAllDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getDashboardStats(),
        _api.getAllRecipes(),
        _api.getAllUsers(),
        _api.getAllRoles(),
        _api.getAllPermissions(),
      ]);

      final stats = results[0] as Map<String, dynamic>?;
      final loadedRecipes = results[1] as List<RecipesModel>;
      final loadedUsers = results[2] as List<Map<String, dynamic>>;
      final loadedRoles = results[3] as List<Map<String, dynamic>>;
      final loadedPermissions = results[4] as List<Map<String, dynamic>>;

      _recipes = loadedRecipes;
      _users = loadedUsers;
      _roles = loadedRoles.isNotEmpty
          ? loadedRoles
          : _fallbackRoles.map((e) => Map<String, dynamic>.from(e)).toList();
      _permissions = loadedPermissions.isNotEmpty
          ? loadedPermissions
          : _fallbackPermissions
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

      if (stats != null) {
        _totalUsers = (stats['totalUsers'] as num?)?.toInt() ?? _users.length;
        _totalChefs = (stats['totalChefs'] as num?)?.toInt() ??
            _users.where((u) => u['role'] == 'admin').length;
        _totalRegularUsers = (stats['totalRegularUsers'] as num?)?.toInt() ??
            _users.where((u) => u['role'] == 'user').length;
        _totalSuperAdmins = (stats['totalSuperAdmins'] as num?)?.toInt() ??
            _users.where((u) => u['role'] == 'super_admin').length;
        _totalRecipes =
            (stats['totalRecipes'] as num?)?.toInt() ?? _recipes.length;
        _totalSalesCount = (stats['totalSalesCount'] as num?)?.toInt() ?? 0;
        _totalGiftsCount = (stats['totalGiftsCount'] as num?)?.toInt() ?? 0;
        _totalRevenue = (stats['totalRevenue'] as num?) ?? 0;
        final rawTx = stats['recentTransactions'];
        if (rawTx is List) {
          _transactions = rawTx.whereType<Map<String, dynamic>>().toList();
        }
      } else {
        _recalculateLocalStats();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _recalculateLocalStats() {
    _totalUsers = _users.length;
    _totalChefs = _users.where((u) => u['role'] == 'admin').length;
    _totalRegularUsers = _users.where((u) => u['role'] == 'user').length;
    _totalSuperAdmins =
        _users.where((u) => u['role'] == 'super_admin').length;
    _totalRecipes = _recipes.length;
  }

  Future<bool> deleteRecipeAsSuperAdmin(String recipeId) async {
    final ok = await _api.deleteRecipe(recipeId);
    if (ok) {
      _recipes.removeWhere((r) => r.id == recipeId);
      _totalRecipes = _recipes.length;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> updateRecipeAsSuperAdmin(
    String recipeId,
    Map<String, dynamic> updateData,
  ) async {
    final updated = await _api.updateRecipe(recipeId, updateData);
    if (updated != null) {
      final index = _recipes.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        _recipes[index] = updated;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> changeUserRole(String userId, String newRole) async {
    final ok = await _api.updateUserRole(userId, newRole);
    if (ok) {
      final idx = _users.indexWhere(
        (u) => (u['_id'] ?? u['id']).toString() == userId,
      );
      if (idx != -1) {
        _users[idx] = {
          ..._users[idx],
          'role': newRole,
        };
      }
      _recalculateLocalStats();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> removeUser(String userId) async {
    final ok = await _api.deleteUser(userId);
    if (ok) {
      _users.removeWhere((u) => (u['_id'] ?? u['id']).toString() == userId);
      _recalculateLocalStats();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> updateRolePermissions(
    String roleId,
    List<String> permissions, {
    String? displayName,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'permissions': permissions,
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      if (description != null) 'description': description,
    };

    final updated = await _api.updateRole(roleId, payload);
    final idx = _roles.indexWhere(
      (r) => (r['_id'] ?? r['id']).toString() == roleId,
    );
    if (idx != -1) {
      _roles[idx] = updated ??
          {
            ..._roles[idx],
            ...payload,
          };
      notifyListeners();
      return true;
    }
    return updated != null;
  }

  Future<bool> createNewRole({
    required String name,
    required String displayName,
    String? description,
    required List<String> permissions,
  }) async {
    final created = await _api.createRole(
      name: name,
      displayName: displayName,
      description: description,
      permissions: permissions,
    );
    if (created != null) {
      _roles.add(created);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createNewPermission({
    required String key,
    required String name,
    required String module,
    String? description,
  }) async {
    final created = await _api.createPermission(
      key: key,
      name: name,
      module: module,
      description: description,
    );
    if (created != null) {
      _permissions.add(created);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> togglePermissionActive(
    String permissionId,
    bool isActive,
  ) async {
    final updated = await _api.updatePermission(permissionId, {
      'isActive': isActive,
    });
    final idx = _permissions.indexWhere(
      (p) => (p['_id'] ?? p['id']).toString() == permissionId,
    );
    if (idx != -1) {
      _permissions[idx] = updated ??
          {
            ..._permissions[idx],
            'isActive': isActive,
          };
      notifyListeners();
      return true;
    }
    return updated != null;
  }

  Future<bool> removePermission(String permissionId) async {
    final ok = await _api.deletePermission(permissionId);
    if (ok) {
      final removed = _permissions.firstWhere(
        (p) => (p['_id'] ?? p['id']).toString() == permissionId,
        orElse: () => <String, dynamic>{},
      );
      final removedKey = (removed['key'] ?? '').toString();
      _permissions.removeWhere(
        (p) => (p['_id'] ?? p['id']).toString() == permissionId,
      );
      if (removedKey.isNotEmpty) {
        for (int i = 0; i < _roles.length; i++) {
          final currentPerms = (_roles[i]['permissions'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          if (currentPerms.contains(removedKey)) {
            currentPerms.remove(removedKey);
            _roles[i] = {
              ..._roles[i],
              'permissions': currentPerms,
            };
          }
        }
      }
      notifyListeners();
    }
    return ok;
  }
}
