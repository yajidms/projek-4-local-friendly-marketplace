import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Top header bar for the admin dashboard pages.
class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: AdminTheme.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AdminTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
          const SizedBox(width: 16),
          // Notification bell
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('3'),
              backgroundColor: AdminTheme.danger,
              child: const Icon(Icons.notifications_outlined,
                  color: AdminTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          // Admin avatar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AdminTheme.bgSurface,
              borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
              border: Border.all(color: AdminTheme.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AdminTheme.primary,
                  child: Text('A',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 8),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
