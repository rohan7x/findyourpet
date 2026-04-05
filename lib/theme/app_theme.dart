import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const teal = Color(0xFF00CFC1);
  static const purple = Color(0xFF8A5CF6);
  static const neonBlue = Color(0xFF00B0FF);
  static const cyan = Color(0xFF80F6FF);
  static const pink = Color(0xFFFF6EC7);
  static const orange = Color(0xFFFFA94D);
  static const deep = Color(0xFF100827); // for contrast (very dark purple)
  // gradient stops
  static const vibrantGradient = LinearGradient(
    colors: [teal, purple, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const cardGradient = LinearGradient(
    colors: [Color(0x66FFFFFF), Color(0x22FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: Brightness.light),
      primaryColor: AppColors.purple,
      scaffoldBackgroundColor: Colors.transparent, // we'll use gradient backgrounds in screens
      textTheme: GoogleFonts.rubikTextTheme(base.textTheme).copyWith(
        headlineSmall: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.rubik(fontSize: 16),
        bodyMedium: GoogleFonts.rubik(fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        ),
      ),
    );
  }
}
