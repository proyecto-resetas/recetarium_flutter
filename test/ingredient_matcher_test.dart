import 'package:flutter_test/flutter_test.dart';
import 'package:recetarium/src/features/recipes/data/ingredient_matcher.dart';
import 'package:recetarium/src/features/recipes/models/ingredients_model.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';

void main() {
  group('IngredientMatcher', () {
    final omelette = RecipesModel(
      id: '1',
      nameRecipe: 'Tortilla Campesina',
      descriptionRecipe: 'Rápida y deliciosa',
      price: 0,
      level: 'Basico',
      category: 'Plato principal',
      ingredientsRecipe: [
        Ingredients(description: '2 huevos grandes', amount: '2 unidades'),
        Ingredients(description: 'Tomate maduro picado', amount: '1 unidad'),
        Ingredients(description: 'Cebolla blanca', amount: '1/2 unidad'),
        Ingredients(description: 'Sal y pimienta al gusto', amount: '1 pizca'),
      ],
    );

    final cevicheAtun = RecipesModel(
      id: '2',
      nameRecipe: 'Ceviche Fresco',
      descriptionRecipe: 'Con limón natural',
      price: 12,
      level: 'Intermedio',
      category: 'Entrada',
      ingredientsRecipe: [
        Ingredients(description: 'Lomo de atún fresco', amount: '250g'),
        Ingredients(description: 'Zumo de limón', amount: '3 unidades'),
        Ingredients(description: 'Cebolla morada', amount: '1 unidad'),
      ],
    );

    final huevosRevueltos = RecipesModel(
      id: '3',
      nameRecipe: 'Desayuno Express',
      descriptionRecipe: 'Sencillo',
      price: 0,
      level: 'Basico',
      category: 'Entrada',
      ingredientsRecipe: [
        Ingredients(description: '1 huevo', amount: '1 unidad'),
        Ingredients(description: 'Sal', amount: '1 pizca'),
      ],
    );

    test('encuentra ingredientes ignorando tildes y singular/plural', () {
      expect(
        IngredientMatcher.matchesSingleTextQuery(cevicheAtun, 'atun'),
        isTrue,
      );
      expect(
        IngredientMatcher.matchesSingleTextQuery(cevicheAtun, 'limones'),
        isTrue,
      );
      expect(
        IngredientMatcher.matchesSingleTextQuery(omelette, 'huevo'),
        isTrue,
      );
      expect(
        IngredientMatcher.matchesSingleTextQuery(huevosRevueltos, 'huevos'),
        isTrue,
      );
    });

    test('clasifica recetas priorizando mayor cantidad de tags coincidentes', () {
      final results = IngredientMatcher.scoreAndRankByTags(
        recipes: [huevosRevueltos, cevicheAtun, omelette],
        tags: ['huevo', 'tomate', 'cebolla'],
      );

      expect(results.length, 3);
      // Tortilla Campesina coincide con los 3 tags (huevo, tomate, cebolla) -> 1ra posición
      expect(results[0].id, '1');
      expect(results[0].effectiveMissingCount, 0); // Sal y pimienta es básico
      expect(results[0].matchPercentage, 75);

      // Desayuno Express (1 tag, 0 faltantes) vs Ceviche Fresco (1 tag, 2 faltantes)
      expect(results[1].id, '3');
      expect(results[2].id, '2');
    });

    test('aplica filtros combinados de categoría y nivel junto con tags', () {
      final results = IngredientMatcher.scoreAndRankByTags(
        recipes: [huevosRevueltos, cevicheAtun, omelette],
        tags: ['huevo', 'cebolla'],
        category: 'Entrada',
      );

      expect(results.length, 2);
      expect(results.any((r) => r.id == '1'), isFalse);
    });
  });
}
