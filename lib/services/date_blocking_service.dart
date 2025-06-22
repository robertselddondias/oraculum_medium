// lib/services/date_blocking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/services/firebase_service.dart';

class DateBlockingService extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  CollectionReference get blockedDatesCollection =>
      _firebaseService.firestore.collection('blocked_dates');

  CollectionReference get mediumAvailabilityCollection =>
      _firebaseService.mediumAvailabilityCollection;

  Future<bool> blockDate({
    required String mediumId,
    required DateTime date,
    String? reason,
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    try {
      debugPrint('=== blockDate() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Date: $date');
      debugPrint('Reason: $reason');

      final dateOnly = DateTime(date.year, date.month, date.day);
      final blockId = '${mediumId}_${dateOnly.millisecondsSinceEpoch}';

      final blockData = {
        'id': blockId,
        'mediumId': mediumId,
        'date': Timestamp.fromDate(dateOnly),
        'reason': reason ?? 'Data bloqueada',
        'isRecurring': isRecurring,
        'recurringPattern': recurringPattern,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await blockedDatesCollection.doc(blockId).set(blockData);

      await _updateMediumAvailabilityBlockedDates(mediumId);

      debugPrint('✅ Data bloqueada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao bloquear data: $e');
      return false;
    }
  }

  Future<bool> unblockDate({
    required String mediumId,
    required DateTime date,
  }) async {
    try {
      debugPrint('=== unblockDate() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Date: $date');

      final dateOnly = DateTime(date.year, date.month, date.day);
      final blockId = '${mediumId}_${dateOnly.millisecondsSinceEpoch}';

      await blockedDatesCollection.doc(blockId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _updateMediumAvailabilityBlockedDates(mediumId);

      debugPrint('✅ Data desbloqueada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao desbloquear data: $e');
      return false;
    }
  }

  Future<List<DateTime>> getBlockedDates(String mediumId) async {
    try {
      debugPrint('=== getBlockedDates() ===');
      debugPrint('Medium ID: $mediumId');

      final snapshot = await blockedDatesCollection
          .where('mediumId', isEqualTo: mediumId)
          .where('isActive', isEqualTo: true)
          .orderBy('date')
          .get();

      final blockedDates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp;
        return timestamp.toDate();
      }).toList();

      debugPrint('✅ ${blockedDates.length} datas bloqueadas encontradas');
      return blockedDates;
    } catch (e) {
      debugPrint('❌ Erro ao buscar datas bloqueadas: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchBlockedDates(String mediumId) {
    return blockedDatesCollection
        .where('mediumId', isEqualTo: mediumId)
        .where('isActive', isEqualTo: true)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<bool> isDateBlocked(String mediumId, DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final blockId = '${mediumId}_${dateOnly.millisecondsSinceEpoch}';

      final doc = await blockedDatesCollection.doc(blockId).get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      return data['isActive'] == true;
    } catch (e) {
      debugPrint('❌ Erro ao verificar se data está bloqueada: $e');
      return false;
    }
  }

  Future<List<DateTime>> getAvailableDatesInPeriod({
    required String mediumId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('=== getAvailableDatesInPeriod() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Period: $startDate to $endDate');

      final availability = await _firebaseService.getMediumAvailability(mediumId);
      final availabilityData = availability.exists
          ? availability.data() as Map<String, dynamic>
          : {};

      final blockedDates = await getBlockedDates(mediumId);
      final blockedDatesSet = blockedDates.map((date) =>
          DateTime(date.year, date.month, date.day)).toSet();

      final availableDates = <DateTime>[];
      var current = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        if (!blockedDatesSet.contains(current) &&
            _isDayAvailable(current, availabilityData)) {
          availableDates.add(DateTime(current.year, current.month, current.day));
        }
        current = current.add(const Duration(days: 1));
      }

      debugPrint('✅ ${availableDates.length} datas disponíveis no período');
      return availableDates;
    } catch (e) {
      debugPrint('❌ Erro ao buscar datas disponíveis: $e');
      return [];
    }
  }

  Future<List<String>> getAvailableTimeSlotsForDate({
    required String mediumId,
    required DateTime date,
    int consultationDuration = 30,
  }) async {
    try {
      debugPrint('=== getAvailableTimeSlotsForDate() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Date: $date');
      debugPrint('Duration: $consultationDuration minutes');

      if (await isDateBlocked(mediumId, date)) {
        debugPrint('⚠️ Data está bloqueada');
        return [];
      }

      final availability = await _firebaseService.getMediumAvailability(mediumId);
      final availabilityData = availability.exists
          ? availability.data() as Map<String, dynamic>
          : {};

      if (!_isDayAvailable(date, availabilityData)) {
        debugPrint('⚠️ Dia não está disponível na agenda');
        return [];
      }

      final dayOfWeek = _getDayOfWeek(date.weekday);
      final dayData = availabilityData[dayOfWeek] as Map<String, dynamic>?;

      if (dayData == null || dayData['isAvailable'] != true) {
        return [];
      }

      final startTime = dayData['startTime'] as String? ?? '09:00';
      final endTime = dayData['endTime'] as String? ?? '18:00';
      final breaks = dayData['breaks'] as List? ?? [];

      final existingAppointments = await _getExistingAppointmentsForDate(mediumId, date);

      final timeSlots = _generateTimeSlots(
        startTime: startTime,
        endTime: endTime,
        duration: consultationDuration,
        breaks: breaks,
        existingAppointments: existingAppointments,
      );

      debugPrint('✅ ${timeSlots.length} horários disponíveis');
      return timeSlots;
    } catch (e) {
      debugPrint('❌ Erro ao buscar horários disponíveis: $e');
      return [];
    }
  }

  Future<bool> blockDateRange({
    required String mediumId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      debugPrint('=== blockDateRange() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Range: $startDate to $endDate');

      final batch = _firebaseService.firestore.batch();

      DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      int blockedCount = 0;

      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        final blockId = '${mediumId}_${current.millisecondsSinceEpoch}';

        final blockData = {
          'id': blockId,
          'mediumId': mediumId,
          'date': Timestamp.fromDate(current),
          'reason': reason ?? 'Período bloqueado',
          'isRecurring': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        batch.set(blockedDatesCollection.doc(blockId), blockData);
        current = current.add(const Duration(days: 1));
        blockedCount++;
      }

      await batch.commit();
      await _updateMediumAvailabilityBlockedDates(mediumId);

      debugPrint('✅ $blockedCount datas bloqueadas no período');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao bloquear período: $e');
      return false;
    }
  }

  Future<bool> blockRecurringDate({
    required String mediumId,
    required int weekday,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('=== blockRecurringDate() ===');
      debugPrint('Medium ID: $mediumId');
      debugPrint('Weekday: $weekday');

      final pattern = 'weekly_$weekday';
      final recurringId = '${mediumId}_recurring_$pattern';

      final blockData = {
        'id': recurringId,
        'mediumId': mediumId,
        'weekday': weekday,
        'reason': reason ?? 'Bloqueio recorrente',
        'isRecurring': true,
        'recurringPattern': pattern,
        'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firebaseService.firestore
          .collection('recurring_blocks')
          .doc(recurringId)
          .set(blockData);

      debugPrint('✅ Bloqueio recorrente criado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao criar bloqueio recorrente: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDateBlockingStatistics(String mediumId) async {
    try {
      final snapshot = await blockedDatesCollection
          .where('mediumId', isEqualTo: mediumId)
          .where('isActive', isEqualTo: true)
          .get();

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);

      int totalBlocked = snapshot.docs.length;
      int thisMonthBlocked = 0;
      int nextMonthBlocked = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();

        if (date.isAfter(thisMonth) && date.isBefore(nextMonth)) {
          thisMonthBlocked++;
        } else if (date.isAfter(nextMonth)) {
          nextMonthBlocked++;
        }
      }

      return {
        'totalBlocked': totalBlocked,
        'thisMonthBlocked': thisMonthBlocked,
        'nextMonthBlocked': nextMonthBlocked,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  Future<void> _updateMediumAvailabilityBlockedDates(String mediumId) async {
    try {
      final blockedDates = await getBlockedDates(mediumId);

      await mediumAvailabilityCollection.doc(mediumId).update({
        'blockedDates': blockedDates.map((date) => Timestamp.fromDate(date)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Erro ao atualizar availability: $e');
    }
  }

  bool _isDayAvailable(DateTime date, Map<dynamic, dynamic> availabilityData) {
    final dayOfWeek = _getDayOfWeek(date.weekday);
    final dayData = availabilityData[dayOfWeek] as Map<String, dynamic>?;
    return dayData != null && dayData['isAvailable'] == true;
  }

  String _getDayOfWeek(int weekday) {
    const days = [
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday'
    ];
    return days[weekday - 1];
  }

  Future<List<Map<String, dynamic>>> _getExistingAppointmentsForDate(
      String mediumId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firebaseService.appointmentsCollection
          .where('mediumId', isEqualTo: mediumId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'dateTime': (data['dateTime'] as Timestamp).toDate(),
          'duration': data['duration'] ?? 30,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar agendamentos existentes: $e');
      return [];
    }
  }

  List<String> _generateTimeSlots({
    required String startTime,
    required String endTime,
    required int duration,
    required List breaks,
    required List<Map<String, dynamic>> existingAppointments,
  }) {
    final slots = <String>[];

    final startHour = int.parse(startTime.split(':')[0]);
    final startMinute = int.parse(startTime.split(':')[1]);
    final endHour = int.parse(endTime.split(':')[0]);
    final endMinute = int.parse(endTime.split(':')[1]);

    var currentHour = startHour;
    var currentMinute = startMinute;

    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute + duration <= endMinute)) {

      final timeString = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';

      if (!_isTimeSlotConflicting(currentHour, currentMinute, duration, existingAppointments) &&
          !_isTimeInBreaks(currentHour, currentMinute, breaks)) {
        slots.add(timeString);
      }

      currentMinute += duration;
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
    }

    return slots;
  }

  bool _isTimeSlotConflicting(int hour, int minute, int duration,
      List<Map<String, dynamic>> existingAppointments) {

    final slotStart = DateTime(2024, 1, 1, hour, minute);
    final slotEnd = slotStart.add(Duration(minutes: duration));

    for (final appointment in existingAppointments) {
      final appointmentStart = appointment['dateTime'] as DateTime;
      final appointmentDuration = appointment['duration'] as int;
      final appointmentEnd = appointmentStart.add(Duration(minutes: appointmentDuration));

      if ((slotStart.isBefore(appointmentEnd) && slotEnd.isAfter(appointmentStart))) {
        return true;
      }
    }

    return false;
  }

  bool _isTimeInBreaks(int hour, int minute, List breaks) {
    for (final breakItem in breaks) {
      if (breakItem is Map<String, dynamic>) {
        final breakStart = breakItem['startTime'] as String?;
        final breakEnd = breakItem['endTime'] as String?;

        if (breakStart != null && breakEnd != null) {
          final breakStartHour = int.parse(breakStart.split(':')[0]);
          final breakStartMinute = int.parse(breakStart.split(':')[1]);
          final breakEndHour = int.parse(breakEnd.split(':')[0]);
          final breakEndMinute = int.parse(breakEnd.split(':')[1]);

          if ((hour > breakStartHour || (hour == breakStartHour && minute >= breakStartMinute)) &&
              (hour < breakEndHour || (hour == breakEndHour && minute < breakEndMinute))) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> cleanupOldBlockedDates() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final oldBlocks = await blockedDatesCollection
          .where('date', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .where('isActive', isEqualTo: false)
          .get();

      final batch = _firebaseService.firestore.batch();
      for (final doc in oldBlocks.docs) {
        batch.delete(doc.reference);
      }

      if (oldBlocks.docs.isNotEmpty) {
        await batch.commit();
        debugPrint('🧹 Limpou ${oldBlocks.docs.length} datas bloqueadas antigas');
      }
    } catch (e) {
      debugPrint('❌ Erro na limpeza: $e');
    }
  }
}
