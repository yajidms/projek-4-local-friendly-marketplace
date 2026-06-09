// File: lib/app/presentation/features/seller/widgets/dashboard_stat_card.dart
//
// NFR-OPR-01: Touch target ≥ 48dp (minHeight constraint).
// NFR-ATR-03: Press animation ≤ 300ms.

import 'package:flutter/material.dart';

import '../../../../theme/seller_theme.dart';

/// Kartu statistik yang ditampilkan di dashboard penjual.
/// Background abu-abu muda sesuai Figma.
class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.accentColor = SellerTheme.primaryGreen,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // NFR-ATR-03: ≤ 300ms
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          // NFR-OPR-01: min height ≥ 48dp
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(SellerTheme.paddingCard),
          decoration: BoxDecoration(
            // Light grey background (Figma spec)
            color: SellerTheme.surfaceCard,
            borderRadius:
                BorderRadius.circular(SellerTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ikon dengan latar warna aksen
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                      SellerTheme.borderRadiusSmall),
                ),
                child: Icon(widget.icon,
                    color: widget.accentColor, size: 26),
              ),
              const SizedBox(width: 16),

              // Teks statistik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: SellerTheme.bodyStyle.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF757575)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(widget.subtitle,
                          style: SellerTheme.bodyStyle
                              .copyWith(fontSize: 12)),
                    ],
                  ],
                ),
              ),

              if (widget.onTap != null)
                const Icon(Icons.chevron_right,
                    color: Color(0xFFBDBDBD), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
