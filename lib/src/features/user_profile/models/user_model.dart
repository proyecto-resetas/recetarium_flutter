import 'package:recetarium/src/features/recipes/models/book_recipe_model.dart';

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
  final List<String> permissions;
  final Map<String, dynamic>? bankAccount;
  final Map<String, dynamic>? billingInfo;
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
    this.permissions = const [],
    this.bankAccount,
    this.billingInfo,
    this.myFavorite,
    this.myRecipe,
    required this.createdAt,
    required this.updatedAt,
  });

  bool hasPermission(String requiredPermission) {
    if (role == 'super_admin' || permissions.contains('*')) {
      return true;
    }
    if (permissions.contains(requiredPermission)) {
      return true;
    }
    final parts = requiredPermission.split(':');
    if (parts.isNotEmpty && permissions.contains('${parts[0]}:*')) {
      return true;
    }
    if (parts.length == 3 &&
        parts[2] == 'own' &&
        permissions.contains('${parts[0]}:${parts[1]}')) {
      return true;
    }
    return false;
  }

  factory UserResModel.fromJsonModel(Map<String, dynamic> json) {
    String parsedPhone = '';
    if (json['phone'] is Map) {
      final cc = (json['phone']['countryCode'] ?? '').toString().trim();
      final num = (json['phone']['phoneNumber'] ?? '').toString().trim();
      parsedPhone = [cc, num].where((s) => s.isNotEmpty).join(' ');
    } else if (json['phone'] is String) {
      parsedPhone = json['phone'] as String;
    }

    return UserResModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: parsedPhone,
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String? ?? '',
      role: json['role'] as String? ?? 'user',
      permissions: json['permissions'] is List
          ? (json['permissions'] as List).map((e) => e.toString()).toList()
          : const [],
      bankAccount: json['bankAccount'] is Map
          ? Map<String, dynamic>.from(json['bankAccount'] as Map)
          : null,
      billingInfo: json['billingInfo'] is Map
          ? Map<String, dynamic>.from(json['billingInfo'] as Map)
          : null,
      myFavorite: json['myFavorite'] is List
          ? (json['myFavorite'] as List)
              .whereType<Map>()
              .map((item) => BookRecipe.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      myRecipe: json['myRecipe'] is List
          ? (json['myRecipe'] as List)
              .whereType<Map>()
              .map((item) => BookRecipe.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
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
      'permissions': permissions,
      if (bankAccount != null) 'bankAccount': bankAccount,
      if (billingInfo != null) 'billingInfo': billingInfo,
      'myFavorite': myFavorite?.map((item) => item.toJson()).toList(),
      'myRecipe': myRecipe?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
