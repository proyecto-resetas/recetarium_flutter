import 'package:flutter/material.dart';
import 'package:resetas/widgets/create_recipe.dart';
import 'package:resetas/widgets/my_profile.dart';
import 'package:resetas/widgets/my_recipes_favorite.dart';
import 'package:resetas/widgets/view_recipes.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Definir la página seleccionada usando un switch-case
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const MyProfile();
        break;
      case 1:
        page = const ViewRecipes();
        break;
      case 2:
        page =  MyRecipesFavorites();
        break;
      case 3:
        page =  CreateRecipe();
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
                  minExtendedWidth: 160,
                  extended: constraints.maxWidth >= 700,
                 // labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.person),
                      label: Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.home),
                      label: Text('Home', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.favorite),
                      label: Text('Favorites', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                      NavigationRailDestination(
                      icon: const Icon(Icons.create),
                      label: Text('Create Recipe', style: Theme.of(context).textTheme.headlineLarge),
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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

