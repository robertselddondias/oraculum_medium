import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/earnings_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EarningsController controller = Get.find<EarningsController>();
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final isTablet = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isLargeScreen),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadEarningsData,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 1200 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCards(controller, isLargeScreen),
                            SizedBox(height: isLargeScreen ? 32 : 24),
                            _buildPeriodFilter(controller, isLargeScreen),
                            SizedBox(height: isLargeScreen ? 24 : 20),
                            _buildEarningsChart(controller, isLargeScreen),
                            SizedBox(height: isLargeScreen ? 32 : 24),
                            _buildHistorySection(controller, isLargeScreen),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isLargeScreen ? 24 : 20,
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meus Ganhos',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Histórico completo de receitas',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showFilterOptions(),
            child: Container(
              padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: isLargeScreen ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: -0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildSummaryCards(EarningsController controller, bool isLargeScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Saldo Atual',
                'R\$ ${controller.totalEarnings.value.toStringAsFixed(2)}',
                'Disponível na carteira',
                Icons.account_balance_wallet,
                const Color(0xFF00C851),
                isLargeScreen,
              ),
            ),
            SizedBox(width: isLargeScreen ? 16 : 12),
            Expanded(
              child: _buildSummaryCard(
                'Este Mês',
                'R\$ ${controller.monthlyEarnings.value.toStringAsFixed(2)}',
                'Ganhos do período',
                Icons.calendar_month,
                AppTheme.primaryColor,
                isLargeScreen,
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeScreen ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Comissões',
                'R\$ ${(controller.totalEarnings.value * 0.25).toStringAsFixed(2)}',
                '20% para o Oraculum',
                Icons.business,
                Colors.orange,
                isLargeScreen,
              ),
            ),
            SizedBox(width: isLargeScreen ? 16 : 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Consultas',
                '${controller.totalConsultations.value}',
                'Finalizadas com sucesso',
                Icons.event_available,
                AppTheme.accentColor,
                isLargeScreen,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isLargeScreen ? 20 : 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.white60,
                size: isLargeScreen ? 16 : 14,
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 10,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter(EarningsController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar Período',
            style: TextStyle(
              fontSize: isLargeScreen ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['week', 'month', 'quarter', 'year'].map((period) {
              final isSelected = controller.selectedPeriod.value == period;
              return GestureDetector(
                onTap: () => controller.selectedPeriod.value = period,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16 : 12,
                    vertical: isLargeScreen ? 10 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPeriodLabel(period),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
    ).slideX(
      begin: -0.1,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildEarningsChart(EarningsController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Evolução dos Ganhos',
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                  '${controller.monthlyGrowthPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 12 : 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00C851),
                  ),
                )),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Container(
            height: isLargeScreen ? 200 : 160,
            width: double.infinity,
            child: Obx(() => _buildLineChart(controller, isLargeScreen)),
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          _buildChartLegend(isLargeScreen),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 600),
    ).slideX(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildLineChart(EarningsController controller, bool isLargeScreen) {
    final chartData = _generateChartData(controller);

    if (chartData.isEmpty) {
      return _buildEmptyChart(isLargeScreen);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartData.isNotEmpty ? _calculateInterval(chartData) : 100,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return _buildBottomTitle(value.toInt(), controller);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: chartData.isNotEmpty ? _calculateInterval(chartData) : 100,
              reservedSize: isLargeScreen ? 50 : 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return _buildLeftTitle(value);
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: chartData.length.toDouble() - 1,
        minY: 0,
        maxY: chartData.isNotEmpty ? _calculateMaxY(chartData) : 1000,
        lineBarsData: [
          // Linha dos ganhos líquidos (80%)
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['mediumAmount']!);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00C851),
                const Color(0xFF00C851).withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00C851).withOpacity(0.3),
                  const Color(0xFF00C851).withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Linha das comissões (20%)
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['oraculumAmount']!);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange,
                Colors.orange.withOpacity(0.7),
              ],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            dashArray: [5, 5],
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceColor,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final spotIndex = touchedSpot.spotIndex;
                final barIndex = touchedSpot.barIndex;

                if (spotIndex >= 0 && spotIndex < chartData.length) {
                  final data = chartData[spotIndex];
                  final isMainLine = barIndex == 0;

                  if (isMainLine) {
                    return LineTooltipItem(
                      'Seus Ganhos\nR\$ ${data['mediumAmount']!.toStringAsFixed(2)}\n${data['date']}',
                      const TextStyle(
                        color: Color(0xFF00C851),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  } else {
                    return LineTooltipItem(
                      'Comissão Oraculum\nR\$ ${data['oraculumAmount']!.toStringAsFixed(2)}\n${data['date']}',
                      const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                }
                return null;
              }).where((item) => item != null).cast<LineTooltipItem>().toList();
            },
          ),
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                const FlLine(
                  color: Colors.white,
                  strokeWidth: 2,
                  dashArray: [3, 3],
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final color = barData.gradient?.colors.first ??
                        barData.color ??
                        const Color(0xFF00C851);
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: color,
                    );
                  },
                ),
              );
            }).toList();
          },
          handleBuiltInTouches: true,
          touchSpotThreshold: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyChart(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              color: Colors.white60,
              size: isLargeScreen ? 48 : 40,
            ),
            SizedBox(height: 8),
            Text(
              'Sem dados para exibir',
              style: TextStyle(
                color: Colors.white60,
                fontSize: isLargeScreen ? 16 : 14,
              ),
            ),
            Text(
              'Complete algumas consultas para ver o gráfico',
              style: TextStyle(
                color: Colors.white38,
                fontSize: isLargeScreen ? 12 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(bool isLargeScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          'Seus Ganhos (80%)',
          const Color(0xFF00C851),
          isLargeScreen,
          isMainLine: true,
        ),
        _buildLegendItem(
          'Comissão Oraculum (20%)',
          Colors.orange,
          isLargeScreen,
          isMainLine: false,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isLargeScreen, {required bool isMainLine}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLargeScreen ? 16 : 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isMainLine ? null : Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: color,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLargeScreen ? 12 : 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTitle(int index, EarningsController controller) {
    final chartData = _generateChartData(controller);
    if (index < 0 || index >= chartData.length) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        chartData[index]['shortDate']!,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(double value) {
    if (value == 0) return const SizedBox.shrink();

    return Text(
      'R\${(value / 1).toInt()}',
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<Map<String, dynamic>> _generateChartData(EarningsController controller) {
    final earnings = controller.earningsHistory;

    // Se não há dados reais, gerar dados de exemplo
    if (earnings.isEmpty) {
      return _generateSampleChartData();
    }

    // Agrupar ganhos por dia
    final Map<String, Map<String, dynamic>> dailyEarnings = {};

    for (final earning in earnings) {
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

  List<Map<String, dynamic>> _generateSampleChartData() {
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

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    double maxValue = 0;
    for (final item in data) {
      final mediumAmount = item['mediumAmount'] as double;
      if (mediumAmount > maxValue) {
        maxValue = mediumAmount;
      }
    }
    // Adicionar 20% de margem
    return maxValue * 1.2;
  }

  double _calculateInterval(List<Map<String, dynamic>> data) {
    final maxY = _calculateMaxY(data);
    return maxY / 4; // Dividir em 4 intervalos
  }

  Widget _buildHistorySection(EarningsController controller, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Histórico de Ganhos',
              style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showExportOptions(),
              child: Container(
                padding: EdgeInsets.all(isLargeScreen ? 8 : 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download,
                      color: Colors.white70,
                      size: isLargeScreen ? 16 : 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Exportar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isLargeScreen ? 12 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeScreen ? 20 : 16),
        Obx(() {
          if (controller.earningsHistory.isEmpty) {
            return _buildEmptyState(isLargeScreen);
          }

          return Column(
            children: controller.earningsHistory.map((earning) {
              return Padding(
                padding: EdgeInsets.only(bottom: isLargeScreen ? 12 : 10),
                child: _buildEarningItem(earning, isLargeScreen),
              );
            }).toList(),
          );
        }),
      ],
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildEarningItem(Map<String, dynamic> earning, bool isLargeScreen) {
    final totalAmount = (earning['totalAmount'] ?? 0.0).toDouble();
    final mediumAmount = (earning['mediumAmount'] ?? 0.0).toDouble();
    final oraculumAmount = (earning['oraculumAmount'] ?? 0.0).toDouble();
    final date = earning['date']?.toDate() ?? DateTime.now();
    final appointmentId = earning['appointmentId'] ?? '';

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: const Color(0xFF00C851),
                  size: isLargeScreen ? 24 : 20,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Consulta Finalizada',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('dd/MM/yyyy').format(date),
                          style: TextStyle(
                            fontSize: isLargeScreen ? 12 : 10,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${appointmentId.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 12 : 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAmountRow(
                  'Valor Total da Consulta',
                  totalAmount,
                  Colors.white70,
                  isLargeScreen,
                ),
                SizedBox(height: isLargeScreen ? 12 : 10),
                _buildAmountRow(
                  'Comissão Oraculum (20%)',
                  oraculumAmount,
                  Colors.orange,
                  isLargeScreen,
                  showMinus: true,
                ),
                SizedBox(height: isLargeScreen ? 12 : 10),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                SizedBox(height: isLargeScreen ? 12 : 10),
                _buildAmountRow(
                  'Seu Ganho Líquido (80%)',
                  mediumAmount,
                  const Color(0xFF00C851),
                  isLargeScreen,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color, bool isLargeScreen, {bool showMinus = false, bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${showMinus ? '- ' : ''}R\$ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isLargeScreen ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 40 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: isLargeScreen ? 64 : 56,
              color: Colors.white30,
            ),
            SizedBox(height: isLargeScreen ? 16 : 12),
            Text(
              'Nenhum ganho registrado',
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Seus ganhos aparecerão aqui conforme\nvocê finalizar as consultas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week':
        return 'Semana';
      case 'month':
        return 'Mês';
      case 'quarter':
        return 'Trimestre';
      case 'year':
        return 'Ano';
      default:
        return 'Mês';
    }
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros Avançados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.white70),
              title: const Text('Período Personalizado', style: TextStyle(color: Colors.white)),
              onTap: () => _showDatePicker(),
            ),
            ListTile(
              leading: const Icon(Icons.sort, color: Colors.white70),
              title: const Text('Ordenar por Valor', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.filter_list, color: Colors.white70),
              title: const Text('Filtrar por Tipo', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exportar Dados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar em PDF', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Exportar em Excel', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Enviar por Email', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    // Implementar seleção de data personalizada
    Get.back();
  }
}
