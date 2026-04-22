import 'package:flutter/foundation.dart';
import 'dart:io';
import 'env.dart' as env;

class Config {
  Config._();

  static String get apiUrl {
    if (kIsWeb) {
      return env.Env.apiUrlDev;
    }
    if (Platform.isAndroid) {
      return env.Env.apiUrlDev;
    } else if (Platform.isIOS) {
      return env.Env.apiUrlDev;
    } else if (Platform.isMacOS) {
      return env.Env.apiUrlDev;
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  static String get xapikey {
    return env.Env.xapikey;
  }

  static String get aiProvider {
    return env.Env.aiProvider;
  }
}
