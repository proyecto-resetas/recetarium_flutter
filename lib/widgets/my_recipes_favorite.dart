import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/providers/auth_provider.dart';
import 'package:resetas/providers/recipes_favorite_provider.dart';
import 'package:resetas/widgets/image_card.dart';


// class MyRecipesFavorites extends StatelessWidget {
//   const MyRecipesFavorites({super.key});
 
//   @override
//   Widget build(BuildContext context) {
//     final recipeFavoriteProvider = Provider.of<RecipeFavoriteProvider>(context);
//      final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Favorites'),
//       ),
//       body: authProvider.user!.myFavorite.isEmpty
//           ? const Center(
//               child: Text('No recipes in the cart'),
//             )
//           : ListView.builder(
//               // itemCount: authProvider.user!.myFavorite.length,
//               itemCount: recipeFavoriteProvider.favoriteList.length,
//               itemBuilder: (context, index) {
//                 final RecipesModel recipe = recipeFavoriteProvider.favoriteList[index];
//                 return Card(
//         clipBehavior: Clip.hardEdge,
//         margin: const EdgeInsets.all(10),
//         child: Row(
//           children: [
//             Container(
//               width: 90,
//               height: 100,
//               padding: const EdgeInsets.all(10),
//               child: MyImage(recipe.imageUrl),
//             ),
//             Expanded(
//               child: Container(
//                 height:100,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       maxLines: 1,
//                       recipe.nameRecipe,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                      Text(
//                       recipe.category,
//                       style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//                     ),
//                     Text('\$${recipe.price.toString()}'),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 90,
//               width: 40,
//               child: Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment.spaceBetween, 
//                 crossAxisAlignment: CrossAxisAlignment
//                     .end, 
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.favorite_border_outlined),
//                     onPressed: () {
//                    //   recipeFavoriteProvider.removeFromCart(recipe);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('${recipe.nameRecipe} removed from cart')),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );                    
//      },
//     ),
//    );
//   }
// }

class MyRecipesFavorites extends StatelessWidget {
  const MyRecipesFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeFavoriteProvider =
        Provider.of<RecipeFavoriteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: FutureBuilder(
        future: recipeFavoriteProvider.getFavorites(authProvider.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load favorites: ${snapshot.error}'),
            );
          }
          final favorites = recipeFavoriteProvider.favoriteList;
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
                              icon: const Icon(Icons.favorite, color: Colors.red,),
                              onPressed: () {
                                recipeFavoriteProvider.favoriteList
                                    .remove(recipe);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${recipe.nameRecipe} removed from favorites')),
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



