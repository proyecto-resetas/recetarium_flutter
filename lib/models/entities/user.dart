class User {

  final String? userName;
  final String? lastName;
  final String email;
  final String password;
  final String? phone;
  final String? country;
  final String? city;
  final String? photoUrl;

  User({
  this.userName,
  this.lastName,
  required this.email,
  required this.password,
  this.phone,
  this.country,
  this.city,
  this.photoUrl
  });

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'lastname': lastName,
      'phone': phone,
      'country': country,
      'city': city,
      'email': email,
      'password': password,
    };
  }

}