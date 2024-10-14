import 'package:flutter/material.dart';
import 'package:resetas/models/recipes_model.dart';

class CarShopProvider extends ChangeNotifier {
  final List<RecipesModel> _shoppingList = [];

  List<RecipesModel> get shoppingList => _shoppingList;

  // Método para agregar una receta a la lista de compras
  void addToCart(RecipesModel recipe) {
    _shoppingList.add(recipe);
    notifyListeners(); // Notifica a los widgets dependientes
  }

  // Método para eliminar una receta de la lista de compras
  void removeFromCart(RecipesModel recipe) {
    _shoppingList.remove(recipe);
    notifyListeners();
  }

  // Método para limpiar la lista de compras
  void clearCart() {
    _shoppingList.clear();
    notifyListeners();
  }
}

  
  
