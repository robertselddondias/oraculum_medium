import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen>
    with SingleTickerProviderStateMixin {
  final MediumAdminController _controller = Get.find<MediumAdminController>();
  late TabController _tabController;

  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final Map<String, String> _weekDayLabels = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestão de Agenda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Configure sua disponibilidade',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => _saveAvailability(),
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              tooltip: 'Salvar alterações',
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
              Colors.purpleAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        indicatorPadding: const EdgeInsets.all(2),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Horários'),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Bloqueios'),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildWeeklySchedule(),
        _buildBlockedDates(),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildScheduleInstructions(),
            const SizedBox(height: 24),
            ..._weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              return _buildDaySchedule(day, index);
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildScheduleInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.lightBlueAccent.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.lightBlueAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Configure seus horários de trabalho para cada dia da semana. Os clientes só poderão agendar consultas nos horários disponíveis.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDaySchedule(String day, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getDayIcon(day),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            _weekDayLabels[day]!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Obx(() {
            final isAvailable = _controller.getDayAvailability(day);
            return Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppTheme.successColor.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable
                            ? AppTheme.successColor.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isAvailable
                          ? '${_controller.getDayStartTime(day)} - ${_controller.getDayEndTime(day)}'
                          : 'Indisponível',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.pink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          trailing: Obx(() {
            final isAvailable = _controller.getDayAvailability(day);
            return Container(
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Switch(
                value: isAvailable,
                onChanged: (value) {
                  _controller.updateDayAvailability(day, {
                    'isAvailable': value,
                    'startTime': _controller.getDayStartTime(day),
                    'endTime': _controller.getDayEndTime(day),
                    'breaks': [],
                  });
                },
                activeColor: AppTheme.primaryColor,
                activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            );
          }),
          children: [
            Obx(() {
              final isAvailable = _controller.getDayAvailability(day);
              if (!isAvailable) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const                       Text(
                        'Este dia está marcado como indisponível',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeSelector(
                            'Início',
                            _controller.getDayStartTime(day),
                                (time) => _updateDayTime(day, 'startTime', time),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTimeSelector(
                            'Fim',
                            _controller.getDayEndTime(day),
                                (time) => _updateDayTime(day, 'endTime', time),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100)))
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildTimeSelector(String label, String currentTime, Function(String) onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              label == 'Início' ? Icons.play_arrow : Icons.stop,
              color: Colors.cyanAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showTimePicker(currentTime, onTimeChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Colors.cyanAccent,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedDates() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildBlockedDatesInstructions(),
          const SizedBox(height: 24),
          _buildAddBlockedDateButton(),
          const SizedBox(height: 24),
          _buildBlockedDatesList(),
        ],
      ),
    );
  }

  Widget _buildBlockedDatesInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.block,
              color: Colors.orangeAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Bloqueie datas específicas em que você não estará disponível para consultas (feriados, viagens, etc).',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAddBlockedDateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showDatePicker(),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Adicionar Data Bloqueada',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildBlockedDatesList() {
    return Obx(() {
      final blockedDates = _controller.getBlockedDates();

      if (blockedDates.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nenhuma data bloqueada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você está disponível em todos os dias',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: blockedDates.map((date) => _buildBlockedDateItem(date)).toList(),
      );
    });
  }

  Widget _buildBlockedDateItem(DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.pink.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.block,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getWeekdayName(date.weekday),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => _removeBlockedDate(date),
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
              tooltip: 'Remover bloqueio',
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares (mantendo a lógica original)
  IconData _getDayIcon(String day) {
    switch (day) {
      case 'monday': case 'tuesday': case 'wednesday': case 'thursday': case 'friday':
      return Icons.work_outline;
      case 'saturday': case 'sunday':
      return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
      'Sexta-feira', 'Sábado', 'Domingo'
    ];
    return weekdays[weekday - 1];
  }

  void _updateDayTime(String day, String timeType, String time) {
    final currentAvailability = {
      'isAvailable': _controller.getDayAvailability(day),
      'startTime': _controller.getDayStartTime(day),
      'endTime': _controller.getDayEndTime(day),
      'breaks': [],
    };
    currentAvailability[timeType] = time;
    _controller.updateDayAvailability(day, currentAvailability);
  }

  void _showTimePicker(String currentTime, Function(String) onTimeChanged) {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        onTimeChanged(formattedTime);
      }
    });
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        _controller.addBlockedDate(selectedDate);
      }
    });
  }

  void _removeBlockedDate(DateTime date) {
    _controller.removeBlockedDate(date);
  }

  void _saveAvailability() {
    _controller.saveAvailabilitySettings();
  }
}
