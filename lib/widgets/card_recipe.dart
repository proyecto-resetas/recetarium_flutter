import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/car_shop_provider.dart';
import 'package:resetas/providers/recipes_favorite.dart';
//import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/screens/recipes_details.screen.dart';
import 'package:resetas/widgets/image_card.dart';

class CardRecipe extends StatelessWidget {
  final RecipesModel recipes;

  const CardRecipe({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);
    final recipesFavorite = Provider.of<RecipeFavoriteProvider>(context);
    
    IconData icon;
    if (recipesFavorite.getFavorite != null) {
      icon = Icons.favorite_border;
    } else {
      icon = Icons.favorite;
    }

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

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
              width: 110,
              height: 155,
              padding: const EdgeInsets.all(10),
              child: MyImage(recipes.imageUrl),
            ),
            Expanded(
              // Para ocupar el espacio disponible
              child: Container(
                height:155,
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
                      children: [
                        const Icon( Icons.person_4_outlined, size: 18 ),
                        Text(
                            '  ${recipes.createdBy}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                            ),
                      ],
                    ),
                     Row(
                       children: [
                        const Icon( Icons.category_outlined, size: 18 ),
                         Text(
                            '  ${recipes.category} ',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                        const Icon( Icons.equalizer, size: 18 ),
                         Text(
                            ' ${recipes.level} ',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                       ],
                     ),  
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 150,
              width: 40,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment
                    .end, 
                children: [
                  IconButton(
                    onPressed: (){
                      shopProvider.addToCart(recipes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipes.nameRecipe} added to cart')),
                      );
                    },
                    icon: const Icon(Bootstrap.bag_plus_fill),
                  ),
                  IconButton(
                    onPressed: () {
                      recipesFavorite.addToCart(recipes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipes.nameRecipe} added to favorites')),
                      );
                    },
                    icon: Icon(icon), 
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
