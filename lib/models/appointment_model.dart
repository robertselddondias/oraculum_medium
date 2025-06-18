import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String mediumId;
  final DateTime dateTime;
  final int durationMinutes;
  final String status; // pending, confirmed, completed, canceled
  final String paymentId;
  final double amount;
  final DateTime createdAt;
  final String? notes;
  final String? feedback;
  final double? rating;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.mediumId,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    required this.paymentId,
    required this.amount,
    required this.createdAt,
    this.notes,
    this.feedback,
    this.rating,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      userId: map['userId'] ?? '',
      mediumId: map['mediumId'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'] ?? 0,
      status: map['status'] ?? 'pending',
      paymentId: map['paymentId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
      feedback: map['feedback'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mediumId': mediumId,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'status': status,
      'paymentId': paymentId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'feedback': feedback,
      'rating': rating,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? mediumId,
    DateTime? dateTime,
    int? durationMinutes,
    String? status,
    String? paymentId,
    double? amount,
    DateTime? createdAt,
    String? notes,
    String? feedback,
    double? rating,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediumId: mediumId ?? this.mediumId,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
    );
  }
}
