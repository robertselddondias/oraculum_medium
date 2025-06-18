import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  State<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  final DashboardController _controller = Get.find<DashboardController>();
  final MediumService _mediumService = Get.find<MediumService>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> earningsHistory = <Map<String, dynamic>>[].obs;

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'all';

  final Map<String, String> _periods = {
    'week': 'Esta Semana',
    'month': 'Este Mês',
    'quarter': 'Este Trimestre',
    'year': 'Este Ano',
    'all': 'Todo Período',
  };

  @override
  void initState() {
    super.initState();
    _loadEarningsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(child: _buildEarningsList()),
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
              'Histórico de Ganhos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showExportOptions(),
            icon: const Icon(Icons.file_download, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPeriodSelector(),
              ),
              const SizedBox(width: 12),
              _buildDateRangeButton(),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          dropdownColor: AppTheme.surfaceColor,
          style: const TextStyle(color: Colors.white),
          items: _periods.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
                _startDate = null;
                _endDate = null;
              });
              _loadEarningsHistory();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return ElevatedButton.icon(
      onPressed: () => _showDateRangePicker(),
      icon: const Icon(Icons.date_range, size: 18),
      label: const Text('Período'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Obx(() {
      final total = earningsHistory.fold<double>(
        0.0,
            (sum, earning) => sum + (earning['amount'] as double),
      );

      final count = earningsHistory.length;

      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
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
                  '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Consultas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
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
                  'R\$ ${count > 0 ? (total / count).toStringAsFixed(2) : '0.00'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Média',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEarningsList() {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }

      if (earningsHistory.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _loadEarningsHistory,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: earningsHistory.length,
          itemBuilder: (context, index) {
            final earning = earningsHistory[index];
            return _buildEarningCard(earning);
          },
        ),
      );
    });
  }

  Widget _buildEarningCard(Map<String, dynamic> earning) {
    final date = earning['date'] as DateTime;
    final amount = earning['amount'] as double;
    final appointmentId = earning['appointmentId'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppTheme.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta realizada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(date),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${appointmentId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white40,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ R\$ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Recebido',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum ganho encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seus ganhos de consultas aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _loadEarningsHistory(),
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadEarningsHistory() async {
    try {
      isLoading.value = true;

      // Calcular datas baseado no período selecionado
      DateTime? startDate = _startDate;
      DateTime? endDate = _endDate;

      if (startDate == null && endDate == null) {
        final now = DateTime.now();
        switch (_selectedPeriod) {
          case 'week':
            startDate = now.subtract(Duration(days: now.weekday - 1));
            endDate = now;
            break;
          case 'month':
            startDate = DateTime(now.year, now.month, 1);
            endDate = now;
            break;
          case 'quarter':
            final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
            startDate = DateTime(now.year, quarterStart, 1);
            endDate = now;
            break;
          case 'year':
            startDate = DateTime(now.year, 1, 1);
            endDate = now;
            break;
        }
      }

      // Simular carregamento de dados (substituir pela chamada real da API)
      await Future.delayed(const Duration(seconds: 1));

      // Dados simulados - substituir pela busca real no Firebase
      final List<Map<String, dynamic>> mockEarnings = List.generate(20, (index) {
        final date = DateTime.now().subtract(Duration(days: index));
        final amount = 50.0 + (index * 5);

        return {
          'id': 'earning_$index',
          'mediumId': _controller.currentMediumId,
          'amount': amount,
          'appointmentId': 'appointment_$index',
          'date': date,
          'createdAt': date,
        };
      });

      earningsHistory.value = mockEarnings;
    } catch (e) {
      debugPrint('❌ Erro ao carregar histórico: $e');
      Get.
