import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/utils/input_sanitizers.dart';
import 'package:recetarium/src/core/widgets/custom_icon_input.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';

class InputDynamicIngredients extends StatefulWidget {
  const InputDynamicIngredients({super.key});

  @override
  _InputDynamicIngredientsState createState() => _InputDynamicIngredientsState();
}
class _InputDynamicIngredientsState extends State<InputDynamicIngredients> {
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
          TextEditingController(text: ingredient['description'] ?? ''),
        );
        _controllersAmount.add(
          TextEditingController(text: ingredient['amount'] ?? ''),
        );
      }
    } else {
      _controllersDescription.add(TextEditingController());
      _controllersAmount.add(TextEditingController());
    }

    // Cargar utensilios existentes si los hay
    if (viewRecipesProvider.selectedUtensil.isNotEmpty) {
      for (var utensil in viewRecipesProvider.selectedUtensil) {
        _controllersUtencilio.add(
          TextEditingController(text: utensil['utensil'] ?? ''),
        );
      }
    } else {
      _controllersUtencilio.add(TextEditingController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToGlobalState());
  }

  /// Sincroniza automáticamente los ingredientes y utensilios en el estado
  /// temporal de [ViewRecipesProvider] sin necesidad de un botón "Save".
  void _syncToGlobalState() {
    if (!mounted) return;
    final viewRecipesProvider =
        Provider.of<ViewRecipesProvider>(context, listen: false);

    final ingredients = <Map<String, dynamic>>[];
    for (int i = 0; i < _controllersDescription.length; i++) {
      ingredients.add({
        'description': _controllersDescription[i].text,
        'amount': _controllersAmount[i].text,
      });
    }
    viewRecipesProvider.syncIngredients(ingredients);

    final utensils = <Map<String, dynamic>>[];
    for (int i = 0; i < _controllersUtencilio.length; i++) {
      utensils.add({
        'utensil': _controllersUtencilio[i].text,
      });
    }
    viewRecipesProvider.syncUtensils(utensils);
  }

  void _addInput() {
    setState(() {
      _controllersDescription.add(TextEditingController());
      _controllersAmount.add(TextEditingController());
    });
    _syncToGlobalState();
  }

  void _removeIngredientAt(int index) {
    if (_controllersDescription.length <= 1) return;
    setState(() {
      _controllersDescription.removeAt(index).dispose();
      _controllersAmount.removeAt(index).dispose();
    });
    _syncToGlobalState();
  }

  void _addInputUtencilio() {
    setState(() {
      _controllersUtencilio.add(TextEditingController());
    });
    _syncToGlobalState();
  }

  void _removeUtensilAt(int index) {
    if (_controllersUtencilio.length <= 1) return;
    setState(() {
      _controllersUtencilio.removeAt(index).dispose();
    });
    _syncToGlobalState();
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomIconInput(
                                controller: _controllersDescription[index],
                                hintText: 'Ingredient ${index + 1} name',
                                prefixIcon: Icons.restaurant_rounded,
                                maxLength: 60,
                                inputFormatters: InputSanitizers.safeText,
                                onChanged: (_) => _syncToGlobalState(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa el nombre del ingrediente';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_controllersDescription.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Eliminar ingrediente',
                                onPressed: () => _removeIngredientAt(index),
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
                          controller: _controllersAmount[index],
                          hintText: 'Ej: 200g, 2 unidades, 1/2 taza',
                          helperText: 'Incluye número y unidad de medida.',
                          prefixIcon: Icons.scale_rounded,
                          keyboardType: TextInputType.text,
                          maxLength: 30,
                          inputFormatters: InputSanitizers.safeAlphanumeric,
                          onChanged: (_) => _syncToGlobalState(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa la cantidad del ingrediente';
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomIconInput(
                            controller: _controllersUtencilio[index],
                            hintText: 'Utensil ${index + 1}',
                            prefixIcon: Icons.handyman_rounded,
                            maxLength: 50,
                            inputFormatters: InputSanitizers.safeText,
                            onChanged: (_) => _syncToGlobalState(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el nombre del utensilio';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_controllersUtencilio.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Eliminar utensilio',
                            onPressed: () => _removeUtensilAt(index),
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Color(0xFFD62828),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            CustomMainButton(
              text: 'Add Utensil',
              icon: Icons.add_to_photos_rounded,
              height: 45,
              color: colorScheme.secondary,
              onPressed: _addInputUtencilio,
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
