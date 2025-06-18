import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/widgets/stats_card.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final DashboardController _controller = Get.find<DashboardController>();
  String _selectedPeriod = 'month';

  final Map<String, String> _periods = {
    'week': 'Esta Semana',
    'month': 'Este Mês',
    'year': 'Este Ano',
    'all': 'Todo Período',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.refreshDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPeriodSelector(),
                        const SizedBox(height: 20),
                        _buildEarningsOverview(),
                        const SizedBox(height: 20),
                        _buildEarningsChart(),
                        const SizedBox(height: 20),
                        _buildConsultationStats(),
                        const SizedBox(height: 20),
                        _buildRecentEarnings(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Meus Ganhos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.earningsHistory),
            icon: const Icon(Icons.history, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = entry.key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Obx(() {
      final stats = _controller.stats.value;
      if (stats == null) {
        return const SizedBox.shrink();
      }

      double earnings = 0;
      String subtitle = '';

      switch (_selectedPeriod) {
        case 'week':
          earnings = stats.weeklyEarnings;
          subtitle = 'nesta semana';
          break;
        case 'month':
          earnings = stats.monthlyEarnings;
          subtitle = 'neste mês';
          break;
        case 'year':
          earnings = stats.totalEarnings; // Para demo, usando total
          subtitle = 'neste ano';
          break;
        case 'all':
          earnings = stats.totalEarnings;
          subtitle = 'total ganho';
          break;
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            const Text(
              'Ganhos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${earnings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${stats.completedAppointments}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Consultas\nConcluídas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'R\$ ${(earnings / (stats.completedAppointments > 0 ? stats.completedAppointments : 1)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Ganho Médio\nPor Consulta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução dos Ganhos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gráfico de ganhos\n(Em desenvolvimento)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationStats() {
    return Obx(() {
      final stats = _controller.stats.value;
      if (stats == null) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'Taxa de\nConclusão',
              value: '${stats.completionRate.toStringAsFixed(1)}%',
              subtitle: 'das consultas',
              icon: Icons.check_circle,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              title: 'Avaliação\nMédia',
              value: stats.formattedAverageRating,
              subtitle: 'estrelas',
              icon: Icons.star,
              color: Colors.amber,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecentEarnings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ganhos Recentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.earningsHistory),
                child: const Text(
                  'Ver tudo',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final date = DateTime.now().subtract(Duration(days: index));
            final amount = (50 + (index * 25)).toDouble();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.attach_money,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consulta realizada',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy - HH:mm').format(date),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+ R\$ ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
