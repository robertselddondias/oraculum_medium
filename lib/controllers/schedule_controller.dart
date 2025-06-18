import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class ScheduleController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxMap<String, dynamic> weeklySchedule = RxMap<String, dynamic>({});
  final RxList<DateTime> blockedDates = <DateTime>[].obs;
  final RxList<int> availableDurations = <int>[15, 30, 45, 60].obs;
  final RxInt defaultDuration = 30.obs;

  final List<String> weekDays = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday'
  ];

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadScheduleData();
  }

  Future<void> loadScheduleData() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadScheduleData() ===');
      isLoading.value = true;

      final availability = await _mediumService.getMediumAvailability(currentMediumId!);

      _parseAvailabilityData(availability);

      debugPrint('✅ Dados da agenda carregados');
    } catch (e) {
      debugPrint('❌ Erro ao carregar agenda: $e');
      Get.snackbar('Erro', 'Não foi possível carregar a agenda');
    } finally {
      isLoading.value = false;
    }
  }

  void _parseAvailabilityData(Map<String, dynamic> data) {
    // Parse weekly schedule
    for (final day in weekDays) {
      if (data.containsKey(day)) {
        weeklySchedule[day] = data[day];
      } else {
        weeklySchedule[day] = {
          'isAvailable': false,
          'startTime': '09:00',
          'endTime': '18:00',
          'breaks': [],
        };
      }
    }

    // Parse blocked dates
    final blockedDatesData = data['blockedDates'] as List?;
    if (blockedDatesData != null) {
      blockedDates.value = blockedDatesData
          .map((date) => date is DateTime ? date : DateTime.parse(date.toString()))
          .toList();
    }

    // Parse available durations
    final durationsData = data['consultationDurations'] as List?;
    if (durationsData != null) {
      availableDurations.value = durationsData.cast<int>();
    }

    // Parse default duration
    defaultDuration.value = data['defaultDuration'] ?? 30;
  }

  void updateDayAvailability(String day, bool isAvailable) {
    final dayData = Map<String, dynamic>.from(weeklySchedule[day] ?? {});
    dayData['isAvailable'] = isAvailable;
    weeklySchedule[day] = dayData;
  }

  void updateDayTime(String day, String timeType, String time) {
    final dayData = Map<String, dynamic>.from(weeklySchedule[day] ?? {});
    dayData[timeType] = time;
    weeklySchedule[day] = dayData;
  }

  void addBlockedDate(DateTime date) {
    if (!blockedDates.contains(date)) {
      blockedDates.add(date);
    }
  }

  void removeBlockedDate(DateTime date) {
    blockedDates.remove(date);
  }

  void updateAvailableDurations(List<int> durations) {
    availableDurations.value = durations;
  }

  void updateDefaultDuration(int duration) {
    defaultDuration.value = duration;
  }

  Future<bool> saveSchedule() async {
    if (currentMediumId == null) return false;

    try {
      debugPrint('=== saveSchedule() ===');
      isSaving.value = true;

      final scheduleData = Map<String, dynamic>.from(weeklySchedule);
      scheduleData['blockedDates'] = blockedDates;
      scheduleData['consultationDurations'] = availableDurations;
      scheduleData['defaultDuration'] = defaultDuration.value;

      final success = await _mediumService.updateMediumAvailability(
        currentMediumId!,
        scheduleData,
      );

      if (success) {
        Get.snackbar(
          'Agenda Salva',
          'Sua agenda foi atualizada com sucesso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Erro', 'Não foi possível salvar a agenda');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Erro ao salvar agenda: $e');
      Get.snackbar('Erro', 'Erro ao salvar agenda: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  bool isDayAvailable(String day) {
    return weeklySchedule[day]?['isAvailable'] ?? false;
  }

  String getDayStartTime(String day) {
    return weeklySchedule[day]?['startTime'] ?? '09:00';
  }

  String getDayEndTime(String day) {
    return weeklySchedule[day]?['endTime'] ?? '18:00';
  }

  List<Map<String, String>> getDayBreaks(String day) {
    final breaks = weeklySchedule[day]?['breaks'] as List?;
    return breaks?.cast<Map<String, String>>() ?? [];
  }

  void addBreakToDay(String day, String startTime, String endTime) {
    final dayData = Map<String, dynamic>.from(weeklySchedule[day] ?? {});
    final breaks = List<Map<String, String>>.from(dayData['breaks'] ?? []);

    breaks.add({
      'startTime': startTime,
      'endTime': endTime,
    });

    dayData['breaks'] = breaks;
    weeklySchedule[day] = dayData;
  }

  void removeBreakFromDay(String day, int breakIndex) {
    final dayData = Map<String, dynamic>.from(weeklySchedule[day] ?? {});
    final breaks = List<Map<String, String>>.from(dayData['breaks'] ?? []);

    if (breakIndex >= 0 && breakIndex < breaks.length) {
      breaks.removeAt(breakIndex);
      dayData['breaks'] = breaks;
      weeklySchedule[day] = dayData;
    }
  }

  Future<void> refreshSchedule() async {
    await loadScheduleData();
  }
}
