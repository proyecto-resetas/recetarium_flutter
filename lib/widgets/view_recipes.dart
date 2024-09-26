import 'package:flutter/material.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/widgets/card_recipe.dart';

class ViewRecipes extends StatelessWidget {

  const ViewRecipes( {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final viewRecipesProvider = context.watch<ViewRecipesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.secondaryContainer,
        title: const Text('All of the Recipes'),
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

  // const Text('Calificación:'),
            // RatingBar.builder(             
            //   itemSize: 20,
            //   initialRating: 3, // Valor inicial
            //   minRating: 1, // Calificación mínima
            //   direction: Axis.horizontal, // Dirección horizontal
            //   allowHalfRating: true, // Permite media estrella
            //   itemCount: 3, // Número de estrellas
            //   itemPadding:const EdgeInsets.symmetric(horizontal: 2.0),
            //    itemBuilder: (context, _) => const Icon(
            //     Icons.star,
            //     color: Colors.amber,
            //   ),
            //   onRatingUpdate: (rating) {
            //     print(rating); // Actualiza la calificación en tiempo real
            //   },
            // ),