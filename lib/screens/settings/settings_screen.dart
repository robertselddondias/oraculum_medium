import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediumAdminController controller = Get.find<MediumAdminController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildNotificationSettings(controller),
                        const SizedBox(height: 16),
                        _buildAppointmentSettings(controller),
                        const SizedBox(height: 16),
                        _buildAvailabilitySettings(controller),
                        const SizedBox(height: 16),
                        _buildAccountSettings(),
                        const SizedBox(height: 16),
                        _buildSaveButton(controller),
                      ],
                    ),
                  );
                }),
              ),
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
              'Configurações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(MediumAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Novos agendamentos',
            'Receba notificações sobre novos agendamentos',
            controller.getNotificationSetting('newAppointments'),
                (value) => controller.updateNotificationSetting('newAppointments', value),
          ),
          _buildSwitchTile(
            'Lembretes de consulta',
            'Receba lembretes antes das consultas',
            controller.getNotificationSetting('appointmentReminders'),
                (value) => controller.updateNotificationSetting('appointmentReminders', value),
          ),
          _buildSwitchTile(
            'Notificações de pagamento',
            'Receba notificações sobre pagamentos recebidos',
            controller.getNotificationSetting('paymentNotifications'),
                (value) => controller.updateNotificationSetting('paymentNotifications', value),
          ),
          _buildSwitchTile(
            'Avaliações recebidas',
            'Receba notificações sobre novas avaliações',
            controller.getNotificationSetting('reviewNotifications'),
                (value) => controller.updateNotificationSetting('reviewNotifications', value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSettings(MediumAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Aceitar automaticamente',
            'Aceitar agendamentos automaticamente',
            controller.autoAcceptAppointments,
                (value) => controller.updateAutoAcceptAppointments(value),
          ),
          const SizedBox(height: 16),
          _buildSliderTile(
            'Intervalo entre consultas',
            'Tempo mínimo entre agendamentos (minutos)',
            controller.bufferTime.toDouble(),
            15.0,
            60.0,
            5.0,
                (value) => controller.updateBufferTime(value.round()),
          ),
          const SizedBox(height: 16),
          _buildSliderTile(
            'Máximo de consultas por dia',
            'Limite diário de agendamentos',
            controller.maxDailyAppointments.toDouble(),
            1.0,
            20.0,
            1.0,
                (value) => controller.updateMaxDailyAppointments(value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySettings(MediumAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: 'Horários de trabalho',
            subtitle: 'Configurar dias e horários disponíveis',
            onTap: () => Get.toNamed(AppRoutes.availabilitySettings),
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.access_time,
            title: 'Durações de consulta',
            subtitle: 'Configurar durações permitidas',
            onTap: () => _showDurationSettings(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Editar perfil',
            subtitle: 'Atualizar informações pessoais',
            onTap: () => Get.toNamed(AppRoutes.profileEdit),
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Alterar senha',
            subtitle: 'Trocar senha da conta',
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacidade',
            subtitle: 'Configurações de privacidade',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
      String title,
      String subtitle,
      double value,
      double min,
      double max,
      double divisions,
      Function(double) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / divisions).round(),
                activeColor: AppTheme.primaryColor,
                inactiveColor: Colors.white24,
                onChanged: onChanged,
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                '${value.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSaveButton(MediumAdminController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() {
        return ElevatedButton(
          onPressed: controller.isSaving.value ? null : () => _saveSettings(controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isSaving.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Salvar Configurações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  void _saveSettings(MediumAdminController controller) async {
    final success = await controller.updateSettings(controller.settings);

    if (success) {
      Get.back();
    }
  }

  void _showDurationSettings(MediumAdminController controller) {
    final durations = controller.getConsultationDurations();
    final selectedDurations = List<int>.from(durations);

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
    child: StatefulBuilder(
    builder: (context, setState) {
    return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    const Text(
    'Durações de Consulta',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    const Text(
    'Selecione as durações disponíveis para suas consultas',
    style: TextStyle(
    color: Colors.white70,
    fontSize: 14,
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 20),
    Wrap(
    spacing: 8,
