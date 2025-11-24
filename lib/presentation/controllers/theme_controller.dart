// lib/presentation/controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  late SharedPreferences prefs;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode');
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    } else {
      // Follow system theme on first launch
      isDarkMode.value = Get.mediaQuery.platformBrightness == Brightness.dark;
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    prefs.setBool('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }
}