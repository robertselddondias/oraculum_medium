import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/models/appointment_model.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class AppointmentAdminController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> filteredAppointments = <AppointmentModel>[].obs;
  final Rx<AppointmentModel?> selectedAppointment = Rx<AppointmentModel?>(null);

  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final List<String> filterOptions = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'canceled',
  ];

  final Map<String, String> filterLabels = {
    'all': 'Todas',
    'pending': 'Pendentes',
    'confirmed': 'Confirmadas',
    'completed': 'Concluídas',
    'canceled': 'Canceladas',
  };

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();

    ever(selectedFilter, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedDate, (_) => _applyFilters());
  }

  Future<void> loadAppointments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadAppointments() ===');
      isLoading.value = true;

      final appointments = await _mediumService.getMediumAppointments(
        currentMediumId!,
        startDate: startDate,
        endDate: endDate,
      );

      allAppointments.value = appointments;
      _applyFilters();

      debugPrint('✅ ${appointments.length} consultas carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas: $e');
      Get.snackbar('Erro', 'Não foi possível carregar as consultas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppointmentDetails(String appointmentId) async {
    try {
      debugPrint('=== loadAppointmentDetails() ===');
      debugPrint('Appointment ID: $appointmentId');

      isLoadingDetails.value = true;

      final appointment = allAppointments.firstWhereOrNull(
            (apt) => apt.id == appointmentId,
      );

      if (appointment != null) {
        selectedAppointment.value = appointment;
        debugPrint('✅ Detalhes da consulta carregados');
      } else {
        debugPrint('❌ Consulta não encontrada');
        Get.snackbar('Erro', 'Consulta não encontrada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar detalhes: $e');
      Get.snackbar('Erro', 'Erro ao carregar detalhes da consulta');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> confirmAppointment(String appointmentId) async {
    try {
      debugPrint('=== confirmAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'confirmed');

      if (success) {
        _updateAppointmentInList(appointmentId, 'confirmed');
        Get.snackbar(
          'Consulta Confirmada',
          'A consulta foi confirmada com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível confirmar a consulta');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao confirmar consulta: $e');
      Get.snackbar('Erro', 'Erro ao confirmar consulta: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      debugPrint('=== cancelAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('Reason: $reason');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'canceled');

      if (success) {
        _updateAppointmentInList(appointmentId, 'canceled');
        Get.snackbar(
          'Consulta Cancelada',
          'A consulta foi cancelada',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível cancelar a consulta');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao cancelar consulta: $e');
      return false;
    }
  }

  Future<bool> completeAppointment(String appointmentId, {String? notes}) async {
    try {
      debugPrint('=== completeAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');

      final success = await _mediumService.updateAppointmentStatus(appointmentId, 'completed');

      if (success) {
        final appointment = allAppointments.firstWhereOrNull((apt) => apt.id == appointmentId);
        if (appointment != null && currentMediumId != null) {
          await _mediumService.recordEarning(
            currentMediumId!,
            appointment.amount,
            appointmentId,
          );
        }

        _updateAppointmentInList(appointmentId, 'completed');
        Get.snackbar(
          'Consulta Finalizada',
          'A consulta foi marcada como concluída',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível finalizar a consulta');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao finalizar consulta: $e');
      Get.snackbar('Erro', 'Erro ao finalizar consulta: $e');
      return false;
    }
  }

  Future<bool> rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    try {
      debugPrint('=== rescheduleAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('New DateTime: $newDateTime');

      final success = await _mediumService.updateMediumProfile(currentMediumId!, {
        'dateTime': newDateTime,
        'status': 'confirmed',
      });

      if (success) {
        final appointmentIndex = allAppointments.indexWhere((apt) => apt.id == appointmentId);
        if (appointmentIndex != -1) {
          final updatedAppointment = allAppointments[appointmentIndex].copyWith(
            dateTime: newDateTime,
            status: 'confirmed',
          );
          allAppointments[appointmentIndex] = updatedAppointment;
          _applyFilters();
        }

        Get.snackbar(
          'Consulta Reagendada',
          'A consulta foi reagendada com sucesso',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível reagendar a consulta');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao reagendar consulta: $e');
      Get.snackbar('Erro', 'Erro ao reagendar consulta: $e');
      return false;
    }
  }

  void _updateAppointmentInList(String appointmentId, String newStatus) {
    final appointmentIndex = allAppointments.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex != -1) {
      final updatedAppointment = allAppointments[appointmentIndex].copyWith(status: newStatus);
      allAppointments[appointmentIndex] = updatedAppointment;

      if (selectedAppointment.value?.id == appointmentId) {
        selectedAppointment.value = updatedAppointment;
      }

      _applyFilters();
    }
  }

  void _applyFilters() {
    var filtered = List<AppointmentModel>.from(allAppointments);

    if (selectedFilter.value != 'all') {
      filtered = filtered.where((apt) => apt.status == selectedFilter.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((apt) {
        return (apt.userName?.toLowerCase().contains(query) ?? false) ||
            (apt.mediumSpecialty?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (selectedDate.value != null) {
      final targetDate = selectedDate.value!;
      filtered = filtered.where((apt) {
        final aptDate = apt.dateTime;
        return aptDate.year == targetDate.year &&
            aptDate.month == targetDate.month &&
            aptDate.day == targetDate.day;
      }).toList();
    }

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    filteredAppointments.value = filtered;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setDateFilter(DateTime? date) {
    selectedDate.value = date;
  }

  void clearFilters() {
    selectedFilter.value = 'all';
    searchQuery.value = '';
    selectedDate.value = null;
  }

  Future<void> refreshAppointments() async {
    await loadAppointments();
  }

  List<AppointmentModel> getAppointmentsByStatus(String status) {
    return allAppointments.where((apt) => apt.status == status).toList();
  }

  List<AppointmentModel> getTodayAppointments() {
    final today = DateTime.now();
    return allAppointments.where((apt) {
      final aptDate = apt.dateTime;
      return aptDate.year == today.year &&
          aptDate.month == today.month &&
          aptDate.day == today.day;
    }).toList();
  }

  List<AppointmentModel> getUpcomingAppointments({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return allAppointments.where((apt) {
      return apt.dateTime.isAfter(now) &&
          apt.dateTime.isBefore(futureDate) &&
          apt.status != 'canceled';
    }).toList();
  }

  Map<String, int> getAppointmentCounts() {
    final counts = <String, int>{};

    for (final option in filterOptions) {
      if (option == 'all') {
        counts[option] = allAppointments.length;
      } else {
        counts[option] = allAppointments.where((apt) => apt.status == option).length;
      }
    }

    return counts;
  }

  double getTotalEarnings() {
    return allAppointments
        .where((apt) => apt.status == 'completed')
        .fold(0.0, (sum, apt) => sum + apt.amount);
  }

  double getMonthlyEarnings() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return allAppointments
        .where((apt) => apt.status == 'completed' && apt.dateTime.isAfter(startOfMonth))
        .fold(0.0, (sum, apt) => sum + apt.amount);
  }

  double getWeeklyEarnings() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return allAppointments
        .where((apt) => apt.status == 'completed' && apt.dateTime.isAfter(startOfWeek))
        .fold(0.0, (sum, apt) => sum + apt.amount);
  }

  int getPendingCount() => getAppointmentsByStatus('pending').length;
  int getConfirmedCount() => getAppointmentsByStatus('confirmed').length;
  int getCompletedCount() => getAppointmentsByStatus('completed').length;
  int getCanceledCount() => getAppointmentsByStatus('canceled').length;

  String getFilterLabel(String filter) => filterLabels[filter] ?? filter;

  bool hasAppointments() => allAppointments.isNotEmpty;
  bool hasFilteredAppointments() => filteredAppointments.isNotEmpty;
}
