import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Color Palette
  static const Color primaryGreen = Color(0xFF2E6342);
  static const Color lightGreen = Color(0xFF4A7C59);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color accentYellow = Color(0xFFF3C623);
  static const Color backgroundCream = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  // 2. Admin Colors
  static const Color adminBlue = Color(0xFF1E3A8A);
  static const Color adminLightBlue = Color(0xFF3B82F6);

  // 3. Text Theme (using Google Fonts - Outfit for modern look)
  static TextTheme get textTheme {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: textDark),
      headlineLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
      titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.normal, color: textDark),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal, color: textDark),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }

  // 4. ThemeData Object
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentYellow,
        background: backgroundCream,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundCream,
      textTheme: textTheme,
      
      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: TextStyle(color: textMuted),
      ),
    );
  }
}
