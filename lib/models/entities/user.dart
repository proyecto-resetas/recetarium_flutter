class User {
  final String? userName;
  final String? lastName;
  final String email;
  final String password;
  final String? phone;
  final String? country;
  final String? city;
  final String? photoUrl;
  final String? role;

  User({
  this.userName,
  this.lastName,
  required this.email,
  required this.password,
  this.phone,
  this.country,
  this.city,
  this.photoUrl,
  this.role
  });

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'lastname': lastName,
      'phone': phone,
      'country': country,
      'city': city,
      'email': email,
      'photo_url': photoUrl,
      'role': role,
      'password': password,
    };
  }

}