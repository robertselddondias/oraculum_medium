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
  CollectionReference get notificationsCollection => _firestore.collection('notifications');
  CollectionReference get chatRoomsCollection => _firestore.collection('chat_rooms');
  CollectionReference get messagesCollection => _firestore.collection('messages');

  // ========== MÉTODOS DE USUÁRIO ==========

  Future<DocumentSnapshot> getUserData(String userId) {
    return usersCollection.doc(userId).get();
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return usersCollection.doc(userId).update(data);
  }

  Future<void> createUserData(String userId, Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return usersCollection.doc(userId).set(data);
  }

  Future<void> deleteUserData(String userId) {
    return usersCollection.doc(userId).delete();
  }

  Future<QuerySnapshot> searchUsers(String query) {
    return usersCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
  }

  // ========== MÉTODOS DE MÉDIUM ==========

  Future<DocumentSnapshot> getMediumData(String mediumId) {
    return mediumsCollection.doc(mediumId).get();
  }

  Future<QuerySnapshot> getMediums() {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .get();
  }

  Future<QuerySnapshot> getAvailableMediums() {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true)
        .get();
  }

  Future<QuerySnapshot> getMediumsBySpecialty(String specialty) {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .where('specialties', arrayContains: specialty)
        .orderBy('rating', descending: true)
        .get();
  }

  Future<QuerySnapshot> searchMediums(String query) {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy('name')
        .limit(20)
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

  Future<void> updateMediumAvailabilityStatus(String mediumId, bool isAvailable) {
    return mediumsCollection.doc(mediumId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMediumRating(String mediumId, double newRating, int totalReviews) {
    return mediumsCollection.doc(mediumId).update({
      'rating': newRating,
      'totalReviews': totalReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== MÉTODOS DE AGENDAMENTO ==========

  Future<DocumentReference> createAppointment(Map<String, dynamic> appointmentData) {
    appointmentData['createdAt'] = FieldValue.serverTimestamp();
    appointmentData['updatedAt'] = FieldValue.serverTimestamp();
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

  Future<void> cancelAppointment(String appointmentId, String reason) {
    return appointmentsCollection.doc(appointmentId).update({
      'status': 'canceled',
      'cancelReason': reason,
      'canceledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeAppointment(String appointmentId, Map<String, dynamic>? completionData) {
    final data = <String, dynamic>{
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (completionData != null) {
      data.addAll(completionData);
    }

    return appointmentsCollection.doc(appointmentId).update(data);
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

  Future<QuerySnapshot> getMediumAppointmentsByStatus(String mediumId, String status) {
    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('status', isEqualTo: status)
        .orderBy('dateTime', descending: false)
        .get();
  }

  Future<QuerySnapshot> getMediumAppointmentsInPeriod(
      String mediumId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('dateTime')
        .get();
  }

  Future<QuerySnapshot> getTodayAppointments(String mediumId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime')
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

  Future<void> addMediumAvailableSlot(String mediumId, Map<String, dynamic> slot) {
    return mediumAvailabilityCollection.doc(mediumId).update({
      'availableSlots': FieldValue.arrayUnion([slot]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeMediumAvailableSlot(String mediumId, Map<String, dynamic> slot) {
    return mediumAvailabilityCollection.doc(mediumId).update({
      'availableSlots': FieldValue.arrayRemove([slot]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();
  }

  Future<QuerySnapshot> getTodayEarnings(String mediumId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return mediumEarningsCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();
  }

  Future<void> updateEarningRecord(String earningId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumEarningsCollection.doc(earningId).update(data);
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

  Future<QuerySnapshot> getUserReviews(String userId) {
    return mediumReviewsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mediumReviewsCollection.doc(reviewId).update(data);
  }

  Future<void> deleteReview(String reviewId) {
    return mediumReviewsCollection.doc(reviewId).delete();
  }

  Future<DocumentSnapshot> getReview(String reviewId) {
    return mediumReviewsCollection.doc(reviewId).get();
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

  Future<void> updateNotificationSettings(String mediumId, Map<String, dynamic> notificationSettings) {
    return mediumSettingsCollection.doc(mediumId).update({
      'notificationSettings': notificationSettings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== MÉTODOS DE PAGAMENTO ==========

  Future<DocumentReference> createPayment(Map<String, dynamic> paymentData) {
    paymentData['createdAt'] = FieldValue.serverTimestamp();
    paymentData['updatedAt'] = FieldValue.serverTimestamp();
    return paymentsCollection.add(paymentData);
  }

  Future<void> updatePaymentStatus(String paymentId, String status) {
    return paymentsCollection.doc(paymentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserPayments(String userId) {
    return paymentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getMediumPayments(String mediumId) {
    return paymentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<DocumentSnapshot> getPaymentData(String paymentId) {
    return paymentsCollection.doc(paymentId).get();
  }

  // ========== MÉTODOS DE NOTIFICAÇÃO ==========

  Future<DocumentReference> createNotification(Map<String, dynamic> notificationData) {
    notificationData['createdAt'] = FieldValue.serverTimestamp();
    notificationData['isRead'] = false;
    return notificationsCollection.add(notificationData);
  }

  Future<QuerySnapshot> getUserNotifications(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  Future<QuerySnapshot> getUnreadNotifications(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> markNotificationAsRead(String notificationId) {
    return notificationsCollection.doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final unreadNotifications = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadNotifications.docs.isEmpty) return;

      final batch = _firestore.batch();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('✅ ${unreadNotifications.docs.length} notificações marcadas como lidas');
    } catch (e) {
      debugPrint('❌ Erro ao marcar notificações como lidas: $e');
      throw Exception('Erro ao marcar notificações como lidas');
    }
  }

  Future<void> deleteNotification(String notificationId) {
    return notificationsCollection.doc(notificationId).delete();
  }

  // ========== MÉTODOS DE CHAT ==========

  Future<DocumentReference> createChatRoom(Map<String, dynamic> chatRoomData) {
    chatRoomData['createdAt'] = FieldValue.serverTimestamp();
    chatRoomData['updatedAt'] = FieldValue.serverTimestamp();
    return chatRoomsCollection.add(chatRoomData);
  }

  Future<QuerySnapshot> getUserChatRooms(String userId) {
    return chatRoomsCollection
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .get();
  }

  Future<DocumentReference> sendMessage(String chatRoomId, Map<String, dynamic> messageData) {
    messageData['createdAt'] = FieldValue.serverTimestamp();

    chatRoomsCollection.doc(chatRoomId).update({
      'lastMessage': messageData['text'],
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return messagesCollection.add({
      ...messageData,
      'chatRoomId': chatRoomId,
    });
  }

  Stream<QuerySnapshot> getChatMessages(String chatRoomId) {
    return messagesCollection
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  // ========== MÉTODOS DE UPLOAD ==========

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final path = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Erro ao deletar imagem: $e');
    }
  }

  // ========== MÉTODOS DE ANALYTICS ==========

  Future<Map<String, dynamic>> getMediumAnalytics(String mediumId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      final monthlyAppointments = await getMediumAppointmentsInPeriod(
        mediumId,
        startOfMonth,
        now,
      );

      final yearlyAppointments = await getMediumAppointmentsInPeriod(
        mediumId,
        startOfYear,
        now,
      );

      final monthlyEarnings = await getMediumEarningsInPeriod(
        mediumId,
        startOfMonth,
        now,
      );

      final reviews = await getMediumReviews(mediumId);

      double totalMonthlyEarnings = 0;
      for (final doc in monthlyEarnings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalMonthlyEarnings += (data['amount'] ?? 0.0).toDouble();
      }

      double averageRating = 0;
      if (reviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (final doc in reviews.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRating += (data['rating'] ?? 0.0).toDouble();
        }
        averageRating = totalRating / reviews.docs.length;
      }

      return {
        'monthlyAppointments': monthlyAppointments.docs.length,
        'yearlyAppointments': yearlyAppointments.docs.length,
        'monthlyEarnings': totalMonthlyEarnings,
        'totalReviews': reviews.docs.length,
        'averageRating': averageRating,
        'updatedAt': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Erro ao buscar analytics: $e');
      return {};
    }
  }

  // ========== MÉTODOS DE BUSCA AVANÇADA ==========

  Future<QuerySnapshot> advancedMediumSearch({
    String? name,
    List<String>? specialties,
    double? minRating,
    double? maxPrice,
    bool? isAvailable,
  }) {
    Query query = mediumsCollection.where('isActive', isEqualTo: true);

    if (name != null && name.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff');
    }

    if (minRating != null) {
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    if (maxPrice != null) {
      query = query.where('pricePerMinute', isLessThanOrEqualTo: maxPrice);
    }

    if (isAvailable == true) {
      query = query.where('isAvailable', isEqualTo: true);
    }

    return query.orderBy('rating', descending: true).limit(20).get();
  }

  // ========== MÉTODOS DE TRANSAÇÃO ==========

  Future<T> runTransaction<T>(Future<T> Function(Transaction) updateFunction) async {
    return await _firestore.runTransaction<T>(updateFunction);
  }

  Future<void> batch(Function(WriteBatch) operations) async {
    final batch = _firestore.batch();
    operations(batch);
    await batch.commit();
  }

  // ========== MÉTODOS DE STREAM ==========

  Stream<DocumentSnapshot> getMediumDataStream(String mediumId) {
    return mediumsCollection.doc(mediumId).snapshots();
  }

  Stream<QuerySnapshot> getMediumAppointmentsStream(String mediumId) {
    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // ========== MÉTODOS DE LIMPEZA ==========

  Future<void> cleanupOldNotifications() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final oldNotifications = await notificationsCollection
        .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    final batch = _firestore.batch();
    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }

    if (oldNotifications.docs.isNotEmpty) {
      await batch.commit();
      debugPrint('Limpou ${oldNotifications.docs.length} notificações antigas');
    }
  }

  Future<void> cleanupCanceledAppointments() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final canceledAppointments = await appointmentsCollection
        .where('status', isEqualTo: 'canceled')
        .where('canceledAt', isLessThan: Timestamp.fromDate(sevenDaysAgo))
        .get();

    final batch = _firestore.batch();
    for (final doc in canceledAppointments.docs) {
      batch.delete(doc.reference);
    }

    if (canceledAppointments.docs.isNotEmpty) {
      await batch.commit();
      debugPrint('Limpou ${canceledAppointments.docs.length} agendamentos cancelados antigos');
    }
  }

  // ========== MÉTODOS DE ESTATÍSTICAS E REPORTS ==========

  Future<Map<String, dynamic>> getDashboardStats(String mediumId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfToday = DateTime(now.year, now.month, now.day);

      final results = await Future.wait([
        getMediumAppointments(mediumId),
        getMediumEarnings(mediumId),
        getMediumReviews(mediumId),
        getTodayAppointments(mediumId),
      ]);

      final allAppointments = results[0] as QuerySnapshot;
      final allEarnings = results[1] as QuerySnapshot;
      final allReviews = results[2] as QuerySnapshot;
      final todayAppointments = results[3] as QuerySnapshot;

      int monthlyAppointments = 0;
      int weeklyAppointments = 0;
      int completedAppointments = 0;
      int pendingAppointments = 0;

      for (final doc in allAppointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        final status = data['status'] as String;

        if (dateTime.isAfter(startOfMonth)) monthlyAppointments++;
        if (dateTime.isAfter(startOfWeek)) weeklyAppointments++;
        if (status == 'completed') completedAppointments++;
        if (status == 'pending') pendingAppointments++;
      }

      double totalEarnings = 0;
      double monthlyEarnings = 0;
      double weeklyEarnings = 0;

      for (final doc in allEarnings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0.0).toDouble();
        final date = (data['date'] as Timestamp).toDate();

        totalEarnings += amount;
        if (date.isAfter(startOfMonth)) monthlyEarnings += amount;
        if (date.isAfter(startOfWeek)) weeklyEarnings += amount;
      }

      double averageRating = 0;
      if (allReviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (final doc in allReviews.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRating += (data['rating'] ?? 0.0).toDouble();
        }
        averageRating = totalRating / allReviews.docs.length;
      }

      return {
        'totalAppointments': allAppointments.docs.length,
        'monthlyAppointments': monthlyAppointments,
        'weeklyAppointments': weeklyAppointments,
        'completedAppointments': completedAppointments,
        'pendingAppointments': pendingAppointments,
        'todayAppointments': todayAppointments.docs.length,
        'totalEarnings': totalEarnings,
        'monthlyEarnings': monthlyEarnings,
        'weeklyEarnings': weeklyEarnings,
        'averageRating': averageRating,
        'totalReviews': allReviews.docs.length,
        'completionRate': allAppointments.docs.isEmpty ? 0.0 : (completedAppointments / allAppointments.docs.length) * 100,
      };
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas do dashboard: $e');
      return {};
    }
  }

  // ========== MÉTODOS DE BACKUP E SYNC ==========

  Future<void> backupMediumData(String mediumId) async {
    try {
      final backupData = {
        'mediumProfile': await getMediumData(mediumId),
        'settings': await getMediumSettings(mediumId),
        'availability': await getMediumAvailability(mediumId),
        'appointments': await getMediumAppointments(mediumId),
        'earnings': await getMediumEarnings(mediumId),
        'reviews': await getMediumReviews(mediumId),
        'backupDate': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('backups').doc(mediumId).set(backupData);
      debugPrint('✅ Backup realizado para médium: $mediumId');
    } catch (e) {
      debugPrint('❌ Erro ao fazer backup: $e');
      throw Exception('Erro ao fazer backup dos dados');
    }
  }

  Future<Map<String, dynamic>?> restoreMediumData(String mediumId) async {
    try {
      final backupDoc = await _firestore.collection('backups').doc(mediumId).get();

      if (backupDoc.exists) {
        debugPrint('✅ Backup encontrado para médium: $mediumId');
        return backupDoc.data() as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ Nenhum backup encontrado para médium: $mediumId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar backup: $e');
      return null;
    }
  }

  // ========== MÉTODOS DE VALIDAÇÃO E SEGURANÇA ==========

  Future<bool> validateMediumAccess(String mediumId, String userId) async {
    try {
      final mediumDoc = await getMediumData(mediumId);

      if (!mediumDoc.exists) return false;

      final mediumData = mediumDoc.data() as Map<String, dynamic>;
      return mediumData['userId'] == userId || mediumId == userId;
    } catch (e) {
      debugPrint('❌ Erro ao validar acesso: $e');
      return false;
    }
  }

  Future<bool> checkAppointmentConflict(String mediumId, DateTime dateTime, int durationMinutes) async {
    try {
      final startTime = dateTime.subtract(const Duration(minutes: 15));
      final endTime = dateTime.add(Duration(minutes: durationMinutes + 15));

      final conflictingAppointments = await appointmentsCollection
          .where('mediumId', isEqualTo: mediumId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return conflictingAppointments.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Erro ao verificar conflitos: $e');
      return true;
    }
  }

  Future<bool> validateBusinessHours(String mediumId, DateTime dateTime) async {
    try {
      final availabilityDoc = await getMediumAvailability(mediumId);

      if (!availabilityDoc.exists) return false;

      final availabilityData = availabilityDoc.data() as Map<String, dynamic>;
      final dayOfWeek = _getDayOfWeek(dateTime.weekday);
      final dayData = availabilityData[dayOfWeek] as Map<String, dynamic>?;

      if (dayData == null || dayData['isAvailable'] != true) return false;

      final startTime = _parseTime(dayData['startTime'] as String);
      final endTime = _parseTime(dayData['endTime'] as String);
      final appointmentTime = TimeOfDay.fromDateTime(dateTime);

      return _isTimeInRange(appointmentTime, startTime, endTime);
    } catch (e) {
      debugPrint('❌ Erro ao validar horário comercial: $e');
      return false;
    }
  }

  // ========== MÉTODOS AUXILIARES ==========

  String _getDayOfWeek(int weekday) {
    const days = [
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday'
    ];
    return days[weekday - 1];
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  // ========== MÉTODOS DE RELATÓRIOS ==========

  Future<Map<String, dynamic>> generateMonthlyReport(String mediumId, int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final appointments = await getMediumAppointmentsInPeriod(mediumId, startDate, endDate);
      final earnings = await getMediumEarningsInPeriod(mediumId, startDate, endDate);

      int totalAppointments = appointments.docs.length;
      int completedAppointments = 0;
      int canceledAppointments = 0;
      double totalEarnings = 0;
      Map<String, int> appointmentsByDay = {};
      Map<String, double> earningsByDay = {};

      for (final doc in appointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        final dayKey = '${dateTime.day.toString().padLeft(2, '0')}';

        appointmentsByDay[dayKey] = (appointmentsByDay[dayKey] ?? 0) + 1;

        if (status == 'completed') completedAppointments++;
        if (status == 'canceled') canceledAppointments++;
      }

      for (final doc in earnings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0.0).toDouble();
        final date = (data['date'] as Timestamp).toDate();
        final dayKey = '${date.day.toString().padLeft(2, '0')}';

        totalEarnings += amount;
        earningsByDay[dayKey] = (earningsByDay[dayKey] ?? 0) + amount;
      }

      return {
        'period': '$month/$year',
        'totalAppointments': totalAppointments,
        'completedAppointments': completedAppointments,
        'canceledAppointments': canceledAppointments,
        'completionRate': totalAppointments > 0 ? (completedAppointments / totalAppointments) * 100 : 0,
        'totalEarnings': totalEarnings,
        'averageEarningsPerAppointment': completedAppointments > 0 ? totalEarnings / completedAppointments : 0,
        'appointmentsByDay': appointmentsByDay,
        'earningsByDay': earningsByDay,
        'generatedAt': DateTime.now(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao gerar relatório mensal: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> generatePerformanceReport(String mediumId) async {
    try {
      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));
      final last7Days = now.subtract(const Duration(days: 7));

      final stats = await getDashboardStats(mediumId);
      final recent30DaysAppointments = await getMediumAppointmentsInPeriod(mediumId, last30Days, now);
      final recent7DaysAppointments = await getMediumAppointmentsInPeriod(mediumId, last7Days, now);

      int responsiveAppointments = 0;
      int totalResponseTime = 0;

      for (final doc in recent30DaysAppointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final updatedAt = (data['updatedAt'] as Timestamp).toDate();
        final status = data['status'] as String;

        if (status == 'confirmed' || status == 'canceled') {
          responsiveAppointments++;
          totalResponseTime += updatedAt.difference(createdAt).inHours;
        }
      }

      final averageResponseTime = responsiveAppointments > 0 ? totalResponseTime / responsiveAppointments : 0;

      return {
        'performancePeriod': '30 dias',
        'totalAppointments': stats['totalAppointments'] ?? 0,
        'completionRate': stats['completionRate'] ?? 0,
        'averageRating': stats['averageRating'] ?? 0,
        'totalEarnings': stats['totalEarnings'] ?? 0,
        'last30DaysAppointments': recent30DaysAppointments.docs.length,
        'last7DaysAppointments': recent7DaysAppointments.docs.length,
        'averageResponseTimeHours': averageResponseTime,
        'recommendations': _generateRecommendations(stats),
        'generatedAt': DateTime.now(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao gerar relatório de performance: $e');
      return {};
    }
  }

  List<String> _generateRecommendations(Map<String, dynamic> stats) {
    final recommendations = <String>[];
    final completionRate = stats['completionRate'] ?? 0;
    final averageRating = stats['averageRating'] ?? 0;
    final totalAppointments = stats['totalAppointments'] ?? 0;

    if (completionRate < 80) {
      recommendations.add('Considere melhorar sua taxa de conclusão de consultas');
    }

    if (averageRating < 4.0) {
      recommendations.add('Foque em melhorar a qualidade do atendimento para aumentar sua avaliação');
    }

    if (totalAppointments < 10) {
      recommendations.add('Considere expandir sua disponibilidade para atrair mais clientes');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Parabéns! Sua performance está excelente');
    }

    return recommendations;
  }

  // ========== MÉTODO DE SINCRONIZAÇÃO ==========

  Future<void> syncOfflineData(List<Map<String, dynamic>> offlineData) async {
    try {
      final batch = _firestore.batch();

      for (final data in offlineData) {
        final collection = data['collection'] as String;
        final docId = data['docId'] as String?;
        final docData = data['data'] as Map<String, dynamic>;
        final operation = data['operation'] as String; // 'create', 'update', 'delete'

        DocumentReference docRef;
        if (docId != null) {
          docRef = _firestore.collection(collection).doc(docId);
        } else {
          docRef = _firestore.collection(collection).doc();
        }

        switch (operation) {
          case 'create':
            batch.set(docRef, docData);
            break;
          case 'update':
            batch.update(docRef, docData);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      debugPrint('✅ Sincronização offline concluída: ${offlineData.length} operações');
    } catch (e) {
      debugPrint('❌ Erro na sincronização offline: $e');
      throw Exception('Erro ao sincronizar dados offline');
    }
  }

  // ========== MÉTODOS DE HEALTH CHECK ==========

  Future<bool> checkFirebaseHealth() async {
    try {
      await _firestore.collection('health_check').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('❌ Firebase Health Check falhou: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final isFirebaseHealthy = await checkFirebaseHealth();
      final currentUser = _auth.currentUser;

      return {
        'firebaseHealthy': isFirebaseHealthy,
        'userAuthenticated': currentUser != null,
        'userId': currentUser?.uid,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao verificar status do sistema: $e');
      return {
        'firebaseHealthy': false,
        'userAuthenticated': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
