import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';

class MediumProfileScreen extends StatelessWidget {
  const MediumProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediumAdminController controller = Get.find<MediumAdminController>();
    final AuthController authController = Get.find<AuthController>();

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
              return _buildErrorState(controller);
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildProfileCard(medium, controller),
                    const SizedBox(height: 16),
                    _buildStatusCard(medium, controller),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildMenuOptions(authController),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const Expanded(
          child: Text(
            'Meu Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.profileEdit),
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileCard(medium, MediumAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
            backgroundImage: medium.imageUrl != null
                ? NetworkImage(medium.imageUrl!)
                : null,
            child: medium.imageUrl == null
                ? const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            medium.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            medium.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'R\$ ${medium.pricePerMinute.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const Text(
                      'por minuto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medium.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'avaliação',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${medium.totalAppointments}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'consultas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (medium.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              medium.bio,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Especialidades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medium.specialties.map<Widget>((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  specialty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(medium, MediumAdminController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Status da Conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: medium.isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medium.isActive ? 'Ativa' : 'Inativa',
                  style: TextStyle(
                    color: medium.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medium.isAvailable ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Disponível para consultas: ${medium.isAvailable ? 'Sim' : 'Não'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Switch(
                value: medium.isAvailable,
                onChanged: medium.isActive ? (_) => controller.toggleAvailabilityStatus() : null,
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.schedule,
            title: 'Agenda',
            subtitle: 'Gerenciar horários',
            onTap: () => Get.toNamed(AppRoutes.scheduleManagement),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.trending_up,
            title: 'Ganhos',
            subtitle: 'Ver relatórios',
            onTap: () => Get.toNamed(AppRoutes.earnings),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(AuthController authController) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Configurações',
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair',
            onTap: () => _showLogoutDialog(authController),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isDestructive
