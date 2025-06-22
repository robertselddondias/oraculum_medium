import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MediumProfileScreen extends StatelessWidget {
  const MediumProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediumAdminController controller = Get.find<MediumAdminController>();
    final AuthController authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final isTablet = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            final medium = controller.mediumProfile.value;
            if (medium == null) {
              return _buildErrorState(controller, isLargeScreen);
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(isLargeScreen),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildProfileCard(medium, controller, isLargeScreen, isTablet),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      _buildStatusCard(medium, controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      _buildPerformanceCard(controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      _buildQuickActions(isLargeScreen, isTablet),
                      SizedBox(height: isLargeScreen ? 20 : 16),
                      _buildMenuOptions(authController, isLargeScreen),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Row(
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
            'Meu Perfil',
            style: TextStyle(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
          ).slideX(
            begin: -0.2,
            end: 0,
            duration: const Duration(milliseconds: 400),
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.profileEdit),
          icon: Icon(
            Icons.edit,
            color: Colors.white,
            size: isLargeScreen ? 28 : 24,
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  Widget _buildProfileCard(medium, MediumAdminController controller, bool isLargeScreen, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: isLargeScreen ? 60 : 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
            backgroundImage: medium.imageUrl != null && medium.imageUrl!.isNotEmpty
                ? NetworkImage(medium.imageUrl!)
                : null,
            child: medium.imageUrl == null || medium.imageUrl!.isEmpty
                ? Icon(
              Icons.person,
              size: isLargeScreen ? 60 : 50,
              color: Colors.white,
            )
                : null,
          ).animate().scale(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Text(
            medium.name ?? 'Nome não informado',
            style: TextStyle(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            medium.email ?? '',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 500),
          ),
          if (medium.specialties != null && medium.specialties!.isNotEmpty) ...[
            SizedBox(height: isLargeScreen ? 16 : 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: medium.specialties!.take(3).map<Widget>((specialty) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 12 : 8,
                    vertical: isLargeScreen ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    specialty.toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 800),
              duration: const Duration(milliseconds: 500),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildStatusCard(medium, MediumAdminController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Status da Conta',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 16 : 12,
                  vertical: isLargeScreen ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: (medium.isActive ?? true)
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (medium.isActive ?? true) ? 'Ativa' : 'Inativa',
                  style: TextStyle(
                    color: (medium.isActive ?? true) ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Obx(() => Row(
            children: [
              Container(
                width: isLargeScreen ? 14 : 12,
                height: isLargeScreen ? 14 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.isAvailable.value ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: Text(
                  'Disponível para consultas: ${controller.isAvailable.value ? 'Sim' : 'Não'}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              Obx(() => Switch(
                value: controller.isAvailable.value,
                onChanged: (medium.isActive ?? true)
                    ? (_) => controller.toggleAvailabilityStatus()
                    : null,
                activeColor: AppTheme.primaryColor,
              )),
            ],
          )),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Obx(() => Row(
            children: [
              Icon(
                Icons.circle,
                size: isLargeScreen ? 14 : 12,
                color: controller.getStatusColor(),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: Text(
                  'Status: ${controller.getStatusText()}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          )),
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

  Widget _buildPerformanceCard(MediumAdminController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Consultas',
                  controller.totalAppointments.value.toString(),
                  Icons.calendar_today,
                  isLargeScreen,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: _buildStatItem(
                  'Avaliação',
                  controller.averageRating.value.toStringAsFixed(1),
                  Icons.star,
                  isLargeScreen,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: _buildStatItem(
                  'Ganhos',
                  'R\$ ${controller.totalEarnings.value.toStringAsFixed(0)}',
                  Icons.attach_money,
                  isLargeScreen,
                ),
              ),
            ],
          )),
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

  Widget _buildStatItem(String label, String value, IconData icon, bool isLargeScreen) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: isLargeScreen ? 28 : 24,
        ),
        SizedBox(height: isLargeScreen ? 8 : 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isLargeScreen ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isLargeScreen ? 4 : 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isLargeScreen ? 14 : 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isLargeScreen, bool isTablet) {
    final actions = [
      {
        'icon': Icons.schedule,
        'title': 'Agenda',
        'subtitle': 'Gerenciar horários',
        'route': AppRoutes.scheduleManagement,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Ganhos',
        'subtitle': 'Ver relatórios',
        'route': AppRoutes.earnings,
      },
      if (isTablet)
        {
          'icon': Icons.analytics,
          'title': 'Relatórios',
          'subtitle': 'Análises detalhadas',
          'route': AppRoutes.analytics,
        },
    ];

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Row(
            children: actions.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final action = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < actions.length - 1 ? (isLargeScreen ? 16 : 12) : 0,
                  ),
                  child: _buildActionCard(
                    icon: action['icon'] as IconData,
                    title: action['title'] as String,
                    subtitle: action['subtitle'] as String,
                    onTap: () => Get.toNamed(action['route'] as String),
                    isLargeScreen: isLargeScreen,
                  ),
                ),
              );
            }).toList(),
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLargeScreen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: isLargeScreen ? 32 : 28,
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLargeScreen ? 4 : 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isLargeScreen ? 12 : 10,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(AuthController authController, bool isLargeScreen) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Configurações',
            onTap: () => Get.toNamed(AppRoutes.settings),
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuItem(
            icon: Icons.schedule,
            title: 'Disponibilidade',
            onTap: () => Get.toNamed(AppRoutes.availabilitySettings),
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            onTap: () => _showHelpDialog(),
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            onTap: () => _showAboutDialog(),
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair',
            onTap: () => _showLogoutDialog(authController),
            isLargeScreen: isLargeScreen,
            isDestructive: true,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isLargeScreen,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 24 : 20,
          vertical: isLargeScreen ? 20 : 16,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white12,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.white70,
              size: isLargeScreen ? 26 : 24,
            ),
            SizedBox(width: isLargeScreen ? 20 : 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  color: isDestructive ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: isLargeScreen ? 18 : 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MediumAdminController controller, bool isLargeScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isLargeScreen ? 80 : 64,
            color: Colors.white.withOpacity(0.5),
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          Text(
            'Erro ao carregar perfil',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 16 : 8),
          Text(
            'Não foi possível carregar as informações do perfil',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 24 : 20,
                vertical: isLargeScreen ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Ajuda e Suporte',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Para suporte técnico ou dúvidas sobre o uso do aplicativo, entre em contato conosco através do email: suporte@oraculum.com',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Fechar',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Sobre o Oraculum Médium',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Oraculum Médium v1.0.0\n\nAplicativo para profissionais místicos oferecerem seus serviços de consulta espiritual.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Fechar',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
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
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 32,
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja sair da sua conta?',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Sair'),
                    ),
                  ),
                ],
              ).animate().slideY(
                begin: 0.3,
                end: 0,
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
