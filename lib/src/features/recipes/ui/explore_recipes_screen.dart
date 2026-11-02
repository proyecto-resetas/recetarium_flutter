import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/widgets/recipe_filters_bar.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class ExploreRecipesScreen extends StatefulWidget {
  const ExploreRecipesScreen({super.key});

  @override
  State<ExploreRecipesScreen> createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLevel;
  RecipeSortOption _sortOption = RecipeSortOption.none;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ViewRecipesProvider>();
      if (provider.recipeListFilter.isEmpty) {
        provider.getRecipeFilter(null, null, null, null);
      }
      final authProvider = context.read<AuthProvider>();
      final favProvider = context.read<RecipeFavoriteProvider>();
      if (favProvider.favoriteList.isEmpty) {
        favProvider.getFavorites(authProvider.user).catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeAdvancedCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedLevel != null) count++;
    if (_sortOption != RecipeSortOption.none) count++;
    if (_maxPrice != null) count++;
    return count;
  }

  bool get _hasActiveFilters =>
      _activeAdvancedCount > 0 || _searchController.text.trim().isNotEmpty;

  void _applyFilters(ViewRecipesProvider provider) {
    provider.getRecipeFilter(
      _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      _selectedCategory,
      _selectedLevel,
      null,
    );
  }

  void _clearAllFilters(ViewRecipesProvider provider) {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedLevel = null;
      _sortOption = RecipeSortOption.none;
      _maxPrice = null;
    });
    _applyFilters(provider);
  }

  List<RecipesModel> _getProcessedRecipes(List<RecipesModel> rawList) {
    return RecipeFilterCatalog.applyFilters(
      source: rawList,
      maxPrice: _maxPrice,
      sortOption: _sortOption,
    );
  }

  void _openFilterAndSortSheet(
    BuildContext context,
    ViewRecipesProvider provider,
  ) {
    RecipeFilterCatalog.openFilterAndSortSheet(
      context: context,
      currentRecipes: provider.recipeListFilter,
      currentSort: _sortOption,
      currentMaxPrice: _maxPrice,
      currentCategory: _selectedCategory,
      currentLevel: _selectedLevel,
      onApply: ({
        required RecipeSortOption sortOption,
        required double? maxPrice,
        required String? category,
        required String? level,
      }) {
        final bool apiFilterChanged =
            category != _selectedCategory || level != _selectedLevel;
        setState(() {
          _sortOption = sortOption;
          _maxPrice = maxPrice;
          _selectedCategory = category;
          _selectedLevel = level;
        });
        if (apiFilterChanged) {
          _applyFilters(provider);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ViewRecipesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final rawName = authProvider.user?.username.trim() ?? '';
    final displayName = rawName.isEmpty
        ? 'Chef'
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';
    final displayedRecipes = _getProcessedRecipes(provider.recipeListFilter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount = width < 380
            ? 1
            : width < 720
                ? 2
                : width < 1060
                    ? 3
                    : 4;

        return CustomScrollView(
          controller: provider.recipeScrollController,
          slivers: [
            // ─── Bienvenida + Componente compartido `RecipeFiltersHeaderWidget` ─
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '¡Hola, $displayName!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.waving_hand_rounded,
                          size: 15,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¿Qué receta deliciosa vamos a preparar hoy?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.secondary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mismo componente de filtros que usa Mi Recetario (`BookRecipes`)
                    RecipeFiltersHeaderWidget(
                      searchController: _searchController,
                      hintText: 'Buscar receta o ingrediente…',
                      selectedCategory: _selectedCategory,
                      selectedLevel: _selectedLevel,
                      sortOption: _sortOption,
                      maxPrice: _maxPrice,
                      onSearchChanged: (value) {
                        provider.progressiveSearch(
                          value,
                          _selectedCategory,
                          _selectedLevel,
                        );
                        setState(() {});
                      },
                      onSearchSubmitted: (_) => _applyFilters(provider),
                      onSearchCleared: () {
                        _searchController.clear();
                        _applyFilters(provider);
                        setState(() {});
                      },
                      onCategorySelected: (val) {
                        setState(() => _selectedCategory = val);
                        _applyFilters(provider);
                      },
                      onLevelSelected: (lvl) {
                        setState(() => _selectedLevel = lvl);
                        _applyFilters(provider);
                      },
                      onOpenFilterModal: () =>
                          _openFilterAndSortSheet(context, provider),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Cabecera de Resultados ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _selectedCategory ?? 'Explorar recetas',
                          style: TextStyle(
                            fontSize: 17,
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
                            '${displayedRecipes.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_hasActiveFilters)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _clearAllFilters(provider),
                        icon: Icon(
                          Icons.restart_alt_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                        label: Text(
                          'Limpiar filtros',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ─── Grid de Recetas o Estado Vacío ─────────────────────────────
            if (displayedRecipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(colors, provider),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 250,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = displayedRecipes[index];
                      return _RecipeGridCard(recipe: recipe);
                    },
                    childCount: displayedRecipes.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colors, ViewRecipesProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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
                Icons.restaurant_menu_rounded,
                size: 52,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No encontramos recetas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prueba con otra categoría o limpia los filtros activos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _clearAllFilters(provider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Ver todas las recetas',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de Receta (Diseño v4 aprobado) ───────────────────────────────────

class _RecipeGridCard extends StatelessWidget {
  final RecipesModel recipe;

  const _RecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shopProvider = context.read<CarShopProvider>();
    final authProvider = context.read<AuthProvider>();
    final favProvider = context.watch<RecipeFavoriteProvider>();
    final isFav = favProvider.favoriteList.any((f) => f.id == recipe.id);
    final lvlColor = RecipeFilterCatalog.levelColor(recipe.level, colors);

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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Imagen + Badges ────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CardRecipeImage(imageUrl: recipe.imageUrl),

                  // Badge de Nivel (arriba izquierda)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
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
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón de Favorito (arriba derecha)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          if (isFav) {
                            await favProvider.removeFavorite(recipe);
                          } else {
                            await favProvider.addFavorite(
                              recipe,
                              authProvider.user?.id,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? const Color(0xFFE53935)
                                : Colors.grey.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Badge de Categoría (abajo izquierda)
                  if (recipe.category.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recipe.category,
                          style: TextStyle(
                            color: colors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Información interna de la tarjeta ──────────────────────────
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${recipe.price}',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            shopProvider.addToCart(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${recipe.nameRecipe} añadido al carrito',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                              color: colors.primary,
                            ),
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
}

class _CardRecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _CardRecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colors.secondary.withValues(alpha: 0.35),
          size: 36,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
            size: 36,
          ),
        );
      },
    );
  }
}
