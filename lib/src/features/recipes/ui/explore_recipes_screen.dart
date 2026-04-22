import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';

class ExploreRecipesScreen extends StatefulWidget {
  const ExploreRecipesScreen({super.key});

  @override
  State<ExploreRecipesScreen> createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLevel;

  static const _categories = [
    'Entrada',
    'Aperitivo',
    'Plato principal',
    'Postre',
    'Sopa',
    'Ensalada',
    'Guarnicion',
    'Salsa',
  ];

  static const _levels = ['Basico', 'Intermedio', 'Avanzado'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(ViewRecipesProvider provider) {
    provider.getRecipeFilter(
      _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      _selectedCategory,
      _selectedLevel,
      null, // createdBy
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ViewRecipesProvider>();
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 420 ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Search Bar ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: CustomIconInput(
                  controller: _searchController,
                  hintText: 'Buscar receta o chef…',
                  prefixIcon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  onCleared: () {
                    _searchController.clear();
                    _applyFilters(provider);
                    setState(() {});
                  },
                  onChanged: (value) {
                    provider.progressiveSearch(
                      value,
                      _selectedCategory,
                      _selectedLevel,
                    );
                    setState(() {});
                  },
                  onSubmitted: (_) => _applyFilters(provider),
                ),
              ),
              const SizedBox(width: 10),
              // Search button
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _applyFilters(provider),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child:
                        Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── Category Chips ───────────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : colors.secondary,
                      )),
                  selected: selected,
                  selectedColor: colors.primary,
                  backgroundColor: colors.secondary.withAlpha(8),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val ? cat : null;
                    });
                    _applyFilters(provider);
                  },
                ),
              );
            },
          ),
        ),

        // ─── Level Chips ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text('Nivel:',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withAlpha(65))),
              const SizedBox(width: 10),
              ..._levels.map((lvl) {
                final selected = _selectedLevel == lvl;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(lvl,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : _levelColor(lvl, colors),
                        )),
                    selected: selected,
                    selectedColor: _levelColor(lvl, colors),
                    backgroundColor: _levelColor(lvl, colors).withAlpha(10),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      setState(() {
                        _selectedLevel = val ? lvl : null;
                      });
                      _applyFilters(provider);
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // ─── Results count ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '${provider.recipeListFilter.length} receta${provider.recipeListFilter.length != 1 ? "s" : ""} encontrada${provider.recipeListFilter.length != 1 ? "s" : ""}',
            style: TextStyle(
              fontSize: 12.5,
              color: colors.onSurface.withAlpha(50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // ─── Recipe Grid ──────────────────────────────────────────────────────
        Expanded(
          child: provider.recipeListFilter.isEmpty
              ? _buildEmptyState(colors)
              : GridView.builder(
                  controller: provider.recipeScrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: crossAxisCount == 1 ? 1.6 : 0.72,
                  ),
                  itemCount: provider.recipeListFilter.length,
                  itemBuilder: (context, index) {
                    final recipe = provider.recipeListFilter[index];
                    return _RecipeGridCard(recipe: recipe);
                  },
                ),
        ),
      ],
    );
  }

  Color _levelColor(String level, ColorScheme colors) {
    switch (level) {
      case 'Basico':
        return colors.tertiary;
      case 'Intermedio':
        return colors.primary;
      case 'Avanzado':
        return const Color(0xFFD32F2F);
      default:
        return colors.secondary;
    }
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu_rounded,
              size: 72, color: colors.primary.withAlpha(30)),
          const SizedBox(height: 16),
          Text('Sin recetas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface.withAlpha(50))),
          const SizedBox(height: 8),
          Text('Intenta con otros filtros',
              style: TextStyle(
                  fontSize: 14, color: colors.onSurface.withAlpha(40))),
        ],
      ),
    );
  }
}

// ─── Recipe Grid Card ─────────────────────────────────────────────────────────

class _RecipeGridCard extends StatelessWidget {
  final dynamic recipe;

  const _RecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shopProvider = context.read<CarShopProvider>();
    final authProvider = context.read<AuthProvider>();
    final favProvider = context.watch<RecipeFavoriteProvider>();
    final isFav = favProvider.favoriteList.any((f) => f.id == recipe.id);

    return GestureDetector(
      onTap: () => context.push(
        '/recipes_details',
        extra: recipe,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MyImage(recipe.imageUrl),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withAlpha(88),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          favProvider.addFavorite(
                              recipe, authProvider.user?.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Level badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _levelColor(recipe.level, colors),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recipe.level,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.nameRecipe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                              size: 13, color: colors.onSurface.withAlpha(50)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            recipe.creatorDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: colors.onSurface.withAlpha(55)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${recipe.price}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.primary),
                        ),
                        GestureDetector(
                          onTap: () {
                            shopProvider.addToCart(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${recipe.nameRecipe} añadido al carrito'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.primary.withAlpha(12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add_shopping_cart_rounded,
                                size: 16, color: colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level, ColorScheme colors) {
    switch (level) {
      case 'Basico':
        return colors.tertiary;
      case 'Intermedio':
        return colors.primary;
      case 'Avanzado':
        return const Color(0xFFD32F2F);
      default:
        return colors.secondary;
    }
  }
}
