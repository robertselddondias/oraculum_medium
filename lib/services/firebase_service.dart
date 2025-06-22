// lib/services/firebase_service.dart
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
  CollectionReference get tarotReadingsCollection => _firestore.collection('tarot_readings');
  CollectionReference get astrologyChartsCollection => _firestore.collection('astrology_charts');
  CollectionReference get mysticCirclesCollection => _firestore.collection('mystic_circles');
  CollectionReference get paymentsCollection => _firestore.collection('payments');
  CollectionReference get notificationsCollection => _firestore.collection('notifications');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get settingsCollection => _firestore.collection('user_settings');

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

  Future<QuerySnapshot> getAllUsers() {
    return usersCollection.orderBy('createdAt', descending: true).get();
  }

  Future<QuerySnapshot> searchUsers(String searchTerm) {
    return usersCollection
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
  }

  // ========== MÉTODOS DE CONFIGURAÇÕES ==========

  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    try {
      final doc = await settingsCollection.doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
      return null;
    }
  }

  Future<bool> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      settings['updatedAt'] = FieldValue.serverTimestamp();
      await settingsCollection.doc(userId).set(settings, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações: $e');
      return false;
    }
  }

  Future<bool> createUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      settings['createdAt'] = FieldValue.serverTimestamp();
      settings['updatedAt'] = FieldValue.serverTimestamp();
      await settingsCollection.doc(userId).set(settings);
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao criar configurações: $e');
      return false;
    }
  }

  // ========== MÉTODOS DE MÉDIUNS ==========

  Future<DocumentSnapshot> getMediumData(String mediumId) {
    return mediumsCollection.doc(mediumId).get();
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

  Future<QuerySnapshot> searchMediums(String searchTerm) {
    return mediumsCollection
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
  }

  // ========== MÉTODOS DE CONSULTAS ==========

  Future<DocumentReference> createAppointment(Map<String, dynamic> appointmentData) {
    appointmentData['createdAt'] = FieldValue.serverTimestamp();
    appointmentData['updatedAt'] = FieldValue.serverTimestamp();
    return appointmentsCollection.add(appointmentData);
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return appointmentsCollection.doc(appointmentId).update(data);
  }

  Future<DocumentSnapshot> getAppointment(String appointmentId) {
    return appointmentsCollection.doc(appointmentId).get();
  }

  Future<QuerySnapshot> getUserAppointments(String userId) {
    return appointmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledDateTime', descending: true)
        .get();
  }

  Future<QuerySnapshot> getMediumAppointments(String mediumId) {
    return appointmentsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('scheduledDateTime', descending: true)
        .get();
  }

  Future<QuerySnapshot> getAppointmentsByStatus(String userId, String status) {
    return appointmentsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('scheduledDateTime', descending: true)
        .get();
  }

  // ========== MÉTODOS DE LEITURAS DE TARÔ ==========

  Future<DocumentReference> createTarotReading(Map<String, dynamic> readingData) {
    readingData['createdAt'] = FieldValue.serverTimestamp();
    readingData['updatedAt'] = FieldValue.serverTimestamp();
    return tarotReadingsCollection.add(readingData);
  }

  Future<void> updateTarotReading(String readingId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return tarotReadingsCollection.doc(readingId).update(data);
  }

  Future<DocumentSnapshot> getTarotReading(String readingId) {
    return tarotReadingsCollection.doc(readingId).get();
  }

  Future<QuerySnapshot> getUserTarotReadings(String userId) {
    return tarotReadingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getSharedTarotReadings() {
    return tarotReadingsCollection
        .where('isShared', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  Future<void> deleteTarotReading(String readingId) {
    return tarotReadingsCollection.doc(readingId).delete();
  }

  // ========== MÉTODOS DE MAPAS ASTROLÓGICOS ==========

  Future<DocumentReference> createAstrologyChart(Map<String, dynamic> chartData) {
    chartData['createdAt'] = FieldValue.serverTimestamp();
    chartData['updatedAt'] = FieldValue.serverTimestamp();
    return astrologyChartsCollection.add(chartData);
  }

  Future<void> updateAstrologyChart(String chartId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return astrologyChartsCollection.doc(chartId).update(data);
  }

  Future<DocumentSnapshot> getAstrologyChart(String chartId) {
    return astrologyChartsCollection.doc(chartId).get();
  }

  Future<QuerySnapshot> getUserAstrologyCharts(String userId) {
    return astrologyChartsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getSharedAstrologyCharts() {
    return astrologyChartsCollection
        .where('isShared', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  Future<void> deleteAstrologyChart(String chartId) {
    return astrologyChartsCollection.doc(chartId).delete();
  }

  // ========== MÉTODOS DE CÍRCULOS MÍSTICOS ==========

  Future<DocumentReference> createMysticCircle(Map<String, dynamic> circleData) {
    circleData['createdAt'] = FieldValue.serverTimestamp();
    circleData['updatedAt'] = FieldValue.serverTimestamp();
    return mysticCirclesCollection.add(circleData);
  }

  Future<void> updateMysticCircle(String circleId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return mysticCirclesCollection.doc(circleId).update(data);
  }

  Future<DocumentSnapshot> getMysticCircle(String circleId) {
    return mysticCirclesCollection.doc(circleId).get();
  }

  Future<QuerySnapshot> getUserMysticCircles(String userId) {
    return mysticCirclesCollection
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getPublicMysticCircles() {
    return mysticCirclesCollection
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('memberCount', descending: true)
        .limit(20)
        .get();
  }

  Future<QuerySnapshot> searchMysticCircles(String searchTerm) {
    return mysticCirclesCollection
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
  }

  // ========== MÉTODOS DE PAGAMENTOS ==========

  Future<DocumentReference> createPayment(Map<String, dynamic> paymentData) {
    paymentData['createdAt'] = FieldValue.serverTimestamp();
    paymentData['updatedAt'] = FieldValue.serverTimestamp();
    return paymentsCollection.add(paymentData);
  }

  Future<void> updatePayment(String paymentId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return paymentsCollection.doc(paymentId).update(data);
  }

  Future<DocumentSnapshot> getPayment(String paymentId) {
    return paymentsCollection.doc(paymentId).get();
  }

  Future<QuerySnapshot> getUserPayments(String userId) {
    return paymentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getPaymentsByStatus(String userId, String status) {
    return paymentsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // ========== MÉTODOS DE AVALIAÇÕES ==========

  Future<DocumentReference> createReview(Map<String, dynamic> reviewData) {
    reviewData['createdAt'] = FieldValue.serverTimestamp();
    reviewData['updatedAt'] = FieldValue.serverTimestamp();
    return reviewsCollection.add(reviewData);
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return reviewsCollection.doc(reviewId).update(data);
  }

  Future<DocumentSnapshot> getReview(String reviewId) {
    return reviewsCollection.doc(reviewId).get();
  }

  Future<QuerySnapshot> getMediumReviews(String mediumId) {
    return reviewsCollection
        .where('mediumId', isEqualTo: mediumId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getUserReviews(String userId) {
    return reviewsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> deleteReview(String reviewId) {
    return reviewsCollection.doc(reviewId).delete();
  }

  // ========== MÉTODOS DE NOTIFICAÇÕES ==========

  Future<DocumentReference> createNotification(Map<String, dynamic> notificationData) {
    notificationData['createdAt'] = FieldValue.serverTimestamp();
    notificationData['updatedAt'] = FieldValue.serverTimestamp();
    return notificationsCollection.add(notificationData);
  }

  Future<void> updateNotification(String notificationId, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return notificationsCollection.doc(notificationId).update(data);
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
    final batch = _firestore.batch();
    final unreadNotifications = await getUnreadNotifications(userId);

    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) {
    return notificationsCollection.doc(notificationId).delete();
  }

  // ========== MÉTODOS DE UPLOAD ==========

  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final path = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagem de perfil enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem de perfil: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadTarotImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final path = 'tarot_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagem de tarô enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem de tarô: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadCircleImage(String circleId, String imagePath) async {
    try {
      final file = File(imagePath);
      final path = 'circle_images/$circleId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagem de círculo enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem de círculo: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadGenericImage(String folder, String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = imagePath.split('/').last;
      final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagem enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload da imagem: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Imagem deletada: $imageUrl');
    } catch (e) {
      debugPrint('❌ Erro ao deletar imagem: $e');
    }
  }

  // ========== MÉTODOS DE ESTATÍSTICAS ==========

  Future<int> getUserTotalReadings(String userId) async {
    try {
      final readings = await getUserTarotReadings(userId);
      return readings.docs.length;
    } catch (e) {
      debugPrint('❌ Erro ao contar leituras: $e');
      return 0;
    }
  }

  Future<int> getUserTotalCharts(String userId) async {
    try {
      final charts = await getUserAstrologyCharts(userId);
      return charts.docs.length;
    } catch (e) {
      debugPrint('❌ Erro ao contar mapas: $e');
      return 0;
    }
  }

  Future<int> getUserTotalCircles(String userId) async {
    try {
      final circles = await getUserMysticCircles(userId);
      return circles.docs.length;
    } catch (e) {
      debugPrint('❌ Erro ao contar círculos: $e');
      return 0;
    }
  }

  Future<double> getUserTotalSpent(String userId) async {
    try {
      final payments = await getUserPayments(userId);
      double total = 0.0;

      for (final doc in payments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0.0).toDouble();
        final status = data['status'] ?? '';

        if (status == 'completed' || status == 'success') {
          total += amount;
        }
      }

      return total;
    } catch (e) {
      debugPrint('❌ Erro ao calcular total gasto: $e');
      return 0.0;
    }
  }

  // ========== MÉTODOS DE BUSCA AVANÇADA ==========

  Future<QuerySnapshot> searchContent(String searchTerm, String contentType) async {
    switch (contentType.toLowerCase()) {
      case 'users':
        return searchUsers(searchTerm);
      case 'mediums':
        return searchMediums(searchTerm);
      case 'circles':
        return searchMysticCircles(searchTerm);
      default:
        throw ArgumentError('Tipo de conteúdo não suportado: $contentType');
    }
  }

  Future<List<DocumentSnapshot>> getRecentActivity(String userId, {int limit = 20}) async {
    final activities = <DocumentSnapshot>[];

    try {
      // Leituras recentes
      final readings = await tarotReadingsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 4)
          .get();
      activities.addAll(readings.docs);

      // Mapas recentes
      final charts = await astrologyChartsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 4)
          .get();
      activities.addAll(charts.docs);

      // Consultas recentes
      final appointments = await appointmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 4)
          .get();
      activities.addAll(appointments.docs);

      // Avaliações recentes
      final reviews = await reviewsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 4)
          .get();
      activities.addAll(reviews.docs);

      // Ordenar por data de criação
      activities.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aCreated = aData['createdAt'] as Timestamp?;
        final bCreated = bData['createdAt'] as Timestamp?;

        if (aCreated == null || bCreated == null) return 0;
        return bCreated.compareTo(aCreated);
      });

      return activities.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar atividades recentes: $e');
      return [];
    }
  }

  // ========== MÉTODOS DE BACKUP E SINCRONIZAÇÃO ==========

  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final userData = await getUserData(userId);
      final userSettings = await getUserSettings(userId);
      final userReadings = await getUserTarotReadings(userId);
      final userCharts = await getUserAstrologyCharts(userId);
      final userPayments = await getUserPayments(userId);
      final userReviews = await getUserReviews(userId);

      return {
        'user': userData.data(),
        'settings': userSettings,
        'tarotReadings': userReadings.docs.map((doc) => doc.data()).toList(),
        'astrologyCharts': userCharts.docs.map((doc) => doc.data()).toList(),
        'payments': userPayments.docs.map((doc) => doc.data()).toList(),
        'reviews': userReviews.docs.map((doc) => doc.data()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao exportar dados do usuário: $e');
      throw Exception('Erro ao exportar dados: $e');
    }
  }

  // ========== MÉTODOS DE LIMPEZA ==========

  Future<void> cleanupOldNotifications(String userId, {int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final oldNotifications = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ ${oldNotifications.docs.length} notificações antigas removidas');
    } catch (e) {
      debugPrint('❌ Erro ao limpar notificações antigas: $e');
    }
  }

  Future<void> cleanupOrphanedImages() async {
    try {
      // Implementar lógica para remover imagens órfãs
      // Esta é uma operação complexa que requer análise cuidadosa
      debugPrint('⚠️ Limpeza de imagens órfãs não implementada ainda');
    } catch (e) {
      debugPrint('❌ Erro ao limpar imagens órfãs: $e');
    }
  }

  // ========== MÉTODOS DE VALIDAÇÃO ==========

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}
    ).hasMatch(email);
  }

  bool isValidPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // ========== MÉTODOS DE CONEXÃO ==========

  Future<bool> checkConnection() async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Transação vazia apenas para testar conectividade
      });
      return true;
    } catch (e) {
      debugPrint('❌ Sem conexão com Firebase: $e');
      return false;
    }
  }

  void enableOfflinePersistence() {
    try {
      _firestore.enablePersistence();
      debugPrint('✅ Persistência offline habilitada');
    } catch (e) {
      debugPrint('❌ Erro ao habilitar persistência offline: $e');
    }
  }

  // ========== GETTERS DE CONVENIÊNCIA ==========

  bool get isUserAuthenticated => _auth.currentUser != null;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserDisplayName => _auth.currentUser?.displayName ?? '';
  String? get currentUserPhotoURL => _auth.currentUser?.photoURL;

  // ========== MÉTODOS DE DEBUG ==========

  void logUserInfo() {
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('=== USER INFO ===');
      debugPrint('UID: ${user.uid}');
      debugPrint('Email: ${user.email}');
      debugPrint('Display Name: ${user.displayName}');
      debugPrint('Photo URL: ${user.photoURL}');
      debugPrint('Email Verified: ${user.emailVerified}');
      debugPrint('Created: ${user.metadata.creationTime}');
      debugPrint('Last Sign In: ${user.metadata.lastSignInTime}');
      debugPrint('================');
    } else {
      debugPrint('❌ Nenhum usuário autenticado');
    }
  }

  Future<void> testFirestoreConnection() async {
    try {
      debugPrint('🔄 Testando conexão com Firestore...');
      final testDoc = await _firestore.collection('test').doc('connection').get();
      debugPrint('✅ Conexão com Firestore funcionando');
    } catch (e) {
      debugPrint('❌ Erro na conexão com Firestore: $e');
    }
  }

  Future<void> testStorageConnection() async {
    try {
      debugPrint('🔄 Testando conexão com Storage...');
      final ref = _storage.ref().child('test/connection.txt');
      await ref.getDownloadURL();
      debugPrint('✅ Conexão com Storage funcionando');
    } catch (e) {
      debugPrint('❌ Erro na conexão com Storage: $e');
    }
  }
}
