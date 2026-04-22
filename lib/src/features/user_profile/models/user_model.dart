import 'package:resetas/src/features/recipes/models/book_recipe_model.dart';

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
  final List<BookRecipe>? myFavorite;
  final List<BookRecipe>? myRecipe;
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
    this.myFavorite,
    this.myRecipe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResModel.fromJsonModel(Map<String, dynamic> json) {
    return UserResModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // Manejar phone como String o Map
      phone: json['phone'] is Map
          ? '${json['phone']['countryCode']} ${json['phone']['phoneNumber']}'
          : json['phone'] as String? ?? '',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String? ?? '',
      role: json['role'] as String? ?? 'user',
      myFavorite: json['myFavorite'] != null
          ? (json['myFavorite'] as List)
              .map((item) => BookRecipe.fromJson(item))
              .toList()
          : [],
      myRecipe: json['myRecipe'] != null
          ? (json['myRecipe'] as List)
              .map((item) => BookRecipe.fromJson(item))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'country': country,
      'city': city,
      'photoUrl': photoUrl,
      'role': role,
      'myFavorite': myFavorite?.map((item) => item.toJson()).toList(),
      'myRecipe': myRecipe?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
