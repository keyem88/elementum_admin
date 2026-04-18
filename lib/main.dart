import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_controller.dart';
import 'core/backend/supabase_service.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Default to DEV if run directly
  AppConfig.current = AppConfig.dev();
  await initializeAndRun();
}

Future<void> initializeAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!Get.isRegistered<SupabaseService>()) {
    await Get.putAsync(() => SupabaseService().init());
  }
  
  if (!Get.isRegistered<AuthController>()) {
    Get.put(AuthController());
  }

  runApp(const ElementumAdminApp());
}

class ElementumAdminApp extends StatelessWidget {
  const ElementumAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Elementum Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: Obx(() {
        if (AuthController.to.isAuthenticated.value) {
          return const AdminDashboardScreen();
        } else {
          return LoginScreen();
        }
      }),
    );
  }
}
