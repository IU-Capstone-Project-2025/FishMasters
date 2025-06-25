import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<bool> hasLoggedInBefore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasLoggedIn') ?? false;
}

Future<void> setLoggedIn(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  if (!isLoggedIn) {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    settingsBox.clear();
  }
  await prefs.setBool('hasLoggedIn', isLoggedIn);
}
