import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

enum _RecipeSortOption {
  none,
  priceAsc,
  priceDesc,
  nameAsc,
}

class ExploreRecipesScreen extends StatefulWidget {
  const ExploreRecipesScreen({super.key});

  @override
  State<ExploreRecipesScreen> createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLevel;
  _RecipeSortOption _sortOption = _RecipeSortOption.none;
  double? _maxPrice;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Todas', 'value': null, 'icon': Icons.local_fire_department_rounded},
    {'label': 'Entrada', 'value': 'Entrada', 'icon': Icons.eco_rounded},
    {'label': 'Aperitivo', 'value': 'Aperitivo', 'icon': Icons.tapas_rounded},
    {'label': 'Plato principal', 'value': 'Plato principal', 'icon': Icons.restaurant_rounded},
    {'label': 'Postre', 'value': 'Postre', 'icon': Icons.cake_rounded},
    {'label': 'Sopa', 'value': 'Sopa', 'icon': Icons.soup_kitchen_rounded},
    {'label': 'Ensalada', 'value': 'Ensalada', 'icon': Icons.grass_rounded},
    {'label': 'Guarnición', 'value': 'Guarnicion', 'icon': Icons.fastfood_rounded},
    {'label': 'Salsa', 'value': 'Salsa', 'icon': Icons.water_drop_rounded},
  ];

  static const _levels = ['Basico', 'Intermedio', 'Avanzado'];

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
    if (_sortOption != _RecipeSortOption.none) count++;
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
      _sortOption = _RecipeSortOption.none;
      _maxPrice = null;
    });
    _applyFilters(provider);
  }

  List<RecipesModel> _getProcessedRecipes(List<RecipesModel> rawList) {
    List<RecipesModel> result = List<RecipesModel>.from(rawList);

    if (_maxPrice != null) {
      result = result.where((r) => r.price <= _maxPrice!).toList();
    }

    switch (_sortOption) {
      case _RecipeSortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _RecipeSortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _RecipeSortOption.nameAsc:
        result.sort(
          (a, b) =>
              a.nameRecipe.toLowerCase().compareTo(b.nameRecipe.toLowerCase()),
        );
        break;
      case _RecipeSortOption.none:
        break;
    }

    return result;
  }

  void _openFilterAndSortSheet(
    BuildContext context,
    ViewRecipesProvider provider,
  ) {
    final colors = Theme.of(context).colorScheme;
    final allPrices =
        provider.recipeListFilter.map((r) => r.price.toDouble()).toList();
    final double highestPrice = allPrices.isEmpty
        ? 100.0
        : (allPrices.reduce((a, b) => a > b ? a : b)).ceilToDouble().clamp(
              10.0,
              500000.0,
            );

    _RecipeSortOption tempSort = _sortOption;
    double? tempMaxPrice = _maxPrice;
    String? tempCategory = _selectedCategory;
    String? tempLevel = _selectedLevel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador superior (drag handle)
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título + Botón restablecer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtrar y ordenar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSort = _RecipeSortOption.none;
                              tempMaxPrice = null;
                              tempCategory = null;
                              tempLevel = null;
                            });
                          },
                          child: Text(
                            'Restablecer',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Ordenar por
                    Text(
                      'Ordenar por',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip(
                          label: 'Predeterminado',
                          icon: Icons.auto_awesome_rounded,
                          selected: tempSort == _RecipeSortOption.none,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = _RecipeSortOption.none,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Menor precio',
                          icon: Icons.trending_down_rounded,
                          selected: tempSort == _RecipeSortOption.priceAsc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = _RecipeSortOption.priceAsc,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Mayor precio',
                          icon: Icons.trending_up_rounded,
                          selected: tempSort == _RecipeSortOption.priceDesc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = _RecipeSortOption.priceDesc,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Nombre (A-Z)',
                          icon: Icons.sort_by_alpha_rounded,
                          selected: tempSort == _RecipeSortOption.nameAsc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = _RecipeSortOption.nameAsc,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Presupuesto / Precio máximo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precio máximo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.secondary,
                          ),
                        ),
                        Text(
                          tempMaxPrice == null
                              ? 'Sin límite'
                              : 'Hasta \$${tempMaxPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: (tempMaxPrice ?? highestPrice)
                          .clamp(0.0, highestPrice),
                      min: 0,
                      max: highestPrice,
                      activeColor: colors.primary,
                      inactiveColor: colors.secondary.withValues(alpha: 0.12),
                      onChanged: (val) {
                        setModalState(() {
                          tempMaxPrice =
                              val >= highestPrice ? null : val.roundToDouble();
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // 3. Nivel de dificultad
                    Text(
                      'Nivel de dificultad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _levels.map((lvl) {
                        final isSelected = tempLevel == lvl;
                        final lvlColor = _levelColor(lvl, colors);
                        return ChoiceChip(
                          label: Text(
                            lvl,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : lvlColor,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: lvlColor,
                          backgroundColor: lvlColor.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (val) {
                            setModalState(() {
                              tempLevel = val ? lvl : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Botón Aplicar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final bool apiFilterChanged =
                              tempCategory != _selectedCategory ||
                                  tempLevel != _selectedLevel;
                          setState(() {
                            _sortOption = tempSort;
                            _maxPrice = tempMaxPrice;
                            _selectedCategory = tempCategory;
                            _selectedLevel = tempLevel;
                          });
                          if (apiFilterChanged) {
                            _applyFilters(provider);
                          }
                          Navigator.pop(sheetContext);
                        },
                        child: const Text(
                          'Aplicar preferencias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip({
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : colors.secondary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.secondary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : colors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : colors.secondary,
              ),
            ),
          ],
        ),
      ),
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
            // ─── Bienvenida + Buscador + Botón Filtrar/Ordenar ──────────────
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

                    // Barra de búsqueda + Botón de Filtrar y Ordenar
                    Row(
                      children: [
                        Expanded(
                          child: CustomIconInput(
                            controller: _searchController,
                            hintText: 'Buscar receta o ingrediente…',
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
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: colors.secondary,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () =>
                                    _openFilterAndSortSheet(context, provider),
                                child: const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            if (_activeAdvancedCount > 0)
                              Positioned(
                                top: -5,
                                right: -5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '$_activeAdvancedCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Píldoras de Categorías ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final val = cat['value'];
                      final selected = _selectedCategory == val;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory =
                                selected && val != null ? null : val;
                          });
                          _applyFilters(provider);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? colors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? colors.primary
                                  : colors.secondary.withValues(alpha: 0.14),
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color:
                                          colors.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 15,
                                color: selected
                                    ? Colors.white
                                    : colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : colors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ─── Barra de Nivel de Dificultad ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Dificultad:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.secondary.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ..._levels.map((lvl) {
                        final selected = _selectedLevel == lvl;
                        final lvlColor = _levelColor(lvl, colors);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLevel = selected ? null : lvl;
                              });
                              _applyFilters(provider);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? lvlColor
                                    : lvlColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? lvlColor
                                      : lvlColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.white : lvlColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    lvl,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : lvlColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
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
                        color: _levelColor(recipe.level, colors),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recipe.level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
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
                            color: isFav ? Colors.red : Colors.grey.shade700,
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
                              color: colors.primary.withValues(alpha: 0.14),
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
