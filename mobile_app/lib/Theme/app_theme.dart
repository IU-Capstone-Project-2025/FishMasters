import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
   static var lightTheme = ThemeData(
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
      headlineSmall: GoogleFonts.comicNeue(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF252A34),
      ),

      // Title Styles
      titleLarge: GoogleFonts.singleDay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF252A34),
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 20,
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
      bodySmall: GoogleFonts.comicNeue(
        fontSize: 16,

        fontWeight: FontWeight.bold,
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

  static var darkTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF1A1A1A),
      secondary: const Color(0xFF00C2BF),
      surface: const Color(0xFF252525),
      surfaceBright: const Color(0xFF2E2E2E),
      onPrimary: const Color(0xFFEAEAEA),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFFEAEAEA),
      error: const Color(0xFFFF2E63),
      onError: const Color(0xFFFFFFFF),
      tertiary: const Color(0x00FFFFFF)
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      // Display Styles
      displayLarge: GoogleFonts.singleDay(
        fontSize: 64,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),
      displayMedium: GoogleFonts.singleDay(
        fontSize: 55,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF1A1A1A),
      ),
      displaySmall: GoogleFonts.singleDay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.comicNeue(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      headlineMedium: GoogleFonts.comicNeue(
        fontSize: 30, // 28
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      headlineSmall: GoogleFonts.comicNeue(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFEAEAEA),
      ),

      // Title Styles
      titleLarge: GoogleFonts.singleDay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),
      titleMedium: GoogleFonts.comicNeue(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF08D9D6),
      ),
      titleSmall: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEAEAEA),
      ),

      // Label Styles
      labelLarge: GoogleFonts.comicNeue(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      labelMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      labelSmall: GoogleFonts.comicNeue(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),

      // Body Styles
      bodyLarge: GoogleFonts.singleDay(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFEAEAEA),
      ),
      bodyMedium: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFFF2E63),
      ),
      bodySmall: GoogleFonts.comicNeue(
        fontSize: 16,

        fontWeight: FontWeight.bold,
        color: const Color(0xFFEAEAEA),
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
}