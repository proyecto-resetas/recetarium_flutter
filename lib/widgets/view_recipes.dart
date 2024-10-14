import 'package:flutter/material.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/widgets/card_recipe.dart';

class ViewRecipes extends StatelessWidget {

  const ViewRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final viewRecipesProvider = context.watch<ViewRecipesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.secondaryContainer,
        title: const Text(''),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                controller: viewRecipesProvider.recipeScrollController,
                itemCount: viewRecipesProvider.recipeList.length, // entrada a la lista que se encuantra en la clase porvider del chat
                itemBuilder: (context, index) {
               final recipe = viewRecipesProvider.recipeList[index];

               return CardRecipe(recipes:recipe);
                },
              ),
            ),
//          const SizedBox(height: 20)
        ],
      ),
    );
  }
}

