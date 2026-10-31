import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/image_card.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/shopping_cart/data/car_shop_provider.dart';

class CarShop extends StatelessWidget {
  const CarShop({super.key});

  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _bgWarm = Color(0xFFFAF8F5);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);

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

  Color _levelBgColor(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return const Color(0xFFE8F5E9);
      case 'intermedio':
        return const Color(0xFFFFF8E1);
      case 'avanzado':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _levelTextColor(String level) {
    switch (level.toLowerCase()) {
      case 'principiante':
        return const Color(0xFF2E7D32);
      case 'intermedio':
        return const Color(0xFFEF6C00);
      case 'avanzado':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF4B5563);
    }
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
              backgroundColor: const Color(0xFFE53935),
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
            textColor: _brandOrange,
            onPressed: () {
              shopProvider.addToCart(recipe);
            },
          ),
        ),
      );
  }

  void _openCheckoutModal(BuildContext context, CarShopProvider shopProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckoutSheet(
        shopProvider: shopProvider,
        formatPrice: _formatPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<CarShopProvider>(context);
    final items = shopProvider.shoppingList;

    return Scaffold(
      backgroundColor: _bgWarm,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/icon/recetariumLogoxxl-03.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'Mi Carrito',
              style: TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    color: _brandOrange,
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
                  color: Color(0xFFE53935),
                ),
                label: const Text(
                  'Vaciar',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Banner informativo superior
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _brandOrange.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: _brandOrange,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Al comprar desbloqueas de por vida el paso a paso completo y los utensilios de cada receta.',
                          style: TextStyle(
                            color: Color(0xFF9A3B0E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de recetas en el carrito
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final recipe = items[index];
                      return _buildCartItemCard(context, shopProvider, recipe);
                    },
                  ),
                ),

                // Panel inferior de resumen y botón de pago
                _buildBottomCheckoutSummary(context, shopProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: const Color(0xFFFFF3EC),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _brandOrange.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 46,
                color: _brandOrange,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
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
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.explore_outlined, size: 19),
              label: const Text(
                'Explorar recetas',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CarShopProvider shopProvider,
    RecipesModel recipe,
  ) {
    final chefName =
        (recipe.createdBy?.username != null &&
            recipe.createdBy!.username.trim().isNotEmpty)
        ? recipe.createdBy!.username
        : 'Chef Recetarium';

    return Dismissible(
      key: ValueKey(recipe.id ?? recipe.nameRecipe),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
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
              // Miniatura redondeada de la receta
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: MyImage(recipe.imageUrl),
                ),
              ),
              const SizedBox(width: 14),

              // Información central de la receta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría + Nivel de dificultad
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (recipe.category.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F1EE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              recipe.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                              ),
                            ),
                          ),
                        if (recipe.level.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _levelBgColor(recipe.level),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              recipe.level,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _levelTextColor(recipe.level),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Nombre de la receta
                    Text(
                      recipe.nameRecipe,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Chef / autor
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: _textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            chefName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Precio
                    Text(
                      _formatPrice(recipe.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _brandOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Botón cuadrado para quitar del carrito
              Tooltip(
                message: 'Quitar del carrito',
                child: InkWell(
                  onTap: () =>
                      _removeRecipeWithUndo(context, shopProvider, recipe),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: Color(0xFFD32F2F),
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
                  'Resumen ($count ${count == 1 ? 'receta' : 'recetas'})',
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _formatPrice(total),
                  style: const TextStyle(
                    fontSize: 20,
                    color: _brandOrange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _openCheckoutModal(context, shopProvider),
                icon: const Icon(Icons.lock_outline_rounded, size: 19),
                label: Text(
                  'Pagar con Wompi • ${_formatPrice(total)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final CarShopProvider shopProvider;
  final String Function(num) formatPrice;

  const _CheckoutSheet({
    required this.shopProvider,
    required this.formatPrice,
  });

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  static const Color _brandOrange = Color(0xFFF26625);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF757575);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expController = TextEditingController();
  final _cvcController = TextEditingController();
  final _giftEmailController = TextEditingController();

  bool _isGift = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expController.dispose();
    _cvcController.dispose();
    _giftEmailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _brandOrange, size: 20),
      filled: true,
      fillColor: const Color(0xFFFAF8F5),
      labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E0D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E0D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandOrange, width: 1.5),
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ref = 'wompi_${DateTime.now().millisecondsSinceEpoch}';
    final giftEmail = _isGift && _giftEmailController.text.trim().isNotEmpty
        ? _giftEmailController.text.trim()
        : null;

    final purchasedCount = await widget.shopProvider.checkoutCart(
      paymentReference: ref,
      recipientEmail: giftEmail,
    );

    if (!mounted) return;
    navigator.pop();

    if (purchasedCount > 0) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  giftEmail != null
                      ? '¡Compra exitosa! Se enviaron $purchasedCount receta(s) a $giftEmail'
                      : '¡Compra exitosa! $purchasedCount receta(s) agregada(s) a tus recetas compradas',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFC62828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            'No se pudo procesar la compra (verifica si ya habías comprado esta receta).',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<CarShopProvider>(
      builder: (context, provider, _) {
        final total = provider.totalPrice;
        final recipes = provider.shoppingList;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle superior
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Encabezado del checkout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: _brandOrange,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Checkout con Wompi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tarjeta resumen del pedido dentro del modal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${recipes.length} ${recipes.length == 1 ? 'receta seleccionada' : 'recetas seleccionadas'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                widget.formatPrice(total),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: _brandOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: recipes
                                .map(
                                  (r) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      r.nameRecipe,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: _textDark,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opción de regalo (usa recipientEmail del backend)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E0D8)),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            secondary: const Icon(
                              Icons.card_giftcard_rounded,
                              color: _brandOrange,
                            ),
                            title: const Text(
                              '¿Enviar como regalo?',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            subtitle: const Text(
                              'Regala el acceso a otro correo registrado',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _textMuted,
                              ),
                            ),
                            activeThumbColor: _brandOrange,
                            value: _isGift,
                            onChanged: (val) => setState(() => _isGift = val),
                          ),
                          if (_isGift)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: TextFormField(
                                controller: _giftEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(
                                  label: 'Correo del destinatario',
                                  hint: 'ejemplo@correo.com',
                                  icon: Icons.alternate_email_rounded,
                                ),
                                validator: (v) {
                                  if (_isGift &&
                                      (v == null || !v.contains('@'))) {
                                    return 'Ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Datos de la tarjeta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        label: 'Nombre en la tarjeta',
                        hint: 'Como aparece en la tarjeta',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el titular de la tarjeta'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _cardController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: 'Número de tarjeta',
                        hint: '0000 0000 0000 0000',
                        icon: Icons.credit_card_rounded,
                      ),
                      validator: (v) => (v == null || v.trim().length < 8)
                          ? 'Ingresa un número de tarjeta válido'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expController,
                            keyboardType: TextInputType.datetime,
                            decoration: _inputDecoration(
                              label: 'Expiración',
                              hint: 'MM/AA',
                              icon: Icons.calendar_today_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvcController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: _inputDecoration(
                              label: 'CVC',
                              hint: '123',
                              icon: Icons.lock_outline_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? 'CVC inválido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: provider.isPurchasing
                            ? null
                            : _submitPayment,
                        icon: provider.isPurchasing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          provider.isPurchasing
                              ? 'Procesando compra...'
                              : 'Confirmar y pagar ${widget.formatPrice(total)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
