
// lib/models/pet.dart
class Pet {
  final String id;
  final String name;
  final String type; // 'lost' or 'found'
  final String? breed;
  final String? description;
  final List<String> photoUrls;
  final String? ownerName;
  final String? ownerPhone;
  final DateTime? lastSeenDate;
  final String? address;
  final String? ownerId;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.description,
    required this.photoUrls,
    this.ownerName,
    this.ownerPhone,
    this.lastSeenDate,
    this.address,
    this.ownerId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'],
      description: json['description'],
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
      lastSeenDate: json['lastSeenDate'] != null ? DateTime.tryParse(json['lastSeenDate']) : null,
      address: json['address'],
      ownerId: json['ownerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'description': description,
      'photoUrls': photoUrls,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'lastSeenDate': lastSeenDate?.toIso8601String(),
      'address': address,
      'ownerId': ownerId,
    };
  }
}
