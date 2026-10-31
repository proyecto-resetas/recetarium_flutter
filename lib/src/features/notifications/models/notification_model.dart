class NotificationModel {
  final String id;
  final String recipientId;
  final String? senderId;
  final String? senderUsername;
  final String type;
  final String title;
  final String message;
  final String? recipeId;
  final String? recipeName;
  final String? recipeImage;
  final num? amount;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    this.senderUsername,
    required this.type,
    required this.title,
    required this.message,
    this.recipeId,
    this.recipeName,
    this.recipeImage,
    this.amount,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      recipientId: (json['recipientId'] ?? '').toString(),
      senderId: json['senderId']?.toString(),
      senderUsername: json['senderUsername']?.toString(),
      type: (json['type'] ?? 'system').toString(),
      title: (json['title'] ?? 'Notificación').toString(),
      message: (json['message'] ?? '').toString(),
      recipeId: json['recipeId']?.toString(),
      recipeName: json['recipeName']?.toString(),
      recipeImage: json['recipeImage']?.toString(),
      amount: json['amount'] is num
          ? json['amount'] as num
          : num.tryParse(json['amount']?.toString() ?? ''),
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    bool? read,
  }) {
    return NotificationModel(
      id: id,
      recipientId: recipientId,
      senderId: senderId,
      senderUsername: senderUsername,
      type: type,
      title: title,
      message: message,
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImage: recipeImage,
      amount: amount,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
