import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/core/widgets/image_card.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';
import 'package:recetarium/src/features/recipes/ui/widgets/recipe_filters_bar.dart';
import 'package:recetarium/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:recetarium/src/features/shopping_cart/ui/widgets/checkout_sheet.dart';

class CarShop extends StatelessWidget {
  const CarShop({super.key});

  static const Color _bgPage = Color(0xFFF8F9FA);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF6E7685);
  static const Color _dangerRed = Color(0xFFE53935);

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
    return '\$ ${buffer.toString()}';
  }

  void _confirmClearCart(BuildContext context, CarShopProvider shopProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Vaciar carrito?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _textDark,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Se eliminarán todas las recetas que tienes seleccionadas en tu carrito de compras.',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              shopProvider.clearCart();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se vació el carrito de compras'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vaciar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _removeRecipeWithUndo(
    BuildContext context,
    CarShopProvider shopProvider,
    RecipesModel recipe,
  ) {
    final colors = Theme.of(context).colorScheme;
    shopProvider.removeFromCart(recipe);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Se quitó "${recipe.nameRecipe}" del carrito'),
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: colors.primary,
            onPressed: () => shopProvider.addToCart(recipe),
          ),
        ),
      );
  }

  void _openCheckoutModal(BuildContext context, CarShopProvider shopProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CheckoutSheet(
        shopProvider: shopProvider,
        formatPrice: _formatPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shopProvider = Provider.of<CarShopProvider>(context);
    final items = shopProvider.shoppingList;

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomBackAppBar(
        backgroundColor: _bgPage,
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mi Carrito',
              style: TextStyle(
                color: colors.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _confirmClearCart(context, shopProvider),
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: _dangerRed,
                ),
                label: const Text(
                  'Vaciar',
                  style: TextStyle(
                    color: _dangerRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmptyState(context, colors)
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.secondary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          color: colors.secondary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Al comprar desbloqueas de por vida el paso a paso completo y los utensilios de cada receta.',
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final recipe = items[index];
                        return _buildBookStyleCartCard(
                          context,
                          colors,
                          shopProvider,
                          recipe,
                        );
                      },
                    ),
                  ),
                  _buildBottomCheckoutSummary(context, colors, shopProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 46,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora el catálogo de Recetarium y agrega tus recetas favoritas para desbloquear su preparación paso a paso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 220,
              child: CustomMainButton(
                text: 'Explorar recetas',
                icon: Icons.explore_outlined,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookStyleCartCard(
    BuildContext context,
    ColorScheme colors,
    CarShopProvider shopProvider,
    RecipesModel recipe,
  ) {
    final lvlColor = RecipeFilterCatalog.levelColor(recipe.level, colors);

    return Dismissible(
      key: ValueKey(recipe.id ?? recipe.nameRecipe),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: _dangerRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      onDismissed: (_) => _removeRecipeWithUndo(context, shopProvider, recipe),
      child: GestureDetector(
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
              // Miniatura estilo Book con badge translúcido de nivel
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

              // Información central idéntica a la vista Book + precio
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
                        color: _textDark,
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
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(recipe.price),
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Botón sutil para quitar del carrito
              Tooltip(
                message: 'Quitar del carrito',
                child: InkWell(
                  onTap: () =>
                      _removeRecipeWithUndo(context, shopProvider, recipe),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: _textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCheckoutSummary(
    BuildContext context,
    ColorScheme colors,
    CarShopProvider shopProvider,
  ) {
    final total = shopProvider.totalPrice;
    final count = shopProvider.shoppingList.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal ($count ${count == 1 ? 'receta' : 'recetas'})',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatPrice(total),
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Acceso',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'De por vida',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 17,
                    color: colors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _formatPrice(total),
                  style: TextStyle(
                    fontSize: 20,
                    color: colors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomMainButton(
              text: 'Continuar al pago',
              icon: Icons.credit_card_rounded,
              onPressed: () => _openCheckoutModal(context, shopProvider),
            ),
          ],
        ),
      ),
    );
  }
}
