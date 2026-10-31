import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_favorite_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class MyRecipesFavorites extends StatefulWidget {
  final bool embedded;
  final String searchQuery;
  final String? selectedCategory;

  const MyRecipesFavorites({
    super.key,
    this.embedded = false,
    this.searchQuery = '',
    this.selectedCategory,
  });

  @override
  State<MyRecipesFavorites> createState() => _MyRecipesFavoritesState();
}

class _MyRecipesFavoritesState extends State<MyRecipesFavorites> {
  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _bgWarm = Color(0xFFFAF8F5);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);

  bool _isLoading = false;
  String _localSearch = '';
  String? _localCategory;
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

  Color _levelBadgeColor(String level) {
    switch (level.toLowerCase()) {
      case 'basico':
      case 'básico':
      case 'principiante':
        return const Color(0xFF2E7D32);
      case 'intermedio':
        return const Color(0xFFF28C25);
      case 'avanzado':
        return const Color(0xFFD32F2F);
      default:
        return _brandOrange;
    }
  }

  List<RecipesModel> _filterRecipes(List<RecipesModel> source) {
    final query =
        (widget.embedded ? widget.searchQuery : _localSearch).trim().toLowerCase();
    final category =
        widget.embedded ? widget.selectedCategory : _localCategory;

    return source.where((r) {
      if (category != null &&
          category.isNotEmpty &&
          r.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = r.nameRecipe.toLowerCase().contains(query);
        final matchCategory = r.category.toLowerCase().contains(query);
        final matchChef = r.creatorDisplayName.toLowerCase().contains(query);
        return matchName || matchCategory || matchChef;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<RecipeFavoriteProvider>();
    final shopProvider = context.watch<CarShopProvider>();
    final authProvider = context.read<AuthProvider>();
    final filtered = _filterRecipes(favProvider.favoriteList);

    final content = RefreshIndicator(
      color: _brandOrange,
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
                        const Text(
                          'Mis Favoritas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${favProvider.favoriteList.length}',
                            style: const TextStyle(
                              color: _brandOrange,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recetas que has guardado para preparar más adelante',
                      style: TextStyle(fontSize: 13.5, color: _textMuted),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _localSearch = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar en mis favoritas...',
                        hintStyle: const TextStyle(
                          color: _textMuted,
                          fontSize: 13.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _textMuted,
                          size: 20,
                        ),
                        suffixIcon: _localSearch.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _localSearch = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFEDEFF2),
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
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final selected = _localCategory == cat.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _localCategory = cat.value),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? _brandOrange : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: selected
                                        ? _brandOrange
                                        : const Color(0xFFD8D4CE),
                                  ),
                                ),
                                child: Row(
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
                                        color: selected
                                            ? Colors.white
                                            : _textDark,
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
                ),
              ),
            ),
          if (_isLoading && favProvider.favoriteList.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: _brandOrange),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
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
      backgroundColor: _bgWarm,
      body: content,
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    RecipesModel recipe,
    RecipeFavoriteProvider favProvider,
    CarShopProvider shopProvider,
    AuthProvider authProvider,
  ) {
    final inCart = shopProvider.shoppingList.any((r) => r.id == recipe.id);

    return GestureDetector(
      onTap: () => context.push('/recipes_details', extra: recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen con badge de dificultad
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
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: _levelBadgeColor(recipe.level),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.level,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
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
                        color: const Color(0xFFE8EEF2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.nameRecipe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 13.5,
                        color: _textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.creatorDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(recipe.price),
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: _brandOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Acciones derechas: Favorito (arriba) + Carrito (abajo)
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
                              textColor: _brandOrange,
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
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFD32F2F),
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
                            ? const Color(0xFFE8F5E9)
                            : _brandOrange.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        inCart
                            ? Icons.check_rounded
                            : Icons.add_shopping_cart_rounded,
                        color: inCart ? const Color(0xFF2E7D32) : _brandOrange,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes recetas favoritas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Toca el corazón en cualquier receta del catálogo para guardarla aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
