class BookRecipe {
  final String nameRecipe;
  final String? idRecipe;
  final String? id;

  BookRecipe({
    required this.nameRecipe,
    required this.idRecipe,
    this.id,
  });

factory BookRecipe.fromJson(Map<String, dynamic> json) {
  return BookRecipe(
    nameRecipe: json['nameRecipe'] ?? 'No nameRecipe provided', // Valor por defecto si no existe
    idRecipe: json['idRecipe'] ?? 'No idRecipe provided', // Valor por defecto si no existe
    id: json['_id'] ?? 'No id provided',
  );
}

 Map<String, dynamic> toJson() {
    return {
      'idRecipe': idRecipe,
      'nameRecipe': nameRecipe,
    };
  }
}