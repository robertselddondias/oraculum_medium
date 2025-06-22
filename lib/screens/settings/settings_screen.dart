// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final SettingsController _settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    _settingsController.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;

              return Column(
                children: [
                  _buildAppBar(isLargeScreen),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                      child: Column(
                        children: [
                          _buildAccountSection(isLargeScreen),
                          const SizedBox(height: 24),
                          _buildNotificationsSection(isLargeScreen),
                          const SizedBox(height: 24),
                          _buildPreferencesSection(isLargeScreen),
                          const SizedBox(height: 24),
                          _buildAboutSection(isLargeScreen),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Configurações',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildAccountSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8E78FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: isLargeScreen ? 28 : 24,
                ),
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
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildNotificationsSection(bool isLargeScreen) {
    return Obx(() => Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: isLargeScreen ? 28 : 24,
                ),
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
            'Novas Consultas',
            'Receber notificações de novas consultas disponíveis',
            _settingsController.newConsultationsNotifications.value,
                (value) => _settingsController.newConsultationsNotifications.value = value,
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Lembretes',
            'Receber lembretes de consultas agendadas',
            _settingsController.appointmentReminders.value,
                (value) => _settingsController.appointmentReminders.value = value,
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Promoções',
            'Receber notificações sobre ofertas especiais',
            _settingsController.promotionalNotifications.value,
                (value) => _settingsController.promotionalNotifications.value = value,
            isLargeScreen,
          ),
          _buildSwitchTile(
            'Atualizações do Sistema',
            'Receber notificações sobre atualizações do app',
            _settingsController.systemUpdates.value,
                (value) => _settingsController.systemUpdates.value = value,
            isLargeScreen,
          ),
        ],
      ),
    )).animate().fadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildPreferencesSection(bool isLargeScreen) {
    return Obx(() => Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: isLargeScreen ? 28 : 24,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Preferências',
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
            'Modo Escuro',
            'Usar tema escuro na interface',
            _settingsController.isDarkMode.value,
                (value) => _settingsController.isDarkMode.value = value,
            isLargeScreen,
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: _settingsController.language.value == 'pt' ? 'Português' : 'English',
            onTap: () => _showLanguageSelector(),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.access_time,
            title: 'Fuso Horário',
            subtitle: _settingsController.timezone.value,
            onTap: () => _showTimezoneSelector(),
            isLargeScreen: isLargeScreen,
          ),
        ],
      ),
    )).animate().fadeIn(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildAboutSection(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: isLargeScreen ? 28 : 24,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Text(
                'Sobre',
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
            icon: Icons.help_outline,
            title: 'Central de Ajuda',
            subtitle: 'FAQ e suporte técnico',
            onTap: () => Get.toNamed(AppRoutes.support),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'Termos de Uso',
            subtitle: 'Termos e condições do serviço',
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Política de Privacidade',
            subtitle: 'Como protegemos seus dados',
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            isLargeScreen: isLargeScreen,
          ),
          const Divider(color: Colors.white24),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            subtitle: 'Versão 1.0.0',
            onTap: () => _showAboutDialog(),
            isLargeScreen: isLargeScreen,
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
        horizontal: 0,
      ),
      leading: Icon(
        icon,
        color: Colors.white70,
        size: isLargeScreen ? 24 : 22,
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
        color: Colors.white60,
        size: isLargeScreen ? 18 : 16,
      ),
      onTap: onTap,
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
              activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              inactiveThumbColor: Colors.white60,
              inactiveTrackColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Alterar Senha',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha Atual',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite sua senha atual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : () async {
              if (formKey.currentState!.validate()) {
                await _changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                  isLoading,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          )),
        ],
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword, RxBool isLoading) async {
    try {
      isLoading.value = true;

      await _authController.changePassword(currentPassword, newPassword);

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Senha alterada com sucesso',
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
            Obx(() => Column(
              children: [
                _buildPrivacyOption(
                  icon: Icons.visibility_outlined,
                  title: 'Perfil Público',
                  subtitle: 'Permitir que outros usuários vejam seu perfil',
                  value: _settingsController.showOnlineStatus.value,
                  onChanged: (value) => _settingsController.showOnlineStatus.value = value,
                ),
                const SizedBox(height: 16),
                _buildPrivacyOption(
                  icon: Icons.message_outlined,
                  title: 'Mensagens Diretas',
                  subtitle: 'Permitir que médiuns enviem mensagens',
                  value: _settingsController.allowDirectMessages.value,
                  onChanged: (value) => _settingsController.allowDirectMessages.value = value,
                ),
                const SizedBox(height: 16),
                _buildPrivacyOption(
                  icon: Icons.analytics_outlined,
                  title: 'Análise de Dados',
                  subtitle: 'Permitir coleta de dados para melhorias',
                  value: _settingsController.shareAnalytics.value,
                  onChanged: (value) => _settingsController.shareAnalytics.value = value,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _settingsController.saveSettings();
                    Get.back();
                  },
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
            )),
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
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            inactiveThumbColor: Colors.white60,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
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
              'Selecionar Idioma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Text('🇧🇷', style: TextStyle(fontSize: 24)),
              title: const Text(
                'Português',
                style: TextStyle(color: Colors.white),
              ),
              trailing: _settingsController.language.value == 'pt'
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                _settingsController.language.value = 'pt';
                _settingsController.saveSettings();
                Get.back();
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text(
                'English',
                style: TextStyle(color: Colors.white),
              ),
              trailing: _settingsController.language.value == 'en'
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                _settingsController.language.value = 'en';
                _settingsController.saveSettings();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneSelector() {
    final timezones = [
      'America/Sao_Paulo',
      'America/New_York',
      'Europe/London',
      'Europe/Paris',
      'Asia/Tokyo',
    ];

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
              'Selecionar Fuso Horário',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...timezones.map((timezone) => ListTile(
              title: Text(
                timezone,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _settingsController.timezone.value == timezone
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                _settingsController.timezone.value = timezone;
                _settingsController.saveSettings();
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sobre o Oraculum',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oraculum - Sua conexão com o mundo espiritual',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Versão: 1.0.0\nDesenvolvido com ❤️ para conectar você aos melhores médiuns e tarólogos.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Oraculum. Todos os direitos reservados.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
