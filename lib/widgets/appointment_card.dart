import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isMediumView;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final bool showActions;
  final bool isPending;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isMediumView = true,
    this.onTap,
    this.onConfirm,
    this.onCancel,
    this.onComplete,
    this.showActions = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final statusColor = _getStatusColor(appointment.status);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isSmallScreen, statusColor),
                const SizedBox(height: 16),
                _buildAppointmentInfo(isSmallScreen),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(isSmallScreen),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildHeader(bool isSmallScreen, Color statusColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: isSmallScreen ? 20 : 24,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
          child: Icon(
            Icons.person,
            size: isSmallScreen ? 20 : 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.clientName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                appointment.consultationType,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            appointment.statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentInfo(bool isSmallScreen) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      children: [
        Row(
          children: [
            _buildInfoChip(
              Icons.calendar_today,
              dateFormat.format(appointment.scheduledDate),
              isSmallScreen,
            ),
            const SizedBox(width: 12),
            _buildInfoChip(
              Icons.access_time,
              timeFormat.format(appointment.scheduledDate),
              isSmallScreen,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(
              Icons.timer,
              '${appointment.duration} min',
              isSmallScreen,
            ),
            const SizedBox(width: 12),
            _buildInfoChip(
              Icons.attach_money,
              appointment.formattedAmount,
              isSmallScreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isPending && appointment.isPending) {
      return Row(
        children: [
          if (onConfirm != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text(
                  'Aceitar',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (onConfirm != null && onCancel != null) const SizedBox(width: 12),
          if (onCancel != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                label: const Text(
                  'Recusar',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        if (appointment.isConfirmed && onComplete != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
              label: const Text(
                'Marcar como Concluída',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if ((appointment.isPending || appointment.isConfirmed) && onCancel != null) ...[
          if (appointment.isConfirmed && onComplete != null) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(
                appointment.isPending ? Icons.close : Icons.cancel_outlined,
                color: appointment.isPending ? Colors.red : Colors.orange,
                size: 18,
              ),
              label: Text(
                appointment.isPending ? 'Recusar' : 'Cancelar',
                style: TextStyle(
                  color: appointment.isPending ? Colors.red : Colors.orange,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: appointment.isPending ? Colors.red : Colors.orange,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
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
}
