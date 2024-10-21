import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/recipes_favorite.dart';


class MyRecipesFavorites extends StatelessWidget {
  const MyRecipesFavorites({super.key});
 
  @override
  Widget build(BuildContext context) {
    final recipeFavoriteProvider = Provider.of<RecipeFavoriteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
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
              child: _MyImage(recipe.imageUrl),
            ),
            Expanded(
              // Para ocupar el espacio disponible
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
                    icon: const Icon(Icons.favorite_border_outlined),
                    onPressed: () {
                      recipeFavoriteProvider.removeFromCart(recipe);
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


class _MyImage extends StatelessWidget {
  final String imageUrl;

  const _MyImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size.width * 0.10, 
        height: size.height * 0.8,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: size.width * 0.18,
            height: size.height * 0.12,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
       
          return Container(
            width: size.width * 0.18,
            height: size.height * 0.12,
            color: Colors.grey.shade300, 
            alignment: Alignment.center,
            child: const Icon(
              Icons.error, 
              color: Colors.red,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}
