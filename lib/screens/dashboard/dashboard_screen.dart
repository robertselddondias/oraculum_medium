import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/widgets/appointment_card.dart';
import 'package:oraculum_medium/widgets/stats_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
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

            return RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(authController, controller),
                    const SizedBox(height: 24),
                    _buildStatusCard(controller),
                    const SizedBox(height: 24),
                    _buildQuickStats(controller),
                    const SizedBox(height: 24),
                    _buildTodaySection(controller),
                    const SizedBox(height: 24),
                    _buildPendingSection(controller),
                    const SizedBox(height: 24),
                    _buildUpcomingSection(controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.scheduleManagement),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.schedule, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(AuthController authController, DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.getGreeting(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final user = authController.currentUser.value;
                return Text(
                  user?.displayName ?? 'Médium',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/default_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(DashboardController controller) {
    return Container(
        padding: const EdgeInsets.all(20),
    decoration: AppTheme.cardDecoration,
    child: Row(
    children: [
    Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: controller.getStatusColor(),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: StatsCard(
    title: 'Ganhos',
    value: 'R\$ ${controller.totalTodayEarnings}',
    subtitle: 'hoje',
    icon: Icons.attach_money,
    color: AppTheme.successColor,
    ),
    ),
    ],
    );
  }

  Widget _buildTodaySection(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Consultas de Hoje',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.appointments),
              child: const Text(
                'Ver todas',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.todayAppointments.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma consulta agendada para hoje',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.todayAppointments
                .take(3)
                .map((appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppointmentCard(
                appointment: appointment,
                onConfirm: () => controller.confirmAppointment(appointment.id),
                onCancel: () => _showCancelDialog(controller, appointment.id),
                onComplete: () => controller.completeAppointment(appointment.id),
                showActions: true,
              ),
            ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPendingSection(DashboardController controller) {
    return Obx(() {
      if (controller.pendingAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aguardando Confirmação',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.pendingAppointments
              .take(2)
              .map((appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentCard(
              appointment: appointment,
              onConfirm: () => controller.confirmAppointment(appointment.id),
              onCancel: () => _showCancelDialog(controller, appointment.id),
              showActions: true,
              isPending: true,
            ),
          ))
              .toList(),
        ],
      );
    });
  }

  Widget _buildUpcomingSection(DashboardController controller) {
    return Obx(() {
      if (controller.upcomingAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximas Consultas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.upcomingAppointments
              .take(3)
              .map((appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentCard(
              appointment: appointment,
              showActions: false,
              isUpcoming: true,
            ),
          ))
              .toList(),
        ],
      );
    });
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.white30,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Get.toNamed(AppRoutes.appointments);
              break;
            case 2:
              Get.toNamed(AppRoutes.earnings);
              break;
            case 3:
              Get.toNamed(AppRoutes.profile);
              break;
            case 4:
              Get.toNamed(AppRoutes.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Ganhos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(DashboardController controller, String appointmentId) {
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
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancelar Consulta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja cancelar esta consulta?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.cancelAppointment(appointmentId, 'Cancelado pelo médium');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Text(
'Status: ${controller.getStatusText()}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
color: Colors.white,
),
),
const Spacer(),
Switch(
value: controller.isOnline.value,
onChanged: (_) => controller.toggleOnlineStatus(),
activeColor: AppTheme.primaryColor,
),
],
),
);
}

Widget _buildQuickStats(DashboardController controller) {
return Row(
children: [
Expanded(
child: StatsCard(
title: 'Hoje',
value: '${controller.todayCount}',
subtitle: 'consultas',
icon: Icons.today,
color: AppTheme.primaryColor,
),
),
const SizedBox(width: 12),
Expanded(
child: StatsCard(
title: 'Pendentes',
value: '${controller.pendingCount}',
subtitle: 'aguardando',
icon: Icons.pending_actions,
color: AppTheme.warningColor,
),
),
const SizedBox(width: 12),
