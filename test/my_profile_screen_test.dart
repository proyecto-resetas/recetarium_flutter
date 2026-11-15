import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/l10n/app_localizations.dart';
import 'package:recetarium/src/core/theme/app_theme.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/core/widgets/custom_select_field.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';
import 'package:recetarium/src/features/user_profile/ui/my_profile_screen.dart';

class _FakeAuthProvider extends AuthProvider {
  final UserResModel _fakeUser;

  _FakeAuthProvider(this._fakeUser);

  @override
  UserResModel? get user => _fakeUser;

  @override
  Future<void> refreshUserProfile() async {}
}

void main() {
  Widget buildTestApp(UserResModel user) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: _FakeAuthProvider(user),
      child: MaterialApp(
        theme: AppTheme(typographyCustom: 0).theme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MyProfileScreen(),
      ),
    );
  }

  final testUser = UserResModel(
    id: 'user-1',
    username: 'Daniel',
    lastname: 'Jimenez',
    email: 'daniel@recetarium.com',
    phone: '+57 300 123 4567',
    country: 'Colombia',
    city: 'Medellín',
    photoUrl: '',
    role: 'super_admin',
    bankAccount: {
      'bankName': 'Bancolombia',
      'accountType': 'Ahorros',
      'accountNumber': '1234564821',
      'holderName': 'Daniel Jimenez',
      'documentType': 'CC',
      'documentNumber': '10203040',
    },
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  testWidgets('MyProfileScreen renderiza con colores del tema y secciones',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(testUser));
    await tester.pumpAndSettle();

    expect(find.text('Daniel Jimenez'), findsOneWidget);
    expect(find.text('Super Administrador'), findsOneWidget);
    expect(find.text('SUPER ADMIN'), findsOneWidget);
    expect(find.text('Datos personales'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Cuenta bancaria'), findsOneWidget);
    expect(find.text('Activa'), findsOneWidget);
    expect(find.text('Datos de facturación'), findsOneWidget);
    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('Modales de perfil reutilizan CustomIconInput, CustomSelectField y CustomMainButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(testUser));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cuenta bancaria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuenta bancaria'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomIconInput), findsWidgets);
    expect(find.byType(CustomSelectField<String>), findsWidgets);
    expect(find.byType(CustomMainButton), findsOneWidget);
    expect(find.text('Guardar cuenta bancaria'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Datos personales'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Datos personales'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomIconInput), findsWidgets);
    expect(find.byType(CustomMainButton), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Datos de facturación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Datos de facturación'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomIconInput), findsWidgets);
    expect(find.byType(CustomSelectField<String>), findsWidgets);
    expect(find.byType(CustomMainButton), findsOneWidget);
    expect(find.text('Guardar facturación'), findsOneWidget);
  });
}
