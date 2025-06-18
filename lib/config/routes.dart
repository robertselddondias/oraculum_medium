import 'package:get/get.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/controllers/dashboard_controller.dart';
import 'package:oraculum_medium/controllers/medium_admin_controller.dart';
import 'package:oraculum_medium/controllers/appointment_admin_controller.dart';
import 'package:oraculum_medium/screens/auth/medium_login_screen.dart';
import 'package:oraculum_medium/screens/auth/medium_register_screen.dart';
import 'package:oraculum_medium/screens/auth/forgot_password_screen.dart';
import 'package:oraculum_medium/screens/dashboard/dashboard_screen.dart';
import 'package:oraculum_medium/screens/profile/medium_profile_screen.dart';
import 'package:oraculum_medium/screens/profile/profile_edit_screen.dart';
import 'package:oraculum_medium/screens/appointments/appointments_list_screen.dart';
import 'package:oraculum_medium/screens/appointments/appointment_details_screen.dart';
import 'package:oraculum_medium/screens/appointments/schedule_management_screen.dart';
import 'package:oraculum_medium/screens/earnings/earnings_screen.dart';
import 'package:oraculum_medium/screens/earnings/earnings_history_screen.dart';
import 'package:oraculum_medium/screens/settings/settings_screen.dart';
import 'package:oraculum_medium/screens/settings/availability_settings_screen.dart';
import 'package:oraculum_medium/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointment-details';
  static const String scheduleManagement = '/schedule-management';
  static const String earnings = '/earnings';
  static const String earningsHistory = '/earnings-history';
  static const String settings = '/settings';
  static const String availabilitySettings = '/availability-settings';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const MediumLoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const MediumRegisterScreen(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
        Get.lazyPut<AppointmentAdminController>(() => AppointmentAdminController());
      }),
    ),
    GetPage(
      name: profile,
      page: () => const MediumProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediumAdminController>(() => MediumAdminController());
      }),
    ),
    GetPage(
      name: profileEdit,
      page: () => const ProfileEditScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediumAdminController>(() => MediumAdminController());
      }),
    ),
    GetPage(
      name: appointments,
      page: () => const AppointmentsListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppointmentAdminController>(() => AppointmentAdminController());
      }),
    ),
    GetPage(
      name: appointmentDetails,
      page: () => const AppointmentDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppointmentAdminController>(() => AppointmentAdminController());
      }),
    ),
    GetPage(
      name: scheduleManagement,
      page: () => const ScheduleManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediumAdminController>(() => MediumAdminController());
      }),
    ),
    GetPage(
      name: earnings,
      page: () => const EarningsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: earningsHistory,
      page: () => const EarningsHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediumAdminController>(() => MediumAdminController());
      }),
    ),
    GetPage(
      name: availabilitySettings,
      page: () => const AvailabilitySettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediumAdminController>(() => MediumAdminController());
      }),
    ),
  ];
}
