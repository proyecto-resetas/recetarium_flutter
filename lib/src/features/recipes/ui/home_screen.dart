import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/theme/bootstrap_icons.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/shopping_cart/ui/car_shop.screen.dart';
import 'package:resetas/src/features/shopping_cart/ui/my_purchased_recipes.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';
import 'package:resetas/src/features/recipes/ui/explore_recipes_screen.dart';
import 'package:resetas/src/features/notifications/data/notifications_provider.dart';
import 'package:resetas/src/features/notifications/ui/live_notification_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const ExploreRecipesScreen();
      case 1:
        return const CarShop();
      case 2:
        return const MyRecipesFavorites();
      case 3:
        return const MyPurchasedRecipes();
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
          // Campana de Notificaciones en Tiempo Real con badge
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
          // Botón rápido al Carrito con badge
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Carrito de compras',
              onPressed: () => _onItemTapped(1),
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
          // Botón rápido a Perfil
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
            Expanded(child: _getSelectedPage()),
          ],
        ),
      ),
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
          CustomBottomNavItem(
            icon: Bootstrap.bag_check,
            activeIcon: Bootstrap.bag_check_fill,
          ),
        ],
      ),
    );
  }
}
