import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  static const String _themeKey = 'isDarkMode';

  ThemeProvider() {
    // 🌟 Safer Initialization: Delay notification to next frame
    _init();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getBool(_themeKey);
    if (savedMode != null && savedMode != _isDarkMode) {
      _isDarkMode = savedMode;
      // 🌟 Use addPostFrameCallback to avoid rebuild errors during main app mount
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
