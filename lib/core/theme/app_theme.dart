import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.voidBg,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electric,
        secondary: AppColors.electric,
        surface: AppColors.surface,
        background: AppColors.voidBg,
        onPrimary: AppColors.voidBg,
        onSurface: AppColors.titanium,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.titanium,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.titanium,
          letterSpacing: 0.05,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.titanium,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.gunmetal,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.electric,
          letterSpacing: 0.1,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.titanium),
      ),

      cardTheme: CardTheme(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electric,
          foregroundColor: AppColors.voidBg,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
