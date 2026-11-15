import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';
import 'package:recetarium/src/features/recipes/ui/add_steps.dart';
import 'package:recetarium/src/features/recipes/ui/input_dynamic_ingredients.dart';

class AddIngredientsUtensils extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddIngredientsUtensils({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = context.watch<ViewRecipesProvider>().isEditingRecipe;

    return Scaffold(
      appBar: CustomBackAppBar(
        title: isEditing
            ? 'Editar Ingredientes y Utensilios'
            : 'Ingredients & Utensils',
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Expanded(
                    child: InputDynamicIngredients(),
                  ),
                  const SizedBox(height: 20),
                  CustomMainButton(
                    text: 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddSteps()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
