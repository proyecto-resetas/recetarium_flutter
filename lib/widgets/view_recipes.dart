import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/widgets/card_recipe.dart';

class ViewRecipes extends StatelessWidget {
  const ViewRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final viewRecipesProvider = context.watch<ViewRecipesProvider>();

    String? selectedCategory;
    String? selectedLevel;
    String? createdBy;

    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              color: colors.onInverseSurface,
              onPressed: () {
                viewRecipesProvider.clearListRecipe();
                viewRecipesProvider.getRecipeFilter(
                    selectedCategory, selectedLevel, createdBy);
              },
              icon: const Icon(Icons.search),
            ),
          ],
          backgroundColor: colors.secondaryContainer,
          title: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  height: 40,
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name Chef',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      createdBy = value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    icon: Icon(color: colors.surface, Icons.filter_alt),
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: const TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    value: selectedCategory,
                    items: [
                      'Entradas',
                      'Aperitivos',
                      'Platos principales', 
                      'Postres',
                      'Sopas', 
                      'Ensaladas', 
                      'Guarniciones', 
                      'Salsas'
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                  ),
                ),
                //   const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    icon: Icon(color: colors.surface, Icons.filter_alt),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: InputDecoration(
                      labelText: 'Nivel',
                      labelStyle: const TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    value: selectedLevel,
                    items: ['Basico', 'Intermedio', 'Avanzado']
                        .map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedLevel = value;
                    },
                  ),
                ),
              ],
            ),
          )),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: viewRecipesProvider.recipeScrollController,
              itemCount: viewRecipesProvider.recipeListFilter
                  .length, // entrada a la lista que se encuantra en la clase porvider del chat
              itemBuilder: (context, index) {
                final recipe = viewRecipesProvider.recipeListFilter[index];

                return CardRecipe(recipes: recipe);
              },
            ),
          ),
        ],
      ),
    );
  }
}
