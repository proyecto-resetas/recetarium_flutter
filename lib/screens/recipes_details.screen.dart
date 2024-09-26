import 'package:flutter/material.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/screens/steps_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipesModel recipe;
 

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.nameRecipe),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius : BorderRadius.circular(15),
              child: Image.network(
                recipe.imageUrl,
                width: size.width * 4, // Ajusta el ancho de la imagen
                height: size.height * 0.28, // Ajusta la altura de la imagen
                fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
                loadingBuilder:(context, child, loadingProgress) {
                if(loadingProgress == null) return child;
              
                return Container(
                width: size.width * 4, // Ajusta el ancho de la imagen
                height: size.height * 0.28,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(), 
                        
                  );
                },
                ),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.nameRecipe,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment : MainAxisAlignment.spaceEvenly,
                children: [
                   Text(
                      "Descripción: ${recipe.descriptionRecipe}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Ingredientes: ${recipe.ingredientsRecipe}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Precio: \$${recipe.price}",
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ), 


            const Text(
              "Comenzar receta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 400,
              height: 50, // Aquí ajustas el ancho
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StepsScreen(recipe: recipe),
                  ),
                );
                },
                child: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
