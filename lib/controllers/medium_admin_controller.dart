import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/models/availability_settings_model.dart';
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

  final availabilitySettings = Rxn<AvailabilitySettingsModel>();

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

  final todayAppointments = 0.obs;
  final weeklyAppointments = 0.obs;
  final monthlyAppointments = 0.obs;
  final pendingAppointments = 0.obs;
  final activeClients = 0.obs;
  final newClients = 0.obs;

  final performanceMetrics = <String, dynamic>{}.obs;
  final recentActivity = <Map<String, dynamic>>[].obs;

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
    performanceMetrics.clear();
    recentActivity.clear();
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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

    totalAppointments.value = mediumData['totalAppointments'] ?? 0;
    averageRating.value = (mediumData['rating'] ?? 0.0).toDouble();
    totalReviews.value = mediumData['totalReviews'] ?? 0;
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

        debugPrint('✅ Configurações do médium carregadas');
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
      final stats = await _mediumService.getMediumStats(currentMediumId);

      totalEarnings.value = stats.totalEarnings;
      monthlyEarnings.value = stats.monthlyEarnings;
      completedAppointments.value = stats.completedAppointments;
      totalAppointments.value = stats.totalAppointments;
      averageRating.value = stats.averageRating;

      weeklyAppointments.value = stats.weeklyAppointments;
      monthlyAppointments.value = stats.monthlyAppointments;

      final appointments = await _mediumService.getMediumAppointments(currentMediumId);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      todayAppointments.value = appointments.where((apt) =>
      apt.dateTime.year == today.year &&
          apt.dateTime.month == today.month &&
          apt.dateTime.day == today.day
      ).length;

      pendingAppointments.value = appointments.where((apt) =>
      apt.status == 'pending'
      ).length;

      canceledAppointments.value = appointments.where((apt) =>
      apt.status == 'canceled'
      ).length;

      final uniqueClients = appointments.map((apt) => apt.userId).toSet();
      activeClients.value = uniqueClients.length;

      final lastMonth = now.subtract(const Duration(days: 30));
      newClients.value = appointments.where((apt) =>
          apt.dateTime.isAfter(lastMonth)
      ).map((apt) => apt.userId).toSet().length;

      performanceMetrics.value = {
        'totalAppointments': totalAppointments.value,
        'completedAppointments': completedAppointments.value,
        'canceledAppointments': canceledAppointments.value,
        'totalEarnings': totalEarnings.value,
        'monthlyEarnings': monthlyEarnings.value,
        'averageRating': averageRating.value,
        'todayAppointments': todayAppointments.value,
        'weeklyAppointments': weeklyAppointments.value,
        'monthlyAppointments': monthlyAppointments.value,
        'pendingAppointments': pendingAppointments.value,
        'activeClients': activeClients.value,
        'newClients': newClients.value,
        'responseTime': stats.responseTime,
      };

      debugPrint('✅ Dados de performance carregados');
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados de performance: $e');
    }
  }

  AvailabilitySettingsModel getCurrentSettings() {
    final sanitizedAvailability = Map<String, dynamic>.from(availability.value);

    if (sanitizedAvailability['blockedDates'] != null) {
      final blockedDates = sanitizedAvailability['blockedDates'] as List;
      sanitizedAvailability['blockedDates'] = blockedDates.map((date) {
        if (date is DateTime) {
          return date.toIso8601String();
        }
        return date.toString();
      }).toList();
    }

    return AvailabilitySettingsModel(
      autoAcceptAppointments: autoAcceptAppointments.value,
      bufferTime: bufferTime.value,
      maxDailyAppointments: maxDailyAppointments.value,
      consultationDurations: consultationDurations.value,
      availability: sanitizedAvailability,
      isAvailable: isAvailable.value,
      notificationSettings: notificationSettings.value,
      minimumSessionPrice: minimumSessionPrice.value,
      acceptsCredits: acceptsCredits.value,
      acceptsCards: acceptsCards.value,
      acceptsPix: acceptsPix.value,
      minAdvanceBooking: minAdvanceBooking.value,
      maxAdvanceBooking: maxAdvanceBooking.value,
      allowSameDayBooking: allowSameDayBooking.value,
      updatedAt: DateTime.now(),
    );
  }

  void updateFromSettings(AvailabilitySettingsModel settings) {
    autoAcceptAppointments.value = settings.autoAcceptAppointments;
    bufferTime.value = settings.bufferTime;
    maxDailyAppointments.value = settings.maxDailyAppointments;
    consultationDurations.value = settings.consultationDurations;
    availability.value = settings.availability;
    isAvailable.value = settings.isAvailable;
    notificationSettings.value = settings.notificationSettings;
    minimumSessionPrice.value = settings.minimumSessionPrice;
    acceptsCredits.value = settings.acceptsCredits;
    acceptsCards.value = settings.acceptsCards;
    acceptsPix.value = settings.acceptsPix;
    minAdvanceBooking.value = settings.minAdvanceBooking;
    maxAdvanceBooking.value = settings.maxAdvanceBooking;
    allowSameDayBooking.value = settings.allowSameDayBooking;

    availabilitySettings.value = settings;
  }

  Future<bool> saveAvailabilitySettings() async {
    try {
      isSaving.value = true;

      final settings = getCurrentSettings();

      if (!settings.validate()) {
        Get.snackbar('Erro', 'Configurações inválidas. Verifique os dados inseridos.');
        return false;
      }

      await _firebaseService.updateMediumAvailability(currentMediumId, settings.toMap());
      await _firebaseService.updateMediumSettings(currentMediumId, settings.toMap());
      await _firebaseService.updateMediumData(currentMediumId, {
        'isAvailable': settings.isAvailable,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      availabilitySettings.value = settings;

      debugPrint('✅ Configurações de disponibilidade salvas');
      Get.snackbar('Sucesso', 'Configurações salvas com sucesso!');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações: $e');
      Get.snackbar('Erro', 'Erro ao salvar configurações: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _sanitizeFirestoreData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    if (sanitized['updatedAt'] != null) {
      final updatedAt = sanitized['updatedAt'];
      if (updatedAt is String) {
        sanitized['updatedAt'] = DateTime.parse(updatedAt);
      } else if (updatedAt.runtimeType.toString().contains('Timestamp')) {
        sanitized['updatedAt'] = updatedAt.toDate();
      } else if (updatedAt is! DateTime) {
        sanitized['updatedAt'] = DateTime.now();
      }
    } else {
      sanitized['updatedAt'] = DateTime.now();
    }

    if (sanitized['blockedDates'] != null) {
      final blockedDates = sanitized['blockedDates'] as List?;
      if (blockedDates != null) {
        sanitized['blockedDates'] = blockedDates.map((date) {
          if (date is String) {
            return DateTime.parse(date);
          } else if (date.runtimeType.toString().contains('Timestamp')) {
            return date.toDate();
          } else if (date is DateTime) {
            return date;
          }
          return DateTime.now();
        }).toList();
      }
    }

    return sanitized;
  }

  Future<void> loadAvailabilitySettings() async {
    try {
      isLoading.value = true;

      final availabilityDoc = await _firebaseService.getMediumAvailability(currentMediumId);
      final settingsDoc = await _firebaseService.getMediumSettings(currentMediumId);

      Map<String, dynamic> combinedData = {};

      if (availabilityDoc.exists) {
        final availabilityData = _sanitizeFirestoreData(availabilityDoc.data() as Map<String, dynamic>);
        combinedData.addAll(availabilityData);
      }

      if (settingsDoc.exists) {
        final settingsData = _sanitizeFirestoreData(settingsDoc.data() as Map<String, dynamic>);
        combinedData.addAll(settingsData);
      }

      if (combinedData.isNotEmpty) {
        final settings = AvailabilitySettingsModel.fromMap(combinedData);
        updateFromSettings(settings);
      }

      debugPrint('✅ Configurações de disponibilidade carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      isSaving.value = true;

      await _firebaseService.updateMediumSettings(currentMediumId, newSettings);
      await _firebaseService.updateMediumData(currentMediumId, {
        'updatedAt': DateTime.now().toIso8601String(),
      });

      settings.addAll(newSettings);

      debugPrint('✅ Configurações atualizadas');
      Get.snackbar('Sucesso', 'Configurações atualizadas com sucesso!');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar configurações: $e');
      Get.snackbar('Erro', 'Erro ao atualizar configurações: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isSaving.value = true;

      profileData['updatedAt'] = DateTime.now().toIso8601String();

      await _firebaseService.updateMediumData(currentMediumId, profileData);

      if (mediumProfile.value != null) {
        final updatedData = {
          ...mediumProfile.value!.toMap(),
          ...profileData,
        };
        mediumProfile.value = MediumModel.fromMap(updatedData, currentMediumId);
      }

      debugPrint('✅ Perfil atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleAvailability() async {
    try {
      final newStatus = !isAvailable.value;

      await _firebaseService.updateMediumData(currentMediumId, {
        'isAvailable': newStatus,
        'status': newStatus ? 'available' : 'offline',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      isAvailable.value = newStatus;
      currentStatus.value = newStatus ? 'available' : 'offline';

      debugPrint('✅ Status de disponibilidade alterado para: $newStatus');
    } catch (e) {
      debugPrint('❌ Erro ao alterar disponibilidade: $e');
      Get.snackbar('Erro', 'Erro ao alterar status de disponibilidade');
    }
  }

  Future<void> updateStatus(String status, [String? message]) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (message != null) {
        updateData['statusMessage'] = message;
      }

      await _firebaseService.updateMediumData(currentMediumId, updateData);

      currentStatus.value = status;
      if (message != null) {
        customStatusMessage.value = message;
      }

      debugPrint('✅ Status atualizado para: $status');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');
      Get.snackbar('Erro', 'Erro ao atualizar status');
    }
  }

  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      await loadMediumProfile();
      await _loadPerformanceData();
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> blockDate(DateTime date) async {
    try {
      final blockedDates = List<DateTime>.from(availability['blockedDates'] ?? []);

      if (!blockedDates.any((d) =>
      d.year == date.year && d.month == date.month && d.day == date.day)) {
        blockedDates.add(date);

        availability['blockedDates'] = blockedDates;

        await _firebaseService.updateMediumAvailability(currentMediumId, {
          'blockedDates': blockedDates.map((d) => d.toIso8601String()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        debugPrint('✅ Data bloqueada: ${date.toString()}');
        Get.snackbar('Sucesso', 'Data bloqueada com sucesso');
      }
    } catch (e) {
      debugPrint('❌ Erro ao bloquear data: $e');
      Get.snackbar('Erro', 'Erro ao bloquear data');
    }
  }

  Future<void> unblockDate(DateTime date) async {
    try {
      final blockedDates = List<DateTime>.from(availability['blockedDates'] ?? []);

      blockedDates.removeWhere((d) =>
      d.year == date.year && d.month == date.month && d.day == date.day);

      availability['blockedDates'] = blockedDates;

      await _firebaseService.updateMediumAvailability(currentMediumId, {
        'blockedDates': blockedDates.map((d) => d.toIso8601String()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Data desbloqueada: ${date.toString()}');
      Get.snackbar('Sucesso', 'Data desbloqueada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao desbloquear data: $e');
      Get.snackbar('Erro', 'Erro ao desbloquear data');
    }
  }

  void updateDayAvailability(String day, Map<String, dynamic> dayData) {
    availability[day] = dayData;

    saveAvailabilitySettings();
  }

  void addBreak(String day, Map<String, String> breakData) {
    final dayAvailability = Map<String, dynamic>.from(availability[day] ?? {});
    final breaks = List<Map<String, String>>.from(dayAvailability['breaks'] ?? []);

    breaks.add(breakData);
    dayAvailability['breaks'] = breaks;
    availability[day] = dayAvailability;

    saveAvailabilitySettings();
  }

  void removeBreak(String day, int breakIndex) {
    final dayAvailability = Map<String, dynamic>.from(availability[day] ?? {});
    final breaks = List<Map<String, String>>.from(dayAvailability['breaks'] ?? []);

    if (breakIndex >= 0 && breakIndex < breaks.length) {
      breaks.removeAt(breakIndex);
      dayAvailability['breaks'] = breaks;
      availability[day] = dayAvailability;

      saveAvailabilitySettings();
    }
  }

  void updateConsultationDurations(List<int> durations) {
    consultationDurations.value = durations;
  }

  void addConsultationDuration(int duration) {
    if (!consultationDurations.contains(duration)) {
      consultationDurations.add(duration);
      consultationDurations.sort();
    }
  }

  void removeConsultationDuration(int duration) {
    consultationDurations.remove(duration);
  }

  void updatePaymentSettings({
    bool? acceptsCredits,
    bool? acceptsCards,
    bool? acceptsPix,
    double? minimumPrice,
  }) {
    if (acceptsCredits != null) this.acceptsCredits.value = acceptsCredits;
    if (acceptsCards != null) this.acceptsCards.value = acceptsCards;
    if (acceptsPix != null) this.acceptsPix.value = acceptsPix;
    if (minimumPrice != null) minimumSessionPrice.value = minimumPrice;
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

  int getDefaultDuration() {
    return consultationDurations.isNotEmpty ? consultationDurations.first : 30;
  }

  void updateDefaultDuration(int duration) {
    if (!consultationDurations.contains(duration)) {
      consultationDurations.add(duration);
    }
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

      availabilityData['updatedAt'] = DateTime.now().toIso8601String();

      await _firebaseService.updateMediumAvailability(currentMediumId, availabilityData);
      availability.value = availabilityData;

      debugPrint('✅ Disponibilidade atualizada');
      Get.snackbar('Sucesso', 'Disponibilidade atualizada com sucesso!');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar disponibilidade: $e');
      Get.snackbar('Erro', 'Erro ao atualizar disponibilidade: $e');
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

      await _firebaseService.updateMediumData(currentMediumId, {
        'isAvailable': newStatus,
        'status': newStatus ? 'available' : 'offline',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      isAvailable.value = newStatus;
      currentStatus.value = newStatus ? 'available' : 'offline';

      if (mediumProfile.value != null) {
        final updatedData = mediumProfile.value!.toMap();
        updatedData['isAvailable'] = newStatus;
        updatedData['status'] = newStatus ? 'available' : 'offline';
        mediumProfile.value = MediumModel.fromMap(updatedData, currentMediumId);
      }

      debugPrint('✅ Status de disponibilidade alterado para: $newStatus');
      Get.snackbar(
        'Status Atualizado',
        newStatus ? 'Você está agora disponível' : 'Você está agora indisponível',
        backgroundColor: newStatus ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Erro ao alterar disponibilidade: $e');
      Get.snackbar('Erro', 'Erro ao alterar status de disponibilidade');
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
        'lastSeen': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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

  Future<bool> updateMediumAvailabilityStatus(bool newStatus) async {
    try {
      await _firebaseService.updateMediumData(currentMediumId, {
        'isAvailable': newStatus,
        'lastSeen': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      isAvailable.value = newStatus;

      if (mediumProfile.value != null) {
        final updatedData = mediumProfile.value!.toMap();
        updatedData['isAvailable'] = newStatus;
        mediumProfile.value = MediumModel.fromMap(updatedData, currentMediumId);
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');
      isAvailable.value = !newStatus;
      return false;
    }
  }

  Map<String, dynamic> getPerformanceSummary() {
    return {
      'totalAppointments': totalAppointments.value,
      'completedAppointments': completedAppointments.value,
      'canceledAppointments': canceledAppointments.value,
      'totalEarnings': totalEarnings.value,
      'monthlyEarnings': monthlyEarnings.value,
      'averageRating': averageRating.value,
      'totalReviews': totalReviews.value,
      'todayAppointments': todayAppointments.value,
      'weeklyAppointments': weeklyAppointments.value,
      'monthlyAppointments': monthlyAppointments.value,
      'pendingAppointments': pendingAppointments.value,
      'activeClients': activeClients.value,
      'newClients': newClients.value,
    };
  }

  bool get isProfileComplete {
    final profile = mediumProfile.value;
    if (profile == null) return false;

    return profile.name.isNotEmpty &&
        profile.bio.isNotEmpty &&
        profile.specialties.isNotEmpty &&
        profile.pricePerMinute > 0;
  }

  bool get hasActiveSettings {
    return isAvailable.value &&
        consultationDurations.isNotEmpty &&
        (acceptsCredits.value || acceptsCards.value || acceptsPix.value);
  }

  String get completionStatus {
    if (!isProfileComplete) return 'Perfil incompleto';
    if (!hasActiveSettings) return 'Configurações pendentes';
    if (!isAvailable.value) return 'Indisponível';
    return 'Ativo';
  }

  Color get statusColor {
    if (!isProfileComplete) return Colors.red;
    if (!hasActiveSettings) return Colors.orange;
    if (!isAvailable.value) return Colors.grey;
    return Colors.green;
  }

  void resetToDefaults() {
    consultationDurations.value = [15, 30, 45, 60];
    bufferTime.value = 15;
    maxDailyAppointments.value = 10;
    autoAcceptAppointments.value = false;

    availability.value = {
      'monday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'tuesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'wednesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'thursday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'friday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '18:00', 'breaks': []},
      'saturday': {'isAvailable': false, 'startTime': '09:00', 'endTime': '17:00', 'breaks': []},
      'sunday': {'isAvailable': false, 'startTime': '10:00', 'endTime': '16:00', 'breaks': []},
      'blockedDates': <DateTime>[],
    };

    notificationSettings.value = {
      'newAppointments': true,
      'appointmentReminders': true,
      'paymentNotifications': true,
      'reviewNotifications': true,
      'promotionalEmails': false,
      'systemUpdates': true,
      'maintenanceAlerts': true,
    };
  }

  bool validateSettings() {
    if (consultationDurations.isEmpty) {
      Get.snackbar('Erro', 'Selecione pelo menos uma duração de consulta');
      return false;
    }

    if (bufferTime.value < 5 || bufferTime.value > 60) {
      Get.snackbar('Erro', 'Tempo entre consultas deve estar entre 5 e 60 minutos');
      return false;
    }

    if (maxDailyAppointments.value < 1 || maxDailyAppointments.value > 20) {
      Get.snackbar('Erro', 'Número máximo de consultas deve estar entre 1 e 20');
      return false;
    }

    return true;
  }

  Future<bool> validateAvailabilitySettings() async {
    if (bufferTime.value < 5 || bufferTime.value > 120) {
      Get.snackbar('Erro', 'Tempo de buffer deve estar entre 5 e 120 minutos');
      return false;
    }

    if (maxDailyAppointments.value < 1 || maxDailyAppointments.value > 100) {
      Get.snackbar('Erro', 'Máximo de consultas deve estar entre 1 e 100');
      return false;
    }

    if (minAdvanceBooking.value < 1 || minAdvanceBooking.value > 168) {
      Get.snackbar('Erro', 'Antecedência mínima deve estar entre 1 e 168 horas');
      return false;
    }

    if (maxAdvanceBooking.value < minAdvanceBooking.value) {
      Get.snackbar('Erro', 'Antecedência máxima deve ser maior que a mínima');
      return false;
    }

    if (minimumSessionPrice.value < 1.0 || minimumSessionPrice.value > 1000.0) {
      Get.snackbar('Erro', 'Preço mínimo deve estar entre R\$ 1,00 e R\$ 1.000,00');
      return false;
    }

    if (consultationDurations.isEmpty) {
      Get.snackbar('Erro', 'Deve haver pelo menos uma duração de consulta');
      return false;
    }

    if (!acceptsCredits.value && !acceptsCards.value && !acceptsPix.value) {
      Get.snackbar('Erro', 'Deve aceitar pelo menos um método de pagamento');
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    debugPrint('=== MediumAdminController.onClose() ===');
    super.onClose();
  }
}
