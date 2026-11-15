import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetarium/src/core/api/auth_interceptor.dart';
import 'package:recetarium/src/features/user_profile/models/user.dart';
import 'package:recetarium/src/features/auth/models/token_model.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';
import 'package:recetarium/src/features/auth/data/auth_api_service.dart';
import 'package:recetarium/src/features/auth/models/login_request_model.dart';
import 'package:recetarium/src/core/services/local_storage_service.dart';
import 'package:recetarium/src/features/recipes/data/recipes_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AccessToken? _accessToken;
  UserResModel? _user;

  final AuthApiService _authApiService = AuthApiService();
  final RecipesApiService _recipesApiService = RecipesApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final TokenRefreshManager _tokenRefreshManager = TokenRefreshManager();

  AuthProvider() {
    _tokenRefreshManager.onTokenRefreshed = (newToken) {
      _accessToken = AccessToken(accessToken: newToken);
    };
    _tokenRefreshManager.onSessionExpired = () {
      logout(callRemoteLogout: false);
    };
  }

  AccessToken? get accessToken => _accessToken;
  UserResModel? get user => _user;

  bool get isAuthenticated => _accessToken != null;

  bool hasPermission(String permission) {
    return _user?.hasPermission(permission) ?? false;
  }

  Future<void> checkAuthStatus() async {
    final token = _localStorageService.token;
    final userData = _localStorageService.userData;
    if (token != null && token.isNotEmpty && userData != null) {
      if (JwtUtils.isTokenExpired(token)) {
        final refreshed = await tryRefreshToken();
        if (!refreshed) {
          logout(callRemoteLogout: false);
          return;
        }
      } else {
        _accessToken = AccessToken(accessToken: token);
      }

      _user = UserResModel.fromJsonModel(userData);
      notifyListeners();
      await refreshUserProfile();
    }
  }

  /// Intenta renovar el `access_token` silenciosamente usando el `refresh_token`.
  Future<bool> tryRefreshToken() async {
    final newToken = await _tokenRefreshManager.refreshAccessToken();
    if (newToken != null && newToken.isNotEmpty) {
      _accessToken = AccessToken(accessToken: newToken);
      return true;
    }
    return false;
  }

  /// Verifica al volver a primer plano si el token caducó y lo renueva o cierra sesión.
  Future<void> validateSessionOnResume() async {
    final token = _accessToken?.accessToken ?? _localStorageService.token;
    if (token == null || token.isEmpty) return;
    if (JwtUtils.isTokenExpired(token)) {
      final refreshed = await tryRefreshToken();
      if (!refreshed) {
        logout(callRemoteLogout: false);
      }
    }
  }

  Future<void> refreshUserProfile() async {
    final token = _accessToken?.accessToken;
    final userId = _user?.id;
    if (token == null || userId == null || userId.isEmpty) return;

    try {
      final results = await Future.wait([
        _authApiService.getUserProfile(userId, token),
        _authApiService.getMyPermissions(token),
      ]);
      final profileJson = results[0] as Map<String, dynamic>?;
      final perms = results[1] as List<String>?;

      if (profileJson != null) {
        profileJson['permissions'] = perms ?? _user?.permissions ?? const [];
        _user = UserResModel.fromJsonModel(profileJson);
        final latestToken = _accessToken?.accessToken ?? token;
        await _saveAuthDataToHive(latestToken, _user!);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateProfile(
    Map<String, dynamic> payload, {
    XFile? newPhoto,
  }) async {
    final token = _accessToken?.accessToken;
    final userId = _user?.id;
    if (token == null || userId == null || userId.isEmpty) return false;

    try {
      final data = Map<String, dynamic>.from(payload);
      if (newPhoto != null) {
        final uploaded = await _recipesApiService.uploadImage(newPhoto);
        if (uploaded != null && uploaded.imageUrl.isNotEmpty) {
          data['photoUrl'] = uploaded.imageUrl;
        }
      }

      final updatedJson = await _authApiService.updateUserProfile(
        userId,
        data,
        token,
      );
      if (updatedJson != null) {
        updatedJson['permissions'] = _user?.permissions ?? const [];
        _user = UserResModel.fromJsonModel(updatedJson);
        final latestToken = _accessToken?.accessToken ?? token;
        await _saveAuthDataToHive(latestToken, _user!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(LoginRequestModel loginRequestModel) async {
    try {
      final success = await _authApiService.login(loginRequestModel);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      if (user.role == 'chef') {
        user.role = 'admin';
      }

      final success = await _authApiService.register(user);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String code) async {
    try {
      final data = await _authApiService.verifyOtp(email, code);
      if (data != null) {
        final userResModel = UserResModel(
          id: data['userId'] ?? '',
          username: data['username'] ?? '',
          lastname: '',
          email: data['email'] ?? '',
          phone: '',
          country: '',
          city: '',
          photoUrl: '',
          role: data['role'] ?? 'user',
          permissions: data['permissions'] is List
              ? (data['permissions'] as List).map((e) => e.toString()).toList()
              : const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final token = data['access_token'] ?? '';
        final refreshToken = data['refresh_token'] as String?;
        _accessToken = AccessToken(accessToken: token);
        _user = userResModel;

        await _saveAuthDataToHive(
          token,
          userResModel,
          refreshToken: refreshToken,
        );
        await refreshUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      return await _authApiService.forgotPassword(email);
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyRecoveryOtp(String email, String code) async {
    try {
      final data = await _authApiService.verifyOtp(email.trim(), code.trim());
      return data != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      return await _authApiService.resetPassword(
        email: email,
        newPassword: newPassword,
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAuthDataToHive(
    String token,
    UserResModel user, {
    String? refreshToken,
  }) async {
    await _localStorageService.saveAuthData(
      token: token,
      userData: user.toJson(),
      refreshToken: refreshToken,
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

  Future<void> logout({bool callRemoteLogout = true}) async {
    final currentToken = _accessToken?.accessToken;
    _accessToken = null;
    _user = null;
    await _localStorageService.clearAuthData();
    notifyListeners();

    if (callRemoteLogout && currentToken != null && currentToken.isNotEmpty) {
      await _authApiService.logout(currentToken);
    }
  }
}
