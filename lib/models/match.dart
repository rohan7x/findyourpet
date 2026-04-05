class Pet {
  final String id;
  final String name;
  final String type;
  final String description;

  Pet({required this.id, required this.name, required this.type, required this.description});

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class MatchModel {
  final String id;
  final Pet lostPet;
  final Pet foundPet;
  final int score;

  MatchModel({required this.id, required this.lostPet, required this.foundPet, required this.score});

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['_id'],
      lostPet: Pet.fromJson(json['lostPet']),
      foundPet: Pet.fromJson(json['foundPet']),
      score: json['score'] ?? 0,
    );
  }
}
