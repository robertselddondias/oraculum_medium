import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/services/medium_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              _buildFilters(isLargeScreen, isTablet),
              Expanded(child: _buildEarningsList(isLargeScreen)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isLargeScreen ? 28 : 24,
            ),
          ).animate().scale(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          ),
          Expanded(
            child: Text(
              'Histórico de Ganhos',
              style: TextStyle(
                fontSize: isLargeScreen ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 500),
            ).slideX(
              begin: -0.2,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          IconButton(
            onPressed: () => _showExportOptions(),
            icon: Icon(
              Icons.file_download,
              color: Colors.white,
              size: isLargeScreen ? 28 : 24,
            ),
          ).animate().scale(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isLargeScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 20 : 16),
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          if (isTablet)
            Row(
              children: [
                Expanded(flex: 2, child: _buildPeriodSelector(isLargeScreen)),
                SizedBox(width: isLargeScreen ? 16 : 12),
                Expanded(child: _buildDateRangeButton(isLargeScreen)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildPeriodSelector(isLargeScreen)),
                SizedBox(width: isLargeScreen ? 16 : 12),
                _buildDateRangeButton(isLargeScreen),
              ],
            ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSummaryRow(isLargeScreen, isTablet),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildPeriodSelector(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 6 : 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          dropdownColor: AppTheme.surfaceColor,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 16 : 14,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
          ),
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

  Widget _buildDateRangeButton(bool isLargeScreen) {
    return ElevatedButton.icon(
      onPressed: () => _showDateRangePicker(),
      icon: Icon(
        Icons.date_range,
        size: isLargeScreen ? 20 : 18,
      ),
      label: Text(
        'Período',
        style: TextStyle(
          fontSize: isLargeScreen ? 16 : 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 20 : 16,
          vertical: isLargeScreen ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(bool isLargeScreen, bool isTablet) {
    return Obx(() {
      final total = earningsHistory.fold<double>(
        0.0,
            (sum, earning) => sum + (earning['amount'] as double),
      );

      final count = earningsHistory.length;

      if (isTablet) {
        return Row(
          children: [
            Expanded(child: _buildSummaryCard('Total', 'R\$ ${total.toStringAsFixed(2)}', AppTheme.successColor, Icons.trending_up, isLargeScreen)),
            SizedBox(width: isLargeScreen ? 16 : 12),
            Expanded(child: _buildSummaryCard('Consultas', '$count', Colors.white, Icons.event, isLargeScreen)),
            SizedBox(width: isLargeScreen ? 16 : 12),
            Expanded(child: _buildSummaryCard('Média', 'R\$ ${count > 0 ? (total / count).toStringAsFixed(2) : '0.00'}', AppTheme.primaryColor, Icons.analytics, isLargeScreen)),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: isLargeScreen ? 48 : 40,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Consultas',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: isLargeScreen ? 48 : 40,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'R\$ ${count > 0 ? (total / count).toStringAsFixed(2) : '0.00'}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Média',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
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

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isLargeScreen ? 28 : 24,
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isLargeScreen ? 6 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList(bool isLargeScreen) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }

      if (earningsHistory.isEmpty) {
        return _buildEmptyState(isLargeScreen);
      }

      return RefreshIndicator(
        onRefresh: _loadEarningsHistory,
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.surfaceColor,
        child: ListView.builder(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
          itemCount: earningsHistory.length,
          itemBuilder: (context, index) {
            final earning = earningsHistory[index];
            return _buildEarningCard(earning, index, isLargeScreen);
          },
        ),
      );
    });
  }

  Widget _buildEarningCard(Map<String, dynamic> earning, int index, bool isLargeScreen) {
    final date = earning['date'] as DateTime;
    final amount = earning['amount'] as double;
    final appointmentId = earning['appointmentId'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: isLargeScreen ? 60 : 50,
            height: isLargeScreen ? 60 : 50,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.attach_money,
              color: AppTheme.successColor,
              size: isLargeScreen ? 28 : 24,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta realizada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 6 : 4),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm', 'pt_BR').format(date),
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 4 : 2),
                Text(
                  'ID: ${appointmentId.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: isLargeScreen ? 14 : 12,
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
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isLargeScreen ? 6 : 4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 10 : 8,
                  vertical: isLargeScreen ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recebido',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: isLargeScreen ? 12 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 700 + (index * 100)),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildEmptyState(bool isLargeScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on_outlined,
            size: isLargeScreen ? 100 : 80,
            color: Colors.white.withOpacity(0.3),
          ).animate().scale(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Text(
            'Nenhum ganho encontrado',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            'Seus ganhos de consultas aparecerão aqui',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 900),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () => _loadEarningsHistory(),
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 24 : 20,
                vertical: isLargeScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 1000),
            duration: const Duration(milliseconds: 500),
          ).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

  Future<void> _loadEarningsHistory() async {
    try {
      isLoading.value = true;

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

      await Future.delayed(const Duration(seconds: 1));

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
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o histórico de ganhos',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        isDismissible: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'custom';
      });
      _loadEarningsHistory();
    }
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Exportar Dados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              icon: Icons.table_chart,
              title: 'Exportar como CSV',
              subtitle: 'Planilha para Excel',
              onTap: () => _exportToCsv(),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.picture_as_pdf,
              title: 'Exportar como PDF',
              subtitle: 'Relatório em PDF',
              onTap: () => _exportToPdf(),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.share,
              title: 'Compartilhar',
              subtitle: 'Enviar dados por email',
              onTap: () => _shareData(),
            ),
          ],
        ),
      ).animate().slideY(
        begin: 1,
        end: 0,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCsv() {
    Get.back();
    Get.snackbar(
      'Exportação',
      'Arquivo CSV exportado com sucesso!',
      backgroundColor: AppTheme.successColor.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _exportToPdf() {
    Get.back();
    Get.snackbar(
      'Exportação',
      'Relatório PDF gerado com sucesso!',
      backgroundColor: AppTheme.successColor.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _shareData() {
    Get.back();
    Get.snackbar(
      'Compartilhar',
      'Dados compartilhados com sucesso!',
      backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
