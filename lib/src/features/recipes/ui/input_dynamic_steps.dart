import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';

class CreateDynamicInputs extends StatefulWidget {
  const CreateDynamicInputs({super.key});

  @override
  _CreateDynamicInputsState createState() => _CreateDynamicInputsState();
}

class _CreateDynamicInputsState extends State<CreateDynamicInputs> {
  // Lista para almacenar los controladores de los inputs
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
  }

  // Función para agregar un nuevo input dinámico
  void _addInput() {
    setState(() {
      _controllersD.add(TextEditingController()); // Agrega un nuevo controlador de texto
      _controllersT.add(TextEditingController()); // Agrega un nuevo controlador de texto
    });
  }

  // Función para guardar los valores de los inputs en el estado global
  void _saveStepsToGlobalState(BuildContext context) {
    final viewRecipesProvider = Provider.of<ViewRecipesProvider>(context, listen: false);

    viewRecipesProvider.clearSteps();
    for (int i = 0; i < _controllersD.length; i++) {
      String description = _controllersD[i].text;
      String time = _controllersT[i].text;
      int timeScreen = timeStringToMilliseconds(_controllersT[i].text);


      viewRecipesProvider.addStep(description, time, timeScreen); // Guarda el paso en el estado global
    }
  }

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
                        CustomIconInput(
                          controller: _controllersD[index],
                          hintText: 'Step ${index + 1} description',
                          prefixIcon: Icons.format_list_numbered_rounded,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomIconInput(
                          controller: _controllersT[index],
                          hintText: 'Time (e.g. 1h 30m, 15m, 45s)',
                          prefixIcon: Icons.timer_outlined,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Time';
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
            Row(
              children: [
                Expanded(
                  child: CustomMainButton(
                    text: 'Add Step',
                    icon: Icons.add_circle_outline_rounded,
                    height: 45,
                    color: colorScheme.secondary,
                    onPressed: _addInput,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomMainButton(
                    text: 'Save Steps',
                    icon: Icons.save_rounded,
                    height: 45,
                    onPressed: () {
                      _saveStepsToGlobalState(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Steps saved locally')),
                      );
                    },
                  ),
                ),
              ],
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
