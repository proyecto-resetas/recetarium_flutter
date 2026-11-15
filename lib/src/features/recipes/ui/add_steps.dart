import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:recetarium/src/core/widgets/custom_back_app_bar.dart';
import 'package:recetarium/src/core/widgets/custom_main_button.dart';
import 'package:recetarium/src/features/recipes/data/my_recipes_created_provider.dart';
import 'package:recetarium/src/features/recipes/models/ingredients_model.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';
import 'package:recetarium/src/features/recipes/models/steps_model.dart';
import 'package:recetarium/src/features/recipes/models/utensil_model.dart';
import 'package:recetarium/src/features/auth/data/auth_provider.dart';
import 'package:recetarium/src/features/recipes/data/recipes_provider.dart';
import 'package:recetarium/src/features/recipes/ui/input_dynamic_steps.dart';

class AddSteps extends StatefulWidget {
  const AddSteps({super.key});

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
      final wasEditing = viewRecipesProvider.isEditingRecipe;
      setState(() => _isSaving = true);
      try {
        RecipesModel newRecipe = RecipesModel(
          id: viewRecipesProvider.editingRecipeId,
          nameRecipe: viewRecipesProvider.selectedNameRecipe ?? '',
          descriptionRecipe:
              viewRecipesProvider.selectedDescriptionRecipe ?? '',
          ingredientsRecipe: viewRecipesProvider.selectedIngredient
              .where(
                (i) =>
                    (i['description'] ?? '').toString().trim().isNotEmpty,
              )
              .map((ingredient) => Ingredients.fromJson(ingredient))
              .toList(),
          utensilRecipe: viewRecipesProvider.selectedUtensil
              .where((u) => (u['utensil'] ?? '').toString().trim().isNotEmpty)
              .map((utensil) => Utensils.fromJson(utensil))
              .toList(),
          category: viewRecipesProvider.selectedCategory ?? 'Plato Fuerte',
          level: viewRecipesProvider.selectedLevel ?? 'Basico',
          imageUrl: viewRecipesProvider.uploadedImageUrl != null
              ? '${viewRecipesProvider.uploadedImageUrl}'
              : null,
          createdBy: authProvider.user!.toJson(),
          price: viewRecipesProvider.selectedPrice ?? 0,
          steps: viewRecipesProvider.steps
              .where(
                (s) =>
                    (s['description'] ?? '').toString().trim().isNotEmpty,
              )
              .map((step) => Steps.fromJson(step))
              .toList(),
        );

        bool success = await viewRecipesProvider.createRecipes(newRecipe);
        if (success) {
          if (context.mounted) {
            await context
                .read<RecipeMyCreatedProvider>()
                .getMyRecipesCreated(authProvider.user);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wasEditing
                      ? 'Receta actualizada exitosamente'
                      : 'Receta creada exitosamente',
                ),
              ),
            );
            viewRecipesProvider.resetForm();
            Navigator.of(context).popUntil((route) => route.isFirst);
            final role = authProvider.user?.role;
            if (role == 'admin' || role == 'super_admin') {
              context.go('/admin_home');
            } else {
              context.go('/home');
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wasEditing
                      ? 'No se pudo actualizar la receta'
                      : 'Falló la creación de la receta',
                ),
              ),
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
    final isEditing = viewRecipesProvider.isEditingRecipe;

    return Scaffold(
      appBar: CustomBackAppBar(
        title: isEditing ? 'Editar Pasos' : 'Create Your Recipe',
      ),
      body: SafeArea(
        child: Center(
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
                      text: _isSaving
                          ? 'Guardando en base de datos...'
                          : (isEditing
                              ? 'Actualizar Receta'
                              : 'Create Recipe'),
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
      ),
    );
  }
}