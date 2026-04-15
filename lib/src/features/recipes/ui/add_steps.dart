import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/ingredients_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/models/steps_model.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
import 'package:resetas/src/features/recipes/models/utensil_model.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/ui/input_dynamic_steps.dart';

class AddSteps extends StatelessWidget {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddSteps({super.key});

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
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(10.0),
            width: 700,
            height: 1000,
            child: Form(
              key: _formKey, 
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                                              
                        const SizedBox(height: 20),
                                          
                        const Expanded(
                          child: CreateDynamicInputs(),
                        ),
                        ElevatedButton(
                          onPressed: () async {

                            if (_formKey.currentState!.validate()) {

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
                                level:  viewRecipesProvider.selectedLevel!,
                                imageUrl:'${viewRecipesProvider.uploadedImageUrl}', // Puedes actualizar esto con la URL subida
                                createdBy: authProvider.user!.username,
                                price: viewRecipesProvider.selectedPrice!,
                                steps: viewRecipesProvider.steps
                                .map((step) => Steps.fromJson(step))
                                .toList(),
                              );
                          
                              // Crea el nuevo modelo de receta
                              AccessToken? token = authProvider.accessToken;

                              print('add steps ${newRecipe}');
                           
                              bool success = await viewRecipesProvider.createRecipes(newRecipe, token?.accessToken);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Receta creada exitosamente')),
                                );
                                viewRecipesProvider.resetForm();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                        Text('Falló la creación de la receta')),
                                );
                              }
                            }
                          },
                          child:const Text('Create'),
                        ),
                      ],
                    ),
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