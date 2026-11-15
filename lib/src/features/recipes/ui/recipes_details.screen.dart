import 'package:flutter/material.dart';
import 'package:recetarium/src/core/services/admob_service.dart';
import 'package:recetarium/src/core/theme/bootstrap_icons.dart';
import 'package:recetarium/src/core/widgets/ad_banner_widget.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:recetarium/src/features/recipes/data/steps_provider.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';
import 'package:recetarium/src/features/recipes/ui/steps_screen.dart';
import 'package:recetarium/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipesModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context, listen: false);
    final currentUser = context.watch<AuthProvider>().user;
    final isCreator = recipe.isCreatedByUser(currentUser);
    final showAds = recipe.shouldShowAdsForUser(currentUser);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        title: const Text(
          "Detalle de Receta",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () {
                  Share.share(
                    '¡Mira esta deliciosa receta de ${recipe.nameRecipe} en Recetarium!\n\n${recipe.descriptionRecipe}',
                  );
                },
                icon: const Icon(Icons.share_outlined, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER IMAGE ---
              Stack(
                children: [
                  Container(
                    height: size.height * 0.42,
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      recipe.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_rounded,
                            size: 100, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CATEGORY & TIME TAGS ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recipe.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 18, color: Colors.blueGrey[400]),
                      const SizedBox(width: 4),
                      Text(
                        recipe.level, // Or time if available
                        style: TextStyle(
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- TITLE ---
                  Text(
                    recipe.nameRecipe,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- DESCRIPTION ---
                  Text(
                    recipe.descriptionRecipe,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CHEF & PRICE INFO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.primary.withAlpha(15),
                            child: Icon(Icons.person_rounded,
                                color: colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chef",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                              Text(
                                recipe.creatorDisplayName,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            recipe.isFree ? "Acceso" : "Precio",
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (recipe.isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isCreator ? "GRATIS (Tu receta)" : "GRATIS",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            )
                          else
                            Text(
                              "\$${recipe.price}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (showAds) ...[
                    const AdBannerWidget(
                      placementLabel:
                          'Receta Gratuita Patrocinada • Google AdMob',
                      margin: EdgeInsets.only(bottom: 16),
                    ),
                  ],

                  // --- ACTION BUTTONS ---
                  Row(
                    children: [
                      // Buy/Cart Button OR Cook / Watch Ad Button for free or own recipes
                      Expanded(
                        child: _DetailActionButton(
                          icon: isCreator
                              ? Icons.play_arrow_rounded
                              : (recipe.isFree
                                  ? Icons.ondemand_video_rounded
                                  : Bootstrap.basket_fill),
                          label: isCreator
                              ? "Cocinar"
                              : (recipe.isFree
                                  ? "Ver Anuncio y Cocinar"
                                  : "Comprar"),
                          color: (recipe.isFree || isCreator)
                              ? const Color(0xFF16A34A)
                              : colorScheme.secondary,
                          onPressed: () async {
                            if (recipe.isFree || isCreator) {
                              if (showAds) {
                                final unlocked = await AdMobService.instance
                                    .showRewardedAdToUnlockRecipe(
                                  context,
                                  recipeName: recipe.nameRecipe,
                                );
                                if (!unlocked || !context.mounted) return;
                              }
                              if (recipe.id != null) {
                                await context
                                    .read<StepsProvider>()
                                    .fetchSteps(recipe.id!);
                              }
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StepsScreen(recipe: recipe),
                                ),
                              );
                              return;
                            }
                            shopProvider.addToCart(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${recipe.nameRecipe} añadido al carrito')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ingredients List Button
                      Expanded(
                        child: _DetailActionButton(
                          icon: Icons.list_alt_rounded,
                          label: "Ingredientes",
                          color: Colors.blueGrey[700]!,
                          onPressed: () {
                            print('Navegando a ingredientes para: ${recipe.id}');
                            context.push(
                              '/ingredients_utensil',
                              extra: recipe,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- FAVORITE BUTTON (AS IN SCREENSHOT) ---
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFFE53935).withAlpha(40),
                      ),
                      onPressed: () async {
                        final favProvider =
                            context.read<RecipeFavoriteProvider>();
                        final authProvider = context.read<AuthProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final added = await favProvider.addFavorite(
                          recipe,
                          authProvider.user?.id,
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${recipe.nameRecipe} añadida a favoritos'
                                  : 'No se pudo añadir a favoritos',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite_rounded),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Añadir a favoritos",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
