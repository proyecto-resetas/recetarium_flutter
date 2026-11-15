import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recetarium/src/app.dart';
import 'package:recetarium/src/core/services/admob_service.dart';
import 'package:recetarium/src/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización del servicio de almacenamiento local y Google AdMob
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  await AdMobService.instance.initialize();

  if (kIsWeb) {
    debugPrint('🌐 Recetarium corriendo en: ${Uri.base.origin}');
  }
  runApp(const MyApp());
}



