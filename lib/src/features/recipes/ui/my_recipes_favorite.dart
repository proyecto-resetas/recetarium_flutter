import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/widgets/recipe_filters_bar.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class MyRecipesFavorites extends StatefulWidget {
  final bool embedded;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedLevel;
  final double? maxPrice;
  final RecipeSortOption sortOption;

  const MyRecipesFavorites({
    super.key,
    this.embedded = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedLevel,
    this.maxPrice,
    this.sortOption = RecipeSortOption.none,
  });

  @override
  State<MyRecipesFavorites> createState() => _MyRecipesFavoritesState();
}

class _MyRecipesFavoritesState extends State<MyRecipesFavorites> {
  bool _isLoading = false;
  String _localSearch = '';
  String? _localCategory;
  String? _localLevel;
  double? _localMaxPrice;
  RecipeSortOption _localSortOption = RecipeSortOption.none;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await context
          .read<RecipeFavoriteProvider>()
          .getFavorites(authProvider.user);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatPrice(num price) {
    if (price <= 0) return 'Gratis';
    final intValue = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intValue.length; i++) {
      if (i > 0 && (intValue.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intValue[i]);
    }
    return '\$${buffer.toString()}';
  }

  List<RecipesModel> _filterRecipes(List<RecipesModel> source) {
    return RecipeFilterCatalog.applyFilters(
      source: source,
      searchQuery: widget.embedded ? widget.searchQuery : _localSearch,
      category: widget.embedded ? widget.selectedCategory : _localCategory,
      level: widget.embedded ? widget.selectedLevel : _localLevel,
      maxPrice: widget.embedded ? widget.maxPrice : _localMaxPrice,
      sortOption: widget.embedded ? widget.sortOption : _localSortOption,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final favProvider = context.watch<RecipeFavoriteProvider>();
    final shopProvider = context.watch<CarShopProvider>();
    final authProvider = context.read<AuthProvider>();
    final filtered = _filterRecipes(favProvider.favoriteList);

    final content = RefreshIndicator(
      color: colors.primary,
      onRefresh: _loadFavorites,
      child: CustomScrollView(
        slivers: [
          if (!widget.embedded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Mis Favoritas',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${favProvider.favoriteList.length}',
                            style: TextStyle(
                              color: colors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recetas que has guardado para preparar más adelante',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 14),
                    RecipeFiltersHeaderWidget(
                      searchController: _searchController,
                      hintText: 'Buscar en mis favoritas…',
                      selectedCategory: _localCategory,
                      selectedLevel: _localLevel,
                      sortOption: _localSortOption,
                      maxPrice: _localMaxPrice,
                      onSearchChanged: (v) =>
                          setState(() => _localSearch = v),
                      onSearchCleared: () {
                        _searchController.clear();
                        setState(() => _localSearch = '');
                      },
                      onCategorySelected: (cat) =>
                          setState(() => _localCategory = cat),
                      onLevelSelected: (lvl) =>
                          setState(() => _localLevel = lvl),
                      onOpenFilterModal: () {
                        RecipeFilterCatalog.openFilterAndSortSheet(
                          context: context,
                          currentRecipes: favProvider.favoriteList,
                          currentSort: _localSortOption,
                          currentMaxPrice: _localMaxPrice,
                          currentCategory: _localCategory,
                          currentLevel: _localLevel,
                          onApply: ({
                            required RecipeSortOption sortOption,
                            required double? maxPrice,
                            required String? category,
                            required String? level,
                          }) {
                            setState(() {
                              _localSortOption = sortOption;
                              _localMaxPrice = maxPrice;
                              _localCategory = category;
                              _localLevel = level;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading && favProvider.favoriteList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: colors.primary),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(colors),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = filtered[index];
                    return _buildFavoriteCard(
                      context,
                      colors,
                      recipe,
                      favProvider,
                      shopProvider,
                      authProvider,
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: content,
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    ColorScheme colors,
    RecipesModel recipe,
    RecipeFavoriteProvider favProvider,
    CarShopProvider shopProvider,
    AuthProvider authProvider,
  ) {
    final inCart = shopProvider.shoppingList.any((r) => r.id == recipe.id);
    final lvlColor = RecipeFilterCatalog.levelColor(recipe.level, colors);

    return GestureDetector(
      onTap: () => context.push('/recipes_details', extra: recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen con badge suave en fondo blanco traslúcido
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MyImage(recipe.imageUrl),
                  ),
                  if (recipe.level.trim().isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: lvlColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.level,
                              style: TextStyle(
                                color: colors.secondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Información central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipe.category.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        recipe.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.nameRecipe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.creatorDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(recipe.price),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Acciones derechas con tonos pastel suaves
            SizedBox(
              height: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await favProvider.removeFavorite(recipe);
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                              'Se quitó "${recipe.nameRecipe}" de favoritas',
                            ),
                            action: SnackBarAction(
                              label: 'Deshacer',
                              textColor: colors.primary,
                              onPressed: () {
                                favProvider.addFavorite(
                                  recipe,
                                  authProvider.user?.id,
                                );
                              },
                            ),
                          ),
                        );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      shopProvider.addToCart(recipe);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            content: Text(
                              '${recipe.nameRecipe} añadida al carrito',
                            ),
                          ),
                        );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: inCart
                            ? colors.tertiary.withValues(alpha: 0.12)
                            : colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        inCart
                            ? Icons.check_rounded
                            : Icons.add_shopping_cart_rounded,
                        color: inCart ? colors.tertiary : colors.primary,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 46,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes recetas favoritas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca el corazón en cualquier receta del catálogo para guardarla aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: colors.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
