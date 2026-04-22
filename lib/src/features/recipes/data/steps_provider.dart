import 'package:flutter/material.dart';
import 'package:resetas/src/features/recipes/data/recipes_api_service.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/recipes/models/steps_model.dart';

class StepsProvider with ChangeNotifier {
  final RecipesApiService _recipesApiService = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Steps> _steps = [];
  bool _isLoading = false;

  List<Steps> get steps => _steps;
  bool get isLoading => _isLoading;

  Future<void> fetchSteps(String recipeId) async {
    _isLoading = true;
    notifyListeners();

    final token = _localStorageService.token;
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final List<dynamic> data = await _recipesApiService.getRecipeSteps(recipeId, token);
      _steps = data.map((stepJson) => Steps.fromJson(stepJson)).toList();
      print('Steps cargados: ${_steps.length}');
      print('Steps: ${_steps}');
    } catch (e) {
      print('Error en fetchSteps: $e');
      _steps = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSteps() {
    _steps = [];
    notifyListeners();
  }
}
