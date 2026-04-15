import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:resetas/src/features/shopping_cart/ui/my_purchased_recipes.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_created.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';

class BookRecipes extends StatefulWidget {
  const BookRecipes({super.key});
  @override
  State<BookRecipes> createState() => _BookRecipesState();
}
class _BookRecipesState extends State<BookRecipes> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    // Definir la página seleccionada usando un switch-case
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const MyRecipesFavorites();
        break;
      case 1:
        page = const MyRecipesCreated();
        break;
      case 2:
        page =  MyPurchasedRecipes();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  //indicatorShape: ShapeBorder.circleShape(),
                  minExtendedWidth: 160,
                  extended: constraints.maxWidth >= 700,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  destinations: [
                     NavigationRailDestination(
                      icon: const Icon(Bootstrap.person_heart),
                      label: Text('Favorites', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Bootstrap.person_up),
                      label: Text('Created', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Bootstrap.bag_check,),
                      label: Text('bouth', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.error,
                  child: page, // Muestra la página seleccionada
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}