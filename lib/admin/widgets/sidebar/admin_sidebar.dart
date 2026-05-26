import 'package:flutter/material.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import 'sidebar_item.dart';

/// The admin sidebar navigation panel with menu items and branding.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.pendingVerifications = 0,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final String currentRoute;
  final void Function(String route) onNavigate;
  final int pendingVerifications;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 72 : 260,
      decoration: const BoxDecoration(
        color: AdminTheme.sidebarBg,
        border: Border(
          right: BorderSide(color: AdminTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AdminTheme.primary, AdminTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PaDe Admin',
                          style: TextStyle(
                            color: AdminTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: AdminTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AdminTheme.border),
          ),
          const SizedBox(height: 8),

          // ─── Menu Items ─────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                _buildSectionLabel('UTAMA'),
                SidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: currentRoute == AdminRoutes.dashboard,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.dashboard),
                ),
                SidebarItem(
                  icon: Icons.verified_user_rounded,
                  label: 'Verifikasi Toko',
                  isSelected: currentRoute == AdminRoutes.verification,
                  isCollapsed: isCollapsed,
                  badge: pendingVerifications,
                  onTap: () => onNavigate(AdminRoutes.verification),
                ),
                const SizedBox(height: 8),
                _buildSectionLabel('MANAJEMEN'),
                SidebarItem(
                  icon: Icons.people_rounded,
                  label: 'Pengguna',
                  isSelected: currentRoute == AdminRoutes.users,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.users),
                ),
                SidebarItem(
                  icon: Icons.storefront_rounded,
                  label: 'Toko',
                  isSelected: currentRoute == AdminRoutes.sellers,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.sellers),
                ),
                SidebarItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Produk',
                  isSelected: currentRoute == AdminRoutes.products,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.products),
                ),
                SidebarItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Pesanan',
                  isSelected: currentRoute == AdminRoutes.orders,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.orders),
                ),
                const SizedBox(height: 8),
                _buildSectionLabel('KONFIGURASI'),
                SidebarItem(
                  icon: Icons.category_rounded,
                  label: 'Kategori',
                  isSelected: currentRoute == AdminRoutes.categories,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.categories),
                ),
                SidebarItem(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  isSelected: currentRoute == AdminRoutes.settings,
                  isCollapsed: isCollapsed,
                  onTap: () => onNavigate(AdminRoutes.settings),
                ),
              ],
            ),
          ),

          // ─── Collapse Toggle ────────────────────────────
          if (onToggleCollapse != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SidebarItem(
                icon: isCollapsed
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                label: 'Sembunyikan',
                isSelected: false,
                isCollapsed: isCollapsed,
                onTap: onToggleCollapse!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    if (isCollapsed) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AdminTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
