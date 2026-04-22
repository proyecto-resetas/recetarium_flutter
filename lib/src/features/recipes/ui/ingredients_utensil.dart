import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/ui/steps_screen.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';

import 'package:resetas/src/features/recipes/data/steps_provider.dart';

class IngredientsUtensil extends StatefulWidget {
  final RecipesModel recipe;

  const IngredientsUtensil({super.key, required this.recipe});

  @override
  State<IngredientsUtensil> createState() => _IngredientsUtensilState();
}

class _IngredientsUtensilState extends State<IngredientsUtensil> {
  bool _isStartingRecipe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Inicializando IngredientsUtensil para receta: ${widget.recipe.id}');
      if (widget.recipe.id != null) {
        context
            .read<ViewRecipesProvider>()
            .getIngredientsUtensils(widget.recipe.id!);
      } else {
        print('Error: El ID de la receta es nulo');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ViewRecipesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: Text(
          widget.recipe.nameRecipe,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoadingIngredients
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- INGREDIENTS HEADER ---
                  _buildSectionHeader(
                    icon: Bootstrap.basket_fill,
                    title: "Ingredientes (2 personas)",
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),

                  // --- INGREDIENTS LIST ---
                  ...provider.ingredientsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return _buildItemCard(
                      title: ingredient.description,
                      trailing: ingredient.amount,
                      icon: _getIngredientIcon(index),
                      color: Colors.redAccent,
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // --- UTENSILS HEADER ---
                  _buildSectionHeader(
                    icon: Bootstrap.tools,
                    title: "Utensilios Necesarios",
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),

                  // --- UTENSILS LIST ---
                  ...provider.utensilsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final utensil = entry.value;
                    return _buildItemCard(
                      title: utensil.utensil,
                      trailing: "",
                      icon: _getUtensilIcon(index),
                      color: Colors.blueAccent,
                    );
                  }).toList(),

                  const SizedBox(height: 40),

                  // --- PLAY BUTTON ---
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withAlpha(76),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _isStartingRecipe
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 45, color: Colors.white),
                              onPressed: () async {
                                if (widget.recipe.id != null) {
                                  setState(() => _isStartingRecipe = true);
                                  try {
                                    // Cargar los pasos antes de navegar
                                    await context
                                        .read<StepsProvider>()
                                        .fetchSteps(widget.recipe.id!);
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isStartingRecipe = false);
                                    }
                                  }
                                }

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StepsScreen(recipe: widget.recipe),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String title,
    required String trailing,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[400],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIngredientIcon(int index) {
    final icons = [
      Bootstrap.egg_fill,
      Bootstrap.cup_hot_fill,
      Bootstrap.egg_fried,
      Bootstrap.cookie,
      Bootstrap.cake2_fill,
    ];
    if (icons.isEmpty) return Icons.restaurant_menu_rounded;
    return icons[index % icons.length];
  }

  IconData _getUtensilIcon(int index) {
    final icons = [
      Bootstrap.tools,
      Bootstrap.box,
      Bootstrap.gear_fill,
      Bootstrap.collection_fill,
    ];
    if (icons.isEmpty) return Icons.build_rounded;
    return icons[index % icons.length];
  }
}
