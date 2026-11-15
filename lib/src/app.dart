import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/theme/app_theme.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:recetarium/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:recetarium/src/features/shopping_cart/data/payment_wompi_provider.dart';
import 'package:recetarium/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';
import 'package:recetarium/src/features/recipes/data/steps_provider.dart';
import 'package:recetarium/src/features/notifications/data/notifications_provider.dart';
import 'package:recetarium/src/features/admin/data/super_admin_provider.dart';
import 'package:recetarium/src/routing/app_router.dart';
import 'package:recetarium/l10n/app_localizations.dart';
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
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationsProvider>(
          create: (_) => NotificationsProvider(),
          update: (_, auth, notifProvider) {
            final provider = notifProvider ?? NotificationsProvider();
            provider.initializeForUser(auth.user?.id);
            return provider;
          },
        ),
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

class _AppContentState extends State<AppContent> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Creamos el router una sola vez pasando el AuthProvider como listenable
    _router = AppRouter.router(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AuthProvider>().validateSessionOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recetarium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(typographyCustom: 0).theme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
