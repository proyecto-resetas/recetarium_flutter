import 'package:recetarium/src/features/auth/models/token_model.dart';
import 'package:recetarium/src/features/user_profile/models/user_model.dart';

class AuthResponse {
  final AccessToken accessToken;
  final UserResModel userResModel;

  AuthResponse({required this.accessToken, required this.userResModel});
}