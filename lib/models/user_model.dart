
import 'package:resetas/models/entities/token.dart';

class UserResModel {
    final String accessToken;

    UserResModel({
        required this.accessToken,
    });

    factory UserResModel.fromJsonModel(Map<String, dynamic> json) => UserResModel(
        accessToken: json["access_token"],
    );

    Map<String, dynamic> toJson() => {
        "access_token": accessToken,
    };


    AccessToken toTokenEntity() => AccessToken(
      accessToken: accessToken,
    );
      
}