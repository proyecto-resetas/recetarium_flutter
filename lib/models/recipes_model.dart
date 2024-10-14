

import 'package:resetas/models/steps_model.dart';

class RecipesModel {
  final String? id;
  final String nameRecipe;
  final String descriptionRecipe;
  final String ingredientsRecipe;
  final String imageUrl;
  final int price;
  final String level;
  final String category;
  final String createdBy;
  final List<Steps> steps; 

  RecipesModel({
  this.id,
  required this.nameRecipe,
  required this.descriptionRecipe,
  required this.ingredientsRecipe,
  required this.imageUrl,
  required this.price,
  required this.level,
  required this.category,
  required this.createdBy,
  required this.steps,

  });

//convercion de lo que se resive de la api 

    factory RecipesModel.fromJsonModel(Map<String, dynamic> json) {
      return RecipesModel(
        id: json['_id'],
        nameRecipe: json["nameRecipe"],
        descriptionRecipe: json["descriptionRecipe"],
        ingredientsRecipe: json["ingredientsRecipe"],
        imageUrl: json["imageUrl"],
        price: json["price"] is int 
        ? json["price"] 
        : throw Exception('Price must be an integer'),
        level: json["level"],
        category: json["category"],
        createdBy: json["createdBy"],
        steps: (json['steps'] as List)
          .map((stepJson) => Steps.fromJson(stepJson))
          .toList(),
      );
    }

    Map<String, dynamic> toJson() {
    return {
      'nameRecipe': nameRecipe,
      'descriptionRecipe': descriptionRecipe,
      'ingredientsRecipe': ingredientsRecipe,
      'imageUrl': imageUrl,
      'category': category,
      'level': level,
      'createdBy': createdBy,
      'price': price,
      'steps': steps,
    };
  }

  
    RecipesModel toRecipesEntity() => RecipesModel(
      id: id,
      nameRecipe: nameRecipe,
      descriptionRecipe: descriptionRecipe,
      ingredientsRecipe: ingredientsRecipe,
      imageUrl: imageUrl,
      price: price,
      level: level,
      category: category,
      createdBy: createdBy,
      steps: steps,
    );
}

