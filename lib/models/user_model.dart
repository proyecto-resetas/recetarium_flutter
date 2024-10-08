class UserResModel {
  final String id;
  final String username;
  final String lastname;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserResModel({
    required this.id,
    required this.username,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResModel.fromJsonModel(Map<String, dynamic> json) {
    return UserResModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      photoUrl: json['photoUrl'] as String? ?? '', // Manejo de valor null
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

