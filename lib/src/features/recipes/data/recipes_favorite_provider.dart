import 'package:flutter/material.dart';
import 'package:resetas/src/features/recipes/data/recipes_api_service.dart';
import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
//import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';

import 'package:resetas/src/core/services/local_storage_service.dart';

class RecipeFavoriteProvider extends ChangeNotifier {

  final RecipesApiService recetasAPI = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final List<RecipesModel> _favoriteList = [];
  BookRecipe? _addFavoriteRecipe;
  UserResModel? recipeRes;
  List<RecipesModel> get favoriteList => _favoriteList;

  get addFavoriteRecipe => _addFavoriteRecipe;

  Future<bool> addFavorite(RecipesModel recipeFavorite, userId) async {
    try {
      final effectiveUserId = userId ?? _localStorageService.userData?['id'];
      if (effectiveUserId == null) return false;

      _addFavoriteRecipe = BookRecipe(
        idRecipe: recipeFavorite.id,
        nameRecipe: recipeFavorite.nameRecipe,
      );

      final recipeResponse =
          await recetasAPI.addRecipeFavorite(effectiveUserId, addFavoriteRecipe);

      recipeRes = recipeResponse;
      if (recipeRes != null) {
        if (!_favoriteList.any((r) => r.id == recipeFavorite.id)) {
          _favoriteList.add(recipeFavorite);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(RecipesModel recipe) async {
    if (recipe.id == null) return false;
    final removed = await recetasAPI.removeRecipeFavorite(recipe.id!);
    if (removed) {
      _favoriteList.removeWhere((r) => r.id == recipe.id);
      notifyListeners();
    }
    return removed;
  }

  Future<void> getFavorites(UserResModel? user) async {
    try {
      final userId = user?.id ?? _localStorageService.userData?['id'] ?? '';

      final recipes =
          await recetasAPI.getRecipesProperty(userId, type: 'favorite');
      _favoriteList.clear();
      _favoriteList.addAll(recipes);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
