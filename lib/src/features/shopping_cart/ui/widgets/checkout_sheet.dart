import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/utils/input_sanitizers.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/shopping_cart/data/car_shop_provider.dart';

/// Formatea fechas de expiración de tarjeta como `MM/AA`.
class _CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clamped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final formatted = clamped.length > 2
        ? '${clamped.substring(0, 2)}/${clamped.substring(2)}'
        : clamped;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Modal de checkout con Wompi alineado al tema y componentes globales de Recetarium.
class CheckoutSheet extends StatefulWidget {
  final CarShopProvider shopProvider;
  final String Function(num) formatPrice;

  const CheckoutSheet({
    super.key,
    required this.shopProvider,
    required this.formatPrice,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textMuted = Color(0xFF6E7685);

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

  bool _isValidExpiration(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value.trim());
    if (match == null) return false;
    final month = int.tryParse(match.group(1)!) ?? 0;
    return month >= 1 && month <= 12;
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
          backgroundColor: const Color(0xFF15803D),
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
          backgroundColor: const Color(0xFFE53935),
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
    final colors = Theme.of(context).colorScheme;
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: colors.secondary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Checkout con Wompi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
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
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primary,
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
                    Material(
                      color: colors.secondary.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colors.secondary.withValues(alpha: 0.14),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            secondary: Icon(
                              Icons.card_giftcard_rounded,
                              color: colors.secondary,
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
                            activeThumbColor: colors.primary,
                            value: _isGift,
                            onChanged: (val) => setState(() => _isGift = val),
                          ),
                          if (_isGift)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: CustomIconInput(
                                controller: _giftEmailController,
                                label: 'Correo del destinatario',
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                maxLength: 100,
                                validator: (v) {
                                  if (!_isGift) return null;
                                  final trimmed = v?.trim() ?? '';
                                  if (!InputSanitizers.isValidEmail(trimmed)) {
                                    return 'Ingresa un correo electrónico válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Datos de la tarjeta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomIconInput(
                      controller: _nameController,
                      label: 'Nombre en la tarjeta',
                      hintText: 'Como aparece en la tarjeta',
                      prefixIcon: Icons.person_outline_rounded,
                      maxLength: 70,
                      inputFormatters: InputSanitizers.safeText,
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Ingresa el titular de la tarjeta';
                        }
                        if (trimmed.length < 3) {
                          return 'Ingresa el nombre completo del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomIconInput(
                      controller: _cardController,
                      label: 'Número de tarjeta',
                      hintText: '0000000000000000',
                      helperText: 'Solo dígitos (sin espacios ni guiones).',
                      prefixIcon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      inputFormatters: InputSanitizers.digitsOnly,
                      validator: (v) {
                        final digits = v?.trim() ?? '';
                        if (digits.length < 13) {
                          return 'Ingresa un número de tarjeta válido (mínimo 13 dígitos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomIconInput(
                            controller: _expController,
                            label: 'Expiración',
                            hintText: 'MM/AA',
                            prefixIcon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [_CardExpirationFormatter()],
                            validator: (v) {
                              if (v == null || !_isValidExpiration(v)) {
                                return 'Usa MM/AA válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomIconInput(
                            controller: _cvcController,
                            label: 'CVC',
                            hintText: '123',
                            prefixIcon: Icons.lock_outline_rounded,
                            keyboardType: TextInputType.number,
                            isPassword: true,
                            maxLength: 4,
                            inputFormatters: InputSanitizers.digitsOnly,
                            validator: (v) {
                              final digits = v?.trim() ?? '';
                              if (digits.length < 3) {
                                return 'CVC de 3 o 4 dígitos';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    CustomMainButton(
                      text: provider.isPurchasing
                          ? 'Procesando compra...'
                          : 'Confirmar y pagar ${widget.formatPrice(total)}',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: provider.isPurchasing,
                      onPressed: provider.isPurchasing ? null : _submitPayment,
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
