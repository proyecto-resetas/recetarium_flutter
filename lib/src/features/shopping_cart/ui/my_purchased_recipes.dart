import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class MyPurchasedRecipes extends StatefulWidget {
  final bool embedded;
  final String searchQuery;
  final String? selectedCategory;

  const MyPurchasedRecipes({
    super.key,
    this.embedded = false,
    this.searchQuery = '',
    this.selectedCategory,
  });

  @override
  State<MyPurchasedRecipes> createState() => _MyPurchasedRecipesState();
}

class _MyPurchasedRecipesState extends State<MyPurchasedRecipes> {
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
  ];

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
    final shopProvider = context.watch<CarShopProvider>();
    final allPurchased = shopProvider.purchasedList;
    final filtered = _filterRecipes(allPurchased);

    final content = RefreshIndicator(
      color: _brandOrange,
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
                        const Text(
                          'Mis Recetas Compradas',
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
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${allPurchased.length}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recetas con el paso a paso e ingredientes desbloqueados de por vida',
                      style: TextStyle(fontSize: 13.5, color: _textMuted),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _localSearch = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar en mis compradas...',
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
          if (_isLoading && allPurchased.isEmpty)
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
                  (context, index) => _buildPurchasedCard(
                    context,
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
      backgroundColor: _bgWarm,
      body: content,
    );
  }

  Widget _buildPurchasedCard(BuildContext context, RecipesModel recipe) {
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
                  // Badge verde "✓ Desbloqueada"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF4E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Color(0xFF1F7A3A),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Desbloqueada',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F7A3A),
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Chef
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

                  // Botón cálido "Ver paso a paso →"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFE6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver paso a paso',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: _textDark,
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
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes recetas compradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Las recetas que compres aparecerán aquí con acceso vitalicio a su preparación paso a paso.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
