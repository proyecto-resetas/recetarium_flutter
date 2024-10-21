import 'package:flutter/material.dart';
import 'package:resetas/models/recipes_model.dart';

class RecipeFavoriteProvider extends ChangeNotifier {
  final List<RecipesModel> _favoriteList = [];

  List<RecipesModel> get favoriteList => _favoriteList;

   get getFavorite => _favoriteList.iterator;

  // Método para agregar una receta a la lista de compras
  void addToCart(RecipesModel recipe) {
    _favoriteList.add(recipe);
    notifyListeners(); // Notifica a los widgets dependientes
  }

  // Método para eliminar una receta de la lista de compras
  void removeFromCart(RecipesModel recipe) {
    _favoriteList.remove(recipe);
    notifyListeners();
  }

  // Método para limpiar la lista de compras
  void clearCart() {
    _favoriteList.clear();
    notifyListeners();
  }
}
