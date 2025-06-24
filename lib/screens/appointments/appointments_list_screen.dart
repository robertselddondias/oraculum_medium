import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oraculum_medium/controllers/appointment_admin_controller.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/widgets/appointment_card.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final AppointmentAdminController _controller = Get.find<AppointmentAdminController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _searchController = TextEditingController();

  bool get isMedium => _authController.mediumId != null;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadAppointments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              _buildFilters(),
              Expanded(child: _buildAppointmentsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMedium ? 'Minhas Consultas' : 'Minhas Consultas',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Obx(() => Text(
                  '${_controller.filteredAppointments.length} consulta(s) encontrada(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                )),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _controller.refreshAppointments(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _controller.setSearchQuery,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: isMedium ? 'Buscar por cliente...' : 'Buscar por médium...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterChips()),
              const SizedBox(width: 16),
              _buildDateFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _controller.filterOptions.map((filter) {
          final isSelected = _controller.selectedFilter.value == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_controller.filterLabels[filter]!),
              selected: isSelected,
              onSelected: (selected) => _controller.setFilter(filter),
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.3),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildDateFilterButton() {
    return Obx(() => IconButton(
      onPressed: _showDateFilter,
      icon: Icon(
        _controller.selectedDate.value != null ? Icons.date_range : Icons.date_range_outlined,
        color: _controller.selectedDate.value != null ? AppTheme.primaryColor : Colors.white,
      ),
      tooltip: 'Filtrar por data',
    ));
  }

  Widget _buildAppointmentsList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        );
      }

      if (_controller.filteredAppointments.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _controller.refreshAppointments,
        backgroundColor: Colors.white,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _controller.filteredAppointments.length,
          itemBuilder: (context, index) {
            final appointment = _controller.filteredAppointments[index];
            return AppointmentCard(
              appointment: appointment,
              isMediumView: isMedium,
              onTap: () => Get.toNamed(
                AppRoutes.appointmentDetails,
                arguments: appointment.id,
              ),
              onConfirm: isMedium && appointment.status == 'pending'
                  ? () => _controller.confirmAppointment(appointment.id)
                  : null,
              onCancel: (appointment.status == 'pending' || appointment.status == 'confirmed')
                  ? () => _showCancelDialog(appointment.id)
                  : null,
              onComplete: isMedium && appointment.status == 'confirmed'
                  ? () => _controller.completeAppointment(appointment.id)
                  : null,
              showActions: appointment.status != 'completed' && appointment.status != 'canceled',
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma consulta encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMedium
                ? 'Suas consultas aparecerão aqui'
                : 'Suas consultas agendadas aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _controller.refreshAppointments(),
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

  void _showDateFilter() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        _controller.setDateFilter(selectedDate);
      }
    });
  }

  void _showCancelDialog(String appointmentId) {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancelar Consulta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tem certeza que deseja cancelar esta consulta?',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Motivo do cancelamento (opcional)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _controller.cancelAppointment(
                        appointmentId,
                        reasonController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Cancelar Consulta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
