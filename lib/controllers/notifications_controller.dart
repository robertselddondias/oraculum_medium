import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class NotificationsController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxMap<String, bool> notificationSettings = RxMap<String, bool>({});

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadNotificationSettings();
  }

  Future<void> loadNotifications() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadNotifications() ===');
      isLoading.value = true;

      // Simular carregamento de notificações
      await Future.delayed(const Duration(milliseconds: 500));

      final mockNotifications = _generateMockNotifications();
      notifications.value = mockNotifications;

      unreadCount.value = mockNotifications
          .where((notification) => !(notification['isRead'] as bool))
          .length;

      debugPrint('✅ ${notifications.length} notificações carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar notificações: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotificationSettings() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadNotificationSettings() ===');

      final settings = await _mediumService.getMediumSettings(currentMediumId!);
      final notificationData = settings['notifications'] as Map<String, dynamic>? ?? {};

      notificationSettings.value = {
        'newAppointments': notificationData['newAppointments'] ?? true,
        'appointmentReminders': notificationData['appointmentReminders'] ?? true,
        'paymentNotifications': notificationData['paymentNotifications'] ?? true,
        'reviewNotifications': notificationData['reviewNotifications'] ?? true,
        'systemUpdates': notificationData['systemUpdates'] ?? true,
      };

      debugPrint('✅ Configurações de notificação carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
    }
  }

  List<Map<String, dynamic>> _generateMockNotifications() {
    return [
      {
        'id': '1',
        'title': 'Nova consulta agendada',
        'message': 'João Silva agendou uma consulta para hoje às 14:00',
        'type': 'appointment',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'icon': Icons.event,
        'color': Colors.blue,
      },
      {
        'id': '2',
        'title': 'Pagamento recebido',
        'message': 'Você recebeu R\$ 75,00 pela consulta com Maria Santos',
        'type': 'payment',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'id': '3',
        'title': 'Nova avaliação',
        'message': 'Carlos Oliveira deixou uma avaliação de 5 estrelas',
        'type': 'review',
        'isRead': true,
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'id': '4',
        'title': 'Lembrete de consulta',
        'message': 'Você tem uma consulta em 1 hora com Ana Costa',
        'type': 'reminder',
        'isRead': true,
        'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        'icon': Icons.alarm,
        'color': Colors.orange,
      },
    ];
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      unreadCount.value = notifications
          .where((notification) => !(notification['isRead'] as bool))
          .length;
    }
  }

  void markAllAsRead() {
    for (final notification in notifications) {
      notification['isRead'] = true;
    }
    unreadCount.value = 0;
    notifications.refresh();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n['id'] == notificationId);
    unreadCount.value = notifications
        .where((notification) => !(notification['isRead'] as bool))
        .length;
  }

  Future<bool> updateNotificationSetting(String key, bool value) async {
    if (currentMediumId == null) return false;

    try {
      debugPrint('=== updateNotificationSetting() ===');
      debugPrint('Key: $key, Value: $value');

      notificationSettings[key] = value;

      final settings = {
        'notifications': notificationSettings,
      };

      final success = await _mediumService.updateMediumSettings(currentMediumId!, settings);

      if (success) {
        Get.snackbar(
          'Configuração Atualizada',
          'Suas preferências de notificação foram salvas',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar configuração: $e');
      return false;
    }
  }

  bool getNotificationSetting(String key) {
    return notificationSettings[key] ?? true;
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  List<Map<String, dynamic>> getUnreadNotifications() {
    return notifications.where((n) => !(n['isRead'] as bool)).toList();
  }

  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return notifications.where((n) => n['type'] == type).toList();
  }
}
