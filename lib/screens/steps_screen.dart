// import 'package:flutter/material.dart';
// import 'package:resetas/models/recipes_model.dart';

// class StepsScreen extends StatefulWidget {
//   final RecipesModel recipe;

//   const StepsScreen({super.key, required this.recipe});

//   @override
//   State<StepsScreen> createState() => _StepsScreenState();
// }

// class _StepsScreenState extends State<StepsScreen> {
//   int _currentStepIndex = 0;
//   bool _isPaused = false;
//   double _progress = 0.0;
//   int _elapsedTime = 0;
//   late int _timeForStep;

//   @override
//   void initState() {
//     super.initState();
//     _timeForStep = widget.recipe.steps[_currentStepIndex].timeScreen;
//     _startStepTimer();
//   }

//   void _startStepTimer() async {
//     while (_currentStepIndex < widget.recipe.steps.length && !_isPaused) {
//       _timeForStep = widget.recipe.steps[_currentStepIndex].timeScreen;

//       // Inicia el temporizador para cada paso
//       for (_elapsedTime = 0; _elapsedTime <= _timeForStep; _elapsedTime += 100) {
//         if (!_isPaused && mounted) {
//           setState(() {
//             _progress = _elapsedTime / _timeForStep; // Actualiza la barra de progreso
//           });
//           await Future.delayed(const Duration(milliseconds: 100)); // Actualiza cada 100ms
//         } else {
//           // Si está pausado, espera antes de continuar
//           await Future.delayed(const Duration(milliseconds: 100));
//         }
//       }

//       // Después de completar el tiempo, pasa al siguiente paso
//       if (mounted) {
//         _goToNextStep();
//       }
//     }
//   }

//   void _goToNextStep() {
//     if (_currentStepIndex < widget.recipe.steps.length - 1) {
//       setState(() {
//         _currentStepIndex++;
//         _progress = 0.0; // Reinicia el progreso para el nuevo paso
//       });
//       _startStepTimer(); // Inicia el temporizador para el siguiente paso
//     } else {
//       _resetSteps(); // Si es el último paso, reinicia los pasos
//       _pauseTimer(); // Pausa automáticamente después de completar todos los pasos
//     }
//   }

//   void _pauseTimer() {
//     setState(() {
//       _isPaused = true;
//     });
//   }

//   void _resumeTimer() {
//     setState(() {
//       _isPaused = false;
//     });
//     _startStepTimer(); // Reinicia el temporizador si se reanuda
//   }

//   void _resetSteps() {
//     setState(() {
//       _currentStepIndex = 0; // Reinicia los pasos
//       _progress = 0.0; // Reinicia el progreso
//     });
//     _startStepTimer();
//   }

//   @override
//   void dispose() {
//     _isPaused = true; // Asegúrate de que el temporizador esté pausado
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!mounted) return Container(); // Devuelve un contenedor vacío si no está montado

//     final currentStep = widget.recipe.steps[_currentStepIndex];

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 59, 99, 104),
//       appBar: AppBar(
//         title: Text('Paso ${_currentStepIndex + 1} de ${widget.recipe.steps.length}'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment : MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//              LinearProgressIndicator(
//               value: _progress,
//               minHeight: 10,
//               backgroundColor: const Color.fromARGB(0, 255, 255, 255),
//               valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(80, 0, 0, 0)),
//               borderRadius : BorderRadius.circular(30)
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Paso ${_currentStepIndex + 1}: ${currentStep.description}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Tiempo de este paso: ${currentStep.time}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isPaused ? _resumeTimer : _pauseTimer,
//                   child: Text(_isPaused ? 'Reanudar' : 'Pausar'),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: _resetSteps,
//                   child: const Text('Reiniciar'),
//                 ),
//               ],
//             ),
//             if (_isPaused && _currentStepIndex == 0) ...[
//               const SizedBox(height: 20),
//               const Center(
//                 child: Text(
//                   'Se ha pausado. Reinicia o Reanuda los pasos',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:resetas/models/recipes_model.dart';

class StepsScreen extends StatefulWidget {
  final RecipesModel recipe;

  const StepsScreen({super.key, required this.recipe});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  int _currentStepIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startStepTimer();
  }

  void _startStepTimer() async {
    while (_currentStepIndex < widget.recipe.steps.length && !_isPaused) {
      // Obtiene el tiempo del paso actual
      int timeForStep = widget.recipe.steps[_currentStepIndex].timeScreen;

      if (!_isPaused && mounted) {
        setState(() {
          // Aquí podrías realizar cualquier acción que necesites al iniciar el paso
        });

        // Espera el tiempo del paso antes de continuar
        await Future.delayed(Duration(milliseconds: timeForStep));

        // Después de completar el tiempo, pasa al siguiente paso
        if (mounted) {
          _goToNextStep();
        }
      } else {
        // Si está pausado, espera un poco antes de continuar
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void _goToNextStep() {
    if (_currentStepIndex < widget.recipe.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _resetSteps(); // Si es el último paso, reiniciar
      _pauseTimer(); // Pausar automáticamente
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _startStepTimer(); // Reinicia el temporizador si se reanuda
  }

  void _resetSteps() {
    setState(() {
      _currentStepIndex = 0; // Reinicia 
    });
  }

  @override
  void dispose() {
    _isPaused = true; // Asegúrate de que esté pausado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container(); // Devuelve un contenedor vacío si no está montado

    final currentStep = widget.recipe.steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 59, 99, 104),
      appBar: AppBar(
        title: Text('Paso ${_currentStepIndex + 1} de ${widget.recipe.steps.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Text(
              'Paso ${_currentStepIndex + 1}: ${currentStep.description}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Tiempo de este paso: ${(currentStep.time).toString()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                  child: Text(_isPaused ? 'Reanudar' : 'Pausar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetSteps,
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
            if (_isPaused && _currentStepIndex == 0) ...[
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Se ha pausado, Reinica o Reanuda los pasos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}