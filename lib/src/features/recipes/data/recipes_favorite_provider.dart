import 'package:flutter/material.dart';
import 'package:resetas/src/core/api/get_api_recetas.dart';
import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
//import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';

class RecipeFavoriteProvider extends ChangeNotifier {

  final RecetasAPI recetasAPI = RecetasAPI();
  final List<RecipesModel> _favoriteList = [];
  BookRecipe? _addFavoriteRecipe;
  UserResModel? recipeRes;
  List<RecipesModel> get favoriteList => _favoriteList;


   get addFavoriteRecipe => _addFavoriteRecipe;

   //get getFavorite => _favoriteList.iterator;

  // Método para agregar una receta a la lista de compras
  // void addToCart(RecipesModel recipe) {
  //   _favoriteList.add(recipe);
  //   notifyListeners(); // Notifica a los widgets dependientes
  // }
 
  Future<bool> addFavorite(RecipesModel recipeFavorite, userId) async {
    try {

      _addFavoriteRecipe = BookRecipe(
        idRecipe: recipeFavorite.id,
        nameRecipe: recipeFavorite.nameRecipe,
    );

    final recipeResponse = await recetasAPI.addRecipeFavorite(userId, addFavoriteRecipe);

   recipeRes = recipeResponse;
      if(recipeRes != null){
           notifyListeners();
           return true; 
      }

      return false; 
    } catch (e) {
      return false; 
    }
  }


  Future<void> getFavorites(UserResModel? user) async {

    try {

final recipes = await recetasAPI.getRecipesProperty(user!.id, type: 'favorite');

      _favoriteList.clear(); 
      _favoriteList.addAll(recipes); 
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
