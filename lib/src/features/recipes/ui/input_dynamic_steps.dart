import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/utils/input_sanitizers.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';

class CreateDynamicInputs extends StatefulWidget {
  const CreateDynamicInputs({super.key});

  @override
  _CreateDynamicInputsState createState() => _CreateDynamicInputsState();
}

class _CreateDynamicInputsState extends State<CreateDynamicInputs> {
  final List<TextEditingController> _controllersD = [];
  final List<TextEditingController> _controllersT = [];

  @override
  void initState() {
    super.initState();
    final viewRecipesProvider =
        Provider.of<ViewRecipesProvider>(context, listen: false);

    // Cargar pasos existentes si los hay
    if (viewRecipesProvider.steps.isNotEmpty) {
      for (var step in viewRecipesProvider.steps) {
        _controllersD
            .add(TextEditingController(text: step['description'] ?? ''));
        _controllersT.add(TextEditingController(text: step['time'] ?? ''));
      }
    } else {
      _controllersD.add(TextEditingController());
      _controllersT.add(TextEditingController());
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncStepsToGlobalState(),
    );
  }

  /// Sincroniza automáticamente los pasos en el estado temporal de
  /// [ViewRecipesProvider] sin necesidad de botón "Save Steps".
  void _syncStepsToGlobalState() {
    if (!mounted) return;
    final viewRecipesProvider =
        Provider.of<ViewRecipesProvider>(context, listen: false);

    final stepsList = <Map<String, dynamic>>[];
    for (int i = 0; i < _controllersD.length; i++) {
      final description = _controllersD[i].text;
      final time = _controllersT[i].text;
      final timeScreen = timeStringToMilliseconds(time);
      stepsList.add({
        'description': description,
        'time': time,
        'timeScreen': timeScreen,
      });
    }
    viewRecipesProvider.syncSteps(stepsList);
  }

  void _addInput() {
    setState(() {
      _controllersD.add(TextEditingController());
      _controllersT.add(TextEditingController());
    });
    _syncStepsToGlobalState();
  }

  void _removeStepAt(int index) {
    if (_controllersD.length <= 1) return;
    setState(() {
      _controllersD.removeAt(index).dispose();
      _controllersT.removeAt(index).dispose();
    });
    _syncStepsToGlobalState();
  }

  int timeStringToMilliseconds(String timeString) {
    final RegExp regExp = RegExp(r'(\d+)\s*([hms])', caseSensitive: false);
    int totalMilliseconds = 0;

    for (final match in regExp.allMatches(timeString)) {
      final int value = int.tryParse(match.group(1) ?? '0') ?? 0;
      final String unit = (match.group(2) ?? 'm').toLowerCase();

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

    return totalMilliseconds > 0 ? totalMilliseconds : 60000;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllersD.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomIconInput(
                                controller: _controllersD[index],
                                hintText: 'Describe el paso ${index + 1}',
                                helperText: 'Máximo 280 caracteres.',
                                prefixIcon: Icons.format_list_numbered_rounded,
                                maxLines: 2,
                                maxLength: 280,
                                inputFormatters: InputSanitizers.safeText,
                                onChanged: (_) => _syncStepsToGlobalState(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa la descripción del paso';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_controllersD.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Eliminar paso',
                                onPressed: () => _removeStepAt(index),
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: Color(0xFFD62828),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomIconInput(
                          controller: _controllersT[index],
                          hintText: 'Ej: 1h 30m, 15m, 45s',
                          helperText: 'Usa h (horas), m (minutos) o s (segundos).',
                          prefixIcon: Icons.timer_outlined,
                          keyboardType: TextInputType.text,
                          maxLength: 20,
                          inputFormatters: InputSanitizers.stepTime,
                          onChanged: (_) => _syncStepsToGlobalState(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa el tiempo del paso';
                            }
                            if (!InputSanitizers.isValidStepTime(value)) {
                              return 'Formato inválido (ej: 15m, 1h 30m, 45s)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            CustomMainButton(
              text: 'Add Step',
              icon: Icons.add_circle_outline_rounded,
              height: 45,
              color: colorScheme.secondary,
              onPressed: _addInput,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Libera los controladores de texto cuando ya no se necesiten
    for (var controller in _controllersD) {
      controller.dispose();
    }
    for (var controller in _controllersT) {
      controller.dispose();
    }
    super.dispose();
  }
}
