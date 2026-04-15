class Ingredients {
  final String description;
  final String amount;
  final String? id;

  Ingredients({
    required this.description,
    required this.amount,
    this.id,
  });

factory Ingredients.fromJson(Map<String, dynamic> json) {
  return Ingredients(
    description: json['description'] ?? 'No description provided', // Valor por defecto si no existe
    amount: json['amount'] ?? 'No amount provided', // Valor por defecto si no existe
    id: json['_id'] ?? 'No id provided',
  );
}

 Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
    };
  }
}