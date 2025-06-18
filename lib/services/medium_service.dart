import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/models/medium_model.dart';
import 'package:oraculum_medium/models/appointment_model.dart';
import 'package:oraculum_medium/models/medium_stats_model.dart';
import 'package:oraculum_medium/services/firebase_service.dart';

class MediumService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  static const String mediumsCollection = 'mediums';
  static const String appointmentsCollection = 'appointments';
  static const String mediumAvailabilityCollection = 'medium_availability';
  static const String mediumEarningsCollection = 'medium_earnings';
  static const String mediumReviewsCollection = 'medium_reviews';
  static const String mediumSettingsCollection = 'medium_settings';

  Future<MediumModel?> getMediumProfile(String mediumId) async {
    try {
      debugPrint('=== getMediumProfile() ===');
      debugPrint('Medium ID: $mediumId');

      final doc = await _firestore.collection(mediumsCollection).doc(mediumId).get();

      if (doc.exists) {
        final mediumData = MediumModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        debugPrint('✅ Perfil do médium carregado: ${mediumData.name}');
        return mediumData;
      } else {
        debugPrint('❌ Médium não encontrado');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil do médium: $e');
      return null;
    }
  }

  Future<bool> updateMediumProfile(String mediumId, Map<String, dynamic> data) async {
    try {
      debugPrint('=== updateMediumProfile() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Data: $data');

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(mediumsCollection).doc(mediumId).update(data);

      debugPrint('✅ Perfil do médium atualizado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil do médium: $e');
      return false;
    }
  }

  Future<List<AppointmentModel>> getMediumAppointments(String mediumId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('=== getMediumAppointments() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Status: $status');

      Query query = _firestore
          .collection(appointmentsCollection)
          .where('mediumId', isEqualTo: mediumId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where('dateTime', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('dateTime', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('dateTime', descending: false);

      final snapshot = await query.get();

      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      debugPrint('✅ ${appointments.length} agendamentos carregados');
      return appointments;
    } catch (e) {
      debugPrint('❌ Erro ao carregar agendamentos: $e');
      return [];
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      debugPrint('=== updateAppointmentStatus() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('New Status: $status');

      await _firestore.collection(appointmentsCollection).doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Status do agendamento atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status do agendamento: $e');
      return false;
    }
  }

  Future<MediumStatsModel> getMediumStats(String mediumId) async {
    try {
      debugPrint('=== getMediumStats() ===');
      debugPrint('Medium ID: $mediumId');

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final allAppointments = await getMediumAppointments(mediumId);
      final monthlyAppointments = allAppointments
          .where((apt) => apt.dateTime.isAfter(startOfMonth))
          .toList();
      final weeklyAppointments = allAppointments
          .where((apt) => apt.dateTime.isAfter(startOfWeek))
          .toList();

      final completedAppointments = allAppointments
          .where((apt) => apt.status == 'completed')
          .toList();

      double totalEarnings = 0;
      double monthlyEarnings = 0;
      double weeklyEarnings = 0;

      for (final apt in completedAppointments) {
        totalEarnings += apt.amount;
        if (apt.dateTime.isAfter(startOfMonth)) {
          monthlyEarnings += apt.amount;
        }
        if (apt.dateTime.isAfter(startOfWeek)) {
          weeklyEarnings += apt.amount;
        }
      }

      final averageRating = await _getAverageRating(mediumId);

      final stats = MediumStatsModel(
        totalAppointments: allAppointments.length,
        completedAppointments: completedAppointments.length,
        monthlyAppointments: monthlyAppointments.length,
        weeklyAppointments: weeklyAppointments.length,
        totalEarnings: totalEarnings,
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: weeklyEarnings,
        averageRating: averageRating,
        responseTime: 5.0,
      );

      debugPrint('✅ Estatísticas carregadas: ${stats.toMap()}');
      return stats;
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
      return MediumStatsModel(
        totalAppointments: 0,
        completedAppointments: 0,
        monthlyAppointments: 0,
        weeklyAppointments: 0,
        totalEarnings: 0,
        monthlyEarnings: 0,
        weeklyEarnings: 0,
        averageRating: 0,
        responseTime: 0,
      );
    }
  }

  Future<double> _getAverageRating(String mediumId) async {
    try {
      final snapshot = await _firestore
          .collection(mediumReviewsCollection)
          .where('mediumId', isEqualTo: mediumId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num).toDouble();
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Erro ao calcular avaliação média: $e');
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> getMediumAvailability(String mediumId) async {
    try {
      debugPrint('=== getMediumAvailability() ===');
      debugPrint('Medium ID: $mediumId');

      final doc = await _firestore
          .collection(mediumAvailabilityCollection)
          .doc(mediumId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('✅ Disponibilidade carregada');
        return data;
      } else {
        debugPrint('⚠️ Disponibilidade não encontrada, criando padrão');
        final defaultAvailability = _getDefaultAvailability();
        await _firestore
            .collection(mediumAvailabilityCollection)
            .doc(mediumId)
            .set(defaultAvailability);
        return defaultAvailability;
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar disponibilidade: $e');
      return _getDefaultAvailability();
    }
  }

  Future<bool> updateMediumAvailability(String mediumId, Map<String, dynamic> availability) async {
    try {
      debugPrint('=== updateMediumAvailability() ===');
      debugPrint('Medium ID: $mediumId');

      availability['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(mediumAvailabilityCollection)
          .doc(mediumId)
          .set(availability, SetOptions(merge: true));

      debugPrint('✅ Disponibilidade atualizada');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar disponibilidade: $e');
      return false;
    }
  }

  Future<bool> updateMediumStatus(String mediumId, bool isOnline) async {
    try {
      debugPrint('=== updateMediumStatus() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Is Online: $isOnline');

      await _firestore.collection(mediumsCollection).doc(mediumId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Status do médium atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getEarningsHistory(
      String mediumId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      debugPrint('=== getEarningsHistory() ===');
      debugPrint('Medium ID: $mediumId');

      Query query = _firestore
          .collection(mediumEarningsCollection)
          .where('mediumId', isEqualTo: mediumId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('date', descending: true);

      final snapshot = await query.get();
      final earnings = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();

      debugPrint('✅ ${earnings.length} registros de ganhos carregados');
      return earnings;
    } catch (e) {
      debugPrint('❌ Erro ao carregar histórico de ganhos: $e');
      return [];
    }
  }

  Future<bool> recordEarning(String mediumId, double amount, String appointmentId) async {
    try {
      debugPrint('=== recordEarning() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Amount: $amount');

      final earningData = {
        'mediumId': mediumId,
        'amount': amount,
        'appointmentId': appointmentId,
        'date': DateTime.now(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(mediumEarningsCollection).add(earningData);

      debugPrint('✅ Ganho registrado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao registrar ganho: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getMediumSettings(String mediumId) async {
    try {
      debugPrint('=== getMediumSettings() ===');
      debugPrint('Medium ID: $mediumId');

      final doc = await _firestore
          .collection(mediumSettingsCollection)
          .doc(mediumId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('✅ Configurações carregadas');
        return data;
      } else {
        debugPrint('⚠️ Configurações não encontradas, criando padrão');
        final defaultSettings = _getDefaultSettings();
        await _firestore
            .collection(mediumSettingsCollection)
            .doc(mediumId)
            .set(defaultSettings);
        return defaultSettings;
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
      return _getDefaultSettings();
    }
  }

  Future<bool> updateMediumSettings(String mediumId, Map<String, dynamic> settings) async {
    try {
      debugPrint('=== updateMediumSettings() ===');
      debugPrint('Medium ID: $mediumId');

      settings['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(mediumSettingsCollection)
          .doc(mediumId)
          .set(settings, SetOptions(merge: true));

      debugPrint('✅ Configurações atualizadas');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar configurações: $e');
      return false;
    }
  }

  Map<String, dynamic> _getDefaultAvailability() {
    return {
      'monday': {
        'isAvailable': true,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'tuesday': {
        'isAvailable': true,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'wednesday': {
        'isAvailable': true,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'thursday': {
        'isAvailable': true,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'friday': {
        'isAvailable': true,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'saturday': {
        'isAvailable': false,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'sunday': {
        'isAvailable': false,
        'startTime': '09:00',
        'endTime': '18:00',
        'breaks': [],
      },
      'blockedDates': [],
      'consultationDurations': [15, 30, 45, 60],
      'defaultDuration': 30,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'notifications': {
        'newAppointments': true,
        'appointmentReminders': true,
        'paymentNotifications': true,
        'reviewNotifications': true,
      },
      'autoAcceptAppointments': false,
      'bufferTimeBetweenAppointments': 15,
      'maxDailyAppointments': 10,
      'allowCancellations': true,
      'cancellationDeadlineHours': 24,
      'language': 'pt',
      'timezone': 'America/Sao_Paulo',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
