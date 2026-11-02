import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/widgets/recipe_filters_bar.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class MyPurchasedRecipes extends StatefulWidget {
  final bool embedded;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedLevel;
  final double? maxPrice;
  final RecipeSortOption sortOption;

  const MyPurchasedRecipes({
    super.key,
    this.embedded = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedLevel,
    this.maxPrice,
    this.sortOption = RecipeSortOption.none,
  });

  @override
  State<MyPurchasedRecipes> createState() => _MyPurchasedRecipesState();
}

class _MyPurchasedRecipesState extends State<MyPurchasedRecipes> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPurchased());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchased() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await context.read<CarShopProvider>().getPurchasedRecipes();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    final shopProvider = context.watch<CarShopProvider>();
    final allPurchased = shopProvider.purchasedList;
    final filtered = _filterRecipes(allPurchased);

    final content = RefreshIndicator(
      color: colors.primary,
      onRefresh: _loadPurchased,
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
                          'Mis Recetas Compradas',
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
                            color: colors.tertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${allPurchased.length}',
                            style: TextStyle(
                              color: colors.tertiary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recetas con el paso a paso e ingredientes desbloqueados de por vida',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 14),
                    RecipeFiltersHeaderWidget(
                      searchController: _searchController,
                      hintText: 'Buscar en mis compradas…',
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
                          currentRecipes: allPurchased,
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
          if (_isLoading && allPurchased.isEmpty)
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
                  (context, index) => _buildPurchasedCard(
                    context,
                    colors,
                    filtered[index],
                  ),
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

  Widget _buildPurchasedCard(
    BuildContext context,
    ColorScheme colors,
    RecipesModel recipe,
  ) {
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
            // Miniatura redondeada
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 96,
                height: 96,
                child: MyImage(recipe.imageUrl),
              ),
            ),
            const SizedBox(width: 14),

            // Información y botón "Ver paso a paso →"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge verde "✓ Desbloqueada" usando colors.tertiary
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: colors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Desbloqueada',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: colors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Nombre de la receta
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

                  // Chef
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

                  // Botón "Ver paso a paso →" con la paleta del Home
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver paso a paso',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: colors.secondary,
                        ),
                      ],
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
                color: colors.tertiary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 46,
                color: colors.tertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes recetas compradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Las recetas que compres aparecerán aquí con acceso vitalicio a su preparación paso a paso.',
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
