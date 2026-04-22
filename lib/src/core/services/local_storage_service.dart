import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Nombres de las cajas (boxes)
  static const String _authBoxName = 'authBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _cacheBoxName = 'cacheBox';

  // Canal Nativo Oficial de Flutter
  static const _securityChannel = MethodChannel('com.recetarium/security');

  late Box _authBox;
  late Box _settingsBox;
  late Box _cacheBox;

  // Inicialización de las cajas
  Future<void> init() async {
    await Hive.initFlutter();

    // 1. Obtener la clave maestra de forma segura desde el hardware nativo
    // Solo si no es entorno Web
    Uint8List? encryptionKey;
    if (!kIsWeb) {
      encryptionKey = await _getNativeEncryptionKey();
    }

    // 2. Abrir la caja de autenticación
    // Si estamos en web o falla lo nativo, se abre sin cifrado para evitar crashes
    _authBox = await Hive.openBox(
      _authBoxName,
      encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
    );

    // Cajas no sensibles
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);
  }

  /// Obtiene una clave de 32 bytes (256 bits) generada y guardada 
  /// en el hardware de seguridad del dispositivo (Keystore/Keychain).
  Future<Uint8List?> _getNativeEncryptionKey() async {
    if (kIsWeb) return null;
    
    try {
      final dynamic key = await _securityChannel.invokeMethod('getEncryptionKey');
      if (key is Uint8List) {
        return key;
      } else if (key is List<int>) {
        return Uint8List.fromList(key);
      }
      return null;
    } on PlatformException catch (e) {
      print('Error obteniendo clave nativa: ${e.message}');
      return null;
    }
  }

  // --- Métodos para Auth ---
  Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    await _authBox.put('access_token', token);
    await _authBox.put('user', userData);
  }

  String? get token => _authBox.get('access_token') as String?;
  
  Map<String, dynamic>? get userData {
    final data = _authBox.get('user');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await _authBox.clear();
  }

  // --- Métodos Genéricos (Escalabilidad) ---
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = await _getBox(boxName);
    await box.put(key, value);
  }

  dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = _getBoxSync(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  // Ayudante interno para obtener la caja correcta
  Future<Box> _getBox(String boxName) async {
    if (boxName == _authBoxName) return _authBox;
    if (boxName == _settingsBoxName) return _settingsBox;
    if (boxName == _cacheBoxName) return _cacheBox;
    
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Box _getBoxSync(String boxName) {
    if (boxName == _authBoxName) return _authBox;
    if (boxName == _settingsBoxName) return _settingsBox;
    if (boxName == _cacheBoxName) return _cacheBox;
    
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('La caja $boxName no está abierta. Llama a init() primero.');
    }
    return Hive.box(boxName);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
