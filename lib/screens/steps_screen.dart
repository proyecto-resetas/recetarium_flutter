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
    // const Color.fromARGB(255, 7, 136, 159),
    // const Color(0xFFE5EDE5),
    // Colors.green,
    // Colors.orange,
    // Colors.orangeAccent,
    // const Color.fromARGB(255, 37, 132, 40),
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
        title: const Text('Pasos de la Receta'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Indicador de pasos con scroll horizontal

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.recipe.steps.map((step) {
                int stepIndex = widget.recipe.steps.indexOf(step);

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
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 133, 133, 133),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            textAlign: TextAlign.center,
                            step.description,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
          
SizedBox(
  child: Container(
  //  width: MediaQuery.of(context).size.width * 0.9, // 90% de la pantalla en ancho
    height: MediaQuery.of(context).size.height < 600
        ? MediaQuery.of(context).size.height * 0.3// 60% de la pantalla en dispositivos pequeños
        : 500, // 500 px en dispositivos grandes
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.recipe.steps[_currentStepIndex].description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tiempo: ${widget.recipe.steps[_currentStepIndex].time} segundos',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        //const SizedBox(height: 70),
      ],
    ),
  ),
),


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _isPaused ? _resumeTimer : _goToNextStep,
                    child:
                        Icon(_isPaused ? Icons.restart_alt : Icons.skip_next)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _currentStepIndex > 0
                      ? () => setState(() => _currentStepIndex--)
                      : null,
                  child: const Icon(Icons.replay),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pauseTimer,
                child: Icon(_isPaused ? Icons.pause : Icons.pause),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetSteps,
                child: const Icon(Icons.cached),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            _isPaused ? 'Pausado' : '',
            style: const TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
