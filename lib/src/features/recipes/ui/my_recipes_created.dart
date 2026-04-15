import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
//import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
//import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';


class MyRecipesCreated extends StatelessWidget {
  const MyRecipesCreated({super.key});
 
  @override
  Widget build(BuildContext context) {
    final recipeMyCreatedProvider = Provider.of<RecipeMyCreatedProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Created for me'),
      ),
      body: FutureBuilder(
        future: recipeMyCreatedProvider.getMyRecipesCreated(authProvider.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load recipe: ${snapshot.error}'),
            );
          }
          final favorites = recipeMyCreatedProvider.myRecipeList;
          return favorites.isEmpty
              ? const Center(
                  child: Text('No recipes in the cart'),
                )
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final recipe = favorites[index];
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            child: MyImage(recipe.imageUrl),
                          ),
                          Expanded(
                            child: Container(
                              height: 100,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.nameRecipe,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    recipe.category,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text('\$${recipe.price.toString()}'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 90,
                            width: 40,
                            child: IconButton(
                    icon: const Icon(Bootstrap.pen_fill),
                              onPressed: () {
                                recipeMyCreatedProvider.myRecipeList
                                    .remove(recipe);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${recipe.nameRecipe} removed from recipe')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}