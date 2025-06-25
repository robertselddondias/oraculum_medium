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
          .where('clientId', isEqualTo: userId)
          .get();

      List<AppointmentModel> appointments = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          await _enrichAppointmentData(data);

          final appointment = AppointmentModel.fromMap(data, doc.id);

          if (startDate != null && appointment.scheduledDate.isBefore(startDate)) {
            continue;
          }

          if (endDate != null && appointment.scheduledDate.isAfter(endDate)) {
            continue;
          }

          appointments.add(appointment);
        } catch (e) {
          debugPrint('❌ Erro ao processar consulta ${doc.id}: $e');
        }
      }

      appointments.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      return appointments;
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas do usuário: $e');
      return [];
    }
  }

  Future<void> _enrichAppointmentData(Map<String, dynamic> appointmentData) async {
    try {
      final clientId = appointmentData['clientId'];
      final mediumId = appointmentData['mediumId'];

      if (clientId != null && (appointmentData['clientName'] == null || appointmentData['clientName'].isEmpty)) {
        final userDoc = await _firebaseService.firestore.collection('users').doc(clientId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          appointmentData['clientName'] = userData['name'] ?? userData['displayName'] ?? 'Cliente';
        }
      }

      if (mediumId != null && (appointmentData['mediumName'] == null || appointmentData['mediumName'].isEmpty)) {
        final mediumDoc = await _firebaseService.firestore.collection('mediums').doc(mediumId).get();
        if (mediumDoc.exists) {
          final mediumData = mediumDoc.data()!;
          appointmentData['mediumName'] = mediumData['name'] ?? 'Médium';
          appointmentData['mediumImageUrl'] = mediumData['imageUrl'];
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao enriquecer dados do appointment: $e');
    }
  }

  Future<void> refreshAppointments() async {
    try {
      await loadAppointments();
    } catch (e) {
      debugPrint('❌ Erro ao atualizar consultas: $e');
    }
  }

  Future<void> loadAppointmentDetails(String appointmentId) async {
    try {
      isLoadingDetails.value = true;

      final appointment = allAppointments.firstWhereOrNull((apt) => apt.id == appointmentId);

      if (appointment != null) {
        selectedAppointment.value = appointment;
      } else {
        final doc = await _firebaseService.firestore
            .collection('appointments')
            .doc(appointmentId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          await _enrichAppointmentData(data);
          selectedAppointment.value = AppointmentModel.fromMap(data, doc.id);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar detalhes da consulta: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> confirmAppointment(String appointmentId) async {
    try {
      await _firebaseService.firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'confirmed',
        'updatedAt': DateTime.now(),
      });

      await refreshAppointments();

      Get.snackbar(
        'Sucesso',
        'Consulta confirmada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao confirmar consulta: $e');
      Get.snackbar('Erro', 'Não foi possível confirmar a consulta');
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String? reason) async {
    try {
      await _firebaseService.firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'cancelled',
        'cancelReason': reason ?? 'Cancelado pelo médium',
        'canceledAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      await refreshAppointments();

      Get.snackbar(
        'Consulta Cancelada',
        'A consulta foi cancelada com sucesso.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao cancelar consulta: $e');
      Get.snackbar('Erro', 'Não foi possível cancelar a consulta');
      return false;
    }
  }

  Future<bool> completeAppointment(String appointmentId) async {
    try {
      await _firebaseService.firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'completed',
        'completedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      await refreshAppointments();

      Get.snackbar(
        'Consulta Concluída',
        'A consulta foi marcada como concluída.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao concluir consulta: $e');
      Get.snackbar('Erro', 'Não foi possível concluir a consulta');
      return false;
    }
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

  void _applyFilters() {
    var filtered = List<AppointmentModel>.from(allAppointments);

    // Filtro por status
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((appointment) {
        switch (selectedFilter.value) {
          case 'pending':
            return appointment.isPending;
          case 'confirmed':
            return appointment.isConfirmed;
          case 'completed':
            return appointment.isCompleted;
          case 'canceled':
            return appointment.isCancelled;
          default:
            return true;
        }
      }).toList();
    }

    // Filtro por busca
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((appointment) =>
      appointment.clientName.toLowerCase().contains(query) ||
          appointment.consultationType.toLowerCase().contains(query) ||
          appointment.description.toLowerCase().contains(query)
      ).toList();
    }

    // Filtro por data
    if (selectedDate.value != null) {
      final filterDate = selectedDate.value!;
      final startOfDay = DateTime(filterDate.year, filterDate.month, filterDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      filtered = filtered.where((appointment) =>
      appointment.scheduledDate.isAfter(startOfDay) &&
          appointment.scheduledDate.isBefore(endOfDay)
      ).toList();
    }

    filteredAppointments.value = filtered;
  }

  // Getters para estatísticas
  List<AppointmentModel> get pendingAppointments =>
      filteredAppointments.where((apt) => apt.isPending).toList();

  List<AppointmentModel> get confirmedAppointments =>
      filteredAppointments.where((apt) => apt.isConfirmed).toList();

  List<AppointmentModel> get completedAppointments =>
      filteredAppointments.where((apt) => apt.isCompleted).toList();

  List<AppointmentModel> get cancelledAppointments =>
      filteredAppointments.where((apt) => apt.isCancelled).toList();

  List<AppointmentModel> get todayAppointments {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return filteredAppointments.where((appointment) =>
    appointment.scheduledDate.isAfter(startOfDay) &&
        appointment.scheduledDate.isBefore(endOfDay)
    ).toList();
  }

  List<AppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    return filteredAppointments.where((appointment) =>
    (appointment.isPending || appointment.isConfirmed) &&
        appointment.scheduledDate.isAfter(now)
    ).toList();
  }
}
