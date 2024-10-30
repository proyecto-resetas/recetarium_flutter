import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/car_shop_provider.dart';
import 'package:resetas/widgets/ingredients_utensil.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipesModel recipe;
 

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.nameRecipe, style: const TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                // Text(
                //   recipe.nameRecipe,
                //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                Text(
                  recipe.category,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                 // mainAxisAlignment : MainAxisAlignment.start,
                    children: [
                       Text(
                          "Description: ${recipe.descriptionRecipe}",
                          style: const TextStyle(fontSize: 16),
                         // textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Chef: ${recipe.createdBy}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 30,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                 // alignment: Alignment.center,
                  children:[ 
                    ElevatedButton(
                    onPressed: (){
                      shopProvider.addToCart(recipe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.nameRecipe} added to cart')),
                      );
                    },
                    child: const Icon(Bootstrap.basket_fill, size: 20,),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IngredientsUtensil(recipe: recipe),
                        ),
                      );
                    },
                    child: const Icon(Icons.list),
                    ),
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
