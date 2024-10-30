import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:resetas/widgets/car_shop.dart';
import 'package:resetas/widgets/create_recipe.dart';
//import 'package:resetas/widgets/my_recipes_favorite.dart';
import 'package:resetas/widgets/view_recipes.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int selectedIndexButtom = 0;

   Widget _page(){
    switch (selectedIndexButtom) {
      case 0:
       return  CreateRecipe();
      case 1:
        return const ViewRecipes();
      case 2:
        return  const CarShop();
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
                       
                        Navigator.pushNamed(context, '/ensayo'); 
                   
                      },
                    ), 
                  ],
                ),
              );
          },
        ),
      ),
      body: _page(),
      // muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        //iconSize: 24,
        type: BottomNavigationBarType.shifting, // Tipo fijo de barra de navegación
        currentIndex: selectedIndexButtom, // Índice seleccionado
        onTap: _onItemTapped, // Cambiar de pestaña
        items: const [
           BottomNavigationBarItem(
            icon: Icon(Bootstrap.pen),
            activeIcon: Icon(Bootstrap.pen_fill),
            label: '',
          ),
         
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
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      ),
    );
  }
}

