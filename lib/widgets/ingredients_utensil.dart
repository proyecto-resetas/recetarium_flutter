import 'package:flutter/material.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/screens/steps_screen.dart';

class IngredientsUtensil extends StatelessWidget {
  final RecipesModel recipe;

  const IngredientsUtensil({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
        final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.nameRecipe, style: const TextStyle(fontWeight: FontWeight.w900),),
      ),
      body: Column(
        children: [
          Container(
            color: colors.tertiary,
            width: MediaQuery.of(context).size.width * 10,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text('Ingredients', style: TextStyle(fontSize: 20, color: Colors.white ),)
            ),
          Expanded(
            child: ListView(
              children: recipe.ingredientsRecipe
                  .map<Widget>((ingredient) => ListTile(
                        title: Text(ingredient.description),
                        subtitle: Text(ingredient.amount),
                      ))
                  .toList(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
            // boxShadow: [ BoxShadow(
            // color: const Color.fromARGB(101, 0, 0, 0).withOpacity(0.5), // Color de la sombra
            // blurRadius: 1, // Desenfoque de la sombra
            // spreadRadius: 0, // Extensión de la sombra
            // offset: Offset(0, 1), // Desplazamiento de la sombra en x y y
            // ),],
              color: colors.secondary, // Color de fondo del container
            //  borderRadius: BorderRadius.circular(5), // Radio para esquinas redondeadas
            ),
            width: MediaQuery.of(context).size.width * 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text('Utesil', style: TextStyle(fontSize: 20, color: Colors.white),)
            ),
          Expanded(
            child: ListView(
              children: recipe.utensilRecipe
                  .map<Widget>((ingredient) => ListTile(
                        title: Text(ingredient.utensil),
                      //  subtitle: Text(ingredient.amount),
                      ))
                  .toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StepsScreen(recipe: recipe),
                ),
              );
            },
            child: const Icon(Icons.play_arrow),
          ),
                                  const SizedBox(height: 20),

        ],
      ),
      // bottomSheet: ElevatedButton(
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => StepsScreen(recipe: recipe),
      //           ),
      //         );
      //       },
      //       child: const Icon(Icons.play_arrow),
      //     ),
    );
  }
}
