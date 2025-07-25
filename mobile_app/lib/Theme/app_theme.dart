import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static var lightTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFFEAEAEA),
      secondary: const Color(0xFF08D9D6),
      secondaryContainer: const Color.fromARGB(255, 50, 205, 192),
      surface: const Color(0xFFEAEAEA),
      surfaceBright: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFF252A34),
      onSecondary: const Color(0xFF000000),
      onSurface: const Color(0xFF252A34),
      error: const Color(0xFFFF2E63),
      onError: const Color(0xFF252A34),
      tertiary: const Color(0x00FFFFFF),
      tertiaryContainer: const Color(0xFF252A34),
      onPrimaryContainer: const Color(0xFF08D9D6),
      primaryContainer: const Color.fromARGB(255, 45, 159, 201),
      surfaceContainerHighest: Colors.grey.shade100,
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      // Display Styles
      displayLarge: GoogleFonts.pangolin(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),
      displayMedium: GoogleFonts.pangolin(
        fontSize: 55,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      displaySmall: GoogleFonts.pangolin(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.bellota(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      headlineMedium: GoogleFonts.bellota(
        fontSize: 30, // 28
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      headlineSmall: GoogleFonts.bellota(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF252A34),
      ),

      // Title Styles
      titleLarge: GoogleFonts.bellota(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),
      titleMedium: GoogleFonts.bellota(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF08D9D6),
      ),
      titleSmall: GoogleFonts.bellota(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),

      // Label Styles
      labelLarge: GoogleFonts.bellota(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),
      labelMedium: GoogleFonts.bellota(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),
      labelSmall: GoogleFonts.bellota(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF000000),
      ),

      // Body Styles
      bodyLarge: GoogleFonts.pangolin(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF252A34),
      ),
      bodyMedium: GoogleFonts.bellota(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFFF2E63),
      ),
      bodySmall: GoogleFonts.bellota(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF252A34),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFFEAEAEA),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFEAEAEA),
      titleTextStyle: GoogleFonts.pangolin(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF252A34),
      ),
      elevation: 0,
    ),
  );

  static var darkTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF1A1A1A),
      secondary: const Color(0xFF00C2BF),
      secondaryContainer: const Color(0xFFCD7F32),
      surface: const Color(0xFF252525),
      surfaceBright: const Color(0xFF2E2E2E),
      onPrimary: const Color(0xFFEAEAEA),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFFEAEAEA),
      error: const Color(0xFFFF2E63),
      onError: const Color(0xFFFFFFFF),
      tertiary: const Color(0x00FFFFFF),
      tertiaryContainer: const Color(0xFF252A34),
      onPrimaryContainer: const Color.fromARGB(255, 0, 151, 149),
      primaryContainer: const Color(0xFF227C9D),
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      // Display Styles
      displayLarge: GoogleFonts.pangolin(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),
      displayMedium: GoogleFonts.pangolin(
        fontSize: 55,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF1A1A1A),
      ),
      displaySmall: GoogleFonts.pangolin(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.bellota(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      headlineMedium: GoogleFonts.bellota(
        fontSize: 30, // 28
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      headlineSmall: GoogleFonts.bellota(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFEAEAEA),
      ),

      // Title Styles
      titleLarge: GoogleFonts.bellota(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),
      titleMedium: GoogleFonts.bellota(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF08D9D6),
      ),
      titleSmall: GoogleFonts.bellota(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),

      // Label Styles
      labelLarge: GoogleFonts.bellota(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      labelMedium: GoogleFonts.bellota(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      labelSmall: GoogleFonts.bellota(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),

      // Body Styles
      bodyLarge: GoogleFonts.pangolin(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      bodyMedium: GoogleFonts.bellota(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFFF2E63),
      ),
      bodySmall: GoogleFonts.bellota(
        fontSize: 16,

        fontWeight: FontWeight.bold,
        color: const Color(0xFFEAEAEA),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFFEAEAEA),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFEAEAEA),
      titleTextStyle: GoogleFonts.pangolin(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF252A34),
      ),
      elevation: 0,
    ),
  );
}
