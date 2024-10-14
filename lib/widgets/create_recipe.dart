import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/models/recipes_model.dart';
import 'package:resetas/models/steps_model.dart';
import 'package:resetas/models/token_model.dart';
import 'package:resetas/providers/auth_provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/widgets/create_input_dynamic.dart';

class CreateRecipe extends StatelessWidget {
  final TextEditingController nameRecipeController = TextEditingController();
  final TextEditingController descriptionRecipeController = TextEditingController();
  final TextEditingController ingredientsRecipeController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController _intController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreateRecipe({super.key});


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
                        viewRecipesProvider.selectedImage == null
                            ? const Placeholder(
                                fallbackHeight: 0,
                                fallbackWidth: 0,
                                color: Colors.black12,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  viewRecipesProvider.selectedImage!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        const SizedBox(height: 20),  
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                viewRecipesProvider
                                    .pickImage(); // Seleccionar imagen
                              },
                              child: const Text("Select Image"),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                viewRecipesProvider
                                    .uploadImage(); // Subir la imagen
                              },
                              child: const Icon(Icons.upload),
                            ),
                          ],
                        ),
                        if (viewRecipesProvider.uploadedOriginalFileName !=
                            null)
                          Text(
                              "${viewRecipesProvider.uploadedOriginalFileName}", maxLines: 1),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameRecipeController,
                          decoration: InputDecoration(
                            labelText: 'Name Recipe',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa el nombre de la receta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: descriptionRecipeController,
                          maxLength: 200,
                          maxLines: 3,
                          textAlign : TextAlign.start,
                          decoration: InputDecoration(
                          labelText: 'Description',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa la descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa la categoría';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                          TextFormField(
                          controller: levelController,
                          decoration: InputDecoration(
                            labelText: 'Level',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa el nivel';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _intController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Ingresar el valor de tu Receta',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el valor de tu Receta';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Por favor ingresa un número válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                         TextFormField(
                          controller: ingredientsRecipeController,
                          maxLength: 200,
                          maxLines: 3,
                          textAlign : TextAlign.start,
                          decoration: InputDecoration(
                            labelText: 'Ingredients',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa los ingredientes';
                            }
                            return null;
                          },
                        ),
                        const Expanded(
                          child: CreateDynamicInputs(),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              int priceValue = int.parse(_intController.text);

                              // Lógica para asegurar que la imagen esté cargada
                              if (viewRecipesProvider.selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Por favor, selecciona una imagen')),
                                );
                                return;
                              }
                              // Crea el nuevo modelo de receta
                              RecipesModel newRecipe = RecipesModel(
                                nameRecipe: nameRecipeController.text,
                                descriptionRecipe: descriptionRecipeController.text,
                                ingredientsRecipe: ingredientsRecipeController.text,
                                level: levelController.text,
                                imageUrl:'${viewRecipesProvider.uploadedImageUrl}', // Puedes actualizar esto con la URL subida
                                category: categoryController.text,
                                createdBy: authProvider.user!.username,
                                price: priceValue,
                                steps: viewRecipesProvider.steps
                                .map((step) => Steps.fromJson(step))
                                .toList(),
                              );

                              AccessToken? token = authProvider.accessToken;

                              bool success =
                                  await viewRecipesProvider.createRecipes(newRecipe, token?.accessToken);
                                  
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Receta creada exitosamente')),
                                );
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
