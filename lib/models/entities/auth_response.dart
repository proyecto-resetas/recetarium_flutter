import 'package:resetas/models/token_model.dart';
import 'package:resetas/models/user_model.dart';

class AuthResponse {
  final AccessToken accessToken;
  final UserResModel userResModel;

  AuthResponse({required this.accessToken, required this.userResModel});
}