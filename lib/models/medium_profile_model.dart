import 'package:cloud_firestore/cloud_firestore.dart';

class MediumProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? imageUrl;
  final List<String> specialties;
  final double rating;
  final int reviewsCount;
  final double pricePerMinute;
  final bool isActive;
  final bool isAvailable;
  final bool isOnline;
  final String experience;
  final int yearsOfExperience;
  final List<String> languages;
  final int totalAppointments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;
  final Map<String, dynamic> availability;

  MediumProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    this.imageUrl,
    required this.specialties,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerMinute,
    required this.isActive,
    required this.isAvailable,
    required this.isOnline,
    required this.experience,
    required this.yearsOfExperience,
    required this.languages,
    required this.totalAppointments,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
    required this.availability,
  });

  factory MediumProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return MediumProfileModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'],
      specialties: List<String>.from(map['specialties'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      pricePerMinute: (map['pricePerMinute'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      isOnline: map['isOnline'] ?? false,
      experience: map['experience'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      languages: List<String>.from(map['languages'] ?? ['Português']),
      totalAppointments: map['totalAppointments'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      lastSeen: map['lastSeen']?.toDate(),
      availability: Map<String, dynamic>.from(map['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'pricePerMinute': pricePerMinute,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'experience': experience,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'totalAppointments': totalAppointments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSeen': lastSeen,
      'availability': availability,
    };
  }

  MediumProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? imageUrl,
    List<String>? specialties,
    double? rating,
    int? reviewsCount,
    double? pricePerMinute,
    bool? isActive,
    bool? isAvailable,
    bool? isOnline,
    String? experience,
    int? yearsOfExperience,
    List<String>? languages,
    int? totalAppointments,
    DateTime? updatedAt,
    DateTime? lastSeen,
    Map<String, dynamic>? availability,
  }) {
    return MediumProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      experience: experience ?? this.experience,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      languages: languages ?? this.languages,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      availability: availability ?? this.availability,
    );
  }

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
}
