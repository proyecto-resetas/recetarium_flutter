import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
//import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/ui/recipes_details.screen.dart';
import 'package:resetas/src/core/widgets/image_card.dart';

class CardRecipe extends StatelessWidget {
  final RecipesModel recipes;

  const CardRecipe({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipesFavorite = Provider.of<RecipeFavoriteProvider>(context);


    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

     final bool isFavorite =
        recipesFavorite.favoriteList.any((fav) => fav.id == recipes.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipes),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 170,
              padding: const EdgeInsets.all(10),
              child: MyImage(recipes.imageUrl),
            ),
            Expanded(
              // Para ocupar el espacio disponible
              child: Container(
                height: size.height * 0.2,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      maxLines: 1,
                      recipes.nameRecipe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('\$${recipes.price.toString()}'),
                    Text(
                      recipes.descriptionRecipe,
                      maxLines: isLandscape ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Row(
                      verticalDirection: VerticalDirection.up,
                      children: [
                        const Icon(Icons.person_4_outlined, size: 18),
                        Text(
                          '  ${recipes.creatorDisplayName}',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 18),
                        Text(
                          '  ${recipes.category} ',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.equalizer, size: 18),
                        Text(
                          ' ${recipes.level} ',
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.2,
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      shopProvider.addToCart(recipes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${recipes.nameRecipe} added to cart')),
                      );
                    },
                    icon: const Icon(Bootstrap.bag_plus_fill),
                  ),
                  IconButton(
                    onPressed: () {
                      recipesFavorite.addFavorite(
                          recipes, authProvider.user?.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${recipes.nameRecipe} added to favorites')),
                      );
                    },
                   // icon: Icon(icon),
                   
                   icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite ? Colors.red : null,
                    ),

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
