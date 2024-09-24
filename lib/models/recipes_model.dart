import 'package:resetas/models/entities/recipes.dart';

class RecipesModel {
  
  final String nameRecipe;
  final String descriptionRecipe;
  final String ingredientsRecipe;
  final String? imageUrl;
  final int price;
  final Iterable steps;
 

  RecipesModel({
  required this.nameRecipe,
  required this.descriptionRecipe,
  required this.ingredientsRecipe,
  this.imageUrl,
  required this.price,
  required this.steps,

  });

//convercion de lo que se resive de la api 

    factory RecipesModel.fromJsonModel(Map<String, dynamic> json) => RecipesModel(
        nameRecipe: json["nameRecipe"],
        descriptionRecipe: json["descriptionRecipe"],
        ingredientsRecipe: json["ingredientsRecipe"],
        imageUrl: json["imageUrl"],
        price: json["price"],
        steps: json["steps"],
    );

    // Map<String, dynamic> toJson() => {
    //     "access_token": accessToken,
    // };

    Map<String, dynamic> toJson() {
    return {
      'nameRecipe': nameRecipe,
      'descriptionRecipe': descriptionRecipe,
      'ingredientsRecipe': ingredientsRecipe,
      'imageUrl': imageUrl,
      'price': price,
      'steps': steps,
    };
  }

  
    Recipes toRecipesEntity() => Recipes(
      nameRecipe: nameRecipe,
      descriptionRecipe: descriptionRecipe,
      ingredientsRecipe: ingredientsRecipe,
      imageUrl: imageUrl,
      price: price,
      steps: steps,
    );
}