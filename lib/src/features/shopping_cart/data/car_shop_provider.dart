import 'package:flutter/material.dart';
import 'package:resetas/src/features/recipes/data/recipes_api_service.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';

class CarShopProvider extends ChangeNotifier {
  final RecipesApiService _recipesApiService = RecipesApiService();
  final List<RecipesModel> _shoppingList = [];
  final List<RecipesModel> _purchasedList = [];
  bool _isPurchasing = false;

  List<RecipesModel> get shoppingList => _shoppingList;
  List<RecipesModel> get purchasedList => _purchasedList;
  bool get isPurchasing => _isPurchasing;

  double get totalPrice =>
      _shoppingList.fold(0.0, (sum, item) => sum + item.price);

  // Método para agregar una receta a la lista de compras
  void addToCart(RecipesModel recipe) {
    if (!_shoppingList.any((r) => r.id == recipe.id)) {
      _shoppingList.add(recipe);
      notifyListeners();
    }
  }

  // Método para eliminar una receta de la lista de compras
  void removeFromCart(RecipesModel recipe) {
    _shoppingList.removeWhere((r) => r.id == recipe.id);
    notifyListeners();
  }

  // Método para limpiar la lista de compras
  void clearCart() {
    _shoppingList.clear();
    notifyListeners();
  }

  // Comprar una receta individual usando POST /Recipes/purchase/:id
  Future<RecipesModel?> purchaseRecipe(
    RecipesModel recipe, {
    String? paymentReference,
    String? recipientEmail,
  }) async {
    if (recipe.id == null) return null;
    final purchased = await _recipesApiService.purchaseRecipe(
      recipe.id!,
      paymentReference: paymentReference,
      recipientEmail: recipientEmail,
    );
    if (purchased != null) {
      _shoppingList.removeWhere((r) => r.id == recipe.id);
      if (!_purchasedList.any((r) => r.id == purchased.id)) {
        _purchasedList.add(purchased);
      }
      notifyListeners();
    }
    return purchased;
  }

  // Comprar todas las recetas en el carrito usando POST /Recipes/purchase/:id
  Future<int> checkoutCart({
    String? paymentReference,
    String? recipientEmail,
  }) async {
    if (_shoppingList.isEmpty) return 0;
    _isPurchasing = true;
    notifyListeners();

    int successCount = 0;
    final itemsToBuy = List<RecipesModel>.from(_shoppingList);

    try {
      for (final recipe in itemsToBuy) {
        if (recipe.id == null) continue;
        try {
          final purchased = await _recipesApiService.purchaseRecipe(
            recipe.id!,
            paymentReference: paymentReference,
            recipientEmail: recipientEmail,
          );
          if (purchased != null) {
            successCount++;
            _shoppingList.removeWhere((r) => r.id == recipe.id);
            if (!_purchasedList.any((r) => r.id == purchased.id)) {
              _purchasedList.add(purchased);
            }
          }
        } catch (e) {
          debugPrint('Error comprando receta ${recipe.id}: $e');
        }
      }
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }

    return successCount;
  }

  // Obtener las recetas compradas usando GET /Recipes/my-list/purchased
  Future<void> getPurchasedRecipes() async {
    final recipes = await _recipesApiService.getPurchasedRecipes();
    _purchasedList
      ..clear()
      ..addAll(recipes);
    notifyListeners();
  }
}

