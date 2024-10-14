import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/car_shop_provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/screens/recipes_details.screen.dart';

class CardRecipe extends StatelessWidget {
  final RecipesModel recipes;

  const CardRecipe({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final viewRecipesState = Provider.of<ViewRecipesProvider>(context);
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);
    
    IconData icon;
    if (viewRecipesState.setFavorite != null) {
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
              child: _MyImage(recipes.imageUrl),
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
              height: 130,
              width: 60,
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
                    icon: Icon(Icons.add_shopping_cart_outlined),
                  ),
                  IconButton(
                    onPressed: () {
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
        width: size.width * 0.18, 
        height: size.height * 0.12,
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
