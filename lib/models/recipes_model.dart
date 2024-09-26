

class RecipesModel {
  final String id;
  final String nameRecipe;
  final String descriptionRecipe;
  final String ingredientsRecipe;
  final String imageUrl;
  final String price;
  final List<Step> steps; 

  RecipesModel({
  required this.id,
  required this.nameRecipe,
  required this.descriptionRecipe,
  required this.ingredientsRecipe,
  required this.imageUrl,
  required this.price,
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
        price: json['price'],
        steps: (json['steps'] as List)
          .map((stepJson) => Step.fromJson(stepJson))
          .toList(),
      );
    }


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

  
    RecipesModel toRecipesEntity() => RecipesModel(
      id: id,
      nameRecipe: nameRecipe,
      descriptionRecipe: descriptionRecipe,
      ingredientsRecipe: ingredientsRecipe,
      imageUrl: imageUrl,
      price: price,
      steps: steps,
    );
}

class Step {
  final String description;
  final String time;
  final String id;

  Step({
    required this.description,
    required this.time,
    required this.id,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      description: json['description'],
      time: json['time'],
      id: json['_id'],
    );
  }
}