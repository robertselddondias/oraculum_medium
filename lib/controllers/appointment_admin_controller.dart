import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/models/appointment_model.dart';
import 'package:oraculum_medium/services/medium_service.dart';
import 'package:oraculum_medium/services/firebase_service.dart';

class AppointmentAdminController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
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
  String? get currentUserId => _authController.currentUser.value?.uid;

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
    try {
      debugPrint('=== loadAppointments() ===');
      isLoading.value = true;

      List<AppointmentModel> appointments = [];

      if (currentMediumId != null) {
        appointments = await _mediumService.getMediumAppointments(
          currentMediumId!,
          startDate: startDate,
          endDate: endDate,
        );
        debugPrint('✅ Carregando consultas para médium: $currentMediumId');
      } else if (currentUserId != null) {
        appointments = await _loadUserAppointments(
          currentUserId!,
          startDate: startDate,
          endDate: endDate,
        );
        debugPrint('✅ Carregando consultas para usuário: $currentUserId');
      }

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

  Future<List<AppointmentModel>> _loadUserAppointments(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      List<AppointmentModel> appointments = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Enriquecer dados do appointment com informações do usuário e médium
          await _enrichAppointmentData(data);

          final appointment = AppointmentModel.fromMap(data, doc.id);

          if (startDate != null && appointment.dateTime.isBefore(startDate)) {
            continue;
          }

          if (endDate != null && appointment.dateTime.isAfter(endDate)) {
            continue;
          }

          appointments.add(appointment);
        } catch (e) {
          debugPrint('❌ Erro ao processar consulta ${doc.id}: $e');
        }
      }

      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return appointments;
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas do usuário: $e');
      return [];
    }
  }

  Future<void> _enrichAppointmentData(Map<String, dynamic> appointmentData) async {
    try {
      final userId = appointmentData['userId'];
      final mediumId = appointmentData['mediumId'];

      // Buscar dados do usuário se não existirem
      if (userId != null && (appointmentData['userName'] == null || appointmentData['userName'].isEmpty)) {
        final userDoc = await _firebaseService.firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          appointmentData['userName'] = userData['name'] ?? userData['displayName'] ?? 'Cliente';
          appointmentData['userEmail'] = userData['email'];
          appointmentData['userPhone'] = userData['phone'];
        }
      }

      // Buscar dados do médium se não existirem
      if (mediumId != null && (appointmentData['mediumName'] == null || appointmentData['mediumName'].isEmpty)) {
        final mediumDoc = await _firebaseService.firestore.collection('mediums').doc(mediumId).get();
        if (mediumDoc.exists) {
          final mediumData = mediumDoc.data()!;
          appointmentData['mediumName'] = mediumData['name'] ?? 'Médium';
          appointmentData['mediumSpecialty'] = mediumData['specialty'] ?? mediumData['specialties']?.first ?? 'Consulta espiritual';
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao enriquecer dados do appointment: $e');
    }
  }

  Future<void> refreshAppointments() async {
    await loadAppointments();
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

  Future<bool> rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    try {
      debugPrint('=== rescheduleAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('New DateTime: $newDateTime');

      final success = await _firebaseService.firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'dateTime': newDateTime,
        'status': 'confirmed',
        'updatedAt': DateTime.now(),
      });

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

      return true;
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
            (apt.mediumName?.toLowerCase().contains(query) ?? false) ||
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

  void clearDateFilter() {
    selectedDate.value = null;
  }

  void clearFilters() {
    selectedFilter.value = 'all';
    searchQuery.value = '';
    selectedDate.value = null;
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
          'A consulta foi marcada como concluída e o valor foi adicionado à sua carteira (80% - após desconto de 20% para o Oraculum)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
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
}
