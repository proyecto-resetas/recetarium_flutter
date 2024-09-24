  
import 'package:flutter/material.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/entities/token.dart';
import 'package:resetas/models/entities/user.dart';

class AuthProvider extends ChangeNotifier {

  AccessToken? _accessToken; 
  final RecetasAPI _recetasAPI = RecetasAPI();

  AccessToken? get accessToken => _accessToken;

    Future<bool> login(User user) async {
    try {
      _accessToken = await _recetasAPI.login(user);
      if (_accessToken != null) {
        notifyListeners();
        return true; // Login exitoso
      }
      return false; // Falló la autenticación
    } catch (e) {
    //  print('Error durante el login: $e');
      return false; // Error de autenticación
    }
  }

   // Función de register modificada para retornar un AccessToken
  Future<bool> register(User user) async {
    try {
      _accessToken = await _recetasAPI.register(user);
      if (_accessToken != null) {
        notifyListeners();
        return true; // Registro exitoso
      }
      return false; // Falló el registro
    } catch (e) {
     //  print('Error durante el registro: $e');
      return false; // Error en el registro
    }
  }

  // Puedes agregar una función para cerrar sesión si es necesario
  void logout() {
    _accessToken = null;
    notifyListeners();
  }



}



  
