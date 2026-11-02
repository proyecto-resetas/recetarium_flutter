import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';
import 'package:resetas/src/features/recipes/data/recipes_api_service.dart';
import 'package:resetas/src/features/recipes/models/image_s3_model.dart';
import 'package:resetas/src/features/recipes/models/recipes_model.dart';
import 'package:resetas/src/features/recipes/models/ingredients_model.dart';
import 'package:resetas/src/features/recipes/models/utensil_model.dart';

class ViewRecipesProvider extends ChangeNotifier {

  final ScrollController recipeScrollController = ScrollController();
  final RecipesApiService recetasAPI = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  Timer? _debounce;
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

  List<Map<String, dynamic>> get steps => _steps;
  List<Map<String, dynamic>> get selectedIngredient => _selectedIngredient;
  List<Map<String, dynamic>> get selectedUtensil => _selectedUtensil;
  
  List<Ingredients> get ingredientsList => _ingredientsList;
  List<Utensils> get utensilsList => _utensilsList;
  bool get isLoadingIngredients => _isLoadingIngredients;
  RecipesModel? get getRecetas => recetas;
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

Future<void> getRecipeFilter(String? name, String? category, String? level, String? createdBy) async{

  final effectiveToken = _localStorageService.token;
  if (effectiveToken == null) return;
  
  final List<RecipesModel> recetas = await recetasAPI.getRecipesFilter(name, category, level, createdBy, _localStorageService.token); 
  recipeListFilter = recetas; // Reemplazar en lugar de agregar para filtros limpios
  notifyListeners();

}

void progressiveSearch(String query, String? category, String? level) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getRecipeFilter(query, category, level, null);
    });
}

void clearListRecipe() {
    recipeListFilter.clear();
    notifyListeners();
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
        id: recipe.id,
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

      final recipeCreatedResponse =
          await recetasAPI.createRecipe(recipeToSave, effectiveToken);

      recipeCreatedRes = recipeCreatedResponse;
      if (recipeCreatedRes != null) {
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
