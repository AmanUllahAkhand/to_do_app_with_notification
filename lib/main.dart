// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/notification_helper.dart';
import 'core/services/auth_service.dart';           // ← NEW
import 'presentation/bindings/task_binding.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';         // ← NEW
import 'core/themes/app_theme.dart';
import 'presentation/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize notifications
  await NotificationHelper.initialize();

  // 2. Setup dependency injection
  TaskBinding().dependencies();

  // 3. Initialize theme controller
  Get.put(ThemeController());

  // 4. Check if user is already logged in
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,

      // Auto decide starting page
      home: isLoggedIn ? HomePage() : LoginPage(),

      // Optional: Named routes (recommended)
      getPages: [
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginPage()),
      ],

      // Optional: Default route
      initialRoute: isLoggedIn ? '/home' : '/login',
    );
  }
}