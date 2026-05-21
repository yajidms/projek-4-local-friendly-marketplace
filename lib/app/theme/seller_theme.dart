// File: lib/app/theme/seller_theme.dart
//
// Centralized design tokens for the PaDe Seller module.
// Palette: "Northern Lights" — hijau neon + deep dark teal
// NFR-ATR-03: All animation durations MUST be ≤ 300ms.
// NFR-OPR-01: All interactive elements MUST have touch targets ≥ 48×48 dp.
// NFR-UND-02: All labels in Indonesian.

import 'package:flutter/material.dart';

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

  /// Hitam kehijauan — background elemen gelap
  static const Color forestDark = Color(0xFF020F0D);

  // ─── Existing Green Palette (tetap dipertahankan) ─────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color onPrimary = Colors.white;

  // ─── Surface & Utility ────────────────────────────────────────────────────
  static const Color surfaceCard = Color(0xFFF8FBF8);
  static const Color dividerColor = Color(0xFFE8F5E9);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color syncPending = Color(0xFFFFA000);
  static const Color syncDone = Color(0xFF388E3C);
  static const Color syncFailed = Color(0xFFD32F2F);

  // ─── Accent Colors (untuk stat cards) ───────────────────────────────────
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentOrange = Color(0xFFE65100);
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color accentTeal = Color(0xFF00838F);

  // ─── Gradients ────────────────────────────────────────────────────────────
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

  // ─── Typography ────────────────────────────────────────────────────────────
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

  // ─── Sizing ──────────────────────────────────────────────────────────────
  static const double minTouchTarget = 48.0; // NFR-OPR-01
  static const double paddingPage = 16.0;
  static const double paddingCard = 16.0;
  static const double borderRadius = 14.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 20.0;

  // ─── Animation (NFR-ATR-03: ≤ 300ms) ────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // ─── Material 3 ThemeData ─────────────────────────────────────────────────
  static ThemeData get sellerThemeData => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          onPrimary: onPrimary,
          secondary: tealGreen,
          tertiary: neonGreen,
          surface: Colors.white,
          error: errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkTeal,
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
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
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
      );

  /// Returns the color representing a product's sync state.
  static Color syncStatusColor(bool isSynced, bool isLocalOnly) {
    if (isSynced) return syncDone;
    if (isLocalOnly) return syncPending;
    return syncFailed;
  }

  /// Human-readable sync label (NFR-UND-02).
  static String syncStatusLabel(bool isSynced, bool isLocalOnly) {
    if (isSynced) return 'Tersinkron';
    if (isLocalOnly) return 'Belum Sinkron';
    return 'Gagal Sinkron';
  }
}
