import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/image_s3_model.dart';
import 'package:resetas/models/recipes_model.dart';

class ViewRecipesProvider extends ChangeNotifier {

  final ScrollController recipeScrollController = ScrollController();
  final RecetasAPI recetasAPI = RecetasAPI();
  String? _uploadedOriginalFileName;
  String? _selectedNameRecipe;
  String? _selectedDescriptionRecipe;
  int? _selectedPrice;
  String? _uploadedImageUrl;
  File? _selectedImage;
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedIngredient;
  String? _selectedUtencilio;

  RecipesModel? recipeCreatedRes;
  RecipesModel? recetas; 

  List<RecipesModel> recipeList = [];
  List<RecipesModel> recipeListFilter = [];
  List<Map<String, dynamic>> _steps = [];
  final _favorites = [];

  List<Map<String, dynamic>> get steps => _steps;
  RecipesModel? get getRecetas => recetas;
  String? get selectedNameRecipe => _selectedNameRecipe;
  String? get selectedDescriptionRecipe => _selectedDescriptionRecipe;
  int? get selectedPrice => _selectedPrice;
  File? get selectedImage => _selectedImage;
  String? get uploadedImageUrl => _uploadedImageUrl;
  String? get uploadedOriginalFileName => _uploadedOriginalFileName;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLevel => _selectedLevel;
   String? get selectedIngredient => _selectedIngredient;
  String? get selectedUtencilio => _selectedUtencilio;
  get setFavorite => _favorites.iterator;

  ViewRecipesProvider() {
    getRecipeFilter('','','');
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
    clearSteps();
   // _steps.clear;
    notifyListeners();
  }



 Future<void> getRecipe() async {
  
  final List<RecipesModel> recetas = await recetasAPI.getRecipe(); 
  recipeList.addAll(recetas); // agregar todos los elementos de la lista
  notifyListeners();
}

Future<void> getRecipeFilter(String? category, String? level, String? createdBy) async{

  final List<RecipesModel> recetas = await recetasAPI.getRecipesFilter(category, level, createdBy); 
  recipeListFilter.addAll(recetas); // agregar todos los elementos de la lista
  print(recetas);
  notifyListeners();

}

void clearListRecipe() {
    recipeListFilter.clear();
    notifyListeners();
  }

  Future<bool> createRecipes(RecipesModel recipe, token) async {

    print('provider,${recipe.category}, ${recipe.createdBy}, ${recipe.descriptionRecipe}, ${recipe.imageUrl}, ${recipe.nameRecipe}, ${recipe.steps[0]}, ${recipe.price}, ${recipe.ingredientsRecipe}');
    try {
      final recipeCreatedResponse = await recetasAPI.createRecipe(recipe, token);

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
      _selectedImage = File(pickedFile.path);
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
    _selectedIngredient = '$description $amount';
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

   void addUtencilio(String utencilio, ) {
    _selectedUtencilio = utencilio;
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  // Método para resetear la lista de pasos
  void clearSteps() {
    _steps.clear();
    notifyListeners();
  }

} 