import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resetas/providers/recipes_provider.dart';
import 'package:resetas/widgets/add_steps.dart';
import 'package:resetas/widgets/input_dynamic_ingredients.dart';

class CreateRecipe extends StatelessWidget {
  final TextEditingController nameRecipeController = TextEditingController();
  final TextEditingController descriptionRecipeController = TextEditingController();
  final TextEditingController _intController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreateRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    final viewRecipesProvider = Provider.of<ViewRecipesProvider>(context);

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
            height: 1200,
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
                         DropdownButtonFormField<String>(
                        value: viewRecipesProvider.selectedCategory,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(labelText: 'Category',
                        border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                              ),
                        borderRadius: BorderRadius.circular(20) ,
                      //  padding: EdgeInsets.symmetric(vertical: 40) ,
                        items: [
                        'Entradas',
                        'Aperitivos',
                        'Platos principales', 
                        'Postres',
                        'Sopas', 
                        'Ensaladas', 
                        'Guarniciones', 
                        'Salsas' ].map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          viewRecipesProvider.setSelectedCategory(newValue);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona un tipo de usuario';
                          }
                          return null;
                        },
                        ),
                        const SizedBox(height: 20),
                         DropdownButtonFormField<String>(
                        value: viewRecipesProvider.selectedLevel,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(labelText: 'Level',
                        border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        borderRadius: BorderRadius.circular(20) ,
                        items: ['Basico', 'Intermedio','Avanzado' ].map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                            viewRecipesProvider.setSelectedLevel(newValue);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecciona un tipo de usuario';
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
                        //  TextFormField(
                        //   controller: ingredientsRecipeController,
                        //   maxLength: 200,
                        //   maxLines: 3,
                        //   textAlign : TextAlign.start,
                        //   decoration: InputDecoration(
                        //     labelText: 'Ingredients',
                        //     border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(10)),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Por favor, ingresa los ingredientes';
                        //     }
                        //     return null;
                        //   },
                        // ),
                         const Expanded(
                          child: InputDynamicIngredients(),
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
                              viewRecipesProvider.setNewRecipe(
                                nameRecipeController.text,
                                descriptionRecipeController.text,
                                priceValue,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddSteps()),
                              );
                            }
                          },
                          child:const Text('Next'),
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


//  RecipesModel newRecipe = RecipesModel(
//                                 nameRecipe: nameRecipeController.text,
//                                 descriptionRecipe: descriptionRecipeController.text,
//                                 ingredientsRecipe: viewRecipesProvider.selectedIngredient!,
//                                 category: viewRecipesProvider.selectedCategory!,
//                                 level:  viewRecipesProvider.selectedLevel!,
//                                 imageUrl:'${viewRecipesProvider.uploadedImageUrl}', // Puedes actualizar esto con la URL subida
//                                 createdBy: authProvider.user!.username,
//                                 price: priceValue,
//                                 steps: viewRecipesProvider.steps
//                                 .map((step) => Steps.fromJson(step))
//                                 .toList(),
//                               );
