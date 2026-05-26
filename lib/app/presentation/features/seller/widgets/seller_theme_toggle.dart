// File: lib/app/presentation/features/seller/widgets/seller_theme_toggle.dart
//
// Widget toggle Light/Dark mode untuk PaDe Seller.
// Tersedia dalam dua varian:
//   1. SellerThemeToggle  — full widget dengan label (untuk halaman Pengaturan).
//   2. SellerThemeModeButton — kompak untuk AppBar.

import 'package:flutter/material.dart';
import '../../../../theme/seller_theme.dart';

// ─── Full Toggle Widget (untuk Settings) ─────────────────────────────────────

/// Widget toggle mode tampilan bergaya pill — sesuai referensi desain.
/// Tampilkan di halaman Pengaturan untuk visibilitas maksimal.
class SellerThemeToggle extends StatelessWidget {
  const SellerThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: sellerIsDarkNotifier,
      builder: (_, isDark, __) {
        return GestureDetector(
          onTap: () => sellerIsDarkNotifier.value = !isDark,
          child: AnimatedContainer(
            duration: SellerTheme.animationDuration,
            curve: Curves.easeInOut,
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF0D1F1A), Color(0xFF07100D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFF4FBF4), Color(0xFFE8F5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
              border: Border.all(
                color: isDark
                    ? SellerTheme.neonGreen.withValues(alpha: 0.35)
                    : const Color(0xFF2E7D32).withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? SellerTheme.neonGreen.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Label kiri ────────────────────────────────────────────
                Row(
                  children: [
                    AnimatedSwitcher(
                      duration: SellerTheme.animationDuration,
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        key: ValueKey(isDark),
                        color: isDark
                            ? SellerTheme.neonGreen
                            : const Color(0xFF1B5E20),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDark ? 'MODE GELAP' : 'MODE TERANG',
                          style: TextStyle(
                            color: isDark
                                ? SellerTheme.neonGreen
                                : const Color(0xFF1B5E20),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDark
                              ? 'Tampilan gelap Northern Lights'
                              : 'Tampilan terang & segar',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : const Color(0xFF4A6741),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Pill toggle ───────────────────────────────────────────
                _PillToggle(isDark: isDark),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Compact AppBar Button ────────────────────────────────────────────────────

/// Tombol mode kompak untuk AppBar — ikon animasi sun/moon.
class SellerThemeModeButton extends StatelessWidget {
  const SellerThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: sellerIsDarkNotifier,
      builder: (_, isDark, __) => Tooltip(
        message: isDark ? 'Mode Terang' : 'Mode Gelap',
        child: GestureDetector(
          onTap: () => sellerIsDarkNotifier.value = !isDark,
          child: AnimatedContainer(
            duration: SellerTheme.animationDuration,
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 4, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? SellerTheme.neonGreen.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? SellerTheme.neonGreen.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: SellerTheme.animationDuration,
                switchInCurve: Curves.elasticOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  color: isDark ? SellerTheme.neonGreen : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pill Toggle Internal ─────────────────────────────────────────────────────

class _PillToggle extends StatelessWidget {
  final bool isDark;
  const _PillToggle({required this.isDark});

  static const _width = 68.0;
  static const _height = 32.0;
  static const _thumbSize = 24.0;
  static const _pad = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        children: [
          // Track
          AnimatedContainer(
            duration: SellerTheme.animationDuration,
            curve: Curves.easeInOut,
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_height / 2),
              color: isDark
                  ? SellerTheme.neonGreen.withValues(alpha: 0.25)
                  : Colors.grey.shade300,
            ),
          ),
          // Thumb — slides left (light) ↔ right (dark)
          AnimatedPositioned(
            duration: SellerTheme.animationDuration,
            curve: Curves.easeInOut,
            left: isDark ? _width - _thumbSize - _pad : _pad,
            top: _pad,
            child: AnimatedContainer(
              duration: SellerTheme.animationDuration,
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? SellerTheme.neonGreen : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? SellerTheme.neonGreen.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: isDark ? 10 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: SellerTheme.animationDuration,
                  child: Icon(
                    isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    key: ValueKey(isDark),
                    size: 13,
                    color:
                        isDark ? SellerTheme.darkTeal : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
