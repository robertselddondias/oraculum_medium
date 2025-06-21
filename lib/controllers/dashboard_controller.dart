import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/models/appointment_model.dart';
import 'package:oraculum_medium/models/medium_stats_model.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class DashboardController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingAppointments = false.obs;

  final Rx<MediumStatsModel?> stats = Rx<MediumStatsModel?>(null);
  final RxList<AppointmentModel> todayAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> upcomingAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> pendingAppointments = <AppointmentModel>[].obs;

  final RxBool isOnline = false.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt monthlyCount = 0.obs;

  String? get currentMediumId => _authController.currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (currentMediumId == null) {
      debugPrint('❌ Médium não logado');
      return;
    }

    isLoading.value = true;
    try {
      await Future.wait([
        loadStats(),
        loadTodayAppointments(),
        loadUpcomingAppointments(),
        loadPendingAppointments(),
      ]);
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados do dashboard: $e');
      Get.snackbar('Erro', 'Não foi possível carregar os dados do dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    if (currentMediumId == null) return;

    isLoadingStats.value = true;
    try {
      debugPrint('=== loadStats() ===');
      final mediumStats = await _mediumService.getMediumStats(currentMediumId!);
      stats.value = mediumStats;
      averageRating.value = mediumStats.averageRating;
      monthlyCount.value = mediumStats.monthlyAppointments;
      debugPrint('✅ Estatísticas carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadTodayAppointments() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadTodayAppointments() ===');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final appointments = await _mediumService.getMediumAppointments(
        currentMediumId!,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      todayAppointments.value = appointments
          .where((apt) => apt.status != 'canceled')
          .toList();

      debugPrint('✅ ${todayAppointments.length} consultas de hoje carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas de hoje: $e');
    }
  }

  Future<void> loadUpcomingAppointments() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadUpcomingAppointments() ===');
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));

      final appointments = await _mediumService.getMediumAppointments(
        currentMediumId!,
        startDate: tomorrow,
        endDate: nextWeek,
      );

      upcomingAppointments.value = appointments
          .where((apt) => apt.status != 'canceled')
          .take(5)
          .toList();

      debugPrint('✅ ${upcomingAppointments.length} próximas consultas carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar próximas consultas: $e');
    }
  }

  Future<void> loadPendingAppointments() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadPendingAppointments() ===');
      final appointments = await _mediumService.getMediumAppointments(
        currentMediumId!,
        status: 'pending',
      );

      pendingAppointments.value = appointments;
      debugPrint('✅ ${pendingAppointments.length} consultas pendentes carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas pendentes: $e');
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      debugPrint('=== confirmAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'confirmed');

      if (success) {
        Get.snackbar(
          'Sucesso',
          'Consulta confirmada com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await loadDashboardData();
      } else {
        Get.snackbar('Erro', 'Não foi possível confirmar a consulta');
      }
    } catch (e) {
      debugPrint('❌ Erro ao confirmar consulta: $e');
      Get.snackbar('Erro', 'Erro ao confirmar consulta: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      debugPrint('=== cancelAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('Reason: $reason');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'canceled');

      if (success) {
        Get.snackbar(
          'Consulta Cancelada',
          'A consulta foi cancelada',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        await loadDashboardData();
      } else {
        Get.snackbar('Erro', 'Não foi possível cancelar a consulta');
      }
    } catch (e) {
      debugPrint('❌ Erro ao cancelar consulta: $e');
      Get.snackbar('Erro', 'Erro ao cancelar consulta: $e');
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      debugPrint('=== completeAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'completed');

      if (success) {
        final appointment = todayAppointments
            .firstWhereOrNull((apt) => apt.id == appointmentId);

        if (appointment != null && currentMediumId != null) {
          await _mediumService.recordEarning(
            currentMediumId!,
            appointment.amount,
            appointmentId,
          );
        }

        Get.snackbar(
          'Consulta Finalizada',
          'A consulta foi marcada como concluída',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await loadDashboardData();
      } else {
        Get.snackbar('Erro', 'Não foi possível finalizar a consulta');
      }
    } catch (e) {
      debugPrint('❌ Erro ao finalizar consulta: $e');
      Get.snackbar('Erro', 'Erro ao finalizar consulta: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== toggleOnlineStatus() ===');
      final newStatus = !isOnline.value;

      final success = await _mediumService.updateMediumStatus(currentMediumId!, newStatus);

      if (success) {
        isOnline.value = newStatus;
        Get.snackbar(
          'Status Atualizado',
          newStatus ? 'Você está online' : 'Você está offline',
          backgroundColor: newStatus ? Colors.green : Colors.grey,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível atualizar o status');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');
      Get.snackbar('Erro', 'Erro ao atualizar status: $e');
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  Color getStatusColor() {
    return isOnline.value ? Colors.green : Colors.grey;
  }

  String getStatusText() {
    return isOnline.value ? 'Online' : 'Offline';
  }

  int get totalTodayEarnings {
    return todayAppointments
        .where((apt) => apt.status == 'completed')
        .fold(0, (sum, apt) => sum + apt.amount.toInt());
  }

  int get pendingCount => pendingAppointments.length;
  int get todayCount => todayAppointments.length;
  int get upcomingCount => upcomingAppointments.length;
}
