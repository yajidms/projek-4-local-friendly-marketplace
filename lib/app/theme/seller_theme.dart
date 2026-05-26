// File: lib/app/theme/seller_theme.dart
//
// Centralized design tokens untuk PaDe Seller module.
// Mendukung Light Mode dan Dark Mode (Northern Lights).
// NFR-ATR-03: Semua durasi animasi ≤ 300ms.
// NFR-OPR-01: Semua elemen interaktif ≥ 48×48 dp.
// NFR-UND-02: Semua label Bahasa Indonesia.

import 'package:flutter/material.dart';

/// Global notifier untuk mode tampilan Seller module.
/// true = Dark Mode (Northern Lights), false = Light Mode
final sellerIsDarkNotifier = ValueNotifier<bool>(true);

class SellerTheme {
  SellerTheme._();

  // ─── Northern Lights Palette ──────────────────────────────────────────────
  /// Hijau neon cerah — aksen utama, highlight, badge aktif
  static const Color neonGreen = Color(0xFF00D540);

  /// Gelap pekat — header gradient ujung gelap
  static const Color deepDark = Color(0xFF020B0B);

  /// Teal gelap — header gradient tengah
  static const Color darkTeal = Color(0xFF072623);

  /// Teal hijau — aksen sekunder, status tersinkron
  static const Color tealGreen = Color(0xFF01A56F);

  // ─── Green Palette ────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color onPrimary = Colors.white;

  /// Primary hijau dalam untuk Light mode (readable on white)
  static const Color lightPrimary = Color(0xFF1B6E35);

  // ─── Dark Mode Surfaces ───────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF0D1F1A);
  static const Color darkScaffold = Color(0xFF07100D);
  static const Color darkCard = Color(0xFF0F2018);
  static const Color darkInput = Color(0xFF0D1F1A);
  static const Color darkBorder = Color(0xFF1E3D30);

  // ─── Surface & Utility ────────────────────────────────────────────────────
  static const Color surfaceCard = Color(0xFFF8FBF8);
  static const Color dividerColor = Color(0xFFE8F5E9);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color syncPending = Color(0xFFFFA000);
  static const Color syncDone = Color(0xFF388E3C);
  static const Color syncFailed = Color(0xFFD32F2F);

  // ─── Accent Colors ────────────────────────────────────────────────────────
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentOrange = Color(0xFFE65100);
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color accentTeal = Color(0xFF00838F);

  // ─── Gradients ────────────────────────────────────────────────────────────
  /// Header utama — selalu dark (identitas merek PaDe)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [deepDark, darkTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientAlt = LinearGradient(
    colors: [darkTeal, Color(0xFF0D3B36)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonGreen, tealGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Typography ───────────────────────────────────────────────────────────
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF424242),
  );
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF616161),
  );
  static const TextStyle neonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: neonGreen,
  );

  // ─── Sizing ───────────────────────────────────────────────────────────────
  static const double minTouchTarget = 48.0;
  static const double paddingPage = 16.0;
  static const double paddingCard = 16.0;
  static const double borderRadius = 14.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 20.0;

  // ─── Animation ────────────────────────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // ─── Computed Theme (reads current notifier) ─────────────────────────────
  /// Dibaca oleh sub-views yang wrap dengan Theme(). Otomatis pilih
  /// dark/light berdasarkan sellerIsDarkNotifier.value saat ini.
  static ThemeData get sellerThemeData =>
      sellerIsDarkNotifier.value ? darkThemeData : lightThemeData;

  // ─── Dark Theme: Northern Lights ──────────────────────────────────────────
  static ThemeData get darkThemeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: neonGreen,
          onPrimary: deepDark,
          secondary: tealGreen,
          tertiary: neonGreen,
          surface: darkSurface,
          onSurface: Colors.white,
          error: errorRed,
          outline: darkBorder,
        ),
        scaffoldBackgroundColor: darkScaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: headingStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(minTouchTarget, minTouchTarget),
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkInput,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: neonGreen, width: 2),
          ),
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white30),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: darkCard,
        ),
        listTileTheme: const ListTileThemeData(
          minTileHeight: minTouchTarget,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        dividerColor: darkBorder,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? neonGreen : Colors.white,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? neonGreen.withValues(alpha: 0.4)
                : const Color(0xFF424242),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );

  // ─── Light Theme: Hijau Segar ─────────────────────────────────────────────
  static ThemeData get lightThemeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: lightPrimary,
          onPrimary: Colors.white,
          secondary: tealGreen,
          tertiary: neonGreen,
          surface: Colors.white,
          onSurface: Color(0xFF1A2E1A),
          error: errorRed,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F7F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: headingStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(minTouchTarget, minTouchTarget),
            backgroundColor: lightPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FDF9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            borderSide: const BorderSide(color: neonGreen, width: 2),
          ),
          labelStyle: labelStyle,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: Colors.white,
          shadowColor: Colors.black12,
        ),
        listTileTheme: const ListTileThemeData(
          minTileHeight: minTouchTarget,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        dividerColor: dividerColor,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? neonGreen : Colors.white,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? neonGreen.withValues(alpha: 0.4)
                : Colors.grey.shade300,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1A2E1A)),
          bodySmall: TextStyle(color: Color(0xFF4A6741)),
          titleMedium: TextStyle(
              color: Color(0xFF1A2E1A), fontWeight: FontWeight.w600),
        ),
      );

  /// Warna berdasarkan status sinkronisasi produk.
  static Color syncStatusColor(bool isSynced, bool isLocalOnly) {
    if (isSynced) return syncDone;
    if (isLocalOnly) return syncPending;
    return syncFailed;
  }

  /// Label sinkronisasi (NFR-UND-02 — Bahasa Indonesia).
  static String syncStatusLabel(bool isSynced, bool isLocalOnly) {
    if (isSynced) return 'Tersinkron';
    if (isLocalOnly) return 'Belum Sinkron';
    return 'Gagal Sinkron';
  }
}
