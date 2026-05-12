import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens and theme configuration for the Admin Dashboard.
/// Uses a dark color scheme with PaDe green (#1B8C3D) as primary.
class AdminTheme {
  AdminTheme._();

  // ─── Brand Colors ─────────────────────────────────────────
  static const Color primary = Color(0xFF1B8C3D);
  static const Color primaryLight = Color(0xFF27AE60);
  static const Color primaryDark = Color(0xFF147030);

  // ─── Background Colors ────────────────────────────────────
  static const Color bgPrimary = Color(0xFF0B1117);
  static const Color bgSecondary = Color(0xFF111922);
  static const Color bgSurface = Color(0xFF1A2535);
  static const Color bgCard = Color(0xFF1E2D3D);
  static const Color bgHover = Color(0xFF243549);

  // ─── Text Colors ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color textMuted = Color(0xFF556677);

  // ─── Status Colors ────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ─── Accent ───────────────────────────────────────────────
  static const Color accent = Color(0xFFFFD700);

  // ─── Sidebar ──────────────────────────────────────────────
  static const Color sidebarBg = Color(0xFF0D1520);
  static const Color sidebarActive = Color(0xFF1B8C3D);
  static const Color sidebarHover = Color(0xFF162231);

  // ─── Border ───────────────────────────────────────────────
  static const Color border = Color(0xFF2A3A4A);
  static const Color borderLight = Color(0xFF1E2D3D);

  // ─── Radius ───────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // ─── ThemeData ────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: bgSurface,
      ),
      scaffoldBackgroundColor: bgPrimary,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: textTheme.bodySmall?.copyWith(color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bgSecondary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgSurface,
        selectedColor: primary.withValues(alpha: 0.2),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(bgSurface),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return bgHover;
          return Colors.transparent;
        }),
        headingTextStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
        dividerThickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
