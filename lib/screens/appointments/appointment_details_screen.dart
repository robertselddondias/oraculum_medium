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
    appointmentId = Get.arguments as String?;
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
                _buildClientInfo(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
                _buildAppointmentInfo(appointment, isLargeScreen),
                SizedBox(height: isLargeScreen ? 24 : 20),
                _buildPaymentInfo(appointment, isLargeScreen),
                if (appointment.description.isNotEmpty) ...[
                  SizedBox(height: isLargeScreen ? 24 : 20),
                  _buildDescriptionSection(appointment, isLargeScreen),
                ],
                SizedBox(height: isLargeScreen ? 32 : 24),
                _buildActionButtons(appointment, isLargeScreen),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Consulta não encontrada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar os detalhes desta consulta.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(AppointmentModel appointment, bool isLargeScreen) {
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.1),
          ],
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
              _getStatusIcon(appointment.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da Consulta',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.statusText,
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildClientInfo(AppointmentModel appointment, bool isLargeScreen) {
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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cliente',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isLargeScreen ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          _buildInfoRow('Data', dateFormat.format(appointment.scheduledDate), isLargeScreen),
          _buildInfoRow('Horário', timeFormat.format(appointment.scheduledDate), isLargeScreen),
          _buildInfoRow('Duração', '${appointment.duration} minutos', isLargeScreen),
          _buildInfoRow('Tipo', appointment.consultationType, isLargeScreen),
          if (appointment.createdAt != null)
            _buildInfoRow('Agendado em', dateFormat.format(appointment.createdAt), isLargeScreen),
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
                    colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payment,
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
          _buildInfoRow('Valor', appointment.formattedAmount, isLargeScreen),
          _buildInfoRow('Método', appointment.paymentMethod ?? 'Créditos', isLargeScreen),
          _buildInfoRow('Status', appointment.paymentStatus ?? 'Processado', isLargeScreen),
          if (appointment.rating != null)
            _buildInfoRow('Avaliação', '${appointment.rating!.toStringAsFixed(1)} ⭐', isLargeScreen),
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

  Widget _buildDescriptionSection(AppointmentModel appointment, bool isLargeScreen) {
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
                    colors: [Color(0xFF2196F3), Color(0xFF03DAC6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Descrição da Consulta',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              appointment.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
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

  Widget _buildActionButtons(AppointmentModel appointment, bool isLargeScreen) {
    return Column(
      children: [
        if (appointment.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmAppointment(appointment),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Aceitar Consulta',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(appointment),
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text(
                'Recusar Consulta',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        if (appointment.isConfirmed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeAppointment(appointment),
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const Text(
                'Marcar como Concluída',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(appointment),
              icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
              label: const Text(
                'Cancelar Consulta',
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isLargeScreen ? 120 : 100,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  void _confirmAppointment(AppointmentModel appointment) async {
    final success = await _controller.confirmAppointment(appointment.id);
    if (success && appointmentId != null) {
      await _controller.loadAppointmentDetails(appointmentId!);
    }
  }

  void _completeAppointment(AppointmentModel appointment) async {
    final success = await _controller.completeAppointment(appointment.id);
    if (success && appointmentId != null) {
      await _controller.loadAppointmentDetails(appointmentId!);
    }
  }

  void _showRejectDialog(AppointmentModel appointment) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Recusar Consulta',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Text(
        'Tem certeza que deseja recusar a consulta com ${appointment.clientName}?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          Get.back();
          final success = await _controller.cancelAppointment(
            appointment.id,
            reason: reasonController.text.trim().isNotEmpty
                ? reasonController.text.trim()
                : 'Cancelado pelo médium',
          );
          if (success && appointmentId != null) {
            await _controller.loadAppointmentDetails(appointmentId!);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        child: const Text(
          'Cancelar Consulta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      ],
    ),
    );
  }
}withOpacity(0.8)),
),
const SizedBox(height: 16),
TextField(
controller: reasonController,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
labelText: 'Motivo (obrigatório)',
labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: const BorderSide(color: AppTheme.primaryColor),
),
),
maxLines: 3,
),
],
),
actions: [
TextButton(
onPressed: () => Get.back(),
child: Text(
'Voltar',
style: TextStyle(color: Colors.white.withOpacity(0.7)),
),
),
ElevatedButton(
onPressed: () async {
if (reasonController.text.trim().isEmpty) {
Get.snackbar('Erro', 'Por favor, informe o motivo da recusa');
return;
}

Get.back();
final success = await _controller.cancelAppointment(
appointment.id,
reason: reasonController.text.trim(),
);
if (success && appointmentId != null) {
await _controller.loadAppointmentDetails(appointmentId!);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
),
child: const Text(
'Recusar',
style: TextStyle(color: Colors.white),
),
),
],
),
);
}

void _showCancelDialog(AppointmentModel appointment) {
final reasonController = TextEditingController();

Get.dialog(
AlertDialog(
backgroundColor: const Color(0xFF1A1A2E),
title: const Text(
'Cancelar Consulta',
style: TextStyle(color: Colors.white),
),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'Tem certeza que deseja cancelar a consulta com ${appointment.clientName}?',
style: TextStyle(color: Colors.white.withOpacity(0.8)),
),
const SizedBox(height: 16),
TextField(
controller: reasonController,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
labelText: 'Motivo (opcional)',
labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
borderSide: const BorderSide(color: AppTheme.primaryColor),
),
),
maxLines: 3,
),
],
),
actions: [
TextButton(
onPressed: () => Get.back(),
child: Text(
'Voltar',
style: TextStyle(color: Colors.white.
