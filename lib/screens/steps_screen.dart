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
      // Si es el último paso, reiniciar
      _resetSteps();
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
      _currentStepIndex = 0; // Reinicia al primer paso
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
      appBar: AppBar(
        title: Text('Paso ${_currentStepIndex + 1} de ${widget.recipe.steps.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso ${_currentStepIndex + 1}: ${currentStep.description}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Tiempo de este paso: ${(currentStep.timeScreen / 1000).toString()} segundos',
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
                  'Todos los pasos completados, se ha pausado automáticamente',
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
