import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/services/firebase_service.dart';
import 'package:oraculum_medium/services/medium_service.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';

class MediumAdminController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isRefreshing = false.obs;
  final mediumProfile = Rxn<MediumModel>();
  final errorMessage = ''.obs;

  final autoAcceptAppointments = false.obs;
  final bufferTime = 15.obs;
  final maxDailyAppointments = 10.obs;
  final minAdvanceBooking = 2.obs;
  final maxAdvanceBooking = 30.obs;
  final allowSameDayBooking = true.obs;

  final notificationSettings = <String, bool>{
    'newAppointments': true,
    'appointmentReminders': true,
    'paymentNotifications': true,
    'reviewNotifications': true,
    'promotionalEmails': false,
    'systemUpdates': true,
    'maintenanceAlerts': true,
  }.obs;

  final settings = <String, dynamic>{}.obs;
  final consultationDurations = <int>[15, 30, 45, 60].obs;
  final availability = <String, dynamic>{
    'monday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
    'tuesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
    'wednesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
    'thursday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
    'friday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
    'saturday': {'isAvailable': false, 'startTime': '09:00', 'endTime': '17:00', 'breaks': []},
    'sunday': {'isAvailable': false, 'startTime': '10:00', 'endTime': '16:00', 'breaks': []},
    'blockedDates': <DateTime>[],
  }.obs;

  final totalAppointments = 0.obs;
  final completedAppointments = 0.obs;
  final canceledAppointments = 0.obs;
  final totalEarnings = 0.0.obs;
  final monthlyEarnings = 0.0.obs;
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;

  final isOnline = false.obs;
  final isAvailable = false.obs;
  final currentStatus = 'offline'.obs;
  final customStatusMessage = ''.obs;

  final minimumSessionPrice = 10.0.obs;
  final acceptsCredits = true.obs;
  final acceptsCards = true.obs;
  final acceptsPix = true.obs;
  final commissionRate = 0.15.obs;

  String get currentMediumId => _authController.currentUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    loadMediumProfile();
  }

  void _initializeController() {
    debugPrint('=== MediumAdminController.onInit() ===');

    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadMediumProfile();
      } else {
        _clearData();
      }
    });
  }

  void _clearData() {
    mediumProfile.value = null;
    totalAppointments.value = 0;
    totalEarnings.value = 0.0;
    averageRating.value = 0.0;
    isOnline.value = false;
    isAvailable.value = false;
  }

  Future<void> loadMediumProfile() async {
    if (currentMediumId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('Carregando perfil do médium: $currentMediumId');

      final mediumDoc = await _firebaseService.getMediumData(currentMediumId);

      if (mediumDoc.exists) {
        final mediumData = mediumDoc.data() as Map<String, dynamic>;
        mediumProfile.value = MediumModel.fromMap(mediumData, currentMediumId);

        _updateLocalSettings(mediumData);

        debugPrint('✅ Perfil carregado: ${mediumProfile.value?.name}');
      } else {
        debugPrint('❌ Perfil do médium não encontrado');
        await _createMediumProfile();
      }

      await _loadMediumSettings();
      await _loadPerformanceData();

    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil: $e');
      errorMessage.value = 'Erro ao carregar perfil: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createMediumProfile() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final mediumData = {
        'name': user.displayName ?? 'Médium',
        'email': user.email ?? '',
        'imageUrl': user.photoURL,
        'bio': '',
        'specialties': <String>[],
        'pricePerMinute': 2.0,
        'rating': 0.0,
        'totalAppointments': 0,
        'totalReviews': 0,
        'isActive': true,
        'isAvailable': false,
        'phone': '',
        'experience': '',
        'languages': ['Português'],
        'certificates': <String>[],
        'socialMedia': <String, String>{},
      };

      await _firebaseService.createMediumData(currentMediumId, mediumData);
      mediumProfile.value = MediumModel.fromMap(mediumData, currentMediumId);

      debugPrint('✅ Perfil do médium criado');
    } catch (e) {
      debugPrint('❌ Erro ao criar perfil: $e');
      throw e;
    }
  }

  void _updateLocalSettings(Map<String, dynamic> mediumData) {
    isAvailable.value = mediumData['isAvailable'] ?? false;
    currentStatus.value = mediumData['status'] ?? 'offline';
    customStatusMessage.value = mediumData['statusMessage'] ?? '';
  }

  Future<void> _loadMediumSettings() async {
    try {
      final settingsDoc = await _firebaseService.getMediumSettings(currentMediumId);

      if (settingsDoc.exists) {
        final settingsData = settingsDoc.data() as Map<String, dynamic>;

        autoAcceptAppointments.value = settingsData['autoAcceptAppointments'] ?? false;
        bufferTime.value = settingsData['bufferTime'] ?? 15;
        maxDailyAppointments.value = settingsData['maxDailyAppointments'] ?? 10;
        minAdvanceBooking.value = settingsData['minAdvanceBooking'] ?? 2;
        maxAdvanceBooking.value = settingsData['maxAdvanceBooking'] ?? 30;
        allowSameDayBooking.value = settingsData['allowSameDayBooking'] ?? true;

        if (settingsData['notificationSettings'] != null) {
          final notifications = settingsData['notificationSettings'] as Map<String, dynamic>;
          notificationSettings.addAll(notifications.cast<String, bool>());
        }

        if (settingsData['consultationDurations'] != null) {
          consultationDurations.value = List<int>.from(settingsData['consultationDurations']);
        }

        if (settingsData['availability'] != null) {
          availability.value = Map<String, dynamic>.from(settingsData['availability']);
        }

        minimumSessionPrice.value = (settingsData['minimumSessionPrice'] ?? 10.0).toDouble();
        acceptsCredits.value = settingsData['acceptsCredits'] ?? true;
        acceptsCards.value = settingsData['acceptsCards'] ?? true;
        acceptsPix.value = settingsData['acceptsPix'] ?? true;

        settings.value = settingsData;
        debugPrint('✅ Configurações carregadas');
      } else {
        await _createDefaultSettings();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
    }
  }

  Future<void> _createDefaultSettings() async {
    try {
      final defaultSettings = {
        'autoAcceptAppointments': false,
        'bufferTime': 15,
        'maxDailyAppointments': 10,
        'minAdvanceBooking': 2,
        'maxAdvanceBooking': 30,
        'allowSameDayBooking': true,
        'notificationSettings': notificationSettings.value,
        'consultationDurations': [15, 30, 45, 60],
        'availability': availability.value,
        'minimumSessionPrice': 10.0,
        'acceptsCredits': true,
        'acceptsCards': true,
        'acceptsPix': true,
      };

      await _firebaseService.createMediumSettings(currentMediumId, defaultSettings);
      settings.value = defaultSettings;

      debugPrint('✅ Configurações padrão criadas');
    } catch (e) {
      debugPrint('❌ Erro ao criar configurações padrão: $e');
    }
  }

  Future<void> _loadPerformanceData() async {
    try {
      final appointments = await _firebaseService.getMediumAppointments(currentMediumId);
      totalAppointments.value = appointments.docs.length;

      int completed = 0;
      int canceled = 0;

      for (final doc in appointments.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'completed') completed++;
        if (status == 'canceled') canceled++;
      }

      completedAppointments.value = completed;
      canceledAppointments.value = canceled;

      final earnings = await _firebaseService.getMediumEarnings(currentMediumId);
      double total = 0.0;

      for (final doc in earnings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] ?? 0.0).toDouble();
      }

      totalEarnings.value = total;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final monthlyEarningsSnapshot = await _firebaseService.getMediumEarningsInPeriod(
        currentMediumId,
        startOfMonth,
        now,
      );

      double monthlyTotal = 0.0;
      for (final doc in monthlyEarningsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        monthlyTotal += (data['amount'] ?? 0.0).toDouble();
      }

      monthlyEarnings.value = monthlyTotal;

      final reviews = await _firebaseService.getMediumReviews(currentMediumId);
      totalReviews.value = reviews.docs.length;

      if (reviews.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (final doc in reviews.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRating += (data['rating'] ?? 0.0).toDouble();
        }
        averageRating.value = totalRating / reviews.docs.length;
      }

      debugPrint('✅ Dados de performance carregados');
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados de performance: $e');
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadMediumProfile();
    isRefreshing.value = false;
  }

  Future<bool> updateMediumProfile(Map<String, dynamic> profileData) async {
    try {
      isSaving.value = true;

      await _firebaseService.updateMediumData(currentMediumId, profileData);

      if (mediumProfile.value != null) {
        final currentData = mediumProfile.value!.toMap();
        currentData.addAll(profileData);
        mediumProfile.value = MediumModel.fromMap(currentData, currentMediumId);
      }

      debugPrint('✅ Perfil atualizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      errorMessage.value = 'Erro ao atualizar perfil: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      isSaving.value = true;

      await _firebaseService.updateMediumSettings(currentMediumId, newSettings);
      settings.value = newSettings;

      debugPrint('✅ Configurações atualizadas com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar configurações: $e');
      errorMessage.value = 'Erro ao atualizar configurações: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  bool getNotificationSetting(String key) {
    return notificationSettings[key] ?? true;
  }

  void updateNotificationSetting(String key, bool value) {
    notificationSettings[key] = value;
  }

  void updateAutoAcceptAppointments(bool value) {
    autoAcceptAppointments.value = value;
  }

  void updateBufferTime(int value) {
    bufferTime.value = value;
  }

  void updateMaxDailyAppointments(int value) {
    maxDailyAppointments.value = value;
  }

  void updateMinAdvanceBooking(int hours) {
    minAdvanceBooking.value = hours;
  }

  void updateMaxAdvanceBooking(int days) {
    maxAdvanceBooking.value = days;
  }

  void updateAllowSameDayBooking(bool value) {
    allowSameDayBooking.value = value;
  }

  List<int> getConsultationDurations() {
    return consultationDurations.value;
  }

  void updateConsultationDurations(List<int> durations) {
    consultationDurations.value = durations;
  }

  int getDefaultDuration() {
    return consultationDurations.isNotEmpty ? consultationDurations.first : 30;
  }

  void updateDefaultDuration(int duration) {
    if (!consultationDurations.contains(duration)) {
      consultationDurations.add(duration);
    }
  }

  void updateDayAvailability(String day, Map<String, dynamic> dayData) {
    availability[day] = dayData;
  }

  bool getDayAvailability(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['isAvailable'] ?? false;
  }

  String getDayStartTime(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['startTime'] ?? '09:00';
  }

  String getDayEndTime(String day) {
    final dayData = availability[day] as Map<String, dynamic>?;
    return dayData?['endTime'] ?? '18:00';
  }

  List<DateTime> getBlockedDates() {
    final dates = availability['blockedDates'] as List?;
    return dates?.cast<DateTime>() ?? [];
  }

  void addBlockedDate(DateTime date) {
    final blockedDates = getBlockedDates();
    if (!blockedDates.contains(date)) {
      blockedDates.add(date);
      availability['blockedDates'] = blockedDates;
    }
  }

  void removeBlockedDate(DateTime date) {
    final blockedDates = getBlockedDates();
    blockedDates.remove(date);
    availability['blockedDates'] = blockedDates;
  }

  Future<bool> updateAvailability(Map<String, dynamic> availabilityData) async {
    try {
      isSaving.value = true;

      await _firebaseService.updateMediumAvailability(currentMediumId, availabilityData);
      availability.value = availabilityData;

      debugPrint('✅ Disponibilidade atualizada');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar disponibilidade: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void updateMinimumSessionPrice(double price) {
    minimumSessionPrice.value = price;
  }

  void updatePaymentMethod(String method, bool accepted) {
    switch (method) {
      case 'credits':
        acceptsCredits.value = accepted;
        break;
      case 'cards':
        acceptsCards.value = accepted;
        break;
      case 'pix':
        acceptsPix.value = accepted;
        break;
    }
  }

  Future<void> toggleAvailabilityStatus() async {
    try {
      final newStatus = !isAvailable.value;
      isAvailable.value = newStatus;

      await _firebaseService.updateMediumAvailabilityStatus(currentMediumId, newStatus);

      if (mediumProfile.value != null) {
        final updatedData = mediumProfile.value!.toMap();
        updatedData['isAvailable'] = newStatus;
        mediumProfile.value = MediumModel.fromMap(updatedData, currentMediumId);
      }

      debugPrint('✅ Status de disponibilidade atualizado: $newStatus');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar disponibilidade: $e');
      isAvailable.value = !isAvailable.value;
    }
  }

  Future<void> updateOnlineStatus(String status, {String? message}) async {
    try {
      currentStatus.value = status;
      customStatusMessage.value = message ?? '';
      isOnline.value = status != 'offline';

      await _firebaseService.updateMediumData(currentMediumId, {
        'status': status,
        'statusMessage': message ?? '',
        'lastSeen': DateTime.now(),
      });

      debugPrint('✅ Status online atualizado: $status');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status online: $e');
    }
  }

  String getStatusText() {
    if (!isAvailable.value) return 'Indisponível';

    switch (currentStatus.value) {
      case 'online':
        return 'Online';
      case 'busy':
        return 'Ocupado';
      case 'away':
        return 'Ausente';
      default:
        return 'Offline';
    }
  }

  Color getStatusColor() {
    if (!isAvailable.value) return Colors.grey;

    switch (currentStatus.value) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'away':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  double getCompletionRate() {
    if (totalAppointments.value == 0) return 0.0;
    return (completedAppointments.value / totalAppointments.value) * 100;
  }

  double getCancellationRate() {
    if (totalAppointments.value == 0) return 0.0;
    return (canceledAppointments.value / totalAppointments.value) * 100;
  }

  String getPerformanceLevel() {
    final rating = averageRating.value;
    final completionRate = getCompletionRate();

    if (rating >= 4.5 && completionRate >= 90) return 'Excelente';
    if (rating >= 4.0 && completionRate >= 80) return 'Muito Bom';
    if (rating >= 3.5 && completionRate >= 70) return 'Bom';
    if (rating >= 3.0 && completionRate >= 60) return 'Regular';
    return 'Iniciante';
  }

  bool canAcceptNewAppointments() {
    return isAvailable.value &&
        currentStatus.value == 'online' &&
        mediumProfile.value?.isActive == true;
  }

  @override
  void onClose() {
    debugPrint('=== MediumAdminController.onClose() ===');
    super.onClose();
  }
}
