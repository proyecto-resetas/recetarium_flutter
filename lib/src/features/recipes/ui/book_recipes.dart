import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_created.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';
import 'package:resetas/src/features/recipes/ui/widgets/recipe_filters_bar.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/shopping_cart/ui/my_purchased_recipes.dart';

class BookRecipes extends StatefulWidget {
  final VoidCallback? onCreateRecipeTap;

  const BookRecipes({super.key, this.onCreateRecipeTap});

  @override
  State<BookRecipes> createState() => _BookRecipesState();
}

class _BookRecipesState extends State<BookRecipes> {
  int _selectedIndex = 0; // 0: Favoritas, 1: Creadas, 2: Compradas
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLevel;
  double? _maxPrice;
  RecipeSortOption _sortOption = RecipeSortOption.none;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      context.read<RecipeFavoriteProvider>().getFavorites(authProvider.user);
      context
          .read<RecipeMyCreatedProvider>()
          .getMyRecipesCreated(authProvider.user);
      context.read<CarShopProvider>().getPurchasedRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecipesModel> _currentActiveList() {
    switch (_selectedIndex) {
      case 0:
        return context.read<RecipeFavoriteProvider>().favoriteList;
      case 1:
        return context.read<RecipeMyCreatedProvider>().myRecipeList;
      case 2:
        return context.read<CarShopProvider>().purchasedList;
      default:
        return const [];
    }
  }

  void _openFilterSheet() {
    RecipeFilterCatalog.openFilterAndSortSheet(
      context: context,
      currentRecipes: _currentActiveList(),
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
        setState(() {
          _sortOption = sortOption;
          _maxPrice = maxPrice;
          _selectedCategory = category;
          _selectedLevel = level;
        });
      },
    );
  }

  Widget _buildActiveTabBody() {
    switch (_selectedIndex) {
      case 0:
        return MyRecipesFavorites(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
          selectedLevel: _selectedLevel,
          maxPrice: _maxPrice,
          sortOption: _sortOption,
        );
      case 1:
        return MyRecipesCreated(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
          selectedLevel: _selectedLevel,
          maxPrice: _maxPrice,
          sortOption: _sortOption,
          onCreateRecipeTap: widget.onCreateRecipeTap,
        );
      case 2:
        return MyPurchasedRecipes(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
          selectedLevel: _selectedLevel,
          maxPrice: _maxPrice,
          sortOption: _sortOption,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final favCount =
        context.watch<RecipeFavoriteProvider>().favoriteList.length;
    final createdCount =
        context.watch<RecipeMyCreatedProvider>().myRecipeList.length;
    final purchasedCount =
        context.watch<CarShopProvider>().purchasedList.length;

    return ColoredBox(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Cabecera Principal "Mi Recetario" (Tonos suaves idénticos al Home)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Recetario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.secondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus recetas favoritas, creadas y desbloqueadas',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // ─── Selector de Pestañas Suave Centrado (Favoritas | Creadas | Compradas)
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabPill(
                          colors: colors,
                          index: 0,
                          label: 'Favoritas ($favCount)',
                          icon: Icons.favorite_border_rounded,
                          activeIcon: Icons.favorite_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildTabPill(
                          colors: colors,
                          index: 1,
                          label: 'Creadas ($createdCount)',
                          icon: Icons.restaurant_menu_rounded,
                          activeIcon: Icons.restaurant_menu_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildTabPill(
                          colors: colors,
                          index: 2,
                          label: 'Compradas ($purchasedCount)',
                          icon: Icons.shopping_bag_outlined,
                          activeIcon: Icons.shopping_bag_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Mismo Componente de Filtros del Home (`RecipeFiltersHeaderWidget`)
                RecipeFiltersHeaderWidget(
                  searchController: _searchController,
                  hintText: 'Buscar receta o ingrediente…',
                  selectedCategory: _selectedCategory,
                  selectedLevel: _selectedLevel,
                  sortOption: _sortOption,
                  maxPrice: _maxPrice,
                  onSearchChanged: (val) =>
                      setState(() => _searchQuery = val),
                  onSearchCleared: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  onCategorySelected: (cat) =>
                      setState(() => _selectedCategory = cat),
                  onLevelSelected: (lvl) =>
                      setState(() => _selectedLevel = lvl),
                  onOpenFilterModal: _openFilterSheet,
                ),
              ],
            ),
          ),

          // ─── Contenido de la pestaña activa ─────────────────────────────
          Expanded(
            child: _buildActiveTabBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required ColorScheme colors,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.45)
                : colors.secondary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 16,
              color: isSelected
                  ? colors.primary
                  : colors.secondary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
