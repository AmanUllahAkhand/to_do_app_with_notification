// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/presentation/controllers/theme_controller.dart';
import 'core/utils/notification_helper.dart';
import 'presentation/bindings/task_binding.dart';
import 'presentation/pages/home_page.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This line is CRUCIAL for iOS light/dark mode to work!
  await Get.putAsync<ThemeController>(() async {
    final controller = ThemeController();
    await controller.loadTheme(); // Load saved theme
    return controller;
  }, permanent: true);

  await NotificationHelper.initialize();
  TaskBinding().dependencies();

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
      themeMode: themeController.themeMode, // Use controller instead of ThemeMode.system
      home: HomePage(),
    );
  }
}