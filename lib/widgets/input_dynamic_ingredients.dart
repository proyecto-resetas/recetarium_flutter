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
      String utensil = _controllersUtencilio[i].text;

      viewRecipesProvider.addUtensil(utensil); // Guarda el paso en el estado global
    }  
    }

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
                          labelText: 'Ingredient ${index + 1}, description',
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
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 10,),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10,),
             ElevatedButton(
                  onPressed: _addInput, // Llama a la función para agregar nuevos inputs
                  child: const Text('Add ingredient'),
              ),
             const SizedBox(height: 10,),
             Expanded(
              child: ListView.builder(
                itemCount: _controllersUtencilio.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _controllersUtencilio[index],
                        decoration: InputDecoration(
                          labelText: 'Utensil ${index + 1}',
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
                  child: const Text('Add utensil'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
              onPressed: () {
                _saveStepsToGlobalState(context); // Guarda los valores en el estado global
                print(Provider.of<ViewRecipesProvider>(context, listen: false).selectedIngredient); // Muestra los valores guardados
              },
              child: const Text('Save'),
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
