import 'package:flutter/material.dart';

class ThemeManager {
  // Global ValueNotifier for ThemeMode. Default is System or Light.
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool isDark() {
    return themeNotifier.value == ThemeMode.dark;
  }
}
