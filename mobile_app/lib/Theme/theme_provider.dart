import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    final themeIndex = settingsBox.get('theme index', defaultValue: ThemeMode.system.index);
    _themeMode = ThemeMode.values[themeIndex];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    await settingsBox.put('theme index', mode.index);
    notifyListeners();
  }
}