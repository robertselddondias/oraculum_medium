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
                  isMedium ? 'Minhas Consultas' : 'Gerenciar Consultas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  '${_controller.filteredAppointments.length} consulta(s) encontrada(s)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                )),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _controller.loadAppointments(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildFilterChips()),
          _buildDateFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'Todas'},
      {'key': 'pending', 'label': 'Pendentes'},
      {'key': 'confirmed', 'label': 'Confirmadas'},
      {'key': 'completed', 'label': 'Concluídas'},
      {'key': 'cancelled', 'label': 'Canceladas'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: filters.map((filter) {
          final isSelected = _controller.selectedFilter.value == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) => _controller.setFilter(filter['key']!),
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
      )),
    );
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
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma consulta encontrada',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há consultas para os filtros selecionados.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _controller.clearFilters(),
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpar Filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Buscar Consulta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Nome do cliente ou ID',
                hintText: 'Digite para buscar...',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // _controller.(_searchController.text);
              Get.back();
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showDateFilter() {
    showDatePicker(
      context: context,
      initialDate: _controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    ).then((date) {
      if (date != null) {
        _controller.setDateFilter(date);
      }
    });
  }

  void _showCancelDialog(String appointmentId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancelar Consulta'),
        content: const Text('Deseja realmente cancelar esta consulta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.cancelAppointment(appointmentId, null);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }
}
