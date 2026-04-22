import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:resetas/src/features/recipes/ui/book_recipes.dart';
import 'package:resetas/src/features/recipes/ui/create_recipe.dart';
import 'package:resetas/src/features/recipes/ui/explore_recipes_screen.dart';
import 'package:resetas/src/core/widgets/custom_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

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
        return const ExploreRecipesScreen();
      case 2:
        return  const BookRecipes();
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
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child:        Image.asset('assets/images/recetas-03.png', scale: 5,),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
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
                        context.push('/ensayo'); 
                   
                      },
                    ), 
                    ListTile(
                      leading: const Icon(Bootstrap.basket),
                      title: const Text('Car Shop'),
                      onTap: () {
                       
                        context.push('/car_shop'); 
                   
                      },
                    ), 
                  ],
                ),
              );
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child:
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: _page(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomBottomNavBar(
        currentIndex: selectedIndexButtom,
        onTap: _onItemTapped,
         items: [
          CustomBottomNavItem(
            icon: Bootstrap.pen,
            activeIcon: Bootstrap.pen_fill,
          ),
          CustomBottomNavItem(
            icon: Bootstrap.house,
            activeIcon: Bootstrap.house_fill,
          ),
          CustomBottomNavItem(
            icon: Bootstrap.journal_bookmark,
            activeIcon: Bootstrap.journal_bookmark_fill,
          ),
        ],
      ),
    );
  }
}

