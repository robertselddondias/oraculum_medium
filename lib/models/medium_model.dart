import 'package:cloud_firestore/cloud_firestore.dart';

class MediumModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String description; // Mantido da sua model original
  final String? imageUrl; // Tornado opcional
  final List<String> specialties;
  final double rating;
  final int reviewsCount;
  final double pricePerMinute;
  final bool isActive;
  final bool isAvailable;
  final bool isOnline;
  final Map<String, dynamic> availability;
  final String biography; // Mantido da sua model original
  final String bio; // Adicionado para compatibilidade com controllers
  final String experience; // Para compatibilidade
  final int yearsOfExperience; // Mantido da sua model original
  final List<String> languages;
  final int totalAppointments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;

  MediumModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    this.imageUrl,
    required this.specialties,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerMinute,
    required this.isActive,
    required this.isAvailable,
    required this.isOnline,
    required this.availability,
    required this.biography,
    required this.bio,
    required this.experience,
    required this.yearsOfExperience,
    required this.languages,
    required this.totalAppointments,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
  });

  factory MediumModel.fromMap(Map<String, dynamic> map, String id) {
    return MediumModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      description: map['description'] ?? map['bio'] ?? '', // Fallback para bio
      imageUrl: map['imageUrl'],
      specialties: List<String>.from(map['specialties'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      pricePerMinute: (map['pricePerMinute'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      isOnline: map['isOnline'] ?? false,
      availability: Map<String, dynamic>.from(map['availability'] ?? {}),
      biography: map['biography'] ?? map['bio'] ?? '', // Fallback para bio
      bio: map['bio'] ?? map['biography'] ?? '', // Fallback para biography
      experience: map['experience'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      languages: List<String>.from(map['languages'] ?? ['Português']),
      totalAppointments: map['totalAppointments'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      lastSeen: map['lastSeen']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'pricePerMinute': pricePerMinute,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'availability': availability,
      'biography': biography,
      'bio': bio,
      'experience': experience,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'totalAppointments': totalAppointments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSeen': lastSeen,
    };
  }

  MediumModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? description,
    String? imageUrl,
    List<String>? specialties,
    double? rating,
    int? reviewsCount,
    double? pricePerMinute,
    bool? isActive,
    bool? isAvailable,
    bool? isOnline,
    Map<String, dynamic>? availability,
    String? biography,
    String? bio,
    String? experience,
    int? yearsOfExperience,
    List<String>? languages,
    int? totalAppointments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
  }) {
    return MediumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      availability: availability ?? this.availability,
      biography: biography ?? this.biography,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      languages: languages ?? this.languages,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  // Getters para compatibilidade e conveniência
  String get statusText {
    if (!isActive) return 'Inativo';
    if (isOnline) return 'Online';
    if (isAvailable) return 'Disponível';
    return 'Ocupado';
  }

  String get formattedPrice {
    return 'R\$ ${pricePerMinute.toStringAsFixed(2)}/min';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get specialtiesString {
    return specialties.join(', ');
  }

  String get languagesString {
    return languages.join(', ');
  }

  String get experienceText {
    if (yearsOfExperience == 0) return 'Novo no ramo';
    if (yearsOfExperience == 1) return '1 ano de experiência';
    return '$yearsOfExperience anos de experiência';
  }

  bool get hasProfileImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Para compatibilidade com as telas que usam 'bio'
  String get displayBio => bio.isNotEmpty ? bio : biography;

  // Para compatibilidade com as telas que usam 'description'
  String get displayDescription => description.isNotEmpty ? description : bio;
}
