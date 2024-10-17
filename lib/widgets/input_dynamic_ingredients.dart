import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';

class InputDynamicIngredients extends StatefulWidget {
  const InputDynamicIngredients({super.key});

  @override
  _InputDynamicIngredientsState createState() => _InputDynamicIngredientsState();
}

class _InputDynamicIngredientsState extends State<InputDynamicIngredients> {
  // Lista para almacenar los controladores de los inputs
  final List<TextEditingController> _controllersDescription = [];
  final List<TextEditingController> _controllersAmount = [];
  final List<TextEditingController> _controllersUtencilio = [];


  @override
  void initState() {
    super.initState();
    _controllersDescription.add(TextEditingController()); // Agregamos un controlador por defecto
    _controllersAmount.add(TextEditingController()); // Agregamos un controlador por defecto
    _controllersUtencilio.add(TextEditingController());
  }

  // Función para agregar un nuevo input dinámico
  void _addInput() {
    setState(() {
      _controllersDescription.add(TextEditingController()); // Agrega un nuevo controlador de texto
      _controllersAmount.add(TextEditingController()); // Agrega un nuevo controlador de texto
    });
  }

   void _addInputUtencilio() {
    setState(() {
      _controllersUtencilio.add(TextEditingController());
    });
  }

  // Función para guardar los valores de los inputs en el estado global
  void _saveStepsToGlobalState(BuildContext context) {
    final viewRecipesProvider = Provider.of<ViewRecipesProvider>(context, listen: false);

    for (int i = 0; i < _controllersDescription.length; i++) {
      String description = _controllersDescription[i].text;
      String amount = _controllersAmount[i].text;


      viewRecipesProvider.addIngredient(description, amount); // Guarda el paso en el estado global
    }
 for (int i = 0; i < _controllersUtencilio.length; i++) {
      String utencilio = _controllersUtencilio[i].text;

      viewRecipesProvider.addUtencilio(utencilio); // Guarda el paso en el estado global
    }  
    }

  //   int timeStringToMilliseconds(String timeString) {
  // final RegExp regExp = RegExp(r'(\d+)([hms])');
  // int totalMilliseconds = 0;

  // for (final match in regExp.allMatches(timeString)) {
  //   final int value = int.parse(match.group(1)!);
  //   final String unit = match.group(2)!;

  //   switch (unit) {
  //     case 'h':
  //       totalMilliseconds += value * 60 * 60 * 1000;
  //       break;
  //     case 'm':
  //       totalMilliseconds += value * 60 * 1000;
  //       break;
  //     case 's':
  //       totalMilliseconds += value * 1000;
  //       break;
  //   }
  // }

//   return totalMilliseconds;
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8.0),
        height: 600,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllersDescription.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _controllersDescription[index],
                        decoration: InputDecoration(
                          labelText: 'Ingredients ${index + 1}, description',
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: _controllersAmount[index],
                        decoration:  InputDecoration(
                          labelText: 'Amount',
                           border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10,),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30,),
             ElevatedButton(
                  onPressed: _addInput, // Llama a la función para agregar nuevos inputs
                  child: const Text('add input Ingredient'),
              ),
             const SizedBox(height: 30,),
             Expanded(
              child: ListView.builder(
                itemCount: _controllersUtencilio.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _controllersUtencilio[index],
                        decoration: InputDecoration(
                          labelText: 'Utencilio ${index + 1}',
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        ),
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
                  onPressed: _addInputUtencilio, // Llama a la función para agregar nuevos inputs
                  child: const Text('Add input u'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
              onPressed: () {
                _saveStepsToGlobalState(context); // Guarda los valores en el estado global
                print(Provider.of<ViewRecipesProvider>(context, listen: false).selectedIngredient); // Muestra los valores guardados
              },
              child: const Text('Guardar'),
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
    for (var controller in _controllersDescription) {
      controller.dispose();
    }
    for (var controller in _controllersAmount) {
      controller.dispose();
    }
     for (var controller in _controllersUtencilio) {
      controller.dispose();
    }
    super.dispose();
  }
}
