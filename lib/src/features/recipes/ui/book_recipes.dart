import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_created.dart';
import 'package:resetas/src/features/recipes/ui/my_recipes_favorite.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:resetas/src/features/shopping_cart/ui/my_purchased_recipes.dart';

class BookRecipes extends StatefulWidget {
  final VoidCallback? onCreateRecipeTap;

  const BookRecipes({super.key, this.onCreateRecipeTap});

  @override
  State<BookRecipes> createState() => _BookRecipesState();
}

class _BookRecipesState extends State<BookRecipes> {
  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _bgWarm = Color(0xFFFAF8F5);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);
  static const Color _filterBtnDark = Color(0xFF1A3A3A);

  int _selectedIndex = 0; // 0: Favoritas, 1: Creadas, 2: Compradas
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  static const List<({String label, String? value, IconData icon})>
      _categories = [
    (
      label: 'Todas',
      value: null,
      icon: Icons.local_fire_department_rounded,
    ),
    (
      label: 'Entrada',
      value: 'Entrada',
      icon: Icons.soup_kitchen_rounded,
    ),
    (
      label: 'Plato principal',
      value: 'Plato principal',
      icon: Icons.restaurant_rounded,
    ),
    (
      label: 'Postre',
      value: 'Postre',
      icon: Icons.cake_rounded,
    ),
    (
      label: 'Sopa',
      value: 'Sopa',
      icon: Icons.ramen_dining_rounded,
    ),
    (
      label: 'Guarnición',
      value: 'Guarnicion',
      icon: Icons.eco_rounded,
    ),
  ];

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

  Widget _buildActiveTabBody() {
    switch (_selectedIndex) {
      case 0:
        return MyRecipesFavorites(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
        );
      case 1:
        return MyRecipesCreated(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
          onCreateRecipeTap: widget.onCreateRecipeTap,
        );
      case 2:
        return MyPurchasedRecipes(
          embedded: true,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<RecipeFavoriteProvider>().favoriteList.length;
    final createdCount =
        context.watch<RecipeMyCreatedProvider>().myRecipeList.length;
    final purchasedCount =
        context.watch<CarShopProvider>().purchasedList.length;

    return Scaffold(
      backgroundColor: _bgWarm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Cabecera Principal "Mi Recetario" ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi Recetario',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tus recetas favoritas, creadas y\ndesbloqueadas',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF3E3E3E),
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),

                // ─── Selector de Pestañas (Favoritas | Creadas | Compradas) ─
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabPill(
                        index: 0,
                        label: 'Favoritas ($favCount)',
                        icon: Icons.favorite_rounded,
                        inactiveIconColor: const Color(0xFFC62828),
                      ),
                      const SizedBox(width: 8),
                      _buildTabPill(
                        index: 1,
                        label: 'Creadas ($createdCount)',
                        icon: Icons.restaurant_menu_rounded,
                        inactiveIconColor: _brandOrange,
                      ),
                      const SizedBox(width: 8),
                      _buildTabPill(
                        index: 2,
                        label: 'Compradas ($purchasedCount)',
                        icon: Icons.shopping_bag_rounded,
                        inactiveIconColor: const Color(0xFF6A1B9A),
                      ),
                    ],
                  ),
                ),

                // ─── Buscador y Categorías (en Favoritas y Compradas) ──────
                if (_selectedIndex != 1) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Buscar en mi recetario...',
                            hintStyle: const TextStyle(
                              color: _textMuted,
                              fontSize: 13.5,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _textDark,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFD9E1E5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          if (_selectedCategory != null ||
                              _searchQuery.isNotEmpty) {
                            _searchController.clear();
                            setState(() {
                              _selectedCategory = null;
                              _searchQuery = '';
                            });
                          }
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _filterBtnDark,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected ? _brandOrange : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: selected
                                      ? _brandOrange
                                      : const Color(0xFF4B5563),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 15,
                                    color:
                                        selected ? Colors.white : _brandOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.label,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          selected ? Colors.white : _textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
    required int index,
    required String label,
    required IconData icon,
    required Color inactiveIconColor,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _brandOrange : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _brandOrange : const Color(0xFF3E3E3E),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandOrange.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : inactiveIconColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
