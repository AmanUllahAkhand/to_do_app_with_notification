// lib/presentation/controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  late SharedPreferences prefs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isDarkMode');

    if (saved != null) {
      isDarkMode.value = saved;
    } else {
      // SAFE WAY: Use WidgetsBinding to get brightness AFTER app starts
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    prefs.setBool('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}