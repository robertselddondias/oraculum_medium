import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class SettingsController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxMap<String, dynamic> settings = RxMap<String, dynamic>({});

  final RxBool newAppointments = true.obs;
  final RxBool appointmentReminders = true.obs;
  final RxBool paymentNotifications = true.obs;
  final RxBool reviewNotifications = true.obs;
  final RxBool systemUpdates = true.obs;
  final RxBool promotionalEmails = false.obs;
  final RxBool maintenanceAlerts = true.obs;

  final RxBool autoAcceptAppointments = false.obs;
  final RxInt bufferTimeBetweenAppointments = 15.obs;
  final RxInt maxDailyAppointments = 10.obs;
  final RxBool allowCancellations = true.obs;
  final RxInt cancellationDeadlineHours = 24.obs;

  final RxBool isDarkMode = false.obs;
  final RxString language = 'pt'.obs;
  final RxString timezone = 'America/Sao_Paulo'.obs;
  final RxBool enableAnimations = true.obs;
  final RxBool enableHapticFeedback = true.obs;
  final RxString defaultCurrency = 'BRL'.obs;

  final RxBool showOnlineStatus = true.obs;
  final RxBool allowDirectMessages = true.obs;
  final RxBool shareAnalytics = false.obs;
  final RxBool sharePerformanceData = false.obs;
  final RxBool allowProfileIndexing = true.obs;

  final RxBool enableTwoFactor = false.obs;
  final RxBool enableEmailVerification = true.obs;
  final RxBool logSecurityEvents = true.obs;
  final RxBool requirePasswordChange = false.obs;

  final RxDouble soundVolume = 0.8.obs;
  final RxBool enableNotificationSounds = true.obs;
  final RxBool enableVibration = true.obs;
  final RxString notificationTone = 'default'.obs;

  final RxBool enableDataBackup = true.obs;
  final RxString backupFrequency = 'weekly'.obs;
  final RxBool autoSync = true.obs;
  final RxBool compressBackups = true.obs;

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadSettings() ===');
      isLoading.value = true;

      final settingsData = await _mediumService.getMediumSettings(currentMediumId!);
      settings.value = settingsData;

      _parseSettings(settingsData);

      debugPrint('✅ Configurações carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
      Get.snackbar('Erro', 'Não foi possível carregar as configurações');
    } finally {
      isLoading.value = false;
    }
  }

  void _parseSettings(Map<String, dynamic> data) {
    final notifications = data['notifications'] as Map<String, dynamic>? ?? {};
    newAppointments.value = notifications['newAppointments'] ?? true;
    appointmentReminders.value = notifications['appointmentReminders'] ?? true;
    paymentNotifications.value = notifications['paymentNotifications'] ?? true;
    reviewNotifications.value = notifications['reviewNotifications'] ?? true;
    systemUpdates.value = notifications['systemUpdates'] ?? true;
    promotionalEmails.value = notifications['promotionalEmails'] ?? false;
    maintenanceAlerts.value = notifications['maintenanceAlerts'] ?? true;

    autoAcceptAppointments.value = data['autoAcceptAppointments'] ?? false;
    bufferTimeBetweenAppointments.value = data['bufferTimeBetweenAppointments'] ?? 15;
    maxDailyAppointments.value = data['maxDailyAppointments'] ?? 10;
    allowCancellations.value = data['allowCancellations'] ?? true;
    cancellationDeadlineHours.value = data['cancellationDeadlineHours'] ?? 24;

    final interface = data['interface'] as Map<String, dynamic>? ?? {};
    isDarkMode.value = interface['isDarkMode'] ?? false;
    language.value = interface['language'] ?? 'pt';
    timezone.value = interface['timezone'] ?? 'America/Sao_Paulo';
    enableAnimations.value = interface['enableAnimations'] ?? true;
    enableHapticFeedback.value = interface['enableHapticFeedback'] ?? true;
    defaultCurrency.value = interface['defaultCurrency'] ?? 'BRL';

    final privacy = data['privacy'] as Map<String, dynamic>? ?? {};
    showOnlineStatus.value = privacy['showOnlineStatus'] ?? true;
    allowDirectMessages.value = privacy['allowDirectMessages'] ?? true;
    shareAnalytics.value = privacy['shareAnalytics'] ?? false;
    sharePerformanceData.value = privacy['sharePerformanceData'] ?? false;
    allowProfileIndexing.value = privacy['allowProfileIndexing'] ?? true;

    final security = data['security'] as Map<String, dynamic>? ?? {};
    enableTwoFactor.value = security['enableTwoFactor'] ?? false;
    enableEmailVerification.value = security['enableEmailVerification'] ?? true;
    logSecurityEvents.value = security['logSecurityEvents'] ?? true;
    requirePasswordChange.value = security['requirePasswordChange'] ?? false;

    final audio = data['audio'] as Map<String, dynamic>? ?? {};
    soundVolume.value = (audio['soundVolume'] ?? 0.8).toDouble();
    enableNotificationSounds.value = audio['enableNotificationSounds'] ?? true;
    enableVibration.value = audio['enableVibration'] ?? true;
    notificationTone.value = audio['notificationTone'] ?? 'default';

    final backup = data['backup'] as Map<String, dynamic>? ?? {};
    enableDataBackup.value = backup['enableDataBackup'] ?? true;
    backupFrequency.value = backup['backupFrequency'] ?? 'weekly';
    autoSync.value = backup['autoSync'] ?? true;
    compressBackups.value = backup['compressBackups'] ?? true;
  }

  Map<String, dynamic> _buildSettingsData() {
    return {
      'notifications': {
        'newAppointments': newAppointments.value,
        'appointmentReminders': appointmentReminders.value,
        'paymentNotifications': paymentNotifications.value,
        'reviewNotifications': reviewNotifications.value,
        'systemUpdates': systemUpdates.value,
        'promotionalEmails': promotionalEmails.value,
        'maintenanceAlerts': maintenanceAlerts.value,
      },
      'autoAcceptAppointments': autoAcceptAppointments.value,
      'bufferTimeBetweenAppointments': bufferTimeBetweenAppointments.value,
      'maxDailyAppointments': maxDailyAppointments.value,
      'allowCancellations': allowCancellations.value,
      'cancellationDeadlineHours': cancellationDeadlineHours.value,
      'interface': {
        'isDarkMode': isDarkMode.value,
        'language': language.value,
        'timezone': timezone.value,
        'enableAnimations': enableAnimations.value,
        'enableHapticFeedback': enableHapticFeedback.value,
        'defaultCurrency': defaultCurrency.value,
      },
      'privacy': {
        'showOnlineStatus': showOnlineStatus.value,
        'allowDirectMessages': allowDirectMessages.value,
        'shareAnalytics': shareAnalytics.value,
        'sharePerformanceData': sharePerformanceData.value,
        'allowProfileIndexing': allowProfileIndexing.value,
      },
      'security': {
        'enableTwoFactor': enableTwoFactor.value,
        'enableEmailVerification': enableEmailVerification.value,
        'logSecurityEvents': logSecurityEvents.value,
        'requirePasswordChange': requirePasswordChange.value,
      },
      'audio': {
        'soundVolume': soundVolume.value,
        'enableNotificationSounds': enableNotificationSounds.value,
        'enableVibration': enableVibration.value,
        'notificationTone': notificationTone.value,
      },
      'backup': {
        'enableDataBackup': enableDataBackup.value,
        'backupFrequency': backupFrequency.value,
        'autoSync': autoSync.value,
        'compressBackups': compressBackups.value,
      },
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<bool> saveSettings() async {
    if (currentMediumId == null) return false;

    try {
      debugPrint('=== saveSettings() ===');
      isSaving.value = true;

      final settingsData = _buildSettingsData();

      final success = await _mediumService.updateMediumSettings(currentMediumId!, settingsData);

      if (success) {
        settings.value = settingsData;
        debugPrint('✅ Configurações salvas com sucesso');
        Get.snackbar(
          'Sucesso',
          'Configurações salvas com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Erro ao salvar configurações');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações: $e');
      Get.snackbar('Erro', 'Erro ao salvar configurações: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> resetSettings() async {
    try {
      debugPrint('=== resetSettings() ===');

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Resetar Configurações'),
          content: const Text(
            'Tem certeza de que deseja resetar todas as configurações para os valores padrão? Esta ação não pode ser desfeita.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Resetar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;

      _resetToDefaults();

      final success = await saveSettings();

      if (success) {
        Get.snackbar(
          'Configurações Resetadas',
          'Todas as configurações foram restauradas para os valores padrão',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao resetar configurações: $e');
      return false;
    }
  }

  void _resetToDefaults() {
    newAppointments.value = true;
    appointmentReminders.value = true;
    paymentNotifications.value = true;
    reviewNotifications.value = true;
    systemUpdates.value = true;
    promotionalEmails.value = false;
    maintenanceAlerts.value = true;

    autoAcceptAppointments.value = false;
    bufferTimeBetweenAppointments.value = 15;
    maxDailyAppointments.value = 10;
    allowCancellations.value = true;
    cancellationDeadlineHours.value = 24;

    isDarkMode.value = false;
    language.value = 'pt';
    timezone.value = 'America/Sao_Paulo';
    enableAnimations.value = true;
    enableHapticFeedback.value = true;
    defaultCurrency.value = 'BRL';

    showOnlineStatus.value = true;
    allowDirectMessages.value = true;
    shareAnalytics.value = false;
    sharePerformanceData.value = false;
    allowProfileIndexing.value = true;

    enableTwoFactor.value = false;
    enableEmailVerification.value = true;
    logSecurityEvents.value = true;
    requirePasswordChange.value = false;

    soundVolume.value = 0.8;
    enableNotificationSounds.value = true;
    enableVibration.value = true;
    notificationTone.value = 'default';

    enableDataBackup.value = true;
    backupFrequency.value = 'weekly';
    autoSync.value = true;
    compressBackups.value = true;
  }

  Future<void> exportSettings() async {
    try {
      debugPrint('=== exportSettings() ===');

      final settingsData = _buildSettingsData();

      Get.snackbar(
        'Em Desenvolvimento',
        'Exportação de configurações será implementada em breve',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Erro ao exportar configurações: $e');
      Get.snackbar('Erro', 'Erro ao exportar configurações');
    }
  }

  Future<void> importSettings() async {
    try {
      debugPrint('=== importSettings() ===');

      Get.snackbar(
        'Em Desenvolvimento',
        'Importação de configurações será implementada em breve',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Erro ao importar configurações: $e');
      Get.snackbar('Erro', 'Erro ao importar configurações');
    }
  }

  void updateNotificationSetting(String key, bool value) {
    switch (key) {
      case 'newAppointments':
        newAppointments.value = value;
        break;
      case 'appointmentReminders':
        appointmentReminders.value = value;
        break;
      case 'paymentNotifications':
        paymentNotifications.value = value;
        break;
      case 'reviewNotifications':
        reviewNotifications.value = value;
        break;
      case 'systemUpdates':
        systemUpdates.value = value;
        break;
      case 'promotionalEmails':
        promotionalEmails.value = value;
        break;
      case 'maintenanceAlerts':
        maintenanceAlerts.value = value;
        break;
    }
  }

  void updatePrivacySetting(String key, bool value) {
    switch (key) {
      case 'showOnlineStatus':
        showOnlineStatus.value = value;
        break;
      case 'allowDirectMessages':
        allowDirectMessages.value = value;
        break;
      case 'shareAnalytics':
        shareAnalytics.value = value;
        break;
      case 'sharePerformanceData':
        sharePerformanceData.value = value;
        break;
      case 'allowProfileIndexing':
        allowProfileIndexing.value = value;
        break;
    }
  }

  void updateSecuritySetting(String key, bool value) {
    switch (key) {
      case 'enableTwoFactor':
        enableTwoFactor.value = value;
        break;
      case 'enableEmailVerification':
        enableEmailVerification.value = value;
        break;
      case 'logSecurityEvents':
        logSecurityEvents.value = value;
        break;
      case 'requirePasswordChange':
        requirePasswordChange.value = value;
        break;
    }
  }

  Future<bool> validateSettings() async {
    if (bufferTimeBetweenAppointments.value < 5 || bufferTimeBetweenAppointments.value > 60) {
      Get.snackbar('Erro', 'Tempo de buffer deve estar entre 5 e 60 minutos');
      return false;
    }

    if (maxDailyAppointments.value < 1 || maxDailyAppointments.value > 50) {
      Get.snackbar('Erro', 'Máximo de consultas diárias deve estar entre 1 e 50');
      return false;
    }

    if (cancellationDeadlineHours.value < 1 || cancellationDeadlineHours.value > 168) {
      Get.snackbar('Erro', 'Prazo de cancelamento deve estar entre 1 e 168 horas');
      return false;
    }

    if (soundVolume.value < 0.0 || soundVolume.value > 1.0) {
      Get.snackbar('Erro', 'Volume do som deve estar entre 0 e 1');
      return false;
    }

    return true;
  }

  Future<void> clearCache() async {
    try {
      debugPrint('=== clearCache() ===');

      settings.clear();

      Get.snackbar(
        'Cache Limpo',
        'Cache das configurações foi limpo com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Erro ao limpar cache: $e');
      Get.snackbar('Erro', 'Erro ao limpar cache');
    }
  }

  Map<String, dynamic> getNotificationSettings() {
    return {
      'newAppointments': newAppointments.value,
      'appointmentReminders': appointmentReminders.value,
      'paymentNotifications': paymentNotifications.value,
      'reviewNotifications': reviewNotifications.value,
      'systemUpdates': systemUpdates.value,
      'promotionalEmails': promotionalEmails.value,
      'maintenanceAlerts': maintenanceAlerts.value,
    };
  }

  Map<String, dynamic> getPrivacySettings() {
    return {
      'showOnlineStatus': showOnlineStatus.value,
      'allowDirectMessages': allowDirectMessages.value,
      'shareAnalytics': shareAnalytics.value,
      'sharePerformanceData': sharePerformanceData.value,
      'allowProfileIndexing': allowProfileIndexing.value,
    };
  }

  Map<String, dynamic> getSecuritySettings() {
    return {
      'enableTwoFactor': enableTwoFactor.value,
      'enableEmailVerification': enableEmailVerification.value,
      'logSecurityEvents': logSecurityEvents.value,
      'requirePasswordChange': requirePasswordChange.value,
    };
  }
}
