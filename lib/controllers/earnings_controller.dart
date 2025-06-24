import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final RxDouble totalCommissions = 0.0.obs;
  final RxDouble monthlyCommissions = 0.0.obs;
  final RxInt totalConsultations = 0.obs;
  final RxInt monthlyConsultations = 0.obs;

  String? get currentMediumId => _authController.mediumId;

  @override
  void onInit() {
    super.onInit();
    loadEarningsData();

    // Atualizar dados quando o período mudar
    ever(selectedPeriod, (_) => loadEarningsData());
  }

  Future<void> loadEarningsData() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadEarningsData() ===');
      isLoading.value = true;

      await Future.wait([
        loadEarningsHistory(),
        calculateTotals(),
        loadWalletBalance(),
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

      // Ordenar por data (mais recente primeiro)
      earnings.sort((a, b) {
        final dateA = a['date']?.toDate() ?? DateTime.now();
        final dateB = b['date']?.toDate() ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      earningsHistory.value = earnings;
      debugPrint('✅ ${earnings.length} registros de ganhos carregados');
    } catch (e) {
      debugPrint('❌ Erro ao carregar histórico: $e');
      earningsHistory.value = [];
    }
  }

  Future<void> loadWalletBalance() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== loadWalletBalance() ===');
      final balance = await _mediumService.getMediumWalletBalance(currentMediumId!);
      totalEarnings.value = balance;
      debugPrint('✅ Saldo da carteira: R\$ ${balance.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar saldo: $e');
    }
  }

  Future<void> calculateTotals() async {
    if (currentMediumId == null) return;

    try {
      debugPrint('=== calculateTotals() ===');

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      // Carregar todos os ganhos
      final allEarnings = await _mediumService.getEarningsHistory(currentMediumId!);

      // Calcular totais
      double monthlyTotal = 0.0;
      double weeklyTotal = 0.0;
      double monthlyCommissionsTotal = 0.0;
      double totalCommissionsCalculated = 0.0;
      int monthlyConsultationsCount = 0;
      int totalConsultationsCount = allEarnings.length;

      for (final earning in allEarnings) {
        final date = earning['date']?.toDate() ?? DateTime.now();
        final mediumAmount = (earning['mediumAmount'] ?? 0.0).toDouble();
        final oraculumAmount = (earning['oraculumAmount'] ?? 0.0).toDouble();

        // Somar comissões totais
        totalCommissionsCalculated += oraculumAmount;

        if (date.isAfter(startOfMonth)) {
          monthlyTotal += mediumAmount;
          monthlyCommissionsTotal += oraculumAmount;
          monthlyConsultationsCount++;
        }

        if (date.isAfter(startOfWeek)) {
          weeklyTotal += mediumAmount;
        }
      }

      monthlyEarnings.value = monthlyTotal;
      weeklyEarnings.value = weeklyTotal;
      totalCommissions.value = totalCommissionsCalculated;
      monthlyCommissions.value = monthlyCommissionsTotal;
      totalConsultations.value = totalConsultationsCount;
      monthlyConsultations.value = monthlyConsultationsCount;

      debugPrint('✅ Totais calculados:');
      debugPrint('  - Mensal: R\$ ${monthlyTotal.toStringAsFixed(2)}');
      debugPrint('  - Semanal: R\$ ${weeklyTotal.toStringAsFixed(2)}');
      debugPrint('  - Total consultas: $totalConsultationsCount');
      debugPrint('  - Total comissões: R\$ ${totalCommissionsCalculated.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Erro ao calcular totais: $e');
    }
  }

  Map<String, DateTime> _getPeriodDates(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final currentQuarter = ((now.month - 1) / 3).floor();
        start = DateTime(now.year, currentQuarter * 3 + 1, 1);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    return {'start': start, 'end': end};
  }

  Future<void> refreshEarnings() async {
    await loadEarningsData();
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    startDate.value = null;
    endDate.value = null;
  }

  void setCustomPeriod(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'custom';
    loadEarningsData();
  }

  double get totalGrossEarnings {
    // Calcular ganhos brutos (valor que seria 100%)
    return totalEarnings.value > 0 ? totalEarnings.value / 0.8 : 0.0;
  }

  double get monthlyGrossEarnings {
    return monthlyEarnings.value > 0 ? monthlyEarnings.value / 0.8 : 0.0;
  }

  String get formattedTotalEarnings {
    return 'R\$ ${totalEarnings.value.toStringAsFixed(2)}';
  }

  String get formattedMonthlyEarnings {
    return 'R\$ ${monthlyEarnings.value.toStringAsFixed(2)}';
  }

  String get formattedWeeklyEarnings {
    return 'R\$ ${weeklyEarnings.value.toStringAsFixed(2)}';
  }

  String get formattedTotalCommissions {
    return 'R\$ ${totalCommissions.value.toStringAsFixed(2)}';
  }

  String get formattedMonthlyCommissions {
    return 'R\$ ${monthlyCommissions.value.toStringAsFixed(2)}';
  }

  double get monthlyGrowthPercentage {
    // Calcular crescimento mensal (simulado - pode ser implementado comparando com mês anterior)
    if (monthlyEarnings.value > 0) {
      return 15.2; // Valor simulado
    }
    return 0.0;
  }

  double get averagePerConsultation {
    return totalConsultations.value > 0
        ? totalEarnings.value / totalConsultations.value
        : 0.0;
  }

  double get monthlyAveragePerConsultation {
    return monthlyConsultations.value > 0
        ? monthlyEarnings.value / monthlyConsultations.value
        : 0.0;
  }

  List<Map<String, dynamic>> get filteredEarnings {
    return earningsHistory.where((earning) {
      final date = earning['date']?.toDate() ?? DateTime.now();
      final dates = _getPeriodDates(selectedPeriod.value);

      if (startDate.value != null && endDate.value != null) {
        return date.isAfter(startDate.value!) && date.isBefore(endDate.value!);
      }

      return date.isAfter(dates['start']!) && date.isBefore(dates['end']!);
    }).toList();
  }

  Map<String, dynamic> getEarningsSummary() {
    return {
      'totalEarnings': totalEarnings.value,
      'monthlyEarnings': monthlyEarnings.value,
      'weeklyEarnings': weeklyEarnings.value,
      'totalCommissions': totalCommissions.value,
      'monthlyCommissions': monthlyCommissions.value,
      'totalConsultations': totalConsultations.value,
      'monthlyConsultations': monthlyConsultations.value,
      'averagePerConsultation': averagePerConsultation,
      'monthlyAveragePerConsultation': monthlyAveragePerConsultation,
      'growthPercentage': monthlyGrowthPercentage,
      'totalGrossEarnings': totalGrossEarnings,
      'monthlyGrossEarnings': monthlyGrossEarnings,
    };
  }

  List<Map<String, dynamic>> getTopPerformingPeriods() {
    // Agrupar ganhos por mês para identificar melhores períodos
    final Map<String, double> monthlyPerformance = {};

    for (final earning in earningsHistory) {
      final date = earning['date']?.toDate() ?? DateTime.now();
      final amount = (earning['mediumAmount'] ?? 0.0).toDouble();
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      monthlyPerformance[monthKey] = (monthlyPerformance[monthKey] ?? 0.0) + amount;
    }

    // Converter para lista e ordenar
    final performance = monthlyPerformance.entries
        .map((entry) => {
      'period': entry.key,
      'amount': entry.value,
      'formattedAmount': 'R\$ ${entry.value.toStringAsFixed(2)}',
    })
        .toList();

    performance.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return performance.take(5).toList();
  }

  Map<String, int> getConsultationsByWeekday() {
    final Map<String, int> weekdayCount = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    for (final earning in earningsHistory) {
      final date = earning['date']?.toDate() ?? DateTime.now();
      final weekdayName = _getWeekdayName(date.weekday);
      weekdayCount[weekdayName] = (weekdayCount[weekdayName] ?? 0) + 1;
    }

    return weekdayCount;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  Future<bool> exportEarnings(String format) async {
    try {
      debugPrint('=== exportEarnings() ===');
      debugPrint('Format: $format');

      // Simular exportação
      await Future.delayed(const Duration(seconds: 2));

      switch (format.toLowerCase()) {
        case 'pdf':
        // Implementar geração de PDF
          break;
        case 'excel':
        // Implementar geração de Excel
          break;
        case 'email':
        // Implementar envio por email
          break;
      }

      Get.snackbar(
        'Exportação Concluída',
        'Dados exportados em formato $format com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao exportar: $e');
      Get.snackbar(
        'Erro na Exportação',
        'Não foi possível exportar os dados: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'custom';
    await loadEarningsData();
  }

  void clearDateFilter() {
    startDate.value = null;
    endDate.value = null;
    selectedPeriod.value = 'month';
  }

  bool get hasCustomDateFilter {
    return startDate.value != null && endDate.value != null;
  }

  String get currentPeriodLabel {
    if (hasCustomDateFilter) {
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(startDate.value!)} - ${formatter.format(endDate.value!)}';
    }

    switch (selectedPeriod.value) {
      case 'week':
        return 'Esta Semana';
      case 'month':
        return 'Este Mês';
      case 'quarter':
        return 'Este Trimestre';
      case 'year':
        return 'Este Ano';
      default:
        return 'Este Mês';
    }
  }

  // Método para gerar dados de exemplo para o gráfico
  List<Map<String, dynamic>> generateSampleChartData() {
    final sampleData = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Gerar 7 dias de dados de exemplo
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final baseAmount = 80.0 + (i * 15) + (DateTime.now().millisecond % 50);
      final totalAmount = baseAmount / 0.8; // Valor bruto
      final mediumAmount = totalAmount * 0.8; // 80% para o médium
      final oraculumAmount = totalAmount * 0.2; // 20% para o Oraculum

      sampleData.add({
        'date': DateFormat('dd/MM').format(date),
        'shortDate': DateFormat('dd').format(date),
        'mediumAmount': mediumAmount,
        'oraculumAmount': oraculumAmount,
        'fullDate': date,
      });
    }

    return sampleData;
  }

  // Método para usar dados reais ou de exemplo
  List<Map<String, dynamic>> getChartData() {
    if (earningsHistory.isEmpty) {
      return generateSampleChartData();
    }

    // Agrupar ganhos por dia
    final Map<String, Map<String, dynamic>> dailyEarnings = {};

    for (final earning in earningsHistory) {
      final date = earning['date']?.toDate() ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final mediumAmount = (earning['mediumAmount'] ?? 0.0).toDouble();
      final oraculumAmount = (earning['oraculumAmount'] ?? 0.0).toDouble();

      if (dailyEarnings.containsKey(dateKey)) {
        dailyEarnings[dateKey]!['mediumAmount'] =
            (dailyEarnings[dateKey]!['mediumAmount'] as double) + mediumAmount;
        dailyEarnings[dateKey]!['oraculumAmount'] =
            (dailyEarnings[dateKey]!['oraculumAmount'] as double) + oraculumAmount;
      } else {
        dailyEarnings[dateKey] = {
          'mediumAmount': mediumAmount,
          'oraculumAmount': oraculumAmount,
          'dateTime': date,
        };
      }
    }

    // Converter para lista e ordenar por data
    final sortedEntries = dailyEarnings.entries.toList();
    sortedEntries.sort((a, b) {
      final dateA = a.value['dateTime'] as DateTime;
      final dateB = b.value['dateTime'] as DateTime;
      return dateA.compareTo(dateB);
    });

    final chartData = sortedEntries.map((entry) {
      final date = entry.value['dateTime'] as DateTime;
      return {
        'date': DateFormat('dd/MM').format(date),
        'shortDate': DateFormat('dd').format(date),
        'mediumAmount': entry.value['mediumAmount'] as double,
        'oraculumAmount': entry.value['oraculumAmount'] as double,
        'fullDate': date,
      };
    }).toList();

    // Pegar apenas os últimos 10 pontos para melhor visualização
    final recentData = chartData.length > 10
        ? chartData.sublist(chartData.length - 10)
        : chartData;

    return recentData;
  }

  @override
  void onClose() {
    debugPrint('🧹 EarningsController finalizando...');
    super.onClose();
  }
}
