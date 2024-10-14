import 'package:flutter/material.dart';
import 'package:resetas/widgets/car_shop.dart';
import 'package:resetas/widgets/create_recipe.dart';
import 'package:resetas/widgets/my_profile.dart';
//import 'package:resetas/widgets/my_recipes_favorite.dart';
import 'package:resetas/widgets/view_recipes.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int selectedIndex = 0;
  int selectedIndexButtom = 0;

  // Método para obtener la página seleccionada
  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const MyProfile();
      case 1:
        return const ViewRecipes();
      case 2:
        return CreateRecipe();
      case 3:
        return const CarShop();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }
  }

   Widget _page(){
    switch (selectedIndexButtom) {
      case 0:
       return  const MyProfile();
      case 1:
        return const ViewRecipes();
      case 2:
        return  CreateRecipe();
      default:
        throw UnimplementedError('No widget for $selectedIndexButtom');
      }
    }

  // Método para actualizar la selección del índice en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      selectedIndexButtom = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/recetas-03.png', scale: 5,), // Título de la aplicación
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
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Profile'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Home'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.create),
                  title: const Text('Create Recipe'),
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                    Navigator.pop(context); // Cerrar el Drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_rounded),
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
      body: _getSelectedPage() , // Muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Tipo fijo de barra de navegación
        currentIndex: selectedIndexButtom, // Índice seleccionado
        onTap: _onItemTapped, // Cambiar de pestaña
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}

