import 'package:flutter/material.dart';
import 'package:mobile_app/pages/pages.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static var themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishMasters',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => PrimaryPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/menu': (context) => const MenuPage(),
        '/profile': (context) => const ProfilePage(),
        '/catch': (context) => const CatchPage(),
        '/discussion': (context) => const DiscussionPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
