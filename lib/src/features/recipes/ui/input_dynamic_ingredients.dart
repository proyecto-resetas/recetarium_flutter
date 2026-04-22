import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';

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
    final viewRecipesProvider =
        Provider.of<ViewRecipesProvider>(context, listen: false);

    // Cargar ingredientes existentes si los hay
    if (viewRecipesProvider.selectedIngredient.isNotEmpty) {
      for (var ingredient in viewRecipesProvider.selectedIngredient) {
        _controllersDescription.add(
            TextEditingController(text: ingredient['description'] ?? ''));
        _controllersAmount.add(
            TextEditingController(text: ingredient['amount'] ?? ''));
      }
    } else {
      _controllersDescription.add(TextEditingController());
      _controllersAmount.add(TextEditingController());
    }

    // Cargar utensilios existentes si los hay
    if (viewRecipesProvider.selectedUtensil.isNotEmpty) {
      for (var utensil in viewRecipesProvider.selectedUtensil) {
        _controllersUtencilio
            .add(TextEditingController(text: utensil['utensil'] ?? ''));
      }
    } else {
      _controllersUtencilio.add(TextEditingController());
    }
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

    viewRecipesProvider.clearIngredients();
    for (int i = 0; i < _controllersDescription.length; i++) {
      String description = _controllersDescription[i].text;
      String amount = _controllersAmount[i].text;

      viewRecipesProvider.addIngredient(description, amount); // Guarda el paso en el estado global
    }

    viewRecipesProvider.clearUtensils();
    for (int i = 0; i < _controllersUtencilio.length; i++) {
      String utensil = _controllersUtencilio[i].text;

      viewRecipesProvider.addUtensil(utensil); // Guarda el paso en el estado global
    }  
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
              flex: 3,
              child: ListView.builder(
                itemCount: _controllersDescription.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      children: [
                        CustomIconInput(
                          controller: _controllersDescription[index],
                          hintText: 'Ingredient ${index + 1} name',
                          prefixIcon: Icons.restaurant_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the ingredient';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomIconInput(
                          controller: _controllersAmount[index],
                          hintText: 'Amount (e.g. 200g, 2 units)',
                          prefixIcon: Icons.scale_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Amount';
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomMainButton(
                text: 'Add Ingredient',
                icon: Icons.add_circle_outline_rounded,
                height: 45,
                color: colorScheme.secondary,
                onPressed: _addInput,
              ),
            ),
            const Divider(height: 30),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: _controllersUtencilio.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: CustomIconInput(
                      controller: _controllersUtencilio[index],
                      hintText: 'Utensil ${index + 1}',
                      prefixIcon: Icons.handyman_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Utensil';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomMainButton(
                    text: 'Add Utensil',
                    icon: Icons.add_to_photos_rounded,
                    height: 45,
                    color: colorScheme.secondary,
                    onPressed: _addInputUtencilio,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CustomMainButton(
                    text: 'Save Items',
                    icon: Icons.check_circle_outline_rounded,
                    height: 45,
                    onPressed: () {
                      _saveStepsToGlobalState(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Items saved locally')),
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
