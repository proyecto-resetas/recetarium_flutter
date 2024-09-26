import 'dart:async';
import 'package:flutter/material.dart';

class StepsProvider with ChangeNotifier {
  int currentPage = 0;
  Timer? _timer;

   int timeStringToMilliseconds(String timeString) {
  final RegExp regExp = RegExp(r'(\d+)([hms])');
  int totalMilliseconds = 0;

  for (final match in regExp.allMatches(timeString)) {
    final int value = int.parse(match.group(1)!);
    final String unit = match.group(2)!;

    switch (unit) {
      case 'h':
        totalMilliseconds += value * 60 * 60 * 1000;
        break;
      case 'm':
        totalMilliseconds += value * 60 * 1000;
        break;
      case 's':
        totalMilliseconds += value * 1000;
        break;
    }
  }

  return totalMilliseconds;
}

  // Convierte el tiempo a milisegundos y maneja el PageController
  void startAutoSlide(PageController controller, int totalPages, int timeInMilliseconds) {
    _timer?.cancel(); // Cancelar cualquier temporizador anterior

    _timer = Timer.periodic(Duration(milliseconds: timeInMilliseconds), (timer) {
      if (currentPage < totalPages - 1) {
        currentPage++;
        controller.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
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
