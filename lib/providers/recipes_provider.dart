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
  String? _uploadedImageUrl;
  File? _selectedImage;
  RecipesModel? recipeCreatedRes;
  RecipesModel? recetas; 
  List<Map<String, dynamic>> _steps = [];
  final _favorites = [];


  List<Map<String, dynamic>> get steps => _steps;
  RecipesModel? get getRecetas => recetas;
  File? get selectedImage => _selectedImage;
  String? get uploadedImageUrl => _uploadedImageUrl;
  String? get uploadedOriginalFileName => _uploadedOriginalFileName;
  get setFavorite => _favorites.iterator;
  
 List<RecipesModel> recipeList = [];
  // void toggleFavorite() {
  //   if (favorites.contains()) {
  //     favorites.remove();
  //   } else {
  //     favorites.add();
  //   }
  //   notifyListeners();
  // }



  ViewRecipesProvider() {
    getResetas();
  }

 Future<void> getResetas() async {
  
  final List<RecipesModel> recetas = await recetasAPI.getResetas(); 
  recipeList.addAll(recetas); // agregar todos los elementos de la lista
  notifyListeners();
}

  Future<bool> createRecipes(RecipesModel recipe) async {

   // print('${recipe.category}, ${recipe.createdBy}, ${recipe.descriptionRecipe}, ${recipe.imageUrl}, ${recipe.nameRecipe}, ${recipe.steps[0]}, ${recipe.price}');
    try {
      final recipeCreatedResponse = await recetasAPI.createRecipe(recipe);

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

  // Método para resetear la lista de pasos
  void clearSteps() {
    _steps.clear();
    notifyListeners();
  }

} 