import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class EarningsController extends GetxController {
  final MediumService _mediumService = Get.find<MediumService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> earningsHistory = <Map<String, dynamic>>[].obs;
  final RxString selectedPeriod = 'month'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble monthlyEarnings = 0.0.obs;
  final RxDouble weeklyEarnings = 0.0.obs;
  final RxInt totalConsultations = 0.obs;

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadEarningsData();
  }

  Future<void> loadEarningsData() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadEarningsData() ===');
      isLoading.value = true;

      await Future.wait([
        loadEarningsHistory(),
        calculateTotals(),
      ]);
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados de ganhos: $e');
      Get.snackbar('Erro', 'Não foi possível carregar os dados de ganhos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEarningsHistory() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadEarningsHistory() ===');

      DateTime? start = startDate.value;
      DateTime? end = endDate.value;

      if (start == null || end == null) {
        final dates = _getPeriodDates(selectedPeriod.value);
        start = dates['start'];
        end = dates['end'];
      }

      final earnings = await _mediumService.getEarningsHistory(
        currentMediumId!,
        startDate: start,
        endDate: end,
      );

      earningsHistory.value = earnings;
      debugPrint('✅ ${earnings.length} registros de ganhos carregados');
    } catch (e) {
      debugPrint('❌ Erro ao carregar histórico: $e');
      earningsHistory.value = [];
    }
  }

  Future<void> calculateTotals() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== calculateTotals() ===');

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final allEarnings = await _mediumService.getEarningsHistory(currentMediumId!);

      double total = 0.0;
      double monthly = 0.0;
      double weekly = 0.0;
      int consultations = 0;

      for (final earning in allEarnings) {
        final amount = (earning['amount'] as num).toDouble();
        final date = earning['date'] as DateTime;

        total += amount;
        consultations++;

        if (date.isAfter(startOfMonth)) {
          monthly += amount;
        }

        if (date.isAfter(startOfWeek)) {
          weekly += amount;
        }
      }

      totalEarnings.value = total;
      monthlyEarnings.value = monthly;
      weeklyEarnings.value = weekly;
      totalConsultations.value = consultations;

      debugPrint('✅ Totais calculados - Total: R\$ ${total.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Erro ao calcular totais: $e');
    }
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    startDate.value = null;
    endDate.value = null;
    loadEarningsHistory();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    selectedPeriod.value = 'custom';
    startDate.value = start;
    endDate.value = end;
    loadEarningsHistory();
  }

  Map<String, DateTime?> _getPeriodDates(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'week':
        return {
          'start': now.subtract(Duration(days: now.weekday - 1)),
          'end': now,
        };
      case 'month':
        return {
          'start': DateTime(now.year, now.month, 1),
          'end': now,
        };
      case 'quarter':
        final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        return {
          'start': DateTime(now.year, quarterStart, 1),
          'end': now,
        };
      case 'year':
        return {
          'start': DateTime(now.year, 1, 1),
          'end': now,
        };
      default:
        return {
          'start': null,
          'end': null,
        };
    }
  }

  Future<void> refreshData() async {
    await loadEarningsData();
  }

  String get formattedTotalEarnings => 'R\$ ${totalEarnings.value.toStringAsFixed(2)}';
  String get formattedMonthlyEarnings => 'R\$ ${monthlyEarnings.value.toStringAsFixed(2)}';
  String get formattedWeeklyEarnings => 'R\$ ${weeklyEarnings.value.toStringAsFixed(2)}';

  double get averageEarningsPerConsultation {
    if (totalConsultations.value == 0) return 0.0;
    return totalEarnings.value / totalConsultations.value;
  }

  String get formattedAverageEarnings => 'R\$ ${averageEarningsPerConsultation.toStringAsFixed(2)}';
}
