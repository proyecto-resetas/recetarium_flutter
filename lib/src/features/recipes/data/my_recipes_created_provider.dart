import 'package:flutter/material.dart';
import 'package:resetas/src/features/recipes/data/recipes_api_service.dart';
//import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';

import 'package:resetas/src/core/services/local_storage_service.dart';

class RecipeMyCreatedProvider extends ChangeNotifier {

  final RecipesApiService recetasAPI = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final List<RecipesModel> _myRecipeList = [];
  UserResModel? recipeRes;

  List<RecipesModel> get myRecipeList => _myRecipeList;

  Future<void> getMyRecipesCreated(UserResModel? user) async {
    try {
      final userId = user?.id ?? _localStorageService.userData?['id'] ?? '';

      final createdRecipes =
          await recetasAPI.getRecipesProperty(userId, type: 'created');
      final myRecipes =
          await recetasAPI.getRecipesProperty(userId, type: 'myRecipes');

      final Map<String, RecipesModel> combined = {};
      for (final r in [...createdRecipes, ...myRecipes]) {
        final key = r.id ?? r.nameRecipe;
        combined[key] = r;
      }

      _myRecipeList
        ..clear()
        ..addAll(combined.values);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
