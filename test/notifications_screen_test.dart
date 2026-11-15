import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/theme/app_theme.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/features/notifications/data/notifications_provider.dart';
import 'package:recetarium/src/features/notifications/models/notification_model.dart';
import 'package:recetarium/src/features/notifications/ui/notifications_screen.dart';

class _FakeNotificationsProvider extends NotificationsProvider {
  final List<NotificationModel> _fakeItems;

  _FakeNotificationsProvider(this._fakeItems);

  @override
  List<NotificationModel> get notifications => _fakeItems;

  @override
  int get unreadCount => _fakeItems.where((n) => !n.read).length;

  @override
  bool get isLoading => false;

  @override
  bool get isSocketConnected => true;

  @override
  Future<void> fetchNotifications() async {}
}

void main() {
  Widget buildTestApp(NotificationsProvider provider) {
    return ChangeNotifierProvider<NotificationsProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme(typographyCustom: 0).theme(),
        home: const NotificationsScreen(),
      ),
    );
  }

  testWidgets(
      'NotificationsScreen vacío usa CustomBackAppBar y no muestra botón de prueba',
      (WidgetTester tester) async {
    final provider = _FakeNotificationsProvider([]);

    await tester.pumpWidget(buildTestApp(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CustomBackAppBar), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Todo al día'), findsOneWidget);
    expect(find.text('Aún no tienes notificaciones'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsNothing);
    expect(find.text('Probar notificación en tiempo real'), findsNothing);
  });

  testWidgets(
      'NotificationsScreen con notificaciones muestra banner, tarjetas y filtros',
      (WidgetTester tester) async {
    final provider = _FakeNotificationsProvider([
      NotificationModel(
        id: 'n-1',
        recipientId: 'user-1',
        type: 'purchase_confirmed',
        title: 'Compra confirmada',
        message: 'Ya tienes acceso a Risotto de Hongos',
        read: false,
        createdAt: DateTime.now(),
      ),
    ]);

    await tester.pumpWidget(buildTestApp(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CustomBackAppBar), findsOneWidget);
    expect(find.text('1 notificación nueva'), findsOneWidget);
    expect(find.text('Leer todas'), findsOneWidget);
    expect(find.text('Compra confirmada'), findsOneWidget);
    expect(find.text('Ir a la receta'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsNothing);
  });
}
