import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/theme/bootstrap_icons.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';

class MyPurchasedRecipes extends StatelessWidget {
  const MyPurchasedRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compradas'),
      ),
      body: FutureBuilder(
        future: shopProvider.getPurchasedRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar compradas: ${snapshot.error}'),
            );
          }

          return Consumer<CarShopProvider>(
            builder: (context, provider, _) {
              final purchased = provider.purchasedList;
              if (purchased.isEmpty) {
                return const Center(
                  child: Text('No tienes recetas compradas aún'),
                );
              }
              return ListView.builder(
                itemCount: purchased.length,
                itemBuilder: (context, index) {
                  final RecipesModel recipe = purchased[index];
                  return GestureDetector(
                    onTap: () => context.push(
                      '/recipes_details',
                      extra: recipe,
                    ),
                    child: Card(
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
                              height: 100,
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
                          const SizedBox(
                            height: 90,
                            width: 40,
                            child: Icon(Bootstrap.bag_check_fill),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
