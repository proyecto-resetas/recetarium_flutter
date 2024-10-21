import 'package:flutter/material.dart';
import 'package:resetas/widgets/car_shop.dart';
import 'package:resetas/widgets/my_recipes_favorite.dart';
import 'package:resetas/widgets/view_recipes.dart';

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
        return  const ViewRecipes();
      case 1:
        return  const CarShop();
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
          crossAxisAlignment:CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/recetas-03.png', scale: 5,),
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
                        Navigator.pushNamed(context, '/my_profile'); 
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
        type: BottomNavigationBarType.fixed, // Tipo fijo de barra de navegación
        currentIndex: selectedIndex, // Índice seleccionado
        onTap: _onItemTapped, // Cambiar de pestaña
        items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart_rounded),
            label: 'Shop',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'favorite',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}

  // Definir la página seleccionada usando un switch-case
//     Widget page;
//     switch (selectedIndex) {
//       case 0:
//         page = const MyProfile();
//         break;
//       case 1:
//         page = const ViewRecipes();
//         break;
//       case 2:
//         page =  MyRecipesFavorites();
//         break;
//         case 3:
//         page = const CarShop();
//         break;  
//       default:
//         throw UnimplementedError('No widget for $selectedIndex');
//     }