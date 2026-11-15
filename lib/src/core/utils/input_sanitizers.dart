import 'package:flutter/services.dart';

/// Filtros y validadores compartidos para proteger los formularios contra
/// entradas inválidas, caracteres de control o etiquetas HTML/scripts.
class InputSanitizers {
  InputSanitizers._();

  static final RegExp _unsafeCharsRegex =
      RegExp(r'[<>\{\}\[\]\\|`~^\x00-\x08\x0B\x0C\x0E-\x1F]');

  static final RegExp _alphanumericSafeRegex =
      RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s.,/\-()]');

  static final RegExp _stepTimeCharsRegex = RegExp(r'[0-9hmsHMS\s]');

  static final RegExp _stepTimeFormatRegex = RegExp(
    r'^(\d+\s*[hms])(\s*\d+\s*[hms])*$',
    caseSensitive: false,
  );

  static final RegExp _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static final RegExp _phoneCodeRegex = RegExp(r'[0-9+]');
  static final RegExp _nitRegex = RegExp(r'[0-9\-]');

  /// Solo permite dígitos enteros positivos (0-9).
  static List<TextInputFormatter> get digitsOnly => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  /// Bloquea caracteres HTML/inyección (`< > { } [ ] \ |`) y de control,
  /// permitiendo letras, acentos, números y puntuación culinaria normal.
  static List<TextInputFormatter> get safeText => [
        FilteringTextInputFormatter.deny(_unsafeCharsRegex),
      ];

  /// Solo permite letras, números, acentos, espacios y puntuación básica (`.,/-()`).
  static List<TextInputFormatter> get safeAlphanumeric => [
        FilteringTextInputFormatter.allow(_alphanumericSafeRegex),
      ];

  /// Solo permite dígitos, espacios y unidades de tiempo (`h`, `m`, `s`).
  static List<TextInputFormatter> get stepTime => [
        FilteringTextInputFormatter.allow(_stepTimeCharsRegex),
      ];

  /// Solo permite dígitos y signo `+` para indicativos telefónicos (ej: `+57`).
  static List<TextInputFormatter> get phoneCode => [
        FilteringTextInputFormatter.allow(_phoneCodeRegex),
      ];

  /// Solo permite dígitos y guion `-` para documentos/NIT (ej: `900123456-1`).
  static List<TextInputFormatter> get documentOrNit => [
        FilteringTextInputFormatter.allow(_nitRegex),
      ];

  /// Valida formato básico de correo electrónico.
  static bool isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return _emailRegex.hasMatch(trimmed);
  }

  /// Valida formatos de duración como `15m`, `1h 30m` o `45s`.
  static bool isValidStepTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return _stepTimeFormatRegex.hasMatch(trimmed);
  }

  /// Limpia espacios extremos y elimina caracteres inseguros si llegaron por estado previo.
  static String sanitize(String value) {
    return value.replaceAll(_unsafeCharsRegex, '').trim();
  }
}
