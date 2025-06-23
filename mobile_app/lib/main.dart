import 'package:flutter/material.dart';
import 'package:mobile_app/pages/pages.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static var themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Fish Masters',
      theme: themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: hasLoggedInBefore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == true) {
              return const PrimaryPage();
            } else {
              return const LoginPage();
            }
          },
        ),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const PrimaryPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        '/menu': (context) => const MenuPage(),
        '/catch': (context) => const CatchPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/discussion': (context) => const DiscussionPage(),
        '/fishing': (context) => const FishingPage(),
      },
    );
  }
}
