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
      final recipeCreatedResponse = await recetasAPI.createRecipe(recipe, effectiveToken);

      recipeCreatedRes = recipeCreatedResponse;
      if(recipeCreatedRes != null){
           notifyListeners();
           return true; 
      }
     
      return false; 
    } catch (e) {
      return false; 
    }
  }

  // Método para seleccionar imagen
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = pickedFile;
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

  Future<bool> analyzeRecipeImage() async {
    if (_analysisImage == null) return false;
    final token = _localStorageService.token;
    if (token == null) return false;

    try {
      final analysis = await recetasAPI.analyzeImage(_analysisImage!, token);
      if (analysis != null) {
        _selectedNameRecipe = analysis['nameRecipe'];
        _selectedDescriptionRecipe = analysis['descriptionRecipe'];
        _selectedPrice = analysis['price'];
        _selectedLevel = analysis['level'];
        _selectedCategory = analysis['category'];

        // Autocompletar ingredientes
        clearIngredients();
        if (analysis['ingredientsRecipe'] != null) {
          for (var item in analysis['ingredientsRecipe']) {
            addIngredient(item['description'] ?? '', item['amount'] ?? '');
          }
        }

        // Autocompletar utensilios
        clearUtensils();
        if (analysis['utensilRecipe'] != null) {
          for (var item in analysis['utensilRecipe']) {
            addUtensil(item['utensil'] ?? '');
          }
        }

        // Autocompletar pasos
        clearSteps();
        if (analysis['steps'] != null) {
          for (var item in analysis['steps']) {
            addStep(item['description'] ?? '', item['time'] ?? '', item['timeScreen'] ?? 0);
          }
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en analyzeRecipeImage: $e');
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
