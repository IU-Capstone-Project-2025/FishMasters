import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/pages/pages.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await Hive.openBox('settings');
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static var themeData = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFFEAEAEA),
      secondary: const Color(0xFF08D9D6),
      surface: const Color(0xFFEAEAEA),
      surfaceBright: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFF252A34),
      onSecondary: const Color(0xFF000000),
      onSurface: const Color(0xFF252A34),
      error: const Color(0xFFFF2E63),
      onError:const Color(0xFF252A34),
      tertiary: const Color(0x00FFFFFF)
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      // Display Styles
      displayLarge: GoogleFonts.singleDay(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),
      displayMedium: GoogleFonts.singleDay(
        fontSize: 55,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      displaySmall: GoogleFonts.singleDay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.comicNeue(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      headlineMedium: GoogleFonts.comicNeue(
        fontSize: 30, // 28
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      headlineSmall: GoogleFonts.singleDay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),

      // Title Styles
      titleLarge: GoogleFonts.singleDay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF08D9D6),
      ),
      titleSmall: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),

      // Label Styles
      labelLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),
      labelMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),
      labelSmall: GoogleFonts.comicNeue(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),

      // Body Styles
      bodyLarge: GoogleFonts.singleDay(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      bodyMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFFF2E63),
      ),
      bodySmall: GoogleFonts.singleDay(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
    ),
  scaffoldBackgroundColor: const Color(0xFFEAEAEA),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFEAEAEA),
    titleTextStyle: GoogleFonts.singleDay(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF252A34),
    ),
    elevation: 0,
  ),
  );

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
      theme: MainApp.themeData,
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
