class Utensils {
  final String utensil;
  final String? id;

  Utensils ({
    required this.utensil,
    this.id,
  });

factory Utensils .fromJson(Map<String, dynamic> json) {
  return Utensils (
    utensil: json['utensil'] ?? 'No utensil provided', // Valor por defecto si no existe
    id: json['_id'] ?? 'No id provided',
  );
}

 Map<String, dynamic> toJson() {
    return {
      'utensil': utensil,
    };
  }
}