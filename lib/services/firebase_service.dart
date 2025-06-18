import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;

  // Referências de coleções
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get mediumsCollection => _firestore.collection('mediums');
  CollectionReference get appointmentsCollection => _firestore.collection('appointments');
  CollectionReference get mediumAvailabilityCollection => _firestore.collection('medium_availability');
  CollectionReference get mediumEarningsCollection => _firestore.collection('medium_earnings');
  CollectionReference get mediumReviewsCollection => _firestore.collection('medium_reviews');
  CollectionReference get mediumSettingsCollection => _firestore.collection('medium_settings');
  CollectionReference get paymentsCollection => _firestore.collection('payments');

  // ========== MÉTODOS DE USUÁRIO ==========

  Future<DocumentSnapshot> getUserData(String userId) {
    return usersCollection.doc(userId).get();
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) {
    return usersCollection.doc(userId).update(data);
  }

  Future<void> createUserData(String userId, Map<String, dynamic> data) {
    return usersCollection.doc(userId).set(data);
  }

  // ========== MÉTODOS DE MÉDIUM ==========

  Future<DocumentSnapshot> getMediumData(String mediumId) {
    return mediumsCollection.doc(mediumId).get();
  }

  Future<QuerySnapshot> getMediums() {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .get();
  }

  Future<QuerySnapshot> getAvailableMediums() {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .get();
  }

  Future<void> updateMediumData(String mediumId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumsCollection.doc(mediumId).update(data);
  }

  Future<void> createMediumData(String mediumId, Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumsCollection.doc(mediumId).set(data);
  }

  // ========== MÉTODOS DE AGENDAMENTO ==========

  Future<DocumentReference> createAppointment(Map<String, dynamic> appointmentData) {
    appointmentData['createdAt'] = FieldValue.serverTimestamp();
    return appointmentsCollection.add(appointmentData);
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return appointmentsCollection.doc(appointmentId).update(data);
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) {
    return appointmentsCollection.doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserAppointments(String userId) {
    return appointmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get();
  }

  Future<QuerySnapshot> getMediumAppointments(String mediumId) {
    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('dateTime', descending: false)
        .get();
  }

  Future<DocumentSnapshot> getAppointmentData(String appointmentId) {
    return appointmentsCollection.doc(appointmentId).get();
  }

  // ========== MÉTODOS DE DISPONIBILIDADE ==========

  Future<DocumentSnapshot> getMediumAvailability(String mediumId) {
    return mediumAvailabilityCollection.doc(mediumId).get();
  }

  Future<void> updateMediumAvailability(String mediumId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumAvailabilityCollection.doc(mediumId).set(data, SetOptions(merge: true));
  }

  Future<void> createMediumAvailability(String mediumId, Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumAvailabilityCollection.doc(mediumId).set(data);
  }

  // ========== MÉTODOS DE GANHOS ==========

  Future<DocumentReference> createEarningRecord(Map<String, dynamic> earningData) {
    earningData['createdAt'] = FieldValue.serverTimestamp();
    return mediumEarningsCollection.add(earningData);
  }

  Future<QuerySnapshot> getMediumEarnings(String mediumId) {
    return mediumEarningsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('date', descending: true)
        .get();
  }

  Future<QuerySnapshot> getMediumEarningsInPeriod(
      String mediumId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return mediumEarningsCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .get();
  }

  // ========== MÉTODOS DE AVALIAÇÕES ==========

  Future<DocumentReference> createReview(Map<String, dynamic> reviewData) {
    reviewData['createdAt'] = FieldValue.serverTimestamp();
    return mediumReviewsCollection.add(reviewData);
  }

  Future<QuerySnapshot> getMediumReviews(String mediumId) {
    return mediumReviewsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumReviewsCollection.doc(reviewId).update(data);
  }

  // ========== MÉTODOS DE CONFIGURAÇÕES ==========

  Future<DocumentSnapshot> getMediumSettings(String mediumId) {
    return mediumSettingsCollection.doc(mediumId).get();
  }

  Future<void> updateMediumSettings(String mediumId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumSettingsCollection.doc(mediumId).set(data, SetOptions(merge: true));
  }

  Future<void> createMediumSettings(String mediumId, Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumSettingsCollection.doc(mediumId).set(data);
  }

// ========
