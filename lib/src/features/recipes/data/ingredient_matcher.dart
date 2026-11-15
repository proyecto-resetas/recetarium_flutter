import 'package:recetarium/src/features/recipes/models/ingredients_model.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';

class IngredientMatcher {
  IngredientMatcher._();

  static const List<String> _commonStaples = [
    'sal',
    'agua',
    'pimienta',
    'aceite',
    'aceite de oliva',
    'aceite vegetal',
    'sal y pimienta',
    'sal marina',
  ];

  /// Normaliza texto eliminando tildes y convirtiendo a minúsculas.
  static String normalizeCulinaryText(String text) {
    if (text.isEmpty) return '';
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .trim();
  }

  /// Genera variantes singular/plural básicas para mejorar coincidencias.
  static List<String> getWordVariants(String word) {
    final clean = normalizeCulinaryText(word);
    if (clean.isEmpty) return const [];
    if (clean.length < 3) return [clean];

    final variants = <String>{clean};
    if (clean.endsWith('es') && clean.length > 4) {
      variants.add(clean.substring(0, clean.length - 2));
    } else if (clean.endsWith('s') && clean.length > 3) {
      variants.add(clean.substring(0, clean.length - 1));
    } else {
      variants.add('${clean}s');
      variants.add('${clean}es');
    }
    return variants.toList();
  }

  /// Verifica si [targetNormalized] contiene alguna variante de [term].
  static bool matchesTerm(String targetNormalized, String term) {
    final variants = getWordVariants(term);
    for (final v in variants) {
      final escaped = RegExp.escape(v);
      final wordRegex = RegExp('(^|\\s|[.,;])$escaped(\$|\\s|[.,;])');
      if (wordRegex.hasMatch(targetNormalized) ||
          targetNormalized.contains(v)) {
        return true;
      }
    }
    return false;
  }

  static bool isStapleIngredient(String normalizedDesc) {
    return _commonStaples.any((staple) {
      final variants = getWordVariants(staple);
      return variants.any((v) {
        final escaped = RegExp.escape(v);
        final regex = RegExp('(^|\\s|[.,;])$escaped(\$|\\s|[.,;])');
        return regex.hasMatch(normalizedDesc);
      });
    });
  }

  /// Evalúa si una receta coincide con un término simple (en título, chef o ingredientes).
  static bool matchesSingleTextQuery(RecipesModel recipe, String query) {
    final qNorm = normalizeCulinaryText(query);
    if (qNorm.isEmpty) return true;

    if (matchesTerm(normalizeCulinaryText(recipe.nameRecipe), qNorm)) {
      return true;
    }
    if (matchesTerm(normalizeCulinaryText(recipe.category), qNorm)) {
      return true;
    }
    if (matchesTerm(normalizeCulinaryText(recipe.creatorDisplayName), qNorm)) {
      return true;
    }
    final ingredients = recipe.ingredientsRecipe ?? const <Ingredients>[];
    for (final ing in ingredients) {
      if (matchesTerm(normalizeCulinaryText(ing.description), qNorm)) {
        return true;
      }
    }
    return false;
  }

  /// Filtra y ordena el catálogo de recetas según una lista de tags de ingredientes.
  static List<RecipesModel> scoreAndRankByTags({
    required List<RecipesModel> recipes,
    required List<String> tags,
    String? extraTextQuery,
    String? category,
    String? level,
    bool excludeStaplesFromMissing = true,
  }) {
    final cleanTags = tags
        .map((t) => normalizeCulinaryText(t))
        .where((t) => t.isNotEmpty)
        .toList();

    final cleanQuery = normalizeCulinaryText(extraTextQuery ?? '');

    final scored = <_ScoredRecipe>[];

    for (final recipe in recipes) {
      if (category != null &&
          category.isNotEmpty &&
          recipe.category.toLowerCase() != category.toLowerCase()) {
        continue;
      }
      if (level != null &&
          level.isNotEmpty &&
          recipe.level.toLowerCase() != level.toLowerCase()) {
        continue;
      }

      if (cleanQuery.isNotEmpty && !matchesSingleTextQuery(recipe, cleanQuery)) {
        continue;
      }

      if (cleanTags.isEmpty) {
        scored.add(_ScoredRecipe(recipe: recipe, matchedUserTags: 0));
        continue;
      }

      final recipeIngredients = recipe.ingredientsRecipe ?? const <Ingredients>[];
      final matched = <Ingredients>[];
      final missing = <Ingredients>[];
      int stapleMissingCount = 0;

      // Track which of the user's tags matched at least 1 ingredient in this recipe
      final matchedTagsSet = <String>{};

      for (final ing in recipeIngredients) {
        final descNorm = normalizeCulinaryText(ing.description);
        bool ingMatched = false;

        for (final tag in cleanTags) {
          if (matchesTerm(descNorm, tag)) {
            ingMatched = true;
            matchedTagsSet.add(tag);
          }
        }

        final isStaple = ing.isStaple || isStapleIngredient(descNorm);
        final enrichedIng = Ingredients(
          id: ing.id,
          description: ing.description,
          amount: ing.amount,
          isStaple: isStaple,
        );

        if (ingMatched) {
          matched.add(enrichedIng);
        } else {
          if (isStaple) stapleMissingCount++;
          missing.add(enrichedIng);
        }
      }

      if (matched.isEmpty) continue;

      final totalCount = recipeIngredients.length;
      final matchedCount = matched.length;
      final missingCount = missing.length;
      final effectiveMissing = excludeStaplesFromMissing
          ? (missingCount - stapleMissingCount).clamp(0, missingCount)
          : missingCount;
      final matchPercentage =
          totalCount > 0 ? ((matchedCount / totalCount) * 100).round() : 0;

      final enrichedRecipe = RecipesModel(
        id: recipe.id,
        nameRecipe: recipe.nameRecipe,
        descriptionRecipe: recipe.descriptionRecipe,
        ingredientsRecipe: recipe.ingredientsRecipe,
        imageUrl: recipe.imageUrl,
        price: recipe.price,
        level: recipe.level,
        category: recipe.category,
        createdBy: recipe.createdBy,
        utensilRecipe: recipe.utensilRecipe,
        steps: recipe.steps,
        matchPercentage: matchPercentage,
        totalIngredientsCount: totalCount,
        matchedIngredientsCount: matchedCount,
        missingIngredientsCount: missingCount,
        effectiveMissingCount: effectiveMissing,
        matchedIngredients: matched,
        missingIngredients: missing,
      );

      scored.add(
        _ScoredRecipe(
          recipe: enrichedRecipe,
          matchedUserTags: matchedTagsSet.length,
        ),
      );
    }

    scored.sort((a, b) {
      // 1. Mayor cantidad de tags del usuario presentes en la receta
      if (b.matchedUserTags != a.matchedUserTags) {
        return b.matchedUserTags.compareTo(a.matchedUserTags);
      }
      // 2. Menor cantidad de ingredientes faltantes reales
      final missingA = a.recipe.effectiveMissingCount ?? 0;
      final missingB = b.recipe.effectiveMissingCount ?? 0;
      if (missingA != missingB) {
        return missingA.compareTo(missingB);
      }
      // 3. Mayor porcentaje de compatibilidad
      final pctA = a.recipe.matchPercentage ?? 0;
      final pctB = b.recipe.matchPercentage ?? 0;
      if (pctB != pctA) {
        return pctB.compareTo(pctA);
      }
      // 4. Mayor número de ingredientes coincidentes
      return (b.recipe.matchedIngredientsCount ?? 0)
          .compareTo(a.recipe.matchedIngredientsCount ?? 0);
    });

    return scored.map((s) => s.recipe).toList();
  }
}

class _ScoredRecipe {
  final RecipesModel recipe;
  final int matchedUserTags;

  _ScoredRecipe({
    required this.recipe,
    required this.matchedUserTags,
  });
}
