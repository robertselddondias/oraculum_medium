import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediumAdminController controller = Get.find<MediumAdminController>();
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
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 800 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          _buildNotificationSettings(controller, isLargeScreen),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildAppointmentSettings(controller, isLargeScreen),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildAvailabilitySettings(controller, isLargeScreen),
                          SizedBox(height: isLargeScreen ? 20 : 16),
                          _buildAccountSettings(isLargeScreen),
                          SizedBox(height: isLargeScreen ? 32 : 24),
                          _buildSaveButton(controller, isLargeScreen),
                        ],
                      ),
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
              'Configurações',
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
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(MediumAdminController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryColor,
                size: isLargeScreen ? 28 : 24,
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Notificações',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSwitchTile(
            'Novos agendamentos',
            'Receba notificações sobre novos agendamentos',
            controller.getNotificationSetting('newAppointments'),
                (value) => controller.updateNotificationSetting('newAppointments', value),
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Lembretes de consulta',
            'Receba lembretes antes das consultas',
            controller.getNotificationSetting('appointmentReminders'),
                (value) => controller.updateNotificationSetting('appointmentReminders', value),
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Notificações de pagamento',
            'Receba notificações sobre pagamentos recebidos',
            controller.getNotificationSetting('paymentNotifications'),
                (value) => controller.updateNotificationSetting('paymentNotifications', value),
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Avaliações recebidas',
            'Receba notificações sobre novas avaliações',
            controller.getNotificationSetting('reviewNotifications'),
                (value) => controller.updateNotificationSetting('reviewNotifications', value),
            isLargeScreen,
          ),
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

  Widget _buildAppointmentSettings(MediumAdminController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                color: AppTheme.primaryColor,
                size: isLargeScreen ? 28 : 24,
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Consultas',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSwitchTile(
            'Aceitar automaticamente',
            'Aceitar agendamentos automaticamente',
            controller.autoAcceptAppointments,
                (value) => controller.updateAutoAcceptAppointments(value),
            isLargeScreen,
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSliderTile(
            'Intervalo entre consultas',
            'Tempo mínimo entre agendamentos (minutos)',
            controller.bufferTime.toDouble(),
            15.0,
            60.0,
            5.0,
                (value) => controller.updateBufferTime(value.round()),
            isLargeScreen,
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSliderTile(
            'Máximo de consultas por dia',
            'Limite diário de agendamentos',
            controller.maxDailyAppointments.toDouble(),
            1.0,
            20.0,
            1.0,
                (value) => controller.updateMaxDailyAppointments(value.round()),
            isLargeScreen,
          ),
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

  Widget _buildAvailabilitySettings(MediumAdminController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: AppTheme.primaryColor,
                size: isLargeScreen ? 28 : 24,
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Disponibilidade',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: 'Horários de trabalho',
            subtitle: 'Configurar dias e horários disponíveis',
            onTap: () => Get.toNamed(AppRoutes.availabilitySettings),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.access_time,
            title: 'Durações de consulta',
            subtitle: 'Configurar durações permitidas',
            onTap: () => _showDurationSettings(controller),
            isLargeScreen: isLargeScreen,
          ),
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

  Widget _buildAccountSettings(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: AppTheme.primaryColor,
                size: isLargeScreen ? 28 : 24,
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Conta',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Editar perfil',
            subtitle: 'Atualizar informações pessoais',
            onTap: () => Get.toNamed(AppRoutes.profileEdit),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Alterar senha',
            subtitle: 'Trocar senha da conta',
            onTap: () => _showChangePasswordDialog(),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacidade',
            subtitle: 'Configurações de privacidade',
            onTap: () => _showPrivacySettings(),
            isLargeScreen: isLargeScreen,
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 700),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildSwitchTile(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      bool isLargeScreen,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLargeScreen ? 12 : 8),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: isLargeScreen ? 16 : 14,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 6 : 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: isLargeScreen ? 14 : 12,
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
      bool isLargeScreen,
      ) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
          SizedBox(height: isLargeScreen ? 6 : 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white60,
              fontSize: isLargeScreen ? 14 : 12,
            ),
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
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
                width: isLargeScreen ? 60 : 50,
                alignment: Alignment.centerRight,
                child: Text(
                  '${value.round()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 16 : 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLargeScreen,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 8 : 4,
      ),
      leading: Icon(
        icon,
        color: Colors.white70,
        size: isLargeScreen ? 28 : 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: isLargeScreen ? 16 : 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white60,
          fontSize: isLargeScreen ? 14 : 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: isLargeScreen ? 18 : 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSaveButton(MediumAdminController controller, bool isLargeScreen) {
    return SizedBox(
      width: double.infinity,
      height: isLargeScreen ? 64 : 56,
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
              ? SizedBox(
            width: isLargeScreen ? 28 : 24,
            height: isLargeScreen ? 28 : 24,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            'Salvar Configurações',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _saveSettings(MediumAdminController controller) async {
    final success = await controller.updateSettings(controller.settings);

    if (success) {
      Get.snackbar(
        'Sucesso',
        'Configurações salvas com sucesso!',
        backgroundColor: AppTheme.successColor.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar as configurações',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void _showDurationSettings(MediumAdminController controller) {
    final durations = controller.getConsultationDurations();
    final selectedDurations = List<int>.from(durations);
    final availableDurations = [15, 30, 45, 60, 90, 120];

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
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecione as durações disponíveis para suas consultas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableDurations.map((duration) {
                      final isSelected = selectedDurations.contains(duration);
                      return FilterChip(
                        label: Text('${duration}min'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDurations.add(duration);
                            } else {
                              selectedDurations.remove(duration);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                        checkmarkColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white.withOpacity(0.3),
                        ),
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: 300 + (duration * 10)),
                        duration: const Duration(milliseconds: 300),
                      ).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 200),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ).animate().fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 300),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedDurations.isNotEmpty
                              ? () {
                            controller.updateConsultationDurations(selectedDurations);
                            Get.back();
                            Get.snackbar(
                              'Sucesso',
                              'Durações atualizadas com sucesso!',
                              backgroundColor: AppTheme.successColor.withOpacity(0.8),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Salvar'),
                        ).animate().fadeIn(
                          delay: const Duration(milliseconds: 500),
                          duration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 300),
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isLoading = false.obs;

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
              const Text(
                'Alterar Senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
              const SizedBox(height: 20),
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha atual',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => _changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                        confirmPasswordController.text,
                        isLoading,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Alterar'),
                    )).animate().fadeIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 300),
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      RxBool isLoading,
      ) async {
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erro',
        'Todos os campos são obrigatórios',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Erro',
        'A nova senha e a confirmação devem ser iguais',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Erro',
        'A nova senha deve ter pelo menos 6 caracteres',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simular chamada da API
      await Future.delayed(const Duration(seconds: 2));

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Senha alterada com sucesso!',
        backgroundColor: AppTheme.successColor.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível alterar a senha',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showPrivacySettings() {
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
              'Configurações de Privacidade',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
            const SizedBox(height: 24),
            _buildPrivacyOption(
              icon: Icons.visibility_outlined,
              title: 'Perfil Público',
              subtitle: 'Permitir que outros usuários vejam seu perfil',
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            _buildPrivacyOption(
              icon: Icons.location_on_outlined,
              title: 'Compartilhar Localização',
              subtitle: 'Mostrar sua localização aproximada',
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            _buildPrivacyOption(
              icon: Icons.analytics_outlined,
              title: 'Análise de Dados',
              subtitle: 'Permitir coleta de dados para melhorias',
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Salvar'),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 300),
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

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
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
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 300),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 200),
    );
  }
}
