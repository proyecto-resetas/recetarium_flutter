import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/theme/app_theme.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:resetas/src/features/shopping_cart/data/payment_wompi_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/data/steps_provider.dart';
import 'package:resetas/src/routing/app_router.dart';
import 'package:resetas/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarShopProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => ViewRecipesProvider()),
        ChangeNotifierProvider(create: (_) => StepsProvider()),
        ChangeNotifierProvider(create: (_) => RecipeFavoriteProvider()),
        ChangeNotifierProvider(create: (_) => RecipeMyCreatedProvider()),
        ChangeNotifierProvider(create: (_) => PaymentWompiProvider()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Creamos el router una sola vez pasando el AuthProvider como listenable
    _router = AppRouter.router(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Resetas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(typographyCustom: 0).theme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
