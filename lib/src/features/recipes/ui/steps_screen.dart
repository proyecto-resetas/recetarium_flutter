import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resetas/src/features/auth/data/auth_provider.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/models/ingredients_model.dart';
import 'package:resetas/src/features/recipes/models/utensil_model.dart';
import 'package:resetas/src/features/recipes/data/recipes_provider.dart';
import 'package:resetas/src/features/recipes/data/steps_provider.dart';
import 'package:resetas/src/features/recipes/models/steps_model.dart';

class StepsScreen extends StatefulWidget {
  final RecipesModel recipe;

  const StepsScreen({super.key, required this.recipe});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  int _currentStepIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    // Iniciar el temporizador después de que el widget se monte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipesProvider = context.read<ViewRecipesProvider>();
      if (recipesProvider.ingredientsList.isEmpty &&
          recipesProvider.utensilsList.isEmpty &&
          widget.recipe.id != null) {
        recipesProvider.getIngredientsUtensils(widget.recipe.id!);
      }
      _startStepTimer();
    });
  }

  void _startStepTimer() async {
    final steps = _getSteps();
    if (steps.isEmpty) return;

    while (_currentStepIndex < steps.length && !_isPaused) {
      // Obtiene el tiempo del paso actual
      int timeForStep = steps[_currentStepIndex].timeScreen;

      if (!_isPaused && mounted) {
        // Espera el tiempo del paso antes de continuar
        await Future.delayed(Duration(milliseconds: timeForStep));

        // Después de completar el tiempo, pasa al siguiente paso
        if (mounted && !_isPaused) {
          _goToNextStep();
        }
      } else {
        // Si está pausado, espera un poco antes de continuar
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
  }

  List<Steps> _getSteps() {
    final providerSteps = context.read<StepsProvider>().steps;
    if (providerSteps.isNotEmpty) return providerSteps;
    return widget.recipe.steps ?? [];
  }

  void _goToNextStep() {
    final steps = _getSteps();
    if (_currentStepIndex < steps.length - 1) {
      if (mounted) {
        setState(() {
          _currentStepIndex++;
        });
      }
    } else {
      _resetSteps(); // Si es el último paso, reiniciar
      _pauseTimer(); // Pausar automáticamente
    }
  }

  void _pauseTimer() {
    if (mounted) {
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeTimer() {
    if (mounted) {
      setState(() {
        _isPaused = false;
      });
      _startStepTimer(); // Reinicia el temporizador si se reanuda
    }
  }

  void _resetSteps() {
    if (mounted) {
      setState(() {
        _currentStepIndex = 0; // Reinicia
      });
    }
  }

  void _goDirectToHome(BuildContext context) {
    _isPaused = true;
    final role = context.read<AuthProvider>().user?.role;
    final homeRoute =
        (role == 'admin' || role == 'super_admin') ? '/admin_home' : '/home';
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.go(homeRoute);
  }

  static const Set<String> _stopWords = {
    'de',
    'del',
    'la',
    'las',
    'el',
    'los',
    'en',
    'con',
    'para',
    'por',
    'un',
    'una',
    'unos',
    'unas',
    'al',
    'a',
    'y',
    'o',
    'u',
    'sin',
    'sobre',
    'entre',
    'hasta',
    'como',
    'mas',
    'muy',
    'poco',
    'poca',
    'grande',
    'grandes',
    'pequeno',
    'pequena',
    'mediano',
    'mediana',
  };

  String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  String _singularStem(String word) {
    if (word.length > 4 && word.endsWith('es')) {
      return word.substring(0, word.length - 2);
    }
    if (word.length > 3 && word.endsWith('s')) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  List<_StepHighlightCandidate> _buildCandidates(
    List<Ingredients> ingredients,
    List<Utensils> utensils,
  ) {
    final List<_StepHighlightCandidate> candidates = [];

    for (final ing in ingredients) {
      final raw = ing.description.trim();
      if (raw.isEmpty) continue;
      final normFull = _normalizeText(raw);
      final label = ing.amount.trim().isNotEmpty
          ? 'Ingrediente: ${ing.description} (${ing.amount})'
          : 'Ingrediente: ${ing.description}';

      candidates.add(
        _StepHighlightCandidate(
          term: normFull,
          isIngredient: true,
          tooltip: label,
        ),
      );

      final words = normFull
          .split(RegExp(r'[^a-zñ0-9]+'))
          .where((w) => w.length >= 3 && !_stopWords.contains(w));
      for (final word in words) {
        candidates.add(
          _StepHighlightCandidate(
            term: word,
            isIngredient: true,
            tooltip: label,
          ),
        );
        final stem = _singularStem(word);
        if (stem.length >= 3 && stem != word) {
          candidates.add(
            _StepHighlightCandidate(
              term: stem,
              isIngredient: true,
              tooltip: label,
            ),
          );
        }
      }
    }

    for (final ut in utensils) {
      final raw = ut.utensil.trim();
      if (raw.isEmpty) continue;
      final normFull = _normalizeText(raw);
      final label = 'Utensilio: ${ut.utensil}';

      candidates.add(
        _StepHighlightCandidate(
          term: normFull,
          isIngredient: false,
          tooltip: label,
        ),
      );

      final words = normFull
          .split(RegExp(r'[^a-zñ0-9]+'))
          .where((w) => w.length >= 3 && !_stopWords.contains(w));
      for (final word in words) {
        candidates.add(
          _StepHighlightCandidate(
            term: word,
            isIngredient: false,
            tooltip: label,
          ),
        );
        final stem = _singularStem(word);
        if (stem.length >= 3 && stem != word) {
          candidates.add(
            _StepHighlightCandidate(
              term: stem,
              isIngredient: false,
              tooltip: label,
            ),
          );
        }
      }
    }

    candidates.sort((a, b) => b.term.length.compareTo(a.term.length));
    return candidates;
  }

  List<_TextMatchSpan> _findMatchesInDescription(
    String description,
    List<Ingredients> ingredients,
    List<Utensils> utensils,
  ) {
    if (description.isEmpty) return [];
    final candidates = _buildCandidates(ingredients, utensils);
    if (candidates.isEmpty) return [];

    final normalizedDesc = _normalizeText(description);
    final List<_TextMatchSpan> matches = [];

    bool overlaps(int start, int end) {
      for (final m in matches) {
        if (start < m.end && end > m.start) return true;
      }
      return false;
    }

    for (final cand in candidates) {
      final escaped = RegExp.escape(cand.term);
      final pattern = RegExp(
        '(?<![a-zñ0-9])$escaped(es|s)?(?![a-zñ0-9])',
        caseSensitive: false,
      );
      for (final regMatch in pattern.allMatches(normalizedDesc)) {
        final start = regMatch.start;
        final end = regMatch.end;
        if (!overlaps(start, end)) {
          matches.add(
            _TextMatchSpan(
              start: start,
              end: end,
              isIngredient: cand.isIngredient,
              tooltip: cand.tooltip,
            ),
          );
        }
      }
    }

    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  Widget _buildHighlightedStepDescription(
    String description,
    List<Ingredients> ingredients,
    List<Utensils> utensils,
  ) {
    final matches = _findMatchesInDescription(
      description,
      ingredients,
      utensils,
    );

    if (matches.isEmpty) {
      return Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );
    }

    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(text: description.substring(currentIndex, match.start)),
        );
      }

      final matchedText = description.substring(match.start, match.end);
      final highlightColor =
          match.isIngredient ? Colors.redAccent : Colors.blueAccent;

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Tooltip(
            message: match.tooltip,
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: highlightColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
                border: Border(
                  bottom: BorderSide(
                    color: highlightColor,
                    width: 2.2,
                  ),
                ),
              ),
              child: Text(
                matchedText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: match.isIngredient
                      ? const Color(0xFF8E1B1B)
                      : const Color(0xFF0D3B66),
                ),
              ),
            ),
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < description.length) {
      spans.add(TextSpan(text: description.substring(currentIndex)));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.5,
          color: Colors.black87,
        ),
        children: spans,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _isPaused = true; // Asegúrate de que esté pausado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();

    final steps = _getSteps();
    final recipesProvider = context.watch<ViewRecipesProvider>();
    final ingredients = recipesProvider.ingredientsList.isNotEmpty
        ? recipesProvider.ingredientsList
        : (widget.recipe.ingredientsRecipe ?? <Ingredients>[]);
    final utensils = recipesProvider.utensilsList.isNotEmpty
        ? recipesProvider.utensilsList
        : (widget.recipe.utensilRecipe ?? <Utensils>[]);

    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pasos de la Receta'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                tooltip: 'Ir al inicio',
                onPressed: () => _goDirectToHome(context),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.home_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: const Center(child: Text('No hay pasos disponibles para esta receta.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.nameRecipe),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: 'Ir al inicio',
              onPressed: () => _goDirectToHome(context),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Indicador de pasos con scroll horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                int stepIndex = entry.key;
                final step = entry.value;

                return GestureDetector(
                  onTap: () => setState(() => _currentStepIndex = stepIndex),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: _currentStepIndex == stepIndex
                              ? const Color.fromRGBO(254, 166, 33, 1)
                              : const Color.fromARGB(255, 205, 205, 205),
                          child: Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: _currentStepIndex == stepIndex
                                  ? Colors.white
                                  : const Color.fromARGB(255, 133, 133, 133),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            step.description,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentStepIndex == stepIndex
                                  ? const Color.fromRGBO(254, 166, 33, 1)
                                  : const Color.fromARGB(255, 205, 205, 205),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHighlightedStepDescription(
                    steps[_currentStepIndex].description,
                    ingredients,
                    utensils,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Tiempo: ${steps[_currentStepIndex].time}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                      icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      label: _isPaused ? 'Reanudar' : 'Pausar',
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      onPressed: _goToNextStep,
                      icon: Icons.skip_next_rounded,
                      label: 'Siguiente',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      onPressed: _currentStepIndex > 0
                          ? () => setState(() => _currentStepIndex--)
                          : null,
                      icon: Icons.skip_previous_rounded,
                      label: 'Anterior',
                      secondary: true,
                    ),
                    const SizedBox(width: 20),
                    _ActionButton(
                      onPressed: _resetSteps,
                      icon: Icons.replay_rounded,
                      label: 'Reiniciar',
                      secondary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool secondary;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary ? Colors.grey[200] : const Color.fromRGBO(254, 166, 33, 1),
        foregroundColor: secondary ? Colors.black87 : Colors.white,
        elevation: secondary ? 0 : 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _StepHighlightCandidate {
  final String term;
  final bool isIngredient;
  final String tooltip;

  const _StepHighlightCandidate({
    required this.term,
    required this.isIngredient,
    required this.tooltip,
  });
}

class _TextMatchSpan {
  final int start;
  final int end;
  final bool isIngredient;
  final String tooltip;

  const _TextMatchSpan({
    required this.start,
    required this.end,
    required this.isIngredient,
    required this.tooltip,
  });
}
