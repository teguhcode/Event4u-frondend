import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const electricBlue   = Color(0xFF2F6BFF);
  static const deepIndigo     = Color(0xFF1E2A78);
  static const festivalOrange = Color(0xFFFF7A00);
  static const neonPink       = Color(0xFFFF4FC3);

  static const pageBg  = Color(0xFFF8F9FC);
  static const cardBg  = Color(0xFFFFFFFF);

  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  static const successGreen      = Color(0xFF16A34A);
  static const successGreenLight = Color(0xFFDCFCE7);
  static const errorRed          = Color(0xFFE24B4A);

  static const midtransBlue = Color(0xFF0066FF);

  static const border      = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.electricBlue,
        primary: AppColors.electricBlue,
        secondary: AppColors.deepIndigo,
        surface: AppColors.cardBg,
        error: AppColors.errorRed,
      ),
      scaffoldBackgroundColor: AppColors.pageBg,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      // Flutter 3.x uses CardThemeData, not CardTheme
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: _bottomNavTheme,
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
      ),
    );
  }

  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.electricBlue,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.electricBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pageBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      );

  static BottomNavigationBarThemeData get _bottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400),
        elevation: 0,
      );
}
