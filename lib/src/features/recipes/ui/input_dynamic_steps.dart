import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/theme/app_input_style.dart';
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
    _controllersD.add(TextEditingController()); // Agregamos un controlador por defecto
    _controllersT.add(TextEditingController()); // Agregamos un controlador por defecto
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
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllersD.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _controllersD[index],
                        decoration: InputStyles.inputDecoration(
                          labelText: 'Step ${index + 1}, description',
                        ),
                         validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the description';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: _controllersT[index],
                        decoration:  InputStyles.inputDecoration(
                          labelText: 'Time, Example 1m, 2s, 3h',    
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Time';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 10,),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addInput, // Llama a la función para agregar nuevos inputs
                  child: const Text('Add Steps'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
              onPressed: () {
                _saveStepsToGlobalState(context); // Guarda los valores en el estado global
                print(Provider.of<ViewRecipesProvider>(context, listen: false).steps); // Muestra los valores guardados
              },
              child: const Text('Guardar Steps'),
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
