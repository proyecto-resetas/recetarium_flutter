import 'dart:async';
import 'package:flutter/material.dart';

class StepsProvider with ChangeNotifier {
  int currentPage = 0;
  Timer? _timer;

  int _timeInMilliseconds = 0;

  set timeInMilliseconds(int value) {
    // forma para entrar a una propiedad de la clase con restriccion, con la linea 4

    if (value < 0) throw 'value have must be >=0';

    _timeInMilliseconds = value;
  }

  // Iniciar auto-slide
  void startAutoSlide(PageController controller, int totalPages) {
    _timer?.cancel(); // Cancelar cualquier temporizador anterior

    _timer =
        Timer.periodic(Duration(milliseconds: _timeInMilliseconds), (timer) {
      if (currentPage < totalPages - 1) {
        currentPage++;
        controller.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  // Pausar el auto-slide
  void pauseAutoSlide() {
    _timer?.cancel();
  }

  // Reiniciar el auto-slide
  void resetAutoSlide(PageController controller) {
    currentPage = 0;
    controller.jumpToPage(0);
    notifyListeners();
    startAutoSlide(controller,
        controller.positions.length); // Reiniciar desde la primera página
  }

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Reinicia el contador al salir de la pantalla
  void resetSlide() {
    currentPage = 0;
    _timer?.cancel();
    notifyListeners();
  }
}

//   void timeStringToMilliseconds(String timeString) {
//   // Expresión regular para detectar los números seguidos de unidades (m, h, s)
//   final RegExp regExp = RegExp(r'(\d+)([hms])');
//   int totalMilliseconds = 0;

//   // Iteramos sobre las coincidencias encontradas
//   for (final match in regExp.allMatches(timeString)) {
//     final int value = int.parse(match.group(1)!); // El número (cantidad)
//     final String unit = match.group(2)!; // La unidad (h, m, s)

//     // Convertir cada unidad a milisegundos
//     switch (unit) {
//       case 'h':
//         totalMilliseconds += value * 60 * 60 * 1000; // Horas a milisegundos
//         break;
//       case 'm':
//         totalMilliseconds += value * 60 * 1000; // Minutos a milisegundos
//         break;
//       case 's':
//         totalMilliseconds += value * 1000; // Segundos a milisegundos
//         break;
//     }
//   }

//   _timeConversion = totalMilliseconds;
// }

//    int timeStringToMilliseconds(String timeString) {
//   final RegExp regExp = RegExp(r'(\d+)([hms])');
//   int totalMilliseconds = 0;

//   for (final match in regExp.allMatches(timeString)) {
//     final int value = int.parse(match.group(1)!);
//     final String unit = match.group(2)!;

//     switch (unit) {
//       case 'h':
//         totalMilliseconds += value * 60 * 60 * 1000;
//         break;
//       case 'm':
//         totalMilliseconds += value * 60 * 1000;
//         break;
//       case 's':
//         totalMilliseconds += value * 1000;
//         break;
//     }
//   }

//   return totalMilliseconds;
// }
