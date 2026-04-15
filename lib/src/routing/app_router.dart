import 'package:go_router/go_router.dart';
import 'package:resetas/src/features/auth/ui/login_screen.dart';
import 'package:resetas/src/features/auth/ui/register_screen.dart';
import 'package:resetas/src/features/recipes/ui/home_screen.dart';
import 'package:resetas/src/features/admin/ui/admin_home_screen.dart';
import 'package:resetas/src/features/user_profile/ui/my_profile_screen.dart';
import 'package:resetas/src/features/shopping_cart/ui/car_shop.screen.dart';
import 'package:resetas/src/core/widgets/MyScrollableWidget.dart';
import 'package:resetas/src/features/auth/ui/otp_verification_screen.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/recipes_details.screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final bool isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/otp_verification';

        // Si el usuario no está autenticado y no está en una ruta de auth, redirigir al login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // Si el usuario está autenticado e intenta ir al login o registro, redirigir al home
        if (isAuthenticated && isAuthRoute) {
          // Si es admin, redirigir a admin_home, si no a home
          return authProvider.user?.role == 'admin' ? '/admin_home' : '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/admin_home',
          builder: (context, state) => const AdminHomeScreen(),
        ),
        GoRoute(
          path: '/recipes_details',
          builder: (context, state) => RecipeDetailScreen(recipe: state.extra as RecipesModel),
        ),
        GoRoute(
          path: '/my_profile',
          builder: (context, state) => const MyProfileScreen(),
        ),
        GoRoute(
          path: '/car_shop',
          builder: (context, state) => const CarShop(),
        ),
        GoRoute(
          path: '/ensayo',
          builder: (context, state) => PaymentScreen(),
        ),
        GoRoute(
          path: '/otp_verification',
          builder: (context, state) =>
              OtpVerificationScreen(email: state.extra as String? ?? ''),
        ),
      ],
    );
  }
}
