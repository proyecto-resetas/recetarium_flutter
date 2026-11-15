import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetarium/src/core/utils/input_sanitizers.dart';

String _applyFormatters(
  List<TextInputFormatter> formatters,
  String input,
) {
  var value = const TextEditingValue();
  final next = TextEditingValue(
    text: input,
    selection: TextSelection.collapsed(offset: input.length),
  );
  for (final formatter in formatters) {
    value = formatter.formatEditUpdate(value, next);
  }
  return value.text;
}

void main() {
  group('InputSanitizers', () {
    test('digitsOnly permite únicamente dígitos numéricos', () {
      expect(_applyFormatters(InputSanitizers.digitsOnly, '15000'), '15000');
      expect(
        _applyFormatters(InputSanitizers.digitsOnly, '-15.50abc \$'),
        '1550',
      );
    });

    test('safeText bloquea caracteres HTML/inyección y conserva tildes', () {
      expect(
        _applyFormatters(
          InputSanitizers.safeText,
          'Arroz con pollo <script>alert(1)</script> ñ',
        ),
        'Arroz con pollo scriptalert(1)/script ñ',
      );
      expect(
        InputSanitizers.sanitize('  Sopa de papa {mal}  '),
        'Sopa de papa mal',
      );
    });

    test('safeAlphanumeric conserva cantidades y unidades culinarias', () {
      expect(
        _applyFormatters(InputSanitizers.safeAlphanumeric, '200g / 1/2 taza'),
        '200g / 1/2 taza',
      );
      expect(
        _applyFormatters(InputSanitizers.safeAlphanumeric, '200g <script>'),
        '200g script',
      );
    });

    test('stepTime e isValidStepTime validan formatos de tiempo', () {
      expect(
        _applyFormatters(InputSanitizers.stepTime, '1h 30m xyz!'),
        '1h 30m ',
      );
      expect(InputSanitizers.isValidStepTime('15m'), isTrue);
      expect(InputSanitizers.isValidStepTime('1h 30m'), isTrue);
      expect(InputSanitizers.isValidStepTime('45s'), isTrue);
      expect(InputSanitizers.isValidStepTime('15'), isFalse);
      expect(InputSanitizers.isValidStepTime('diez minutos'), isFalse);
      expect(InputSanitizers.isValidStepTime(''), isFalse);
    });
  });
}
