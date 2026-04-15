import 'package:flutter/foundation.dart';
import 'dart:io';
import 'env.dart' as env;

class Config {
  Config._();

  static String get apiUrl {
    if (kIsWeb) {
      return env.Env.apiUrlProd;
    }
    if (Platform.isAndroid) {
      return env.Env.apiUrlLocal;
    } else if (Platform.isIOS) {
      return env.Env.apiUrlDev;
    } else if (Platform.isMacOS) {
      return env.Env.apiUrlDev;
    } else {
      throw Exception('Plataforma no soportada');
    }
  }
}
