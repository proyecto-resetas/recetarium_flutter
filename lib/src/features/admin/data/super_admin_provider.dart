import 'package:flutter/material.dart';
import 'package:resetas/src/features/admin/data/super_admin_api_service.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';

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
  List<Map<String, dynamic>> get transactions => _transactions;

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
      ]);

      final stats = results[0] as Map<String, dynamic>?;
      final loadedRecipes = results[1] as List<RecipesModel>;
      final loadedUsers = results[2] as List<Map<String, dynamic>>;
      final loadedRoles = results[3] as List<Map<String, dynamic>>;

      _recipes = loadedRecipes;
      _users = loadedUsers;
      _roles = loadedRoles.isNotEmpty
          ? loadedRoles
          : _fallbackRoles.map((e) => Map<String, dynamic>.from(e)).toList();

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
}
