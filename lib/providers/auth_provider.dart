  
import 'package:flutter/material.dart';
import 'package:resetas/api/get_api_recetas.dart';
import 'package:resetas/models/entities/user.dart';
import 'package:resetas/models/token_model.dart';
import 'package:resetas/models/user_model.dart';

class AuthProvider extends ChangeNotifier {

  AccessToken? _accessToken; 
  UserResModel? _user;
  

  final RecetasAPI _recetasAPI = RecetasAPI();

  AccessToken? get accessToken => _accessToken;
  UserResModel? get user => _user;



  Future<bool> login(User user) async {
    try {
      final authResponse = await _recetasAPI.login(user);
      _accessToken = authResponse.accessToken;
       _user = authResponse.userResModel;

      if (_accessToken != null) {
        notifyListeners();
        return true;
      }
      return false; 
    } catch (e) {
      throw('Error durante el login: $e');
    //  return false; // Error de autenticación
    }
  }

  Future<bool> register(User user) async {
    try {

      if (user.role == 'chef') {
      user.role = 'admin';
    }

      final authResponse = await _recetasAPI.register(user);
      _accessToken = authResponse.accessToken;
      _user = authResponse.userResModel;
      if (_accessToken != null) {
        notifyListeners();
        return true; 
      }
      return false; 
    } catch (e) {
     //  print('Error durante el registro: $e');
      return false; 
    }
  }

  void logout() {
    _accessToken = null;
    notifyListeners();
  }
  

}



  
