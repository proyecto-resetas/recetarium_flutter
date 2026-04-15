class AccessToken {
    final String accessToken;

    AccessToken({
        required this.accessToken,
    });

    factory AccessToken.fromJsonModel(Map<String, dynamic> json) => AccessToken(
        accessToken: json["access_token"],
    );

    Map<String, dynamic> toJson() => {
        "access_token": accessToken,
    };


    AccessToken toTokenEntity() => AccessToken(
      accessToken: accessToken,
    );
      
}