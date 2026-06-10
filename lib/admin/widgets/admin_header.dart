import 'package:flutter/material.dart';
import '../../domain/repositories/admin_repository.dart';
import '../theme/admin_theme.dart';
import 'admin_provider.dart';

/// Top header bar for the admin dashboard pages.
/// Shows notification badge with real pending verification count from database.
class AdminHeader extends StatefulWidget {
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
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final repo = AdminProvider.read(context);
      final requests = await repo.getVerificationRequests(status: 'pending');
      if (mounted) setState(() => _pendingCount = requests.length);
    } catch (_) {
      // Silently ignore — keep count at 0
    }
  }

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
                  widget.title,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      color: AdminTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.actions != null) ...widget.actions!,
          const SizedBox(width: 16),
          // Notification bell — real pending count
          IconButton(
            onPressed: () {},
            icon: Badge(
              isLabelVisible: _pendingCount > 0,
              label: Text('$_pendingCount'),
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
