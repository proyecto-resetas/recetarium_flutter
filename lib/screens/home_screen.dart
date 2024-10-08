// import 'package:flutter/material.dart';
// import 'package:resetas/widgets/car_shop.dart';
// import 'package:resetas/widgets/my_profile.dart';
// import 'package:resetas/widgets/my_recipes_favorite.dart';
// import 'package:resetas/widgets/view_recipes.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     // Definir la página seleccionada usando un switch-case
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

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Scaffold(
//           body: Row(
//             children: [
//               SafeArea(
//                 child: NavigationRail(
//                   minExtendedWidth: 160,
//                   extended: constraints.maxWidth >= 700,
//                  // labelType: NavigationRailLabelType.all,
//                   destinations: [
//                     NavigationRailDestination(
//                       icon: const Icon(Icons.person),
//                       label: Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
//                     ),
//                     NavigationRailDestination(
//                       icon: const Icon(Icons.home),
//                       label: Text('Home', style: Theme.of(context).textTheme.headlineLarge),
//                     ),
//                     NavigationRailDestination(
//                       icon: const Icon(Icons.favorite),
//                       label: Text('Favorites', style: Theme.of(context).textTheme.headlineLarge),
//                     ),
//                       NavigationRailDestination(
//                       icon: const Icon(Icons.shopping_cart),
//                       label: Text('Shop', style: Theme.of(context).textTheme.headlineLarge),
//                     ),
//                   ],
//                   selectedIndex: selectedIndex,
//                   onDestinationSelected: (value) {
//                     setState(() {
//                       selectedIndex = value;
//                     });
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   color: Theme.of(context).colorScheme.primary,
//                   child: page, // Muestra la página seleccionada
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:resetas/widgets/car_shop.dart';
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

  // Método para obtener la página seleccionada
  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const MyProfile();
      case 1:
        return const ViewRecipes();
      case 2:
        return MyRecipesFavorites();
      case 3:
        return const CarShop();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
  }

  // Método para actualizar la selección del índice en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Title'), // Título de la aplicación
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Ícono de menú hamburguesa
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Abre el Drawer
              },
            );
          },
        ),
      ),
      drawer: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool isLargeScreen = constraints.maxWidth >= 600;
          return Drawer(
            width: isLargeScreen ? 300 : 170, // Ancho extendido en pantallas grandes
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary, // Color de encabezado
                  ),
                  child: const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Favorites'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Shop'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: _getSelectedPage(), // Muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Tipo fijo de barra de navegación
        currentIndex: selectedIndex, // Índice seleccionado
        onTap: _onItemTapped, // Cambiar de pestaña
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}
