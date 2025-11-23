// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/bindings/task_binding.dart';
import 'presentation/pages/home_page.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();

  // Register the binding globally
  TaskBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}