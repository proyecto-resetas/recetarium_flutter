import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:resetas/src/features/shopping_cart/ui/car_shop.screen.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';
import 'package:resetas/src/features/recipes/ui/explore_recipes_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/widgets/custom_bottom_nav_bar.dart';
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
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
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
              width: isLargeScreen ? 250 : 170, // Ancho extendido en pantallas grandes
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
      body: SafeArea(
        child: _getSelectedPage(),
      ), // Muestra la página seleccionada
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        items: [
          CustomBottomNavItem(
            icon: Bootstrap.house,
            activeIcon: Bootstrap.house_fill,
          ),
          CustomBottomNavItem(
            icon: Bootstrap.basket,
            activeIcon: Bootstrap.basket_fill,
          ),
          CustomBottomNavItem(
            icon: Bootstrap.balloon_heart,
            activeIcon: Bootstrap.balloon_heart_fill,
          ),
        ],
      ),
    );
  }
}
