import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/config/themes/app_theme.dart';
import 'package:resetas/providers/auth_provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/providers/steps_provider.dart';
import 'package:resetas/screens/admin_home_screen.dart';
import 'package:resetas/screens/home_screen.dart';
import 'package:resetas/screens/login_screen.dart';
import 'package:resetas/screens/register_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ViewRecipesProvider()),
        ChangeNotifierProvider(create: (_) => StepsProvider()),

      ],
      child: MaterialApp(
        title: 'Resetas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme( typographyCustom: 0).theme(),
        initialRoute: '/login', // Ruta inicial que carga al inicio de la app
      routes: {
        '/login': (context) => const LoginScreen(),   // Ruta para la pantalla de inicio de sesión
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(), 
        '/admin_home': (context) => const AdminHomeScreen(),
      },
      ),
    );
  }
}
