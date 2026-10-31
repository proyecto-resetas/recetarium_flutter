import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/theme/bootstrap_icons.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/recipes/ui/book_recipes.dart';
import 'package:resetas/src/features/recipes/ui/create_recipe.dart';
import 'package:resetas/src/features/recipes/ui/explore_recipes_screen.dart';
import 'package:resetas/src/features/notifications/data/notifications_provider.dart';
import 'package:resetas/src/features/notifications/ui/live_notification_banner.dart';
import 'package:resetas/src/core/widgets/custom_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int selectedIndexButtom = 1; // Inicia en Explorar Recetas (Home)

  Widget _page() {
    switch (selectedIndexButtom) {
      case 0:
        return CreateRecipe();
      case 1:
        return const ExploreRecipesScreen();
      case 2:
        return const BookRecipes();
      default:
        throw UnimplementedError('No widget for $selectedIndexButtom');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndexButtom = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cartCount = context.watch<CarShopProvider>().shoppingList.length;
    final unreadNotifications =
        context.watch<NotificationsProvider>().unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Image.asset(
          'assets/images/recetas-03.png',
          height: 34,
          fit: BoxFit.contain,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Notificaciones',
              onPressed: () => context.push('/notifications'),
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: unreadNotifications > 0
                      ? colors.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Badge(
                  isLabelVisible: unreadNotifications > 0,
                  backgroundColor: colors.primary,
                  label: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Icon(
                    unreadNotifications > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: colors.secondary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Carrito de compras',
              onPressed: () => context.push('/car_shop'),
              icon: Badge(
                isLabelVisible: cartCount > 0,
                backgroundColor: colors.primary,
                label: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Icon(
                  Bootstrap.basket,
                  color: colors.secondary,
                  size: 22,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/my_profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colors.secondary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_rounded,
                  color: colors.secondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const LiveNotificationBanner(),
            Expanded(child: _page()),
          ],
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
