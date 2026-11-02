import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/recipes/models/ingredients_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/models/steps_model.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
import 'package:resetas/src/features/recipes/models/utensil_model.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/ui/input_dynamic_steps.dart';

class AddSteps extends StatefulWidget {
  AddSteps({super.key});

  @override
  State<AddSteps> createState() => _AddStepsState();
}

class _AddStepsState extends State<AddSteps> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleCreateRecipe(
    BuildContext context,
    ViewRecipesProvider viewRecipesProvider,
    AuthProvider authProvider,
  ) async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() => _isSaving = true);
      try {
        RecipesModel newRecipe = RecipesModel(
          nameRecipe: viewRecipesProvider.selectedNameRecipe!,
          descriptionRecipe: viewRecipesProvider.selectedDescriptionRecipe!,
          ingredientsRecipe: viewRecipesProvider.selectedIngredient
              .map((ingredient) => Ingredients.fromJson(ingredient))
              .toList(),
          utensilRecipe: viewRecipesProvider.selectedUtensil
              .map((utensil) => Utensils.fromJson(utensil))
              .toList(),
          category: viewRecipesProvider.selectedCategory!,
          level: viewRecipesProvider.selectedLevel!,
          imageUrl: viewRecipesProvider.uploadedImageUrl != null
              ? '${viewRecipesProvider.uploadedImageUrl}'
              : null,
          createdBy: authProvider.user!.toJson(),
          price: viewRecipesProvider.selectedPrice!,
          steps: viewRecipesProvider.steps
              .map((step) => Steps.fromJson(step))
              .toList(),
        );

        bool success = await viewRecipesProvider.createRecipes(newRecipe);
        if (success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receta creada exitosamente')),
            );
            viewRecipesProvider.resetForm();
            final role = authProvider.user?.role;
            if (role == 'admin' || role == 'super_admin') {
              context.go('/admin_home'); // Volver al home después de crear
            } else {
              context.go('/home'); // Volver al home después de crear
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falló la creación de la receta')),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewRecipesProvider = Provider.of<ViewRecipesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Recipe'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Expanded(
                    child: CreateDynamicInputs(),
                  ),
                  const SizedBox(height: 20),
                  CustomMainButton(
                    text: _isSaving ? 'Guardando receta e imagen...' : 'Create Recipe',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: _isSaving
                        ? null
                        : () {
                            _handleCreateRecipe(
                              context,
                              viewRecipesProvider,
                              authProvider,
                            );
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