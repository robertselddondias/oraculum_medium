import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oraculum_medium/config/routes.dart';
import 'package:oraculum_medium/config/theme.dart';
import 'package:oraculum_medium/controllers/auth_controller.dart';
import 'package:oraculum_medium/services/firebase_service.dart';
import 'package:oraculum_medium/services/medium_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(FirebaseService(), permanent: true);
  Get.put(MediumService(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const OraculumMediumApp());
}

class OraculumMediumApp extends StatelessWidget {
  const OraculumMediumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Oraculum Médium',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('pt', 'BR'),
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
