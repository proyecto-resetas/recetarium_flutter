import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/data/steps_provider.dart';
import 'package:resetas/src/features/recipes/models/steps_model.dart';

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
    // Iniciar el temporizador después de que el widget se monte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStepTimer();
    });
  }

  void _startStepTimer() async {
    final steps = _getSteps();
    if (steps.isEmpty) return;

    while (_currentStepIndex < steps.length && !_isPaused) {
      // Obtiene el tiempo del paso actual
      int timeForStep = steps[_currentStepIndex].timeScreen;

      if (!_isPaused && mounted) {
        // Espera el tiempo del paso antes de continuar
        await Future.delayed(Duration(milliseconds: timeForStep));

        // Después de completar el tiempo, pasa al siguiente paso
        if (mounted && !_isPaused) {
          _goToNextStep();
        }
      } else {
        // Si está pausado, espera un poco antes de continuar
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
  }

  List<Steps> _getSteps() {
    final providerSteps = context.read<StepsProvider>().steps;
    if (providerSteps.isNotEmpty) return providerSteps;
    return widget.recipe.steps ?? [];
  }

  void _goToNextStep() {
    final steps = _getSteps();
    if (_currentStepIndex < steps.length - 1) {
      if (mounted) {
        setState(() {
          _currentStepIndex++;
        });
      }
    } else {
      _resetSteps(); // Si es el último paso, reiniciar
      _pauseTimer(); // Pausar automáticamente
    }
  }

  void _pauseTimer() {
    if (mounted) {
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeTimer() {
    if (mounted) {
      setState(() {
        _isPaused = false;
      });
      _startStepTimer(); // Reinicia el temporizador si se reanuda
    }
  }

  void _resetSteps() {
    if (mounted) {
      setState(() {
        _currentStepIndex = 0; // Reinicia
      });
    }
  }

  @override
  void dispose() {
    _isPaused = true; // Asegúrate de que esté pausado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();

    final steps = _getSteps();

    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pasos de la Receta')),
        body: const Center(child: Text('No hay pasos disponibles para esta receta.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.nameRecipe),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Indicador de pasos con scroll horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                int stepIndex = entry.key;
                final step = entry.value;

                return GestureDetector(
                  onTap: () => setState(() => _currentStepIndex = stepIndex),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: _currentStepIndex == stepIndex
                              ? const Color.fromRGBO(254, 166, 33, 1)
                              : const Color.fromARGB(255, 205, 205, 205),
                          child: Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: _currentStepIndex == stepIndex
                                  ? Colors.white
                                  : const Color.fromARGB(255, 133, 133, 133),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            step.description,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentStepIndex == stepIndex
                                  ? const Color.fromRGBO(254, 166, 33, 1)
                                  : const Color.fromARGB(255, 205, 205, 205),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    steps[_currentStepIndex].description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Tiempo: ${steps[_currentStepIndex].time}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                      icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      label: _isPaused ? 'Reanudar' : 'Pausar',
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      onPressed: _goToNextStep,
                      icon: Icons.skip_next_rounded,
                      label: 'Siguiente',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      onPressed: _currentStepIndex > 0
                          ? () => setState(() => _currentStepIndex--)
                          : null,
                      icon: Icons.skip_previous_rounded,
                      label: 'Anterior',
                      secondary: true,
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      onPressed: _resetSteps,
                      icon: Icons.replay_rounded,
                      label: 'Reiniciar',
                      secondary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool secondary;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary ? Colors.grey[200] : const Color.fromRGBO(254, 166, 33, 1),
        foregroundColor: secondary ? Colors.black87 : Colors.white,
        elevation: secondary ? 0 : 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
