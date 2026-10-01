import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/verifier_profile_screen.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'controller/session_controller.dart';
import 'controller/login_controller.dart';
import 'controller/dashboard_controller.dart';
import 'controller/candidates_controller.dart';
import 'controller/device_info_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('candidates_box');
  final pendingBox = await Hive.openBox('pending_sync_box');

  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);

  Get.put(ApiService(), permanent: true);

  final sync = SyncService();
  await sync.init(pendingBox);
  Get.put(sync, permanent: true);

  Get.put(SessionController(), permanent: true);
  Get.put(LoginController(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.put(CandidatesController(), permanent: true);
  Get.put(DeviceInfoController(), permanent: true);

  final bool loggedIn = StorageService.to.isLoggedIn();
  final bool profileDone =
      StorageService.to.getBool(StorageService.keyIsProfileCompleted) ?? false;

  Widget initialScreen;
  if (!loggedIn) {
    initialScreen = const LoginScreen();
  } else if (!profileDone) {
    initialScreen = const VerifierProfileScreen();
  } else {
    initialScreen = const DashboardScreen();
  }

  runApp(VerifySecureExamApp(initialScreen: initialScreen));
}

class VerifySecureExamApp extends StatelessWidget {
  final Widget initialScreen;
  const VerifySecureExamApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Secure Exam Verifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: initialScreen,
    );
  }
}
