// File: lib/app/theme/seller_theme.dart
//
// Centralized design tokens for the PaDe Seller module.
// NFR-ATR-03: All animation durations MUST be ≤ 300ms.
// NFR-OPR-01: All interactive elements MUST have touch targets ≥ 48×48 dp.
// NFR-UND-02: All labels in Indonesian.

import 'package:flutter/material.dart';

class SellerTheme {
  SellerTheme._();

  // ─── Color Palette ────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color onPrimary = Colors.white;
  static const Color surfaceCard = Color(0xFFF5F5F5);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color syncPending = Color(0xFFFFA000);
  static const Color syncDone = Color(0xFF388E3C);
  static const Color syncFailed = Color(0xFFD32F2F);

  // ─── Typography (NFR-UND-02: min 14sp) ───────────────────────────────────
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

  // ─── Sizing ───────────────────────────────────────────────────────────────
  static const double minTouchTarget = 48.0; // NFR-OPR-01
  static const double paddingPage = 16.0;
  static const double paddingCard = 16.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;

  // ─── Animation (NFR-ATR-03: ≤ 300ms, 60fps target) ───────────────────────
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
          secondary: primaryGreenLight,
          surface: Colors.white,
          error: errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
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
          fillColor: Colors.white,
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
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          labelStyle: labelStyle,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(
          minTileHeight: minTouchTarget, // NFR-OPR-01
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
