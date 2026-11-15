import 'package:recetarium/src/features/recipes/models/ingredients_model.dart';
import 'package:recetarium/src/features/recipes/models/steps_model.dart';
import 'package:recetarium/src/features/recipes/models/utensil_model.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';

class RecipesModel {
  final String? id;
  final String nameRecipe;
  final String descriptionRecipe;
  final List<Ingredients>? ingredientsRecipe;
  final String? imageUrl;
  final num price;
  final String level;
  final String category;
  final dynamic createdBy;
  final List<Utensils>? utensilRecipe;
  final List<Steps>? steps;

  // Campos calculados para búsqueda por ingredientes de la despensa
  final int? matchPercentage;
  final int? totalIngredientsCount;
  final int? matchedIngredientsCount;
  final int? missingIngredientsCount;
  final int? effectiveMissingCount;
  final List<Ingredients>? matchedIngredients;
  final List<Ingredients>? missingIngredients;

  bool get isFree => price <= 0;

  /// Verifica si el [user] actual es el creador de esta receta.
  bool isCreatedByUser(UserResModel? user) {
    if (user == null) return false;
    final userId = user.id.trim();
    if (createdBy is Map) {
      final creatorId =
          (createdBy['_id'] ?? createdBy['id'] ?? '').toString().trim();
      if (userId.isNotEmpty && creatorId == userId) {
        return true;
      }
      final creatorEmail = (createdBy['email'] ?? '').toString().trim();
      if (user.email.isNotEmpty &&
          creatorEmail.isNotEmpty &&
          creatorEmail.toLowerCase() == user.email.trim().toLowerCase()) {
        return true;
      }
    } else if (createdBy is String) {
      final raw = (createdBy as String).trim();
      if (userId.isNotEmpty && raw == userId) {
        return true;
      }
      if (user.username.isNotEmpty &&
          raw.toLowerCase() == user.username.trim().toLowerCase()) {
        return true;
      }
    }
    if (id != null && id!.isNotEmpty && user.myRecipe != null) {
      final matchesMyRecipe = user.myRecipe!.any(
        (b) => b.idRecipe == id || b.id == id,
      );
      if (matchesMyRecipe) return true;
    }
    return false;
  }

  /// Solo muestra publicidad cuando la receta es gratuita y el usuario actual
  /// NO es quien creó la receta.
  bool shouldShowAdsForUser(UserResModel? user) {
    return isFree && !isCreatedByUser(user);
  }

  String get creatorDisplayName {
    if (createdBy == null) return 'Anónimo';
    if (createdBy is String) return createdBy as String;
    if (createdBy is Map) {
      final username = createdBy['username'] ?? '';
      final lastname = createdBy['lastname'] ?? '';
      final fullName = '$username $lastname'.trim();
      return fullName.isEmpty ? 'Anónimo' : fullName;
    }
    return 'Anónimo';
  }

  RecipesModel({
    this.id,
    required this.nameRecipe,
    required this.descriptionRecipe,
    this.ingredientsRecipe,
    this.imageUrl,
    required this.price,
    required this.level,
    required this.category,
    this.createdBy,
    this.utensilRecipe,  
    this.steps,
    this.matchPercentage,
    this.totalIngredientsCount,
    this.matchedIngredientsCount,
    this.missingIngredientsCount,
    this.effectiveMissingCount,
    this.matchedIngredients,
    this.missingIngredients,
  });

  // Conversión de lo que se recibe de la API
  factory RecipesModel.fromJsonModel(Map<String, dynamic> json) {
    return RecipesModel(
      id: json['_id'],
      nameRecipe: json["nameRecipe"] ?? '',
      descriptionRecipe: json["descriptionRecipe"] ?? '',
      ingredientsRecipe: json['ingredientsRecipe'] != null
        ? (json['ingredientsRecipe'] as List)
            .whereType<Map<String, dynamic>>()
            .map((ingredientJson) => Ingredients.fromJson(ingredientJson))
            .toList()
        : [],
      imageUrl: json["imageUrl"],
      price: json["price"] ?? 0,
      level: json["level"] ?? '',
      category: json["category"] ?? '',
      createdBy: json['createdBy'],
      utensilRecipe: json['utensilRecipe'] != null
        ? (json['utensilRecipe'] as List)
            .whereType<Map<String, dynamic>>()
            .map((utensilJson) => Utensils.fromJson(utensilJson))
            .toList()
        : [],
      steps: json['steps'] != null
        ? (json['steps'] as List)
            .whereType<Map<String, dynamic>>()
            .map((stepJson) => Steps.fromJson(stepJson))
            .toList()
        : [],
      matchPercentage: json['matchPercentage'] != null
          ? (json['matchPercentage'] as num).toInt()
          : null,
      totalIngredientsCount: json['totalIngredientsCount'] != null
          ? (json['totalIngredientsCount'] as num).toInt()
          : null,
      matchedIngredientsCount: json['matchedIngredientsCount'] != null
          ? (json['matchedIngredientsCount'] as num).toInt()
          : null,
      missingIngredientsCount: json['missingIngredientsCount'] != null
          ? (json['missingIngredientsCount'] as num).toInt()
          : null,
      effectiveMissingCount: json['effectiveMissingCount'] != null
          ? (json['effectiveMissingCount'] as num).toInt()
          : null,
      matchedIngredients: json['matchedIngredients'] != null
          ? (json['matchedIngredients'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => Ingredients.fromJson(i))
              .toList()
          : null,
      missingIngredients: json['missingIngredients'] != null
          ? (json['missingIngredients'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => Ingredients.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nameRecipe': nameRecipe,
      'descriptionRecipe': descriptionRecipe,
      'ingredientsRecipe': ingredientsRecipe,
      'imageUrl': imageUrl,
      'category': category,
      'level': level,
      'createdBy': createdBy,
      'price': price,
      'utensilRecipe': utensilRecipe,
      'steps': steps,
      if (matchPercentage != null) 'matchPercentage': matchPercentage,
      if (effectiveMissingCount != null)
        'effectiveMissingCount': effectiveMissingCount,
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
    utensilRecipe: utensilRecipe, 
    steps: steps,
    matchPercentage: matchPercentage,
    totalIngredientsCount: totalIngredientsCount,
    matchedIngredientsCount: matchedIngredientsCount,
    missingIngredientsCount: missingIngredientsCount,
    effectiveMissingCount: effectiveMissingCount,
    matchedIngredients: matchedIngredients,
    missingIngredients: missingIngredients,
  );
}

