import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetarium/src/core/services/local_storage_service.dart';
import 'package:recetarium/src/features/recipes/data/ingredient_matcher.dart';
import 'package:recetarium/src/features/recipes/data/recipes_api_service.dart';
import 'package:recetarium/src/features/recipes/models/image_s3_model.dart';
import 'package:recetarium/src/features/recipes/models/recipes_model.dart';
import 'package:recetarium/src/features/recipes/models/ingredients_model.dart';
import 'package:recetarium/src/features/recipes/models/utensil_model.dart';

class ViewRecipesProvider extends ChangeNotifier {

  final ScrollController recipeScrollController = ScrollController();
  final RecipesApiService recetasAPI = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  Timer? _debounce;
  String? _editingRecipeId;
  String? _uploadedOriginalFileName;
  String? _selectedNameRecipe;
  String? _selectedDescriptionRecipe;
  num? _selectedPrice;
  String? _uploadedImageUrl;
  XFile? _selectedImage;
  XFile? _analysisImage;
  String? _selectedCategory;
  String? _selectedLevel;

  RecipesModel? recipeCreatedRes;
  RecipesModel? recetas; 

  List<RecipesModel> recipeList = [];
  List<RecipesModel> recipeListFilter = [];
  final List<Map<String, dynamic>> _steps = [];
  final List<Map<String, dynamic>> _selectedIngredient = [];
  final List<Map<String, dynamic>> _selectedUtensil = [];
  final _favorites = [];

  bool _isLoadingIngredients = false;
  List<Ingredients> _ingredientsList = [];
  List<Utensils> _utensilsList = [];

  // Tags de ingredientes activos en el Home y caché para búsqueda híbrida confiable
  final List<String> _ingredientTags = [];
  bool _isSearchingIngredients = false;
  List<RecipesModel> _catalogCache = [];
  final Map<String, List<Ingredients>> _recipeIngredientsCache = {};

  static const List<String> quickIngredientSuggestions = [
    'Huevo',
    'Tomate',
    'Cebolla',
    'Pollo',
    'Arroz',
    'Queso',
    'Papa',
    'Pasta',
    'Ajo',
    'Leche',
  ];

  List<String> get ingredientTags => List.unmodifiable(_ingredientTags);
  bool get isSearchingIngredients => _isSearchingIngredients;

  List<Map<String, dynamic>> get steps => _steps;
  List<Map<String, dynamic>> get selectedIngredient => _selectedIngredient;
  List<Map<String, dynamic>> get selectedUtensil => _selectedUtensil;
  
  List<Ingredients> get ingredientsList => _ingredientsList;
  List<Utensils> get utensilsList => _utensilsList;
  bool get isLoadingIngredients => _isLoadingIngredients;
  RecipesModel? get getRecetas => recetas;
  String? get editingRecipeId => _editingRecipeId;
  bool get isEditingRecipe =>
      _editingRecipeId != null && _editingRecipeId!.isNotEmpty;
  String? get selectedNameRecipe => _selectedNameRecipe;
  String? get selectedDescriptionRecipe => _selectedDescriptionRecipe;
  num? get selectedPrice => _selectedPrice;
  XFile? get selectedImage => _selectedImage;
  XFile? get analysisImage => _analysisImage;
  String? get uploadedImageUrl => _uploadedImageUrl;
  String? get uploadedOriginalFileName => _uploadedOriginalFileName;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLevel => _selectedLevel;
  get setFavorite => _favorites.iterator;

  ViewRecipesProvider() {
    getRecipeFilter(null, null, null, null);
  }


  // Setters para actualizar los valores y notificar cambios
  void setNewRecipe(nameRecipe, descriptionRecipe, price) {
    _selectedNameRecipe = nameRecipe;
    _selectedDescriptionRecipe = descriptionRecipe;
    _selectedPrice = price;
    notifyListeners(); // Notificar a los widgets que dependen de este valor
  }

  /// Actualiza en memoria los datos básicos mientras el usuario escribe,
  /// conservando el estado temporal al navegar entre vistas.
  void updateDraftBasicInfo({
    String? nameRecipe,
    String? descriptionRecipe,
    num? price,
  }) {
    if (nameRecipe != null) _selectedNameRecipe = nameRecipe;
    if (descriptionRecipe != null) {
      _selectedDescriptionRecipe = descriptionRecipe;
    }
    if (price != null) _selectedPrice = price;
  }

  /// Sincroniza automáticamente la lista temporal de ingredientes en memoria.
  void syncIngredients(List<Map<String, dynamic>> items) {
    _selectedIngredient
      ..clear()
      ..addAll(items);
  }

  /// Sincroniza automáticamente la lista temporal de utensilios en memoria.
  void syncUtensils(List<Map<String, dynamic>> items) {
    _selectedUtensil
      ..clear()
      ..addAll(items);
  }

  /// Sincroniza automáticamente la lista temporal de pasos en memoria.
  void syncSteps(List<Map<String, dynamic>> items) {
    _steps.clear();
    for (final item in items) {
      final desc = (item['description'] ?? '').toString();
      final timeStr = (item['time'] ?? '').toString();
      final timeScreenMs =
          _parseTimeToMilliseconds(timeStr, item['timeScreen']);
      _steps.add({
        'description': desc,
        'time': timeStr,
        'timeScreen': timeScreenMs,
      });
    }
  }

  /// Carga una receta existente en el estado temporal para editarla desde
  /// el flujo de creación/edición.
  Future<void> loadRecipeForEdit(RecipesModel recipe) async {
    resetForm();
    final token = _localStorageService.token;
    RecipesModel target = recipe;

    if (recipe.id != null && recipe.id!.isNotEmpty) {
      final fetched = await recetasAPI.getRecipeById(recipe.id!);
      if (fetched != null) {
        target = fetched;
      }
    }

    _editingRecipeId = target.id ?? recipe.id;
    _selectedNameRecipe = target.nameRecipe;
    _selectedDescriptionRecipe = target.descriptionRecipe;
    _selectedPrice = target.price;
    _uploadedImageUrl = target.imageUrl;
    _selectedImage = null;
    _uploadedOriginalFileName = null;

    final rawLevel = target.level
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('Á', 'A');
    _selectedLevel = _validLevels.firstWhere(
      (l) => l.toLowerCase() == rawLevel.toLowerCase(),
      orElse: () => _validLevels.first,
    );

    final rawCategory = target.category
        .trim()
        .replaceAll('ó', 'o')
        .replaceAll('Ó', 'O');
    _selectedCategory = _validCategories.firstWhere(
      (c) => c.toLowerCase() == rawCategory.toLowerCase(),
      orElse: () => _validCategories.first,
    );

    // Cargar ingredientes y utensilios
    List<Ingredients> ingList = target.ingredientsRecipe ?? [];
    List<Utensils> utList = target.utensilRecipe ?? [];
    if ((ingList.isEmpty && utList.isEmpty) &&
        _editingRecipeId != null &&
        token != null) {
      try {
        final data =
            await recetasAPI.getIngredientsUtensils(_editingRecipeId!, token);
        if (data['ingredientsRecipe'] is List) {
          ingList = (data['ingredientsRecipe'] as List)
              .map((item) => Ingredients.fromJson(item))
              .toList();
        }
        if (data['utensilRecipe'] is List) {
          utList = (data['utensilRecipe'] as List)
              .map((item) => Utensils.fromJson(item))
              .toList();
        }
      } catch (_) {}
    }

    _selectedIngredient.clear();
    for (final ing in ingList) {
      _selectedIngredient.add({
        'description': ing.description,
        'amount': ing.amount,
      });
    }

    _selectedUtensil.clear();
    for (final ut in utList) {
      _selectedUtensil.add({
        'utensil': ut.utensil,
      });
    }

    // Cargar pasos
    _steps.clear();
    if (target.steps != null && target.steps!.isNotEmpty) {
      for (final s in target.steps!) {
        _steps.add({
          'description': s.description,
          'time': s.time,
          'timeScreen': s.timeScreen,
        });
      }
    } else if (_editingRecipeId != null && token != null) {
      try {
        final rawSteps =
            await recetasAPI.getRecipeSteps(_editingRecipeId!, token);
        for (final item in rawSteps) {
          if (item is Map) {
            final desc = (item['description'] ?? '').toString();
            final timeStr = (item['time'] ?? '').toString();
            final timeScreenMs =
                _parseTimeToMilliseconds(timeStr, item['timeScreen']);
            _steps.add({
              'description': desc,
              'time': timeStr,
              'timeScreen': timeScreenMs,
            });
          }
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  // Setters para actualizar los valores y notificar cambios
  void setSelectedCategory(String? value) {
    _selectedCategory = value;
    notifyListeners(); // Notificar a los widgets que dependen de este valor
  }

  void setSelectedLevel(String? value) {
    _selectedLevel = value;
    notifyListeners(); // Notificar a los widgets que dependen de este valor
  }

  // Para limpiar los valores seleccionados si es necesario
  void resetForm() {
    _editingRecipeId = null;
    _selectedCategory = null;
    _selectedLevel = null;
    _selectedNameRecipe = null;
    _selectedDescriptionRecipe = null;
    _selectedPrice = null;
    _uploadedImageUrl = null;
    _uploadedOriginalFileName = null;
    _selectedImage = null;
    _analysisImage = null;
    clearSteps();
    clearIngredients();
    clearUtensils();
    notifyListeners();
  }

  void clearIngredients() {
    _selectedIngredient.clear();
    notifyListeners();
  }

  void clearUtensils() {
    _selectedUtensil.clear();
    notifyListeners();
  }


 Future<void> getRecipe() async {
  
  final List<RecipesModel> recetas = await recetasAPI.getRecipe(); 
  recipeList.addAll(recetas); // agregar todos los elementos de la lista
  notifyListeners();
}

  Future<void> getRecipeFilter(
      String? name, String? category, String? level, String? createdBy) async {
    if (createdBy != null) {
      final effectiveToken = _localStorageService.token;
      if (effectiveToken == null) return;
      final List<RecipesModel> recetas = await recetasAPI.getRecipesFilter(
          name, category, level, createdBy, effectiveToken);
      recipeListFilter = recetas;
      notifyListeners();
      return;
    }

    await searchHomeRecipes(
      query: name,
      category: category,
      level: level,
    );
  }

  void progressiveSearch(String query, String? category, String? level) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      searchHomeRecipes(
        query: query,
        category: category,
        level: level,
      );
    });
  }

  /// Agrega uno o varios ingredientes (separados por coma) como tags activos en el Home.
  Future<void> addIngredientTag(
    String rawTag, {
    String? currentTextQuery,
    String? category,
    String? level,
  }) async {
    final parts = rawTag
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return;

    bool addedAny = false;
    for (final part in parts) {
      final normalizedNew = IngredientMatcher.normalizeCulinaryText(part);
      final exists = _ingredientTags.any(
        (existing) =>
            IngredientMatcher.normalizeCulinaryText(existing) == normalizedNew,
      );
      if (!exists) {
        _ingredientTags.add(part);
        addedAny = true;
      }
    }

    if (addedAny) {
      notifyListeners();
      await searchHomeRecipes(
        query: currentTextQuery,
        category: category,
        level: level,
      );
    }
  }

  /// Elimina un tag de ingrediente y actualiza el catálogo del Home.
  Future<void> removeIngredientTag(
    String tag, {
    String? currentTextQuery,
    String? category,
    String? level,
  }) async {
    final normalizedTarget = IngredientMatcher.normalizeCulinaryText(tag);
    _ingredientTags.removeWhere(
      (t) => IngredientMatcher.normalizeCulinaryText(t) == normalizedTarget,
    );
    notifyListeners();
    await searchHomeRecipes(
      query: currentTextQuery,
      category: category,
      level: level,
    );
  }

  /// Limpia todos los tags de ingredientes del Home.
  Future<void> clearIngredientTags({
    String? currentTextQuery,
    String? category,
    String? level,
    bool triggerSearch = true,
  }) async {
    if (_ingredientTags.isEmpty && !triggerSearch) return;
    _ingredientTags.clear();
    notifyListeners();
    if (triggerSearch) {
      await searchHomeRecipes(
        query: currentTextQuery,
        category: category,
        level: level,
      );
    }
  }

  /// Hidrata el catálogo completo con los ingredientes reales de cada receta
  /// usando caché en memoria/Hive + `GET /Recipes/ingredients-utensils/:id`.
  Future<List<RecipesModel>> _hydrateCatalogWithIngredients(
    String token, {
    bool forceRefresh = false,
  }) async {
    if (_catalogCache.isEmpty || forceRefresh) {
      try {
        _catalogCache = await recetasAPI.getRecipe(token: token);
      } catch (_) {
        _catalogCache = await recetasAPI.getRecipesFilter(
            null, null, null, null, token);
      }
    }

    // Recetas que aún no tienen ingredientes en caché en memoria
    final missingRecipes = <RecipesModel>[];
    for (final r in _catalogCache) {
      final id = r.id;
      if (id == null || id.isEmpty) continue;
      if (_recipeIngredientsCache.containsKey(id)) continue;

      if (r.ingredientsRecipe != null && r.ingredientsRecipe!.isNotEmpty) {
        _recipeIngredientsCache[id] = r.ingredientsRecipe!;
        continue;
      }

      // Revisar caché persistente Hive
      try {
        final cached = _localStorageService.get('cacheBox', 'ing_$id');
        if (cached is List) {
          final parsed = cached
              .whereType<Map>()
              .map((m) => Ingredients.fromJson(Map<String, dynamic>.from(m)))
              .toList();
          if (parsed.isNotEmpty) {
            _recipeIngredientsCache[id] = parsed;
            continue;
          }
        }
      } catch (_) {}

      missingRecipes.add(r);
    }

    // Descargar ingredientes faltantes en lotes paralelos de 6
    const int batchSize = 6;
    for (int i = 0; i < missingRecipes.length; i += batchSize) {
      final end = (i + batchSize < missingRecipes.length)
          ? i + batchSize
          : missingRecipes.length;
      final chunk = missingRecipes.sublist(i, end);

      await Future.wait(
        chunk.map((recipe) async {
          final id = recipe.id!;
          try {
            final data = await recetasAPI.getIngredientsUtensils(id, token);
            if (data['ingredientsRecipe'] is List) {
              final ings = (data['ingredientsRecipe'] as List)
                  .whereType<Map>()
                  .map((item) =>
                      Ingredients.fromJson(Map<String, dynamic>.from(item)))
                  .toList();
              _recipeIngredientsCache[id] = ings;
              try {
                await _localStorageService.put(
                  'cacheBox',
                  'ing_$id',
                  ings.map((e) => e.toJson()).toList(),
                );
              } catch (_) {}
            } else {
              _recipeIngredientsCache[id] = [];
            }
          } catch (_) {
            _recipeIngredientsCache[id] = [];
          }
        }),
      );
    }

    return _catalogCache.map((r) {
      final cachedIngs =
          r.id != null ? (_recipeIngredientsCache[r.id!] ?? r.ingredientsRecipe) : r.ingredientsRecipe;
      return RecipesModel(
        id: r.id,
        nameRecipe: r.nameRecipe,
        descriptionRecipe: r.descriptionRecipe,
        ingredientsRecipe: cachedIngs,
        imageUrl: r.imageUrl,
        price: r.price,
        level: r.level,
        category: r.category,
        createdBy: r.createdBy,
        utensilRecipe: r.utensilRecipe,
        steps: r.steps,
      );
    }).toList();
  }

  /// Búsqueda principal del Home: soporta lista de tags de ingredientes,
  /// búsqueda simple por nombre/ingrediente y fallback automático si Koyeb aún no
  /// tiene el endpoint nuevo.
  Future<void> searchHomeRecipes({
    String? query,
    String? category,
    String? level,
  }) async {
    final effectiveToken = _localStorageService.token;
    if (effectiveToken == null) return;

    final trimmedQuery = query?.trim() ?? '';

    // ─── CASO 1: Hay tags de ingredientes activos en el slider ───
    if (_ingredientTags.isNotEmpty) {
      _isSearchingIngredients = true;
      notifyListeners();

      try {
        final searchTerms = <String>[
          ..._ingredientTags,
          if (trimmedQuery.isNotEmpty) trimmedQuery,
        ];

        try {
          final res = await recetasAPI.searchRecipesByIngredients(
            ingredients: searchTerms,
            category: category,
            level: level,
            excludeStaplesFromMissing: true,
            limit: 60,
            token: effectiveToken,
          );
          final backendRecipes = (res['recipes'] as List<RecipesModel>?) ?? [];
          // Cachear ingredientes si vinieron en la respuesta
          for (final r in backendRecipes) {
            if (r.id != null &&
                r.ingredientsRecipe != null &&
                r.ingredientsRecipe!.isNotEmpty) {
              _recipeIngredientsCache[r.id!] = r.ingredientsRecipe!;
            }
          }
          recipeListFilter = backendRecipes;
          return;
        } catch (e) {
          // Fallback automático si Koyeb aún retorna 404/no tiene el endpoint
          debugPrint('Usando búsqueda híbrida de ingredientes en cliente: $e');
          final hydrated = await _hydrateCatalogWithIngredients(effectiveToken);
          recipeListFilter = IngredientMatcher.scoreAndRankByTags(
            recipes: hydrated,
            tags: _ingredientTags,
            extraTextQuery: trimmedQuery.isNotEmpty ? trimmedQuery : null,
            category: category,
            level: level,
          );
        }
      } finally {
        _isSearchingIngredients = false;
        notifyListeners();
      }
      return;
    }

    // ─── CASO 2: Sin tags, pero el usuario escribió texto en el buscador ───
    if (trimmedQuery.isNotEmpty) {
      _isSearchingIngredients = true;
      notifyListeners();

      try {
        List<RecipesModel> backendMatches = [];
        try {
          backendMatches = await recetasAPI.getRecipesFilter(
            trimmedQuery,
            category,
            level,
            null,
            effectiveToken,
          );
        } catch (_) {}

        try {
          final hydrated = await _hydrateCatalogWithIngredients(effectiveToken);
          final localMatches = hydrated.where((r) {
            if (category != null &&
                category.isNotEmpty &&
                r.category.toLowerCase() != category.toLowerCase()) {
              return false;
            }
            if (level != null &&
                level.isNotEmpty &&
                r.level.toLowerCase() != level.toLowerCase()) {
              return false;
            }
            return IngredientMatcher.matchesSingleTextQuery(r, trimmedQuery);
          }).toList();

          final seen = <String>{};
          final merged = <RecipesModel>[];
          for (final r in [...backendMatches, ...localMatches]) {
            final key = r.id ?? r.nameRecipe;
            if (seen.add(key)) merged.add(r);
          }
          recipeListFilter = merged;
        } catch (_) {
          recipeListFilter = backendMatches;
        }
      } finally {
        _isSearchingIngredients = false;
        notifyListeners();
      }
      return;
    }

    // ─── CASO 3: Catálogo estándar (sin tags ni texto) ───
    final List<RecipesModel> recetas = await recetasAPI.getRecipesFilter(
      null,
      category,
      level,
      null,
      effectiveToken,
    );
    recipeListFilter = recetas;
    notifyListeners();
  }

void clearListRecipe() {
    recipeListFilter.clear();
    notifyListeners();
  }

  void _invalidateRecipeCache([String? recipeId]) {
    _catalogCache.clear();
    if (recipeId != null) {
      _recipeIngredientsCache.remove(recipeId);
      try {
        _localStorageService.delete('cacheBox', 'ing_$recipeId');
      } catch (_) {}
    } else {
      _recipeIngredientsCache.clear();
    }
  }

  Future<bool> createRecipes(RecipesModel recipe) async {
    final effectiveToken = _localStorageService.token;
    if (effectiveToken == null) return false;

    try {
      // Subir la imagen a S3 únicamente en el momento de guardar la receta en la BD
      if (_selectedImage != null && _uploadedImageUrl == null) {
        await uploadImage();
      }

      final recipeToSave = RecipesModel(
        id: _editingRecipeId ?? recipe.id,
        nameRecipe: recipe.nameRecipe,
        descriptionRecipe: recipe.descriptionRecipe,
        ingredientsRecipe: recipe.ingredientsRecipe,
        utensilRecipe: recipe.utensilRecipe,
        category: recipe.category,
        level: recipe.level,
        imageUrl: _uploadedImageUrl ?? recipe.imageUrl,
        createdBy: recipe.createdBy,
        price: recipe.price,
        steps: recipe.steps,
      );

      if (isEditingRecipe) {
        final updated = await recetasAPI.updateRecipe(
          _editingRecipeId!,
          recipeToSave.toJson(),
        );
        if (updated != null) {
          recipeCreatedRes = updated;
          _invalidateRecipeCache(_editingRecipeId);
          await getRecipeFilter(null, null, null, null);
          notifyListeners();
          return true;
        }
        return false;
      }

      final recipeCreatedResponse =
          await recetasAPI.createRecipe(recipeToSave, effectiveToken);

      recipeCreatedRes = recipeCreatedResponse;
      if (recipeCreatedRes != null) {
        _invalidateRecipeCache();
        await getRecipeFilter(null, null, null, null);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Error en createRecipes: $e');
      return false;
    }
  }

  // Método para seleccionar imagen (se subirá a S3 al guardar la receta)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = pickedFile;
      _uploadedImageUrl = null;
      _uploadedOriginalFileName = pickedFile.name;
      notifyListeners();
    }
  }

  // Método para seleccionar imagen para análisis
  Future<void> pickAnalysisImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _analysisImage = pickedFile;
      notifyListeners();
    }
  }

  // Método para subir la imagen a s3
  Future<void> uploadImage() async {
  if (_selectedImage == null) return;

  try {
    // Llamar al servicio para subir la imagen y obtener la respuesta
    UploadImageResponse? imageResponse = await recetasAPI.uploadImage(_selectedImage!);

    // Guardar la URL de la imagen si la respuesta no es nula
    if (imageResponse != null) {
      _uploadedImageUrl = imageResponse.imageUrl;  // Asignar la URL desde el modelo
       _uploadedOriginalFileName = imageResponse.originalFileName;
      // También podrías utilizar imageResponse.originalFileName si lo necesitas
      notifyListeners();
    } else {
      throw Exception('Image upload failed');
    }
  } catch (e) {
    print('Error uploading image: $e');
    throw Exception('Failed to upload image');
  }
}

  // Método para agregar un nuevo paso
  void addStep(String description, String time, int timeScreen) {
    _steps.add({
      'description': description,
      'time': time,
      'timeScreen':timeScreen,
    });
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

   void addIngredient(String description, String amount) {
    _selectedIngredient.add({
      'description': description,
      'amount': amount
    });
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

   void addUtensil(String utensil ) {
     _selectedUtensil.add({
      'utensil': utensil,

    });
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  // Método para resetear la lista de pasos
  void clearSteps() {
    _steps.clear();
    notifyListeners();
  }

  static const List<String> _validCategories = [
    'Entrada',
    'Aperitivo',
    'Plato Fuerte',
    'Postre',
    'Sopa',
    'Ensalada',
    'Guarnicion',
    'Salsa',
    'Italiana',
    'Principal',
  ];

  static const List<String> _validLevels = [
    'Basico',
    'Intermedio',
    'Avanzado',
  ];

  int _parseTimeToMilliseconds(String timeString, dynamic rawTimeScreen) {
    final RegExp regExp = RegExp(r'(\d+)\s*([hms])', caseSensitive: false);
    int totalMilliseconds = 0;

    for (final match in regExp.allMatches(timeString)) {
      final int value = int.tryParse(match.group(1) ?? '0') ?? 0;
      final String unit = (match.group(2) ?? 'm').toLowerCase();

      switch (unit) {
        case 'h':
          totalMilliseconds += value * 60 * 60 * 1000;
          break;
        case 'm':
          totalMilliseconds += value * 60 * 1000;
          break;
        case 's':
          totalMilliseconds += value * 1000;
          break;
      }
    }

    if (totalMilliseconds > 0) {
      return totalMilliseconds;
    }

    final parsedRaw = rawTimeScreen is int
        ? rawTimeScreen
        : int.tryParse(rawTimeScreen?.toString() ?? '0') ?? 0;
    // Si viene en minutos pequeños (ej. 10 en lugar de 600000 ms), convertir a ms
    if (parsedRaw > 0 && parsedRaw < 1000) {
      return parsedRaw * 60 * 1000;
    }
    return parsedRaw > 0 ? parsedRaw : 60000;
  }

  void _applyAiAnalysisResult(Map<String, dynamic> analysis) {
    _selectedNameRecipe = analysis['nameRecipe']?.toString().trim();
    final rawDesc = analysis['descriptionRecipe']?.toString().trim() ?? '';
    _selectedDescriptionRecipe =
        rawDesc.length > 200 ? rawDesc.substring(0, 200) : rawDesc;

    final rawPrice = analysis['price'];
    if (rawPrice is num) {
      _selectedPrice = rawPrice.toInt();
    } else if (rawPrice != null) {
      _selectedPrice = num.tryParse(rawPrice.toString())?.toInt() ?? 0;
    } else {
      _selectedPrice = 0;
    }

    final rawLevel = (analysis['level']?.toString().trim() ?? '')
        .replaceAll('á', 'a')
        .replaceAll('Á', 'A');
    _selectedLevel = _validLevels.firstWhere(
      (l) => l.toLowerCase() == rawLevel.toLowerCase(),
      orElse: () => 'Basico',
    );

    final rawCategory = (analysis['category']?.toString().trim() ?? '')
        .replaceAll('ó', 'o')
        .replaceAll('Ó', 'O');
    _selectedCategory = _validCategories.firstWhere(
      (c) => c.toLowerCase() == rawCategory.toLowerCase(),
      orElse: () => 'Plato Fuerte',
    );

    // Autocompletar ingredientes
    clearIngredients();
    if (analysis['ingredientsRecipe'] is List) {
      for (var item in analysis['ingredientsRecipe']) {
        if (item is Map) {
          final desc = item['description']?.toString().trim() ?? '';
          final amt = item['amount']?.toString().trim() ?? '';
          if (desc.isNotEmpty) {
            addIngredient(desc, amt.isNotEmpty ? amt : 'Al gusto');
          }
        }
      }
    }

    // Autocompletar utensilios
    clearUtensils();
    if (analysis['utensilRecipe'] is List) {
      for (var item in analysis['utensilRecipe']) {
        if (item is Map) {
          final ut = item['utensil']?.toString().trim() ?? '';
          if (ut.isNotEmpty) addUtensil(ut);
        } else if (item is String && item.trim().isNotEmpty) {
          addUtensil(item.trim());
        }
      }
    }

    // Autocompletar pasos
    clearSteps();
    if (analysis['steps'] is List) {
      for (var item in analysis['steps']) {
        if (item is Map) {
          final stepDesc = item['description']?.toString().trim() ?? '';
          if (stepDesc.isEmpty) continue;
          final timeStr = item['time']?.toString().trim() ?? '5m';
          final timeScreenMs =
              _parseTimeToMilliseconds(timeStr, item['timeScreen']);
          addStep(
            stepDesc,
            timeStr,
            timeScreenMs,
          );
        }
      }
    }

    notifyListeners();
  }

  Future<bool> analyzeRecipeImage() async {
    if (_analysisImage == null) return false;
    final token = _localStorageService.token;
    if (token == null) return false;

    try {
      final analysis = await recetasAPI.analyzeImage(_analysisImage!, token);
      if (analysis != null) {
        _applyAiAnalysisResult(analysis);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en analyzeRecipeImage: $e');
      return false;
    }
  }

  Future<bool> analyzeRecipeText(String rawText) async {
    if (rawText.trim().isEmpty) return false;
    final token = _localStorageService.token;
    if (token == null) return false;

    try {
      final analysis =
          await recetasAPI.analyzeRecipeText(rawText.trim(), token);
      if (analysis != null) {
        _applyAiAnalysisResult(analysis);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en analyzeRecipeText: $e');
      return false;
    }
  }

  Future<void> getIngredientsUtensils(String recipeId) async {
    _isLoadingIngredients = true;
    notifyListeners();

    final token = _localStorageService.token;
    if (token == null) {
      _isLoadingIngredients = false;
      notifyListeners();
      return;
    }

    try {
      final data = await recetasAPI.getIngredientsUtensils(recipeId, token);
      
      if (data['ingredientsRecipe'] != null) {
        _ingredientsList = (data['ingredientsRecipe'] as List)
            .map((item) => Ingredients.fromJson(item))
            .toList();
      }
      
      if (data['utensilRecipe'] != null) {
        _utensilsList = (data['utensilRecipe'] as List)
            .map((item) => Utensils.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error al cargar ingredientes/utensilios: $e');
    } finally {
      _isLoadingIngredients = false;
      notifyListeners();
    }
  }
}
