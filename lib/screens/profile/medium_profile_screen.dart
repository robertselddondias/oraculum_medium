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
            backgroundImage: medium.imageUrl != null
                ? NetworkImage(medium.imageUrl!)
                : null,
            child: medium.imageUrl == null
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
            medium.name,
            style: TextStyle(
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            medium.email,
            style: TextStyle(
              fontSize: isLargeScreen ? 18 : 16,
              color: Colors.white60,
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 500),
          ),
          SizedBox(height: isLargeScreen ? 24 : 16),
          _buildStatsRow(medium, isLargeScreen, isTablet),
          if (medium.bio.isNotEmpty) ...[
            SizedBox(height: isLargeScreen ? 20 : 16),
            const Divider(color: Colors.white24),
            SizedBox(height: isLargeScreen ? 20 : 16),
            Text(
              medium.bio,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 1000),
              duration: const Duration(milliseconds: 500),
            ),
          ],
          SizedBox(height: isLargeScreen ? 20 : 16),
          const Divider(color: Colors.white24),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Especialidades',
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 1100),
              duration: const Duration(milliseconds: 500),
            ),
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Wrap(
            spacing: isLargeScreen ? 12 : 8,
            runSpacing: isLargeScreen ? 12 : 8,
            children: medium.specialties.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final specialty = entry.value;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 16 : 12,
                  vertical: isLargeScreen ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: 1200 + ((index ?? 0) * 100)),
                duration: const Duration(milliseconds: 500),
              ).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 300),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.1,
      end: 0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildStatsRow(medium, bool isLargeScreen, bool isTablet) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'R\$ ${medium.pricePerMinute.toStringAsFixed(2)}',
              'por minuto',
              AppTheme.successColor,
              Icons.attach_money,
              isLargeScreen,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: _buildStatCard(
              medium.rating.toStringAsFixed(1),
              'avaliação',
              Colors.amber,
              Icons.star,
              isLargeScreen,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: _buildStatCard(
              '${medium.totalAppointments}',
              'consultas',
              Colors.white,
              Icons.event,
              isLargeScreen,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                'R\$ ${medium.pricePerMinute.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
              Text(
                'por minuto',
                style: TextStyle(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
          ),
        ),
        Container(
          width: 1,
          height: isLargeScreen ? 48 : 40,
          color: Colors.white.withOpacity(0.2),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: isLargeScreen ? 24 : 20,
                  ),
                  SizedBox(width: isLargeScreen ? 6 : 4),
                  Text(
                    medium.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'avaliação',
                style: TextStyle(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 850),
            duration: const Duration(milliseconds: 500),
          ),
        ),
        Container(
          width: 1,
          height: isLargeScreen ? 48 : 40,
          color: Colors.white.withOpacity(0.2),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${medium.totalAppointments}',
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'consultas',
                style: TextStyle(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 900),
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isLargeScreen ? 32 : 28,
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isLargeScreen ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
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
                  color: medium.isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medium.isActive ? 'Ativa' : 'Inativa',
                  style: TextStyle(
                    color: medium.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Row(
            children: [
              Container(
                width: isLargeScreen ? 14 : 12,
                height: isLargeScreen ? 14 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medium.isAvailable ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(width: isLargeScreen ? 16 : 12),
              Expanded(
                child: Text(
                  'Disponível para consultas: ${medium.isAvailable ? 'Sim' : 'Não'}',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              Switch(
                value: medium.isAvailable,
                onChanged: medium.isActive
                    ? (_) => controller.toggleAvailabilityStatus()
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
            ],
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

  Widget _buildQuickActions(bool isLargeScreen, bool isTablet) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.schedule,
              title: 'Agenda',
              subtitle: 'Gerenciar horários',
              onTap: () => Get.toNamed(AppRoutes.scheduleManagement),
              isLargeScreen: isLargeScreen,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.trending_up,
              title: 'Ganhos',
              subtitle: 'Ver relatórios',
              onTap: () => Get.toNamed(AppRoutes.earnings),
              isLargeScreen: isLargeScreen,
            ),
          ),
          SizedBox(width: isLargeScreen ? 20 : 12),
          Expanded(
            child: _buildActionCard(
              icon: Icons.analytics,
              title: 'Relatórios',
              subtitle: 'Análises detalhadas',
              onTap: () => Get.toNamed(AppRoutes.analytics),
              isLargeScreen: isLargeScreen,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.schedule,
            title: 'Agenda',
            subtitle: 'Gerenciar horários',
            onTap: () => Get.toNamed(AppRoutes.scheduleManagement),
            isLargeScreen: isLargeScreen,
          ),
        ),
        SizedBox(width: isLargeScreen ? 16 : 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.trending_up,
            title: 'Ganhos',
            subtitle: 'Ver relatórios',
            onTap: () => Get.toNamed(AppRoutes.earnings),
            isLargeScreen: isLargeScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLargeScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        decoration: AppTheme.cardDecoration.copyWith(
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isLargeScreen ? 40 : 32,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isLargeScreen ? 6 : 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 12,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            onTap: () => _showSupportOptions(),
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
            isDestructive: true,
            isLargeScreen: isLargeScreen,
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 900),
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
    bool isDestructive = false,
    required bool isLargeScreen,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
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
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 500),
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: const Duration(milliseconds: 400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sair'),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 500),
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: const Duration(milliseconds: 400),
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

  void _showSupportOptions() {
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
              'Ajuda e Suporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text('Email', style: TextStyle(color: Colors.white)),
              subtitle: const Text('suporte@oraculum.app', style: TextStyle(color: Colors.white60)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
              title: const Text('Telefone', style: TextStyle(color: Colors.white)),
              subtitle: const Text('(11) 99999-9999', style: TextStyle(color: Colors.white60)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
              title: const Text('Chat ao Vivo', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Disponível 24/7', style: TextStyle(color: Colors.white60)),
              onTap: () => Get.back(),
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

  void _showAboutDialog() {
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
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sobre o Oraculum',
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
                'Conectando pessoas a médiuns especializados para orientação espiritual e autoconhecimento.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Versão 1.0.0',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 500),
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
                child: const Text('Fechar'),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
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
}
