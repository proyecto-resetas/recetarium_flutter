import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/l10n/app_localizations.dart';
import 'package:recetarium/src/core/theme/app_theme.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';
import 'package:recetarium/src/features/shopping_cart/data/car_shop_provider.dart';
import 'package:recetarium/src/features/shopping_cart/ui/car_shop.screen.dart';
import 'package:recetarium/src/features/shopping_cart/ui/widgets/checkout_sheet.dart';

void main() {
  Widget buildTestApp(CarShopProvider provider) {
    return ChangeNotifierProvider<CarShopProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme(typographyCustom: 0).theme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CarShop(),
      ),
    );
  }

  testWidgets('CarShop vacío muestra CustomBackAppBar y estado vacío',
      (WidgetTester tester) async {
    final provider = CarShopProvider();

    await tester.pumpWidget(buildTestApp(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CustomBackAppBar), findsOneWidget);
    expect(find.text('Mi Carrito'), findsOneWidget);
    expect(find.text('Tu carrito está vacío'), findsOneWidget);
  });

  testWidgets(
      'CarShop con recetas muestra cards estilo Book, resumen y abre CheckoutSheet',
      (WidgetTester tester) async {
    final provider = CarShopProvider();
    provider.addToCart(
      RecipesModel(
        id: 'r-1',
        nameRecipe: 'Risotto de Hongos Trufado',
        descriptionRecipe: 'Cremoso risotto italiano',
        price: 15000,
        level: 'Intermedio',
        category: 'Italiana',
        createdBy: {'username': 'Chef Marco'},
      ),
    );

    await tester.pumpWidget(buildTestApp(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CustomBackAppBar), findsOneWidget);
    expect(find.text('Risotto de Hongos Trufado'), findsOneWidget);
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Italiana'), findsOneWidget);
    expect(find.text('Chef Marco'), findsOneWidget);
    expect(find.text('\$ 15.000'), findsWidgets);
    expect(find.text('De por vida'), findsOneWidget);

    final payButton = find.widgetWithText(CustomMainButton, 'Continuar al pago');
    expect(payButton, findsOneWidget);

    await tester.tap(payButton);
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutSheet), findsOneWidget);
    expect(find.text('Checkout con Wompi'), findsOneWidget);
    expect(find.byType(CustomIconInput), findsNWidgets(4));
    expect(
      find.widgetWithText(CustomMainButton, 'Confirmar y pagar \$ 15.000'),
      findsOneWidget,
    );
  });
}
