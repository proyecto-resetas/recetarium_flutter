import 'package:flutter/material.dart';
import 'package:resetas/src/app.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización del servicio de almacenamiento local
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  debugPrint('🌐 Recetarium corriendo en: ${Uri.base.origin}');
  runApp(const MyApp());
}



