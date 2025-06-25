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
  static const String mediumWalletCollection = 'medium_wallet';
  static const String oraculumEarningsCollection = 'oraculum_earnings';

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

      Query query = _firestore
          .collection(appointmentsCollection)
          .where('mediumId', isEqualTo: mediumId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where('scheduledDate', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('scheduledDate', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('scheduledDate', descending: true);

      final snapshot = await query.get();
      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      debugPrint('✅ ${appointments.length} consultas carregadas');
      return appointments;
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas: $e');
      return [];
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      debugPrint('=== updateAppointmentStatus() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('New Status: $newStatus');

      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'cancelled' || newStatus == 'canceled') {
        updateData['canceledAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(appointmentsCollection).doc(appointmentId).update(updateData);

      debugPrint('✅ Status da consulta atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status da consulta: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String cancelReason) async {
    try {
      debugPrint('=== cancelAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');
      debugPrint('Cancel Reason: $cancelReason');

      await _firestore.collection(appointmentsCollection).doc(appointmentId).update({
        'status': 'cancelled',
        'cancelReason': cancelReason,
        'canceledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Consulta cancelada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao cancelar consulta: $e');
      return false;
    }
  }

  Future<bool> completeAppointment(String appointmentId, {String? feedback, double? rating}) async {
    try {
      debugPrint('=== completeAppointment() ===');
      debugPrint('Appointment ID: $appointmentId');

      final updateData = {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (feedback != null) {
        updateData['feedback'] = feedback;
      }

      if (rating != null) {
        updateData['rating'] = rating;
      }

      await _firestore.collection(appointmentsCollection).doc(appointmentId).update(updateData);

      debugPrint('✅ Consulta finalizada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao finalizar consulta: $e');
      return false;
    }
  }

  Future<bool> updateMediumStatus(String mediumId, bool isOnline) async {
    try {
      debugPrint('=== updateMediumStatus() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Is Online: $isOnline');

      await _firestore.collection(mediumsCollection).doc(mediumId).update({
        'status': isOnline ? 'online' : 'offline',
        'isAvailable': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Status do médium atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar status do médium: $e');
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
          .where((apt) => apt.scheduledDate.isAfter(startOfMonth))
          .toList();
      final weeklyAppointments = allAppointments
          .where((apt) => apt.scheduledDate.isAfter(startOfWeek))
          .toList();

      final completedAppointments = allAppointments
          .where((apt) => apt.isCompleted)
          .toList();

      double totalEarnings = 0;
      double monthlyEarnings = 0;
      double weeklyEarnings = 0;

      for (final apt in completedAppointments) {
        totalEarnings += apt.amount;
        if (apt.scheduledDate.isAfter(startOfMonth)) {
          monthlyEarnings += apt.amount;
        }
        if (apt.scheduledDate.isAfter(startOfWeek)) {
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

      debugPrint('✅ Estatísticas carregadas');
      return stats;
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
      return MediumStatsModel(
        totalEarnings: 0.0,
        monthlyEarnings: 0.0,
        weeklyEarnings: 0.0,
        totalAppointments: 0,
        completedAppointments: 0,
        averageRating: 0.0,
        weeklyAppointments: 0,
        monthlyAppointments: 0,
        responseTime: 0.0,
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

  Future<List<AppointmentModel>> getTodayAppointments(String mediumId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getMediumAppointments(
        mediumId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas de hoje: $e');
      return [];
    }
  }

  Future<List<AppointmentModel>> getUpcomingAppointments(String mediumId) async {
    try {
      final now = DateTime.now();
      final appointments = await getMediumAppointments(mediumId, startDate: now);

      return appointments
          .where((apt) => apt.isUpcoming)
          .toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    } catch (e) {
      debugPrint('❌ Erro ao carregar consultas próximas: $e');
      return [];
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
        'endTime': '17:00',
        'breaks': [],
      },
      'sunday': {
        'isAvailable': false,
        'startTime': '10:00',
        'endTime': '16:00',
        'breaks': [],
      },
      'blockedDates': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'autoAcceptAppointments': false,
      'bufferTime': 15,
      'maxDailyAppointments': 10,
      'minAdvanceBooking': 2,
      'maxAdvanceBooking': 30,
      'allowSameDayBooking': true,
      'notificationSettings': {
        'newAppointments': true,
        'appointmentReminders': true,
        'paymentNotifications': true,
        'reviewNotifications': true,
        'promotionalEmails': false,
        'systemUpdates': true,
        'maintenanceAlerts': true,
      },
      'consultationDurations': [15, 30, 45, 60],
      'minimumSessionPrice': 10.0,
      'acceptsCredits': true,
      'acceptsCards': true,
      'acceptsPix': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
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

  Future<double> getMediumWalletBalance(String mediumId) async {
    try {
      debugPrint('=== getMediumWalletBalance() ===');
      debugPrint('Medium ID: $mediumId');

      final doc = await _firestore.collection(mediumWalletCollection).doc(mediumId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final balance = (data['balance'] ?? 0.0).toDouble();
        debugPrint('✅ Saldo da carteira: R\$ ${balance.toStringAsFixed(2)}');
        return balance;
      } else {
        await _createMediumWallet(mediumId);
        return 0.0;
      }
    } catch (e) {
      debugPrint('❌ Erro ao obter saldo da carteira: $e');
      return 0.0;
    }
  }

  Future<bool> _createMediumWallet(String mediumId) async {
    try {
      debugPrint('=== _createMediumWallet() ===');

      await _firestore.collection(mediumWalletCollection).doc(mediumId).set({
        'mediumId': mediumId,
        'balance': 0.0,
        'totalEarnings': 0.0,
        'totalWithdrawals': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Carteira do médium criada');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao criar carteira: $e');
      return false;
    }
  }

  Future<bool> updateMediumWallet(String mediumId, double amount, String type, {String? description}) async {
    try {
      debugPrint('=== updateMediumWallet() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Amount: R\$ ${amount.toStringAsFixed(2)}');
      debugPrint('Type: $type');

      final walletRef = _firestore.collection(mediumWalletCollection).doc(mediumId);

      await _firestore.runTransaction((transaction) async {
        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          transaction.set(walletRef, {
            'mediumId': mediumId,
            'balance': 0.0,
            'totalEarnings': 0.0,
            'totalWithdrawals': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final currentData = walletDoc.data() as Map<String, dynamic>? ?? {};
        final currentBalance = (currentData['balance'] ?? 0.0).toDouble();
        final totalEarnings = (currentData['totalEarnings'] ?? 0.0).toDouble();
        final totalWithdrawals = (currentData['totalWithdrawals'] ?? 0.0).toDouble();

        double newBalance = currentBalance;
        double newTotalEarnings = totalEarnings;
        double newTotalWithdrawals = totalWithdrawals;

        if (type == 'add') {
          newBalance += amount;
          newTotalEarnings += amount;
        } else if (type == 'subtract') {
          newBalance -= amount;
          newTotalWithdrawals += amount;
        }

        transaction.update(walletRef, {
          'balance': newBalance,
          'totalEarnings': newTotalEarnings,
          'totalWithdrawals': newTotalWithdrawals,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _createWalletTransaction(transaction, mediumId, amount, type, newBalance, description);
      });

      debugPrint('✅ Carteira atualizada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar carteira: $e');
      return false;
    }
  }

  Future<void> _createWalletTransaction(Transaction transaction, String mediumId, double amount, String type, double newBalance, String? description) async {
    final transactionRef = _firestore.collection('wallet_transactions').doc();

    transaction.set(transactionRef, {
      'mediumId': mediumId,
      'amount': amount,
      'type': type,
      'balanceAfter': newBalance,
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> recordEarning(String mediumId, double amount, String appointmentId) async {
    try {
      debugPrint('=== recordEarning() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Amount: R\$ ${amount.toStringAsFixed(2)}');

      const double oraculumCommission = 0.20;
      final double mediumEarning = amount * (1 - oraculumCommission);
      final double oraculumEarning = amount * oraculumCommission;

      debugPrint('Comissão Oraculum (20%): R\$ ${oraculumEarning.toStringAsFixed(2)}');
      debugPrint('Ganho do Médium (80%): R\$ ${mediumEarning.toStringAsFixed(2)}');

      await _firestore.runTransaction((transaction) async {
        final earningRef = _firestore.collection(mediumEarningsCollection).doc();
        final oraculumRef = _firestore.collection(oraculumEarningsCollection).doc();

        transaction.set(earningRef, {
          'mediumId': mediumId,
          'appointmentId': appointmentId,
          'totalAmount': amount,
          'mediumAmount': mediumEarning,
          'oraculumAmount': oraculumEarning,
          'commissionRate': oraculumCommission,
          'date': DateTime.now(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(oraculumRef, {
          'mediumId': mediumId,
          'appointmentId': appointmentId,
          'amount': oraculumEarning,
          'commissionRate': oraculumCommission,
          'date': DateTime.now(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await updateMediumWallet(
          mediumId,
          mediumEarning,
          'add',
          description: 'Consulta finalizada - ID: $appointmentId'
      );

      debugPrint('✅ Ganho registrado e carteira atualizada');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao registrar ganho: $e');
      return false;
    }
  }
}
