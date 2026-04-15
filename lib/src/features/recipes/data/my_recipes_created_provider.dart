import 'package:flutter/material.dart';
import 'package:resetas/src/core/api/get_api_recetas.dart';
//import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';

class RecipeMyCreatedProvider extends ChangeNotifier {

  final RecetasAPI recetasAPI = RecetasAPI();
  final List<RecipesModel> _myRecipeList = [];
  UserResModel? recipeRes;

  //BookRecipe? _addFavoriteRecipe;
  List<RecipesModel> get myRecipeList => _myRecipeList;

   //get addFavoriteRecipe => _addFavoriteRecipe;

  Future<void> getMyRecipesCreated(UserResModel? user) async {

    try {
final recipes = await recetasAPI.getRecipesProperty(user!.id, type: 'myRecipes');

      _myRecipeList.clear(); 
      _myRecipeList.addAll(recipes); 
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
