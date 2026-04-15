import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:resetas/src/features/shopping_cart/ui/car_shop.screen.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';
import 'package:resetas/src/features/recipes/ui/explore_recipes_screen.dart';
import 'package:go_router/go_router.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // Método para obtener la página seleccionada
  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const ExploreRecipesScreen();
      case 1:
        return const CarShop();
      case 2:
        return MyRecipesFavorites();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/recetas-03.png',
              scale: 5,
            ),
          ],
        ),
      ),
      endDrawer: SizedBox(
        height: 400,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isLargeScreen = constraints.maxWidth >= 600;
            return Drawer(
              width: isLargeScreen
                  ? 250
                  : 170, // Ancho extendido en pantallas grandes
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_rounded),
                    title: const Text('Profile'),
                    onTap: () {
                      context.push('/my_profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: _getSelectedPage(), // Muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .shifting, // Tipo fijo de barra de navegación
        currentIndex: selectedIndex, // Índice seleccionado
        onTap: _onItemTapped, // Cambiar de pestaña
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Bootstrap.house),
            activeIcon: Icon(Bootstrap.house_fill),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Bootstrap.basket),
            activeIcon: Icon(Bootstrap.basket_fill),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Bootstrap.balloon_heart),
            activeIcon: Icon(Bootstrap.balloon_heart_fill),
            label: '',
          ),
        ],
        selectedItemColor: Theme.of(context)
            .colorScheme
            .primary, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}
