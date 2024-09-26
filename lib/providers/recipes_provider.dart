import 'package:flutter/material.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/recipes_model.dart';

class ViewRecipesProvider extends ChangeNotifier {

  final ScrollController recipeScrollController = ScrollController();
  
  RecipesModel? recetas; 
  final _favorites = [];
  final RecetasAPI recetasAPI = RecetasAPI();

  RecipesModel? get getRecetas => recetas;

  get setFavorite => _favorites.iterator;
  
 List<RecipesModel> recipeList = [
   RecipesModel( 
     id:'',
      nameRecipe: 'huevo',
      descriptionRecipe: 'descriptionRecipe',
      ingredientsRecipe: 'ingredientsRecipe',
      imageUrl: 'https://cdn.recetasderechupete.com/wp-content/uploads/2020/09/4.jpg',
      price: '1234',
      steps: [],
      ),
       RecipesModel( 
        id:'',
      nameRecipe: 'cafe',
      descriptionRecipe: 'descriptionRecipe',
      ingredientsRecipe: 'ingredientsRecipe',
      imageUrl: 'https://mascolombia.com/wp-content/uploads/2023/09/precio-del-cafe-en-el-mundo-asi-funciona-la-montana-rusa-de-la-cotizacion-internacional.jpg',
      price: '1634',
      steps: [],
      ),
  ];
  // void toggleFavorite() {
  //   if (favorites.contains()) {
  //     favorites.remove();
  //   } else {
  //     favorites.add();
  //   }
  //   notifyListeners();
  // }
  ViewRecipesProvider() {
    getResetas();
  }

 Future<void> getResetas() async {
  // Asegúrate de que getResetas devuelva un List<Recipes>
  final List<RecipesModel> recetas = await recetasAPI.getResetas(); 
  print(recetas);
  recipeList.addAll(recetas); // Usa addAll para agregar todos los elementos de la lista
  notifyListeners();
}

} 