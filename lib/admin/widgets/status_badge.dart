import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// A colored status pill/badge widget.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  /// Factory constructors for common statuses
  factory StatusBadge.verified() => const StatusBadge(
        label: 'Terverifikasi',
        color: AdminTheme.success,
        icon: Icons.verified_rounded,
      );

  factory StatusBadge.pending() => const StatusBadge(
        label: 'Menunggu',
        color: AdminTheme.warning,
        icon: Icons.hourglass_top_rounded,
      );

  factory StatusBadge.rejected() => const StatusBadge(
        label: 'Ditolak',
        color: AdminTheme.danger,
        icon: Icons.cancel_rounded,
      );

  factory StatusBadge.active() => const StatusBadge(
        label: 'Aktif',
        color: AdminTheme.success,
      );

  factory StatusBadge.inactive() => const StatusBadge(
        label: 'Nonaktif',
        color: AdminTheme.textMuted,
      );

  factory StatusBadge.online() => const StatusBadge(
        label: 'Online',
        color: AdminTheme.success,
        icon: Icons.circle,
      );

  factory StatusBadge.offline() => const StatusBadge(
        label: 'Offline',
        color: AdminTheme.textMuted,
        icon: Icons.circle,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: icon == Icons.circle ? 8 : 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
