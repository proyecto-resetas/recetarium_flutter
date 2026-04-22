import 'package:flutter/material.dart';
import 'package:resetas/src/features/user_profile/models/user.dart';
import 'package:resetas/src/features/auth/models/token_model.dart';
import 'package:resetas/src/features/user_profile/models/user_model.dart';
import 'package:resetas/src/features/auth/data/auth_api_service.dart';
import 'package:resetas/src/features/auth/models/login_request_model.dart';
import 'package:resetas/src/core/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AccessToken? _accessToken;
  UserResModel? _user;

  final AuthApiService _authApiService = AuthApiService();
  final LocalStorageService _localStorageService = LocalStorageService();

  AccessToken? get accessToken => _accessToken;
  UserResModel? get user => _user;

  bool get isAuthenticated => _accessToken != null;

  Future<void> checkAuthStatus() async {
    final token = _localStorageService.token;
    final userData = _localStorageService.userData;
    if (token != null && userData != null) {
      _accessToken = AccessToken(accessToken: token);
      _user = UserResModel.fromJsonModel(userData);
      notifyListeners();
    }
  }

  Future<bool> login(LoginRequestModel loginRequestModel) async {
    try {
      final success = await _authApiService.login(loginRequestModel);
      return success;
    } catch (e) {
      // Feedback discreto
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      if (user.role == 'chef') {
        user.role = 'admin';
      }

      final success = await _authApiService.register(user);
      if (success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Feedback discreto
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
    await _localStorageService.saveAuthData(
      token: token,
      userData: user.toJson(),
    );
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
    await _localStorageService.clearAuthData();
    notifyListeners();
  }
}
