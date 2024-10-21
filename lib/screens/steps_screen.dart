import 'dart:math';

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
        await Future.delayed(const Duration(milliseconds: 1000));
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

   List<Color> colorThemes = [
  const Color.fromARGB(255, 218, 182, 1),
  const Color.fromARGB(255, 7, 136, 159),
  const Color(0xFFE5EDE5),
  Colors.green,
  Colors.orange,
  Colors.orangeAccent,
  const Color.fromARGB(255, 37, 132, 40),
];

Color getRandomColor() {
  final random = Random();
  return colorThemes[random.nextInt(colorThemes.length)];
}

@override
Widget build(BuildContext context) {
  if (!mounted) return Container();

  return Scaffold(
    appBar: AppBar(
      title: Text('Pasos de la Receta'),
    ),
    body: SingleChildScrollView( // Permite scroll vertical si el contenido es muy largo
      child: Column(
        children: [
          // Limita el tamaño del Stepper en horizontal
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 400.0,  // Limita la altura para evitar el error de flex
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStepIndex,
              steps: widget.recipe.steps.map((step) {
                return Step(
                  title: Text('Paso ${widget.recipe.steps.indexOf(step) + 1}'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.description,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tiempo: ${step.time} segundos',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  isActive: widget.recipe.steps.indexOf(step) == _currentStepIndex,
                  state: widget.recipe.steps.indexOf(step) <= _currentStepIndex
                      ? StepState.complete
                      : StepState.indexed,
                );
              }).toList(),
              onStepContinue: !_isPaused ? _goToNextStep : null, // Evita continuar si está pausado
              onStepCancel: _currentStepIndex > 0 ? () => setState(() => _currentStepIndex--) : null,
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isPaused ? _resumeTimer : details.onStepContinue,
                          child: Text(_isPaused ? 'Reanudar' : 'Siguiente'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Anterior'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pauseTimer,
                          child: Text(_isPaused ? 'Pausado' : 'Pausar'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}



}