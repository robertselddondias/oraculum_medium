import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/appointment_admin_controller.dart';
import 'package:oraculum_medium/models/appointment_model.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final AppointmentAdminController _controller = Get.find<AppointmentAdminController>();
  String? appointmentId;

  @override
  void initState() {
    super.initState();
    appointmentId = Get.arguments?['appointmentId'];
    if (appointmentId != null) {
      _controller.loadAppointmentDetails(appointmentId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detalhes da Consulta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingDetails.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        final appointment = _controller.selectedAppointment.value;
        if (appointment == null) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (appointmentId != null) {
              await _controller.loadAppointmentDetails(appointmentId!);
            }
          },
          backgroundColor: Colors.white,
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
                _buildPatientInfo(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
                _buildAppointmentInfo(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
                _buildPaymentInfo(appointment, isLargeScreen),
                if (appointment.notes?.isNotEmpty == true) ...[
                  SizedBox(height: isLargeScreen ? 24 : 20),
                  _buildNotesSection(appointment, isLargeScreen),
                ],
                SizedBox(height: isLargeScreen ? 32 : 24),
                _buildActionButtons(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Consulta não encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar os detalhes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(AppointmentModel appointment, bool isLargeScreen) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (appointment.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendente';
        statusIcon = Icons.schedule;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'Confirmada';
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Finalizada';
        statusIcon = Icons.done_all;
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconhecido';
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: isLargeScreen ? 32 : 28,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da Consulta',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isLargeScreen ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  Widget _buildPatientInfo(AppointmentModel appointment, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8E78FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informações do Cliente',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildInfoRow('Nome', appointment.userName ?? 'Não informado', isLargeScreen),
          _buildInfoRow('Email', appointment.userEmail ?? 'Não informado', isLargeScreen),
          if (appointment.userPhone?.isNotEmpty == true)
            _buildInfoRow('Telefone', appointment.userPhone!, isLargeScreen),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildAppointmentInfo(AppointmentModel appointment, bool isLargeScreen) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dados da Consulta',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildInfoRow('Data', dateFormat.format(appointment.dateTime), isLargeScreen),
          _buildInfoRow('Horário', timeFormat.format(appointment.dateTime), isLargeScreen),
          _buildInfoRow('Duração', '${appointment.duration} minutos', isLargeScreen),
          if (appointment.type?.isNotEmpty == true)
            _buildInfoRow('Tipo', appointment.type!, isLargeScreen),
          if (appointment.mediumSpecialty?.isNotEmpty == true)
            _buildInfoRow('Especialidade', appointment.mediumSpecialty!, isLargeScreen),

        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildPaymentInfo(AppointmentModel appointment, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9D8A), Color(0xFFFFB74D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informações de Pagamento',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildInfoRow('Valor Total', 'R\$ ${appointment.amount.toStringAsFixed(2)}', isLargeScreen),
          _buildInfoRow('Status do Pagamento', appointment.paymentStatus ?? 'Não informado', isLargeScreen),
          if (appointment.paymentMethod?.isNotEmpty == true)
            _buildInfoRow('Método de Pagamento', appointment.paymentMethod!, isLargeScreen),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildNotesSection(AppointmentModel appointment, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.note,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Observações',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              appointment.notes!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isLargeScreen ? 16 : 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isLargeScreen ? 140 : 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppointmentModel appointment, bool isLargeScreen) {
    final canConfirm = appointment.status == 'pending';
    final canCancel = appointment.status == 'pending' || appointment.status == 'confirmed';
    final canComplete = appointment.status == 'confirmed';
    final canReschedule = appointment.status == 'confirmed';

    if (!canConfirm && !canCancel && !canComplete && !canReschedule) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          if (canConfirm) ...[
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 56 : 48,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAppointment(appointment.id),
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: isLargeScreen ? 16 : 12),
          ],
          if (canComplete) ...[
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 56 : 48,
              child: ElevatedButton.icon(
                onPressed: () => _completeAppointment(appointment.id),
                icon: const Icon(Icons.done_all),
                label: const Text('Finalizar Consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: isLargeScreen ? 16 : 12),
          ],
          if (canReschedule) ...[
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 56 : 48,
              child: OutlinedButton.icon(
                onPressed: () => _rescheduleAppointment(appointment),
                icon: const Icon(Icons.schedule),
                label: const Text('Reagendar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: isLargeScreen ? 16 : 12),
          ],
          if (canCancel) ...[
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 56 : 48,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(appointment.id),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _confirmAppointment(String appointmentId) async {
    final success = await _controller.confirmAppointment(appointmentId);
    if (success) {
      setState(() {});
    }
  }

  void _completeAppointment(String appointmentId) async {
    final success = await _controller.completeAppointment(appointmentId);
    if (success) {
      setState(() {});
    }
  }

  void _rescheduleAppointment(AppointmentModel appointment) {
    showDatePicker(
      context: context,
      initialDate: appointment.dateTime,
      firstDate: DateTime.now(),
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
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(appointment.dateTime),
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
        ).then((selectedTime) {
          if (selectedTime != null) {
            final newDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            _controller.rescheduleAppointment(appointment.id, newDateTime);
          }
        });
      }
    });
  }

  void _showCancelDialog(String appointmentId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
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
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja cancelar esta consulta?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _controller.cancelAppointment(appointmentId, 'Cancelado pelo médium');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Cancelar'),
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
