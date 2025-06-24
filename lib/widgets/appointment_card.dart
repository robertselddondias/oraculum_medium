import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  final bool isMediumView;

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
    this.isMediumView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                        _getDisplayName(),
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
                const Icon(
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
                const Icon(
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
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      color: Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showActions && _shouldShowActions()) ...[
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (appointment.status) {
      case 'pending':
        badgeColor = AppTheme.warningColor;
        badgeText = 'Pendente';
        badgeIcon = Icons.schedule;
        break;
      case 'confirmed':
        badgeColor = AppTheme.primaryColor;
        badgeText = 'Confirmada';
        badgeIcon = Icons.check_circle;
        break;
      case 'completed':
        badgeColor = AppTheme.successColor;
        badgeText = 'Concluída';
        badgeIcon = Icons.done_all;
        break;
      case 'canceled':
        badgeColor = AppTheme.errorColor;
        badgeText = 'Cancelada';
        badgeIcon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Desconhecido';
        badgeIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            color: badgeColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowActions() {
    return appointment.status != 'completed' && appointment.status != 'canceled';
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    if (appointment.status == 'pending' && onConfirm != null) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Confirmar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    if ((appointment.status == 'pending' || appointment.status == 'confirmed') && onCancel != null) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
              side: const BorderSide(color: AppTheme.warningColor),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    if (appointment.status == 'confirmed' && onComplete != null) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.done, size: 16),
            label: const Text('Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    return Row(children: buttons);
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
    try {
      final formatter = DateFormat('dd/MM - HH:mm');
      return formatter.format(appointment.dateTime);
    } catch (e) {
      return '${appointment.dateTime.day.toString().padLeft(2, '0')}/${appointment.dateTime.month.toString().padLeft(2, '0')} - ${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getSpecialtyText() {
    return appointment.mediumSpecialty ?? 'Consulta espiritual';
  }

  String _getDisplayName() {
    if (isMediumView) {
      // Se é a visualização do médium, mostrar nome do cliente
      return appointment.userName ?? 'Cliente';
    } else {
      // Se é a visualização do cliente, mostrar nome do médium
      return appointment.mediumName ?? 'Médium';
    }
  }
}
