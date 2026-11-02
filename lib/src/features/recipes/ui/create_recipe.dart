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
  final TextEditingController aiTextPromptController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isAnalyzing = false;
  bool _isAnalyzingText = false;

  void _syncControllersFromProvider(ViewRecipesProvider provider) {
    nameRecipeController.text = provider.selectedNameRecipe ?? '';
    descriptionRecipeController.text = provider.selectedDescriptionRecipe ?? '';
    _intController.text = provider.selectedPrice?.toString() ?? '0';
  }

  Future<void> _handleImageAnalysis(ViewRecipesProvider provider) async {
    setState(() => _isAnalyzing = true);
    final success = await provider.analyzeRecipeImage();
    if (success && mounted) {
      _syncControllersFromProvider(provider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Receta analizada desde imagen con éxito!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo analizar la imagen')),
      );
    }
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _showAiTextPopup(
    BuildContext context,
    ViewRecipesProvider provider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Organizar Receta con IA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          if (!_isAnalyzingText)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                              icon: const Icon(Icons.close_rounded, size: 20),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pega o escribe aquí tu receta (ingredientes, utensilios y pasos). La IA organizará todo automáticamente.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: aiTextPromptController,
                          maxLines: 7,
                          minLines: 4,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            hintText:
                                'Ej: Pasta carbonara para 2 personas:\n200g espaguetis, 150g panceta, 3 yemas, 80g queso pecorino.\n\n1. Hervir la pasta en olla por 10m.\n2. Dorar la panceta en sartén.\n3. Mezclar yemas con queso en bowl...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (aiTextPromptController.text.isNotEmpty && !_isAnalyzingText) ...[
                            TextButton.icon(
                              onPressed: () {
                                aiTextPromptController.clear();
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.clear_all_rounded, size: 18),
                              label: const Text('Limpiar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),
                          TextButton(
                            onPressed: _isAnalyzingText
                                ? null
                                : () => Navigator.of(bottomSheetCtx).pop(),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isAnalyzingText
                                ? null
                                : () async {
                                    final text = aiTextPromptController.text.trim();
                                    if (text.isEmpty) {
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Escribe o pega primero el texto de tu receta',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isAnalyzingText = true);
                                    setSheetState(() {});

                                    final success =
                                        await provider.analyzeRecipeText(text);

                                    if (mounted) {
                                      setState(() => _isAnalyzingText = false);
                                    }

                                    if (success && mounted) {
                                      _syncControllersFromProvider(provider);
                                      if (bottomSheetCtx.mounted) {
                                        Navigator.of(bottomSheetCtx).pop();
                                      }
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '¡Receta organizada con IA! Se autocompletaron datos, ingredientes, utensilios y pasos.',
                                          ),
                                        ),
                                      );
                                    } else if (mounted) {
                                      setSheetState(() {});
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No se pudo organizar el texto con IA',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            icon: _isAnalyzingText
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome_rounded, size: 18),
                            label: Text(
                              _isAnalyzingText ? 'Organizando...' : 'Organizar con IA',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    nameRecipeController.dispose();
    descriptionRecipeController.dispose();
    _intController.dispose();
    aiTextPromptController.dispose();
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
                                text: "Photo AI",
                                icon: Icons.add_a_photo_rounded,
                                height: 45,
                                color: Colors.deepPurple.withValues(alpha: 0.85),
                                onPressed: () {
                                  viewRecipesProvider.pickAnalysisImage();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomMainButton(
                                text: "Text AI",
                                icon: Icons.auto_awesome_rounded,
                                height: 45,
                                color: Colors.deepPurple,
                                onPressed: () => _showAiTextPopup(
                                  context,
                                  viewRecipesProvider,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (viewRecipesProvider.analysisImage != null) ...[
                          const SizedBox(height: 10),
                          CustomMainButton(
                            text: _isAnalyzing
                                ? "Analyzing Photo..."
                                : "Analyze Selected Photo",
                            icon: Icons.auto_fix_high_rounded,
                            height: 44,
                            color: Colors.deepPurple.shade700,
                            onPressed: _isAnalyzing
                                ? null
                                : () => _handleImageAnalysis(viewRecipesProvider),
                          ),
                        ],
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
                  CustomMainButton(
                    text: viewRecipesProvider.selectedImage == null
                        ? "Select Image"
                        : "Change Image",
                    icon: Icons.image_rounded,
                    height: 45,
                    onPressed: () {
                      viewRecipesProvider.pickImage();
                    },
                  ),
                  if (viewRecipesProvider.uploadedOriginalFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${viewRecipesProvider.uploadedOriginalFileName} (se subirá al guardar la receta)",
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
