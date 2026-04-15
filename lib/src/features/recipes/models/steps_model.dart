class Steps {
  final String description;
  final String time;
  final int timeScreen;
  final String? id;

  Steps({
    required this.description,
    required this.time,
    required this.timeScreen,
    this.id,
  });

factory Steps.fromJson(Map<String, dynamic> json) {
  return Steps(
    description: json['description'] ?? 'No description provided', // Valor por defecto si no existe
    time: json['time'] ?? 'No time provided', // Valor por defecto si no existe
    timeScreen: json['timeScreen'] is int
      ? json["timeScreen"]
      : int.tryParse(json["timeScreen"].toString()) ?? 0, // Intenta convertir a entero o asigna un valor por defecto
    id: json['_id'] ?? 'No time provided',
  );
}

 Map<String, dynamic> toJson() {
    return {
      'description': description,
      'time': time,
      'timeScreen': timeScreen,
    };
  }
}