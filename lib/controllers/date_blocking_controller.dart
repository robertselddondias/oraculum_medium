// lib/controllers/date_blocking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/date_blocking_service.dart';

class DateBlockingController extends GetxController {
  final DateBlockingService _dateBlockingService = Get.find<DateBlockingService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<Map<String, dynamic>> blockedDates = <Map<String, dynamic>>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString blockReason = ''.obs;
  final RxBool isRangeMode = false.obs;
  final Rx<DateTime?> rangeStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> rangeEndDate = Rx<DateTime?>(null);

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadBlockedDates();
  }

  Future<void> loadBlockedDates() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadBlockedDates() ===');
      isLoading.value = true;

      final dates = await _dateBlockingService.getBlockedDates(currentMediumId!);

      blockedDates.value = dates.map((date) => {
        'date': date,
        'dateString': _formatDate(date),
        'reason': 'Data bloqueada',
        'isActive': true,
      }).toList();

      debugPrint('✅ ${blockedDates.length} datas bloqueadas carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar datas bloqueadas: $e');
      Get.snackbar('Erro', 'Não foi possível carregar as datas bloqueadas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockSingleDate({
    DateTime? date,
    String? reason,
  }) async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== blockSingleDate() ===');
      isSaving.value = true;

      final dateToBlock = date ?? selectedDate.value;
      final blockReason = reason ?? this.blockReason.value;

      final success = await _dateBlockingService.blockDate(
        mediumId: currentMediumId!,
        date: dateToBlock,
        reason: blockReason.isEmpty ? 'Data bloqueada' : blockReason,
      );

      if (success) {
        await loadBlockedDates();
        Get.snackbar(
          'Sucesso',
          'Data bloqueada com sucesso',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
        resetForm();
      } else {
        throw Exception('Falha ao bloquear data');
      }
    } catch (e) {
      debugPrint('❌ Erro ao bloquear data: $e');
      Get.snackbar('Erro', 'Não foi possível bloquear a data');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> blockDateRange() async {
    if (currentMediumId == null ||
        rangeStartDate.value == null ||
        rangeEndDate.value == null) return;

    try {
      debugPrint('=== blockDateRange() ===');
      isSaving.value = true;

      final success = await _dateBlockingService.blockDateRange(
        mediumId: currentMediumId!,
        startDate: rangeStartDate.value!,
        endDate: rangeEndDate.value!,
        reason: blockReason.value.isEmpty ? 'Período bloqueado' : blockReason.value,
      );

      if (success) {
        await loadBlockedDates();
        Get.snackbar(
          'Sucesso',
          'Período bloqueado com sucesso',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
        resetForm();
      } else {
        throw Exception('Falha ao bloquear período');
      }
    } catch (e) {
      debugPrint('❌ Erro ao bloquear período: $e');
      Get.snackbar('Erro', 'Não foi possível bloquear o período');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> unblockDate(DateTime date) async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== unblockDate() ===');
      debugPrint('Data: $date');

      final success = await _dateBlockingService.unblockDate(
        mediumId: currentMediumId!,
        date: date,
      );

      if (success) {
        await loadBlockedDates();
        Get.snackbar(
          'Sucesso',
          'Data desbloqueada com sucesso',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Falha ao desbloquear data');
      }
    } catch (e) {
      debugPrint('❌ Erro ao desbloquear data: $e');
      Get.snackbar('Erro', 'Não foi possível desbloquear a data');
    }
  }

  Future<List<DateTime>> getAvailableDatesInMonth(DateTime month) async {
    if (currentMediumId == null) return [];

    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      return await _dateBlockingService.getAvailableDatesInPeriod(
        mediumId: currentMediumId!,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      debugPrint('❌ Erro ao buscar datas disponíveis: $e');
      return [];
    }
  }

  Future<List<String>> getAvailableTimeSlotsForDate(DateTime date) async {
    if (currentMediumId == null) return [];

    try {
      return await _dateBlockingService.getAvailableTimeSlotsForDate(
        mediumId: currentMediumId!,
        date: date,
        consultationDuration: 30,
      );
    } catch (e) {
      debugPrint('❌ Erro ao buscar horários disponíveis: $e');
      return [];
    }
  }

  Future<bool> isDateBlocked(DateTime date) async {
    if (currentMediumId == null) return false;

    return await _dateBlockingService.isDateBlocked(
      currentMediumId!,
      date,
    );
  }

  Future<Map<String, dynamic>> getBlockingStatistics() async {
    if (currentMediumId == null) return {};

    try {
      return await _dateBlockingService.getDateBlockingStatistics(currentMediumId!);
    } catch (e) {
      debugPrint('❌ Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void setBlockReason(String reason) {
    blockReason.value = reason;
  }

  void toggleRangeMode() {
    isRangeMode.value = !isRangeMode.value;
    if (!isRangeMode.value) {
      rangeStartDate.value = null;
      rangeEndDate.value = null;
    }
  }

  void setRangeStartDate(DateTime? date) {
    rangeStartDate.value = date;
    if (date != null && rangeEndDate.value != null && date.isAfter(rangeEndDate.value!)) {
      rangeEndDate.value = null;
    }
  }

  void setRangeEndDate(DateTime? date) {
    rangeEndDate.value = date;
  }

  void resetForm() {
    blockReason.value = '';
    isRangeMode.value = false;
    rangeStartDate.value = null;
    rangeEndDate.value = null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getRangeDisplayText() {
    if (rangeStartDate.value == null && rangeEndDate.value == null) {
      return 'Selecione o período';
    }

    if (rangeStartDate.value != null && rangeEndDate.value == null) {
      return 'De ${_formatDate(rangeStartDate.value!)} até...';
    }

    if (rangeStartDate.value != null && rangeEndDate.value != null) {
      return 'De ${_formatDate(rangeStartDate.value!)} até ${_formatDate(rangeEndDate.value!)}';
    }

    return 'Selecione o período';
  }

  bool get isValidRange {
    return rangeStartDate.value != null &&
        rangeEndDate.value != null &&
        rangeStartDate.value!.isBefore(rangeEndDate.value!) ||
        rangeStartDate.value!.isAtSameMomentAs(rangeEndDate.value!);
  }

  bool get canBlockDate {
    if (isRangeMode.value) {
      return isValidRange;
    }
    return selectedDate.value.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  List<DateTime> getBlockedDatesOnly() {
    return blockedDates.map((item) => item['date'] as DateTime).toList();
  }

  int get totalBlockedDates => blockedDates.length;

  int get thisMonthBlockedDates {
    final now = DateTime.now();
    return blockedDates.where((item) {
      final date = item['date'] as DateTime;
      return date.year == now.year && date.month == now.month;
    }).length;
  }

  int get nextMonthBlockedDates {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    return blockedDates.where((item) {
      final date = item['date'] as DateTime;
      return date.year == nextMonth.year && date.month == nextMonth.month;
    }).length;
  }

  Future<void> refreshData() async {
    await loadBlockedDates();
  }

  void showBlockDateDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Bloquear Data',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => SwitchListTile(
              title: const Text(
                'Bloquear período',
                style: TextStyle(color: Colors.white),
              ),
              value: isRangeMode.value,
              onChanged: (_) => toggleRangeMode(),
              activeColor: const Color(0xFF8C6BAE),
            )),

            const SizedBox(height: 16),

            TextField(
              onChanged: setBlockReason,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8C6BAE)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: canBlockDate && !isSaving.value
                ? () async {
              Get.back();
              if (isRangeMode.value) {
                await blockDateRange();
              } else {
                await blockSingleDate();
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C6BAE),
            ),
            child: isSaving.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Bloquear',
              style: TextStyle(color: Colors.white),
            ),
          )),
        ],
      ),
    );
  }

  void showUnblockConfirmation(DateTime date) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Desbloquear Data',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja desbloquear a data ${_formatDate(date)}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await unblockDate(date);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text(
              'Desbloquear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
