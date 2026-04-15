import 'package:flutter/material.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';
import 'package:resetas/src/features/auth/data/auth_api_service.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:resetas/src/features/auth/models/login_request_model.dart';

class AuthProvider extends ChangeNotifier {
  AccessToken? _accessToken;
  UserResModel? _user;

  final AuthApiService _authApiService = AuthApiService();

  AccessToken? get accessToken => _accessToken;
  UserResModel? get user => _user;

  bool get isAuthenticated => _accessToken != null;

  Future<void> checkAuthStatus() async {
    var box = await Hive.openBox('authBox');
    final token = box.get('access_token');
    if (token != null) {
      _accessToken = AccessToken(accessToken: token);
      final userId = box.get('userId');
      final username = box.get('username');
      final email = box.get('email');
      final role = box.get('role');

      _user = UserResModel(
        id: userId ?? '',
        username: username ?? '',
        lastname: '',
        email: email ?? '',
        phone: '',
        country: '',
        city: '',
        photoUrl: '',
        role: role ?? 'user',
        myFavorite: [],
        myRecipe: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<bool> login(LoginRequestModel loginRequestModel) async {
    try {
      final success = await _authApiService.login(loginRequestModel);
      return success;
    } catch (e) {
      throw ('Error durante el login: $e');
    }
  }

  Future<bool> register(User user) async {
    try {
      if (user.role == 'chef') {
        user.role = 'admin';
      }

      final authResponse = await _authApiService.register(user);
      _accessToken = authResponse.accessToken;
      _user = authResponse.userResModel;
      if (_accessToken != null) {
        await _saveAuthDataToHive(_accessToken!.accessToken, _user!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String code) async {
    try {
      final data = await _authApiService.verifyOtp(email, code);
      if (data != null) {
        // Mapear la respuesta flat al modelo UserResModel
        final userResModel = UserResModel(
          id: data['userId'] ?? '',
          username: data['username'] ?? '',
          lastname: '', // No viene en el verify flat
          email: data['email'] ?? '',
          phone: '', 
          country: '', 
          city: '', 
          photoUrl: '', 
          role: data['role'] ?? 'user',
          myFavorite: [],
          myRecipe: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final token = data['access_token'] ?? '';
        _accessToken = AccessToken(accessToken: token);
        _user = userResModel;

        await _saveAuthDataToHive(token, userResModel);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAuthDataToHive(String token, UserResModel user) async {
    var box = await Hive.openBox('authBox');
    await box.put('access_token', token);
    await box.put('userId', user.id);
    await box.put('username', user.username);
    await box.put('email', user.email);
    await box.put('role', user.role);
  }

  Future<bool> resendOtp(String email) async {
    try {
      final success = await _authApiService.resendOtp(email);
      return success;
    } catch (e) {
      return false;
    }
  }

  void logout() async {
      if (_accessToken != null) {
        await _authApiService.logout(_accessToken!.accessToken);
        }
      _accessToken = null;
      _user = null;
      var box = await Hive.openBox('authBox');
      await box.clear();
      notifyListeners();
    
  }
}
