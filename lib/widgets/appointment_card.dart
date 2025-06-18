import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final bool showActions;
  final bool isPending;
  final bool isUpcoming;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onConfirm,
    this.onCancel,
    this.onComplete,
    this.onTap,
    this.showActions = false,
    this.isPending = false,
    this.isUpcoming = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration.copyWith(
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.userName ?? 'Cliente',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSpecialtyText(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${appointment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white60,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  color: Colors.white60,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${appointment.durationMinutes} min',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (appointment.status) {
      case 'pending':
        backgroundColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningColor;
        text = 'Pendente';
        break;
      case 'confirmed':
        backgroundColor = AppTheme.primaryColor.withOpacity(0.2);
        textColor = AppTheme.primaryColor;
        text = 'Confirmado';
        break;
      case 'completed':
        backgroundColor = AppTheme.successColor.withOpacity(0.2);
        textColor = AppTheme.successColor;
        text = 'Concluído';
        break;
      case 'canceled':
        backgroundColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        text = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        text = 'Desconhecido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (appointment.status == 'completed' || appointment.status == 'canceled') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (appointment.status == 'pending') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Recusar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirmar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ] else if (appointment.status == 'confirmed') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningColor,
                side: const BorderSide(color: AppTheme.warningColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.done, size: 16),
              label: const Text('Finalizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    if (isPending) return AppTheme.warningColor.withOpacity(0.3);
    if (isUpcoming) return AppTheme.primaryColor.withOpacity(0.3);

    switch (appointment.status) {
      case 'pending':
        return AppTheme.warningColor.withOpacity(0.3);
      case 'confirmed':
        return AppTheme.primaryColor.withOpacity(0.3);
      case 'completed':
        return AppTheme.successColor.withOpacity(0.3);
      case 'canceled':
        return AppTheme.errorColor.withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.1);
    }
  }

  String _formatDateTime() {
    final formatter = DateFormat('dd/MM - HH:mm', 'pt_BR');
    return formatter.format(appointment.dateTime);
  }

  String _getSpecialtyText() {
    return appointment.mediumSpecialty ?? 'Consulta espiritual';
  }
}
