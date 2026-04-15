class User {
  final String? userName;
  final String? lastName;
  final String email;
  final String password;
  final String? countryCode;
  final String? phoneNumber;
  final String? country;
  final String? city;
  final String? photoUrl;
  final myFavorite;
  final myRecipe;
  late String? role;

  User({
    this.userName,
    this.lastName,
    required this.email,
    required this.password,
    this.countryCode,
    this.phoneNumber,
    this.country,
    this.city,
    this.photoUrl,
    this.role,
    this.myFavorite,
    this.myRecipe,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'lastname': lastName,
      'phone': {
        'countryCode': countryCode ?? '+57',
        'phoneNumber': phoneNumber ?? '',
      },
      'country': country,
      'city': city,
      'email': email,
      'role': role,
      'password': password,
    };
  }
}
