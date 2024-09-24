import 'package:flutter/material.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/entities/recipes.dart';

class ViewRecipesProvider extends ChangeNotifier {
  
  Recipes? recetas; 
  final _favorites = [];
  final RecetasAPI recetasAPI = RecetasAPI();

  Recipes? get getRecetas => recetas;

  get setFavorite => _favorites.iterator;
  

  // void toggleFavorite() {
  //   if (favorites.contains()) {
  //     favorites.remove();
  //   } else {
  //     favorites.add();
  //   }
  //   notifyListeners();
  // }

  Future<bool> getResetas() async {
    try {
      recetas = await recetasAPI.getResetas();
      if (recetas != null) {
        notifyListeners();
        return true; // Registro exitoso
      }
      return false; // Falló el registro
    } catch (e) {
     //  print('Error durante el registro: $e');
      return false; // Error en el registro
    }
  }



} 