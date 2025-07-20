import 'package:flutter/material.dart';
import 'package:mobile_app/Theme/app_theme.dart';
import 'package:mobile_app/Theme/theme_provider.dart';
import 'package:mobile_app/pages/pages.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await Hive.openBox('settings');
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  runApp(ChangeNotifierProvider.value(
      value: themeProvider,
      child: MainApp(),
      )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Locale? _selectLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final box = Hive.box('settings');
    final localeCode = box.get('locale', defaultValue: 'en');
    setState(() {
      _selectLocale = Locale(localeCode);
    });
  }

  void _changeLocale(Locale locale) async {
    final box = Hive.box('settings');
    await box.put('locale', locale.languageCode);
    setState(() {
      _selectLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (themeProvider.isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      locale: _selectLocale,
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Fish Masters',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
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
        '/settings': (context) => SettingsPage(onLocaleChange: _changeLocale),
        '/about': (context) => const AboutPage(),
        '/menu': (context) => const MenuPage(),
        '/catch': (context) => const CatchPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/discussion': (context) => const ChatPage(),
        '/fishing': (context) => const FishingPage(),
        '/developer': (context) => const DeveloperPage(),
      },
    );
  }
}
