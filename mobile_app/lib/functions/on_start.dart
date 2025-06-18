import 'package:shared_preferences/shared_preferences.dart';

Future<bool> hasLoggedInBefore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasLoggedIn') ?? false;
}

Future<void> setLoggedIn(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasLoggedIn', isLoggedIn);
}
