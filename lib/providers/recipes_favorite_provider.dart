import 'package:flutter/material.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/book_recipe_model.dart';
//import 'package:resetas/models/book_recipe_model.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/models/user_model.dart';

class RecipeFavoriteProvider extends ChangeNotifier {

  final RecetasAPI recetasAPI = RecetasAPI();
  final List<RecipesModel> _favoriteList = [];
  BookRecipe? _addFavoriteRecipe;
  UserResModel? recipeRes;
  List<RecipesModel> get favoriteList => _favoriteList;


   get addFavoriteRecipe => _addFavoriteRecipe;

   //get getFavorite => _favoriteList.iterator;

  // Método para agregar una receta a la lista de compras
  void addToCart(RecipesModel recipe) {
    _favoriteList.add(recipe);
    notifyListeners(); // Notifica a los widgets dependientes
  }
 
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
      final response = await recetasAPI.getFavoriteRecipes(user!.id);

      // Supongamos que 'response' es una lista de recetas.
      _favoriteList.clear(); 
      _favoriteList.addAll(response); 
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }
}
