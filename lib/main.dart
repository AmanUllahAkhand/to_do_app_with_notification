// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/notification_helper.dart';
import 'presentation/bindings/task_binding.dart';
import 'presentation/pages/home_page.dart';
import 'core/themes/app_theme.dart';
import 'presentation/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationHelper.initialize();
  TaskBinding().dependencies();

  // Put ThemeController normally (NOT async!)
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode, // Uses observable
      home: HomePage(),
    );
  }
}