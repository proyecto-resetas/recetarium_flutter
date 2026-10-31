import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';

class MyRecipesCreated extends StatefulWidget {
  final bool embedded;
  final String searchQuery;
  final String? selectedCategory;
  final VoidCallback? onCreateRecipeTap;

  const MyRecipesCreated({
    super.key,
    this.embedded = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.onCreateRecipeTap,
  });

  @override
  State<MyRecipesCreated> createState() => _MyRecipesCreatedState();
}

class _MyRecipesCreatedState extends State<MyRecipesCreated> {
  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _bgWarm = Color(0xFFFAF8F5);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCreatedRecipes());
  }

  Future<void> _loadCreatedRecipes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await context
          .read<RecipeMyCreatedProvider>()
          .getMyRecipesCreated(authProvider.user);
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
    final query = widget.searchQuery.trim().toLowerCase();
    final category = widget.selectedCategory;

    return source.where((r) {
      if (category != null &&
          category.isNotEmpty &&
          r.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = r.nameRecipe.toLowerCase().contains(query);
        final matchCategory = r.category.toLowerCase().contains(query);
        return matchName || matchCategory;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final createdProvider = context.watch<RecipeMyCreatedProvider>();
    final allCreated = createdProvider.myRecipeList;
    final filtered = _filterRecipes(allCreated);

    final content = RefreshIndicator(
      color: _brandOrange,
      onRefresh: _loadCreatedRecipes,
      child: CustomScrollView(
        slivers: [
          // Banner Resumen de Creador ("Has creado X recetas en Recetarium")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _brandOrange.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: _textDark,
                        ),
                        children: [
                          const TextSpan(text: 'Has creado '),
                          TextSpan(
                            text:
                                '${allCreated.length} ${allCreated.length == 1 ? 'receta' : 'recetas'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(text: ' en Recetarium'),
                        ],
                      ),
                    ),
                    if (widget.onCreateRecipeTap != null) ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: widget.onCreateRecipeTap,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Crear receta',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading && allCreated.isEmpty)
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCreatedRecipeCard(
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

  Widget _buildCreatedRecipeCard(BuildContext context, RecipesModel recipe) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda: miniatura + badge "★ Tu receta"
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 92,
                    height: 82,
                    child: MyImage(recipe.imageUrl),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: _textDark,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Tu receta',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Información central y acciones
            Expanded(
              child: SizedBox(
                height: 108,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          )
                        else
                          const SizedBox.shrink(),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEFF2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatPrice(recipe.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _brandOrange,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _brandOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ver receta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
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
                color: Color(0xFFFFF3EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 40,
                color: _brandOrange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no has creado recetas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Publica tus propias creaciones culinarias y compártelas con la comunidad de Recetarium.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
