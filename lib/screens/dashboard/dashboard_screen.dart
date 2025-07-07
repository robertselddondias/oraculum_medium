import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/widgets/appointment_card.dart';
import 'package:oraculum_medium/widgets/stats_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
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

            return RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 1200 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(authController, controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 24 : 20),
                      _buildWalletCard(controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildStatusCard(controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildQuickStats(controller, isLargeScreen, isTablet),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildTodaySection(controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildPendingSection(controller, isLargeScreen),
                      SizedBox(height: isLargeScreen ? 32 : 24),
                      _buildUpcomingSection(controller, isLargeScreen),
                      const SizedBox(height: 100),
                    ],
                  ),
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
      ).animate().scale(
        delay: const Duration(milliseconds: 800),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildHeader(AuthController authController, DashboardController controller, bool isLargeScreen) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.getGreeting(),
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 500),
              ).slideX(
                begin: -0.2,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final user = authController.currentUser.value;
                return Text(
                  user?.displayName ?? 'Médium',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                ).slideX(
                  begin: -0.2,
                  end: 0,
                  duration: const Duration(milliseconds: 400),
                );
              }),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Obx(() {
            final user = authController.currentUser.value;

            final currentMedium = authController.currentMedium.value;

            return Container(
              width: isLargeScreen ? 56 : 48,
              height: isLargeScreen ? 56 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
                image: currentMedium?.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(currentMedium!.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: AssetImage('assets/images/default_avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).animate().scale(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(DashboardController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C851),
            const Color(0xFF007E33),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C851).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: isLargeScreen ? 20 : 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Carteira Digital',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 12 : 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 16 : 14,
                      vertical: isLargeScreen ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(() => Text(
                      'R\$ ${controller.walletBalance.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 36 : 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    )),
                  ),
                  SizedBox(height: isLargeScreen ? 6 : 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Saldo disponível',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 12 : 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.earnings),
                child: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 16 : 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: isLargeScreen ? 28 : 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ver\nDetalhes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 10 : 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          _buildWalletStats(controller, isLargeScreen),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.earnings),
                  icon: Icon(
                    Icons.history,
                    size: isLargeScreen ? 18 : 16,
                  ),
                  label: Text(
                    'Ver Histórico',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF007E33),
                    elevation: 3,
                    padding: EdgeInsets.symmetric(
                      vertical: isLargeScreen ? 12 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isLargeScreen ? 12 : 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showWalletInfo(),
                  icon: Icon(
                    Icons.info_outline,
                    size: isLargeScreen ? 18 : 16,
                  ),
                  label: Text(
                    'Como Funciona',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(
                      vertical: isLargeScreen ? 12 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.2,
      end: 0,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildWalletStats(DashboardController controller, bool isLargeScreen) {
    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildWalletStatItem(
                'Este Mês',
                'R\$ ${stats.monthlyEarnings.toStringAsFixed(2)}',
                Icons.calendar_today,
                isLargeScreen,
              ),
            ),
            Container(
              width: 2,
              height: isLargeScreen ? 45 : 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Expanded(
              child: _buildWalletStatItem(
                'Total Ganho',
                'R\$ ${stats.totalEarnings.toStringAsFixed(2)}',
                Icons.trending_up,
                isLargeScreen,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWalletStatItem(String label, String value, IconData icon, bool isLargeScreen) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: isLargeScreen ? 22 : 20,
        ),
        SizedBox(height: isLargeScreen ? 8 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isLargeScreen ? 12 : 10,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(DashboardController controller, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: isLargeScreen ? 14 : 12,
            height: isLargeScreen ? 14 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.getStatusColor(),
            ),
          ).animate().scale(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 400),
          ),
          SizedBox(width: isLargeScreen ? 16 : 12),
          Expanded(
            child: Text(
              'Status: ${controller.getStatusText()}',
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: controller.isOnline.value,
            onChanged: (_) => controller.toggleOnlineStatus(),
            activeColor: AppTheme.primaryColor,
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

  Widget _buildQuickStats(DashboardController controller, bool isLargeScreen, bool isTablet) {
    final spacing = isLargeScreen ? 16.0 : 12.0;

    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: Obx(() => StatsCard(
              title: 'Hoje',
              value: '${controller.todayAppointments.length}',
              subtitle: 'consultas',
              icon: Icons.today,
              color: AppTheme.primaryColor,
            )).animate().fadeIn(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 500),
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Obx(() => StatsCard(
              title: 'Pendentes',
              value: '${controller.pendingAppointments.length}',
              subtitle: 'aguardando',
              icon: Icons.pending_actions,
              color: AppTheme.warningColor,
            )).animate().fadeIn(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 500),
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Obx(() => StatsCard(
              title: 'Mês',
              value: '${controller.stats.value?.monthlyAppointments ?? 0}',
              subtitle: 'consultas',
              icon: Icons.calendar_month,
              color: AppTheme.successColor,
            )).animate().fadeIn(
              delay: const Duration(milliseconds: 700),
              duration: const Duration(milliseconds: 500),
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Obx(() => StatsCard(
              title: 'Rating',
              value: '${controller.averageRating.value.toStringAsFixed(1)}',
              subtitle: 'estrelas',
              icon: Icons.star,
              color: AppTheme.accentColor,
            )).animate().fadeIn(
              delay: const Duration(milliseconds: 800),
              duration: const Duration(milliseconds: 500),
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() => StatsCard(
                title: 'Hoje',
                value: '${controller.todayAppointments.length}',
                subtitle: 'consultas',
                icon: Icons.today,
                color: AppTheme.primaryColor,
              )).animate().fadeIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Obx(() => StatsCard(
                title: 'Pendentes',
                value: '${controller.pendingAppointments.length}',
                subtitle: 'aguardando',
                icon: Icons.pending_actions,
                color: AppTheme.warningColor,
              )).animate().fadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: Obx(() => StatsCard(
                title: 'Mês',
                value: '${controller.stats.value?.monthlyAppointments ?? 0}',
                subtitle: 'consultas',
                icon: Icons.calendar_month,
                color: AppTheme.successColor,
              )).animate().fadeIn(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Obx(() => StatsCard(
                title: 'Rating',
                value: '${controller.averageRating.value.toStringAsFixed(1)}',
                subtitle: 'estrelas',
                icon: Icons.star,
                color: AppTheme.accentColor,
              )).animate().fadeIn(
                delay: const Duration(milliseconds: 800),
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
    );
  }

  Widget _buildTodaySection(DashboardController controller, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consultas de Hoje',
              style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 900),
              duration: const Duration(milliseconds: 500),
            ).slideX(
              begin: -0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.appointments),
              child: const Text(
                'Ver todas',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 1000),
              duration: const Duration(milliseconds: 500),
            ),
          ],
        ),
        SizedBox(height: isLargeScreen ? 16 : 12),
        Obx(() {
          if (controller.todayAppointments.isEmpty) {
            return Container(
              padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
              decoration: AppTheme.cardDecoration,
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: isLargeScreen ? 56 : 48,
                      color: Colors.white30,
                    ),
                    SizedBox(height: isLargeScreen ? 16 : 12),
                    Text(
                      'Nenhuma consulta agendada para hoje',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: isLargeScreen ? 18 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 1100),
              duration: const Duration(milliseconds: 500),
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 400),
            );
          }

          return Column(
            children: controller.todayAppointments
                .take(3)
                .toList()
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final appointment = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
                child: AppointmentCard(
                  appointment: appointment,
                  isMediumView: true,
                  onConfirm: appointment.status == 'pending' ? () => controller.acceptAppointment(appointment.id) : null,
                  onComplete: appointment.status == 'confirmed' ? () => controller.completeAppointment(appointment.id) : null,
                  onCancel: () => _showCancelDialog(controller, appointment.id),
                  showActions: true,
                  isPending: appointment.status == 'pending',
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 1100 + (index * 100)),
                  duration: const Duration(milliseconds: 500),
                ).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: const Duration(milliseconds: 400),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPendingSection(DashboardController controller, bool isLargeScreen) {
    return Obx(() {
      if (controller.pendingAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aguardando Confirmação',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 1400),
            duration: const Duration(milliseconds: 500),
          ).slideX(
            begin: -0.1,
            end: 0,
            duration: const Duration(milliseconds: 400),
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          ...controller.pendingAppointments
              .take(2)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final appointment = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
              child: AppointmentCard(
                appointment: appointment,
                isMediumView: true,
                onConfirm: () => controller.acceptAppointment(appointment.id),
                onCancel: () => _showCancelDialog(controller, appointment.id),
                showActions: true,
                isPending: true,
              ).animate().fadeIn(
                delay: Duration(milliseconds: 1500 + (index * 100)),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildUpcomingSection(DashboardController controller, bool isLargeScreen) {
    return Obx(() {
      if (controller.upcomingAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximas Consultas',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 1700),
            duration: const Duration(milliseconds: 500),
          ).slideX(
            begin: -0.1,
            end: 0,
            duration: const Duration(milliseconds: 400),
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          ...controller.upcomingAppointments
              .take(3)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final appointment = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
              child: AppointmentCard(
                isMediumView: true,
                appointment: appointment,
                showActions: false,
              ).animate().fadeIn(
                delay: Duration(milliseconds: 1800 + (index * 100)),
                duration: const Duration(milliseconds: 500),
              ).slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
            );
          }).toList(),
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

  void _showWalletInfo() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
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
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.successColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Como Funciona a Carteira',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '• A cada consulta finalizada, você recebe 80% do valor\n'
                    '• 20% fica como comissão para o Oraculum\n'
                    '• O valor é creditado automaticamente na sua carteira\n'
                    '• Você pode acompanhar todo o histórico de ganhos\n'
                    '• Saques disponíveis conforme política da plataforma',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              ).animate().scale(
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancelar Consulta',
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
                'Tem certeza que deseja cancelar esta consulta?',
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
                        'Voltar',
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
                        controller.cancelAppointment(appointmentId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancelar'),
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
}
