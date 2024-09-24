import 'package:flutter/material.dart';
import 'package:resetas/widgets/my_profile.dart';
import 'package:resetas/widgets/my_recipes_favorite.dart';
import 'package:resetas/widgets/view_recipes.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        page = const Home();
        break;
      case 2:
        page = const MyRecipesFavorites();
        break;
      case 3:
        page = const ViewRecipes();
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
                  extended: constraints.maxWidth >= 600,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.person),
                      label: Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.kitchen),
                      label: Text('Recetas'),
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

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column();
  }
}
