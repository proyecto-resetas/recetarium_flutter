import 'package:flutter/foundation.dart'; // Añadido para kIsWeb
import 'package:flutter/material.dart';
import 'dart:io' show File; // Importado para Image.file en móvil
import 'package:provider/provider.dart';
import 'package:resetas/src/core/widgets/custom_icon_input.dart';
import 'package:resetas/src/core/widgets/custom_select_field.dart';
import 'package:resetas/src/core/widgets/custom_main_button.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/ui/add_ingredients_utensils.dart';


class CreateRecipe extends StatefulWidget {
  CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final TextEditingController nameRecipeController = TextEditingController();
  final TextEditingController descriptionRecipeController = TextEditingController();
  final TextEditingController _intController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isAnalyzing = false;

  Future<void> _handleImageAnalysis(ViewRecipesProvider provider) async {
    setState(() => _isAnalyzing = true);
    final success = await provider.analyzeRecipeImage();
    if (success && mounted) {
      nameRecipeController.text = provider.selectedNameRecipe ?? '';
      descriptionRecipeController.text = provider.selectedDescriptionRecipe ?? '';
      _intController.text = provider.selectedPrice?.toString() ?? '0';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe analyzed successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to analyze image')),
      );
    }
    setState(() => _isAnalyzing = false);
  }

  @override
  void dispose() {
    nameRecipeController.dispose();
    descriptionRecipeController.dispose();
    _intController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewRecipesProvider = Provider.of<ViewRecipesProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.only(top: 20.0, bottom: 120.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- AI ANALYSIS SECTION ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "AI Recipe Assistant",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (viewRecipesProvider.analysisImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: kIsWeb
                                ? Image.network(
                                    viewRecipesProvider.analysisImage!.path,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(viewRecipesProvider.analysisImage!.path),
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomMainButton(
                                text: "Select Photo to Analyze",
                                icon: Icons.add_a_photo_rounded,
                                height: 45,
                                color: Colors.deepPurple.withValues(alpha: 0.8),
                                onPressed: () {
                                  viewRecipesProvider.pickAnalysisImage();
                                },
                              ),
                            ),
                            if (viewRecipesProvider.analysisImage != null) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomMainButton(
                                  text: _isAnalyzing ? "Analyzing..." : "Analyze",
                                  icon: Icons.auto_fix_high_rounded,
                                  height: 45,
                                  color: Colors.deepPurple,
                                  onPressed: _isAnalyzing
                                      ? null
                                      : () => _handleImageAnalysis(viewRecipesProvider),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- MANUAL RECIPE SECTION ---
                  const Text(
                    "Recipe Main Image",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: viewRecipesProvider.selectedImage == null
                        ? Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.image_search_rounded,
                                size: 50, color: Colors.grey),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb
                                ? Image.network(
                                    viewRecipesProvider.selectedImage!.path,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(viewRecipesProvider.selectedImage!.path),
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomMainButton(
                          text: "Select Image",
                          icon: Icons.image_rounded,
                          height: 45,
                          onPressed: () {
                            viewRecipesProvider.pickImage();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomMainButton(
                          text: "Upload Image",
                          icon: Icons.upload_rounded,
                          height: 45,
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: viewRecipesProvider.selectedImage == null
                              ? null
                              : () {
                                  viewRecipesProvider.uploadImage();
                                },
                        ),
                      ),
                    ],
                  ),
                  if (viewRecipesProvider.uploadedOriginalFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${viewRecipesProvider.uploadedOriginalFileName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 30),
                  CustomIconInput(
                    controller: nameRecipeController,
                    label: 'Name Recipe',
                    hintText: 'Enter recipe name',
                    prefixIcon: Icons.restaurant_menu_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el nombre de la receta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomIconInput(
                    controller: descriptionRecipeController,
                    label: 'Description',
                    hintText: 'Enter recipe description',
                    prefixIcon: Icons.description_rounded,
                    maxLines: 3,
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa la descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomSelectField<String>(
                    value: viewRecipesProvider.selectedCategory,
                    label: 'Category',
                    hintText: 'Select a category',
                    prefixIcon: Icons.category_rounded,
                    items: [
                      'Entrada',
                      'Aperitivo',
                      'Plato Fuerte',
                      'Postre',
                      'Sopa',
                      'Ensalada',
                      'Guarnicion',
                      'Salsa',
                      'Italiana',
                      'Principal'
                    ].map((String category) {
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
                        return 'Por favor, selecciona una categoría';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomSelectField<String>(
                    value: viewRecipesProvider.selectedLevel,
                    label: 'Level',
                    hintText: 'Select difficulty level',
                    prefixIcon: Icons.bar_chart_rounded,
                    items: ['Basico', 'Intermedio', 'Avanzado']
                        .map((String level) {
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
                        return 'Por favor, selecciona un nivel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomIconInput(
                    controller: _intController,
                    label: 'Recipe Value',
                    hintText: 'Enter the value of your recipe',
                    prefixIcon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
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
                  const SizedBox(height: 30),
                  CustomMainButton(
                    text: 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        int priceValue = int.parse(_intController.text);

                        // La imagen ahora es opcional
                        viewRecipesProvider.setNewRecipe(
                          nameRecipeController.text,
                          descriptionRecipeController.text,
                          priceValue,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddIngredientsUtensils()),
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
