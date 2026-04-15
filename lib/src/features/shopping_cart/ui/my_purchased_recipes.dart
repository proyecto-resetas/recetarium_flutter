import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';


class MyPurchasedRecipes extends StatelessWidget {
  const MyPurchasedRecipes({super.key});
 
  @override
  Widget build(BuildContext context) {
    final recipeFavoriteProvider = Provider.of<RecipeFavoriteProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bouth'),
      ),
      body: recipeFavoriteProvider.favoriteList.isEmpty
          ? const Center(
              child: Text('No recipes in the cart'),
            )
          : ListView.builder(
              itemCount: recipeFavoriteProvider.favoriteList.length,
              itemBuilder: (context, index) {
                final RecipesModel recipe = recipeFavoriteProvider.favoriteList[index];
                return Card(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 110,
              height: 100,
              padding: const EdgeInsets.all(10),
              child: MyImage(recipe.imageUrl),
            ),
            Expanded(
              child: Container(
                height:100,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      maxLines: 1,
                      recipe.nameRecipe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                     Text(
                      recipe.category,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    Text('\$${recipe.price.toString()}'),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 90,
              width: 40,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment
                    .end, 
                children: [
                  IconButton(
                    icon: const Icon(Bootstrap.bag_check_fill),
                    onPressed: () {
                    //  recipeFavoriteProvider.removeFromCart(recipe);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.nameRecipe} removed from cart')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );                    
     },
    ),
   );
  }
}