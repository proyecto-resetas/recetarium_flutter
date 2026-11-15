class Ingredients {
  final String description;
  final String amount;
  final String? id;
  final bool isStaple;

  Ingredients({
    required this.description,
    required this.amount,
    this.id,
    this.isStaple = false,
  });

  factory Ingredients.fromJson(Map<String, dynamic> json) {
    return Ingredients(
      description: json['description'] ?? 'No description provided',
      amount: json['amount'] ?? 'No amount provided',
      id: json['_id'],
      isStaple: json['isStaple'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'description': description,
      'amount': amount,
      'isStaple': isStaple,
    };
  }
}