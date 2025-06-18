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

  // Configurações de Notificação
  final RxBool newAppointments = true.obs;
  final RxBool appointmentReminders = true.obs;
  final RxBool paymentNotifications = true.obs;
  final RxBool reviewNotifications = true.obs;
  final RxBool systemUpdates = true.obs;

  // Configurações de Consulta
  final RxBool autoAcceptAppointments = false.obs;
  final RxInt bufferTimeBetweenAppointments = 15.obs;
  final RxInt maxDailyAppointments = 10.obs;
  final RxBool allowCancellations = true.obs;
  final RxInt cancellationDeadlineHours = 24.obs;

  // Configurações de Interface
  final RxBool isDarkMode = false.obs;
  final RxString language = 'pt'.obs;
  final RxString timezone = 'America/Sao_Paulo'.obs;

  // Configurações de Privacidade
  final RxBool showOnlineStatus = true.obs;
  final RxBool allowDirectMessages = true.obs;
  final RxBool shareAnalytics = false.obs;

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
    // Notificações
    final notifications = data['notifications'] as Map<String, dynamic>? ?? {};
    newAppointments.value = notifications['newAppointments'] ?? true;
    appointmentReminders.value = notifications['appointmentReminders'] ?? true;
    paymentNotifications.value = notifications['paymentNotifications'] ?? true;
    reviewNotifications.value = notifications['reviewNotifications'] ?? true;
    systemUpdates.value = notifications['systemUpdates'] ?? true;

    // Consultas
    autoAcceptAppointments.value = data['autoAcceptAppointments'] ?? false;
    bufferTimeBetweenAppointments.value = data['bufferTimeBetweenAppointments'] ?? 15;
    maxDailyAppointments.value = data['maxDailyAppointments'] ?? 10;
    allowCancellations.value = data['allowCancellations'] ?? true;
    cancellationDeadlineHours.value = data['cancellationDeadlineHours'] ?? 24;

    // Interface
    isDarkMode.value = data['isDarkMode'] ?? false;
    language.value = data['language'] ?? 'pt';
    timezone.value = data['timezone'] ?? 'America/Sao_Paulo';

    // Privacidade
    final privacy = data['privacy'] as Map<String, dynamic>? ?? {};
    showOnlineStatus.value = privacy['showOnlineStatus'] ?? true;
    allowDirectMessages.value = privacy['allowDirectMessages'] ?? true;
    shareAnalytics.value = privacy['shareAnalytics'] ?? false;
  }

  Map<String, dynamic> _buildSettingsData() {
    return {
      'notifications': {
        'newAppointments': newAppointments.value,
        'appointmentReminders': appointmentReminders.value,
        'paymentNotifications': paymentNotifications.value,
        'reviewNotifications': reviewNotifications.value,
        'systemUpdates': systemUpdates.value,
      },
      'autoAcceptAppointments': autoAcceptAppointments.value,
      'bufferTimeBetweenAppointments': bufferTimeBetweenAppointments.value,
      'maxDailyAppointments': maxDailyAppointments.value,
      'allowCancellations': allowCancellations.value,
      'cancellationDeadlineHours': cancellationDeadlineHours.value,
      'isDarkMode': isDarkMode.value,
      'language': language.value,
      'timezone': timezone.value,
      'privacy': {
        'showOnlineStatus': showOnlineStatus.value,
        'allowDirectMessages': allowDirectMessages.value,
        'shareAnalytics': shareAnalytics.value,
      },
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
        Get.snackbar(
          'Configurações Salvas',
          'Suas configurações foram atualizadas com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível salvar as configurações');
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

  // Métodos para atualizar configurações específicas
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
    }
  }

  void updateAutoAcceptAppointments(bool value) {
    autoAcceptAppointments.value = value;
  }

  void updateBufferTime(int minutes) {
    bufferTimeBetweenAppointments.value = minutes;
  }

  void updateMaxDailyAppointments(int max) {
    maxDailyAppointments.value = max;
  }

  void updateCancellationPolicy(bool allowCancellations, int deadlineHours) {
    this.allowCancellations.value = allowCancellations;
    cancellationDeadlineHours.value = deadlineHours;
  }

  void updateTheme(bool darkMode) {
    isDarkMode.value = darkMode;
  }

  void updateLanguage(String lang) {
    language.value = lang;
  }

  void updateTimezone(String tz) {
    timezone.value = tz;
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
    }
  }

  Future<bool> resetAllSettings() async {
    try {
      debugPrint('=== resetAllSettings() ===');

      // Confirmar com o usuário
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF2A2A40),
          title: const Text(
            'Resetar Configurações',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tem certeza que deseja restaurar todas as configurações para os valores padrão?',
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

      // Resetar para valores padrão
      _resetToDefaults();

      // Salvar configurações padrão
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
    // Notificações
    newAppointments.value = true;
    appointmentReminders.value = true;
    paymentNotifications.value = true;
    reviewNotifications.value = true;
    systemUpdates.value = true;

    // Consultas
    autoAcceptAppointments.value = false;
    bufferTimeBetweenAppointments.value = 15;
    maxDailyAppointments.value = 10;
    allowCancellations.value = true;
    cancellationDeadlineHours.value = 24;

    // Interface
    isDarkMode.value = false;
    language.value = 'pt';
    timezone.value = 'America/Sao_Paulo';

    // Privacidade
    showOnlineStatus.value = true;
    allowDirectMessages.value = true;
    shareAnalytics.value = false;
  }

  Future<void> exportSettings() async {
    try {
      debugPrint('=== exportSettings() ===');

      final settingsData = _buildSettingsData();

      // Implementar exportação das configurações
      // Por enquanto, apenas mostrar uma mensagem
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

      // Implementar importação das configurações
      // Por enquanto, apenas mostrar uma mensagem
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

  Future<void> refreshSettings() async {
    await loadSettings();
  }

  // Getters para facilitar o acesso
  bool getNotificationSetting(String key) {
    switch (key) {
      case 'newAppointments':
        return newAppointments.value;
      case 'appointmentReminders':
        return appointmentReminders.value;
      case 'paymentNotifications':
        return paymentNotifications.value;
      case 'reviewNotifications':
        return reviewNotifications.value;
      case 'systemUpdates':
        return systemUpdates.value;
      default:
        return true;
    }
  }

  bool getPrivacySetting(String key) {
    switch (key) {
      case 'showOnlineStatus':
        return showOnlineStatus.value;
      case 'allowDirectMessages':
        return allowDirectMessages.value;
      case 'shareAnalytics':
        return shareAnalytics.value;
      default:
        return true;
    }
  }

  Map<String, String> get availableLanguages => {
    'pt': 'Português',
    'en': 'English',
    'es': 'Español',
  };

  Map<String, String> get availableTimezones => {
    'America/Sao_Paulo': 'São Paulo (GMT-3)',
    'America/New_York': 'New York (GMT-5)',
    'Europe/London': 'London (GMT+0)',
    'Europe/Madrid': 'Madrid (GMT+1)',
  };
}
