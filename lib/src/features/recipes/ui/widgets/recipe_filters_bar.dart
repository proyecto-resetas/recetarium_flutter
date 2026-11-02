import 'package:flutter/material.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';

enum RecipeSortOption {
  none,
  priceAsc,
  priceDesc,
  nameAsc,
}

class RecipeFilterCatalog {
  RecipeFilterCatalog._();

  static const List<Map<String, dynamic>> categories = [
    {
      'label': 'Todas',
      'value': null,
      'icon': Icons.local_fire_department_rounded,
    },
    {'label': 'Entrada', 'value': 'Entrada', 'icon': Icons.eco_rounded},
    {'label': 'Aperitivo', 'value': 'Aperitivo', 'icon': Icons.tapas_rounded},
    {
      'label': 'Plato principal',
      'value': 'Plato principal',
      'icon': Icons.restaurant_rounded,
    },
    {'label': 'Postre', 'value': 'Postre', 'icon': Icons.cake_rounded},
    {'label': 'Sopa', 'value': 'Sopa', 'icon': Icons.soup_kitchen_rounded},
    {'label': 'Ensalada', 'value': 'Ensalada', 'icon': Icons.grass_rounded},
    {
      'label': 'Guarnición',
      'value': 'Guarnicion',
      'icon': Icons.fastfood_rounded,
    },
    {'label': 'Salsa', 'value': 'Salsa', 'icon': Icons.water_drop_rounded},
  ];

  static const List<String> levels = ['Basico', 'Intermedio', 'Avanzado'];

  static Color levelColor(String level, ColorScheme colors) {
    switch (level.toLowerCase()) {
      case 'basico':
      case 'básico':
      case 'principiante':
        return colors.tertiary;
      case 'intermedio':
        return colors.primary;
      case 'avanzado':
        return const Color(0xFFD32F2F);
      default:
        return colors.secondary;
    }
  }

  static List<RecipesModel> applyFilters({
    required List<RecipesModel> source,
    String searchQuery = '',
    String? category,
    String? level,
    double? maxPrice,
    RecipeSortOption sortOption = RecipeSortOption.none,
  }) {
    final q = searchQuery.trim().toLowerCase();

    List<RecipesModel> result = source.where((r) {
      if (category != null &&
          category.isNotEmpty &&
          r.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (level != null &&
          level.isNotEmpty &&
          r.level.toLowerCase() != level.toLowerCase()) {
        return false;
      }
      if (maxPrice != null && r.price > maxPrice) {
        return false;
      }
      if (q.isNotEmpty) {
        final matchName = r.nameRecipe.toLowerCase().contains(q);
        final matchCat = r.category.toLowerCase().contains(q);
        final matchChef = r.creatorDisplayName.toLowerCase().contains(q);
        return matchName || matchCat || matchChef;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case RecipeSortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case RecipeSortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case RecipeSortOption.nameAsc:
        result.sort(
          (a, b) =>
              a.nameRecipe.toLowerCase().compareTo(b.nameRecipe.toLowerCase()),
        );
        break;
      case RecipeSortOption.none:
        break;
    }

    return result;
  }

  static void openFilterAndSortSheet({
    required BuildContext context,
    required List<RecipesModel> currentRecipes,
    required RecipeSortOption currentSort,
    required double? currentMaxPrice,
    required String? currentCategory,
    required String? currentLevel,
    required void Function({
      required RecipeSortOption sortOption,
      required double? maxPrice,
      required String? category,
      required String? level,
    }) onApply,
  }) {
    final colors = Theme.of(context).colorScheme;
    final allPrices =
        currentRecipes.map((r) => r.price.toDouble()).toList();
    final double highestPrice = allPrices.isEmpty
        ? 100.0
        : (allPrices.reduce((a, b) => a > b ? a : b))
            .ceilToDouble()
            .clamp(10.0, 500000.0);

    RecipeSortOption tempSort = currentSort;
    double? tempMaxPrice = currentMaxPrice;
    String? tempCategory = currentCategory;
    String? tempLevel = currentLevel;

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
                              tempSort = RecipeSortOption.none;
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
                          selected: tempSort == RecipeSortOption.none,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = RecipeSortOption.none,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Menor precio',
                          icon: Icons.trending_down_rounded,
                          selected: tempSort == RecipeSortOption.priceAsc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = RecipeSortOption.priceAsc,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Mayor precio',
                          icon: Icons.trending_up_rounded,
                          selected: tempSort == RecipeSortOption.priceDesc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = RecipeSortOption.priceDesc,
                          ),
                        ),
                        _buildSortChip(
                          label: 'Nombre (A-Z)',
                          icon: Icons.sort_by_alpha_rounded,
                          selected: tempSort == RecipeSortOption.nameAsc,
                          colors: colors,
                          onTap: () => setModalState(
                            () => tempSort = RecipeSortOption.nameAsc,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                      children: levels.map((lvl) {
                        final isSelected = tempLevel == lvl;
                        final lvlColor = levelColor(lvl, colors);
                        return ChoiceChip(
                          label: Text(
                            lvl,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? lvlColor
                                  : colors.secondary.withValues(alpha: 0.75),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: lvlColor.withValues(alpha: 0.14),
                          backgroundColor:
                              colors.secondary.withValues(alpha: 0.05),
                          side: BorderSide(
                            color: isSelected
                                ? lvlColor.withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
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
                          onApply(
                            sortOption: tempSort,
                            maxPrice: tempMaxPrice,
                            category: tempCategory,
                            level: tempLevel,
                          );
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

  static Widget _buildSortChip({
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
              ? colors.primary.withValues(alpha: 0.14)
              : colors.secondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.45)
                : colors.secondary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? colors.primary : colors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeFiltersHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;
  final String? selectedCategory;
  final String? selectedLevel;
  final RecipeSortOption sortOption;
  final double? maxPrice;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<String?> onLevelSelected;
  final VoidCallback onOpenFilterModal;

  const RecipeFiltersHeaderWidget({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.selectedCategory,
    required this.selectedLevel,
    required this.sortOption,
    required this.maxPrice,
    required this.onSearchChanged,
    this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onCategorySelected,
    required this.onLevelSelected,
    required this.onOpenFilterModal,
  });

  int get _activeAdvancedCount {
    int count = 0;
    if (selectedCategory != null) count++;
    if (selectedLevel != null) count++;
    if (sortOption != RecipeSortOption.none) count++;
    if (maxPrice != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Buscador + Botón de Filtrar y Ordenar ──────────────────────────
        Row(
          children: [
            Expanded(
              child: CustomIconInput(
                controller: searchController,
                hintText: hintText,
                prefixIcon: Icons.search_rounded,
                textInputAction: TextInputAction.search,
                onCleared: onSearchCleared,
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted,
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onOpenFilterModal,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colors.secondary,
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
        const SizedBox(height: 12),

        // ─── Píldoras de Categorías Centradas ───────────────────────────────
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                RecipeFilterCatalog.categories.length,
                (i) {
                  final cat = RecipeFilterCatalog.categories[i];
                  final val = cat['value'] as String?;
                  final selected = selectedCategory == val;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i == RecipeFilterCatalog.categories.length - 1
                          ? 0
                          : 8,
                    ),
                    child: GestureDetector(
                      onTap: () => onCategorySelected(
                        selected && val != null ? null : val,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: selected
                                ? colors.primary.withValues(alpha: 0.45)
                                : colors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 15,
                              color: selected
                                  ? colors.primary
                                  : colors.secondary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['label'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: colors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ─── Píldoras de Nivel de Dificultad Centradas (sin etiqueta) ────────
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                RecipeFilterCatalog.levels.length,
                (i) {
                  final lvl = RecipeFilterCatalog.levels[i];
                  final selected = selectedLevel == lvl;
                  final lvlColor = RecipeFilterCatalog.levelColor(lvl, colors);
                  return Padding(
                    padding: EdgeInsets.only(
                      right:
                          i == RecipeFilterCatalog.levels.length - 1 ? 0 : 8,
                    ),
                    child: GestureDetector(
                      onTap: () => onLevelSelected(selected ? null : lvl),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? lvlColor.withValues(alpha: 0.14)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? lvlColor.withValues(alpha: 0.45)
                                : colors.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: lvlColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lvl,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: selected
                                    ? lvlColor
                                    : colors.secondary.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
