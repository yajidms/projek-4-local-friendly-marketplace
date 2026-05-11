// File: lib/app/presentation/features/seller/widgets/seller_nav_drawer.dart
//
// NFR-OPR-01: Semua ListTile memiliki minTileHeight ≥ 48 dp.
// NFR-ATR-03: Animasi expand Katalog ≤ 300ms.
// NFR-UND-02: Semua label dalam Bahasa Indonesia.

import 'package:flutter/material.dart';

import '../../../../theme/seller_theme.dart';

/// Item navigasi yang tersedia di drawer.
enum SellerNavItem {
  beranda,
  penjualan,
  daftarProduk,
  tambahProduk,
  statistik,
  pengaturan,
}

extension SellerNavItemLabel on SellerNavItem {
  String get label {
    switch (this) {
      case SellerNavItem.beranda:
        return 'Beranda';
      case SellerNavItem.penjualan:
        return 'Penjualan';
      case SellerNavItem.daftarProduk:
        return 'Daftar Produk';
      case SellerNavItem.tambahProduk:
        return 'Tambah Produk';
      case SellerNavItem.statistik:
        return 'Statistik';
      case SellerNavItem.pengaturan:
        return 'Pengaturan';
    }
  }

  IconData get icon {
    switch (this) {
      case SellerNavItem.beranda:
        return Icons.home_rounded;
      case SellerNavItem.penjualan:
        return Icons.receipt_long_rounded;
      case SellerNavItem.daftarProduk:
        return Icons.list_alt_rounded;
      case SellerNavItem.tambahProduk:
        return Icons.add_box_rounded;
      case SellerNavItem.statistik:
        return Icons.bar_chart_rounded;
      case SellerNavItem.pengaturan:
        return Icons.settings_rounded;
    }
  }
}

/// Drawer navigasi samping untuk PaDe Seller Dashboard.
/// Berisi: Beranda, Penjualan, Katalog (Daftar & Tambah Produk), Statistik,
/// Pengaturan.
class SellerNavDrawer extends StatefulWidget {
  final SellerNavItem selectedItem;
  final ValueChanged<SellerNavItem> onItemSelected;
  final String shopName;

  const SellerNavDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    this.shopName = 'Toko Saya',
  });

  @override
  State<SellerNavDrawer> createState() => _SellerNavDrawerState();
}

class _SellerNavDrawerState extends State<SellerNavDrawer>
    with SingleTickerProviderStateMixin {
  bool _katalogExpanded = false;
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    // NFR-ATR-03: ≤ 300ms
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOut);

    if (widget.selectedItem == SellerNavItem.daftarProduk ||
        widget.selectedItem == SellerNavItem.tambahProduk) {
      _katalogExpanded = true;
      _expandCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleKatalog() {
    setState(() => _katalogExpanded = !_katalogExpanded);
    _katalogExpanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          _DrawerHeader(shopName: widget.shopName),

          // ── Nav Items ─────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavTile(
                  item: SellerNavItem.beranda,
                  selected: widget.selectedItem == SellerNavItem.beranda,
                  onTap: () => _select(SellerNavItem.beranda),
                ),
                _NavTile(
                  item: SellerNavItem.penjualan,
                  selected: widget.selectedItem == SellerNavItem.penjualan,
                  onTap: () => _select(SellerNavItem.penjualan),
                ),

                // ── Katalog (expandable) ──────────────────────────────────
                _KatalogSection(
                  expanded: _katalogExpanded,
                  expandAnim: _expandAnim,
                  selectedItem: widget.selectedItem,
                  onToggle: _toggleKatalog,
                  onSelect: _select,
                ),

                _NavTile(
                  item: SellerNavItem.statistik,
                  selected: widget.selectedItem == SellerNavItem.statistik,
                  onTap: () => _select(SellerNavItem.statistik),
                ),
                _NavTile(
                  item: SellerNavItem.pengaturan,
                  selected: widget.selectedItem == SellerNavItem.pengaturan,
                  onTap: () => _select(SellerNavItem.pengaturan),
                ),
              ],
            ),
          ),

          // ── Footer: Keluar ────────────────────────────────────────────────
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: SellerTheme.errorRed, size: 22),
            title: Text('Keluar',
                style: SellerTheme.labelStyle
                    .copyWith(color: SellerTheme.errorRed)),
            // TODO(auth): Implementasi logout yang sesungguhnya di branch Auth.
            // Saat ini hanya menutup drawer — belum membersihkan sesi/BLoC.
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _select(SellerNavItem item) {
    widget.onItemSelected(item);
    Navigator.of(context).pop();
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final String shopName;
  const _DrawerHeader({required this.shopName});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SellerTheme.primaryGreenDark, SellerTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              shopName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'PaDe Seller',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final SellerNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SellerTheme.animationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? SellerTheme.primaryGreen.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(SellerTheme.borderRadiusSmall),
      ),
      child: ListTile(
        contentPadding: padding,
        leading: Icon(item.icon,
            color: selected
                ? SellerTheme.primaryGreen
                : const Color(0xFF757575),
            size: 22),
        title: Text(
          item.label,
          style: SellerTheme.labelStyle.copyWith(
            color: selected
                ? SellerTheme.primaryGreen
                : const Color(0xFF424242),
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _KatalogSection extends StatelessWidget {
  final bool expanded;
  final Animation<double> expandAnim;
  final SellerNavItem selectedItem;
  final VoidCallback onToggle;
  final ValueChanged<SellerNavItem> onSelect;

  const _KatalogSection({
    required this.expanded,
    required this.expandAnim,
    required this.selectedItem,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: const Icon(Icons.inventory_2_rounded,
              color: Color(0xFF757575), size: 22),
          title: Text('Katalog', style: SellerTheme.labelStyle),
          trailing: AnimatedRotation(
            duration: SellerTheme.animationDuration,
            turns: expanded ? 0.5 : 0,
            child: const Icon(Icons.expand_more,
                color: Color(0xFFBDBDBD)),
          ),
          onTap: onToggle,
        ),
        SizeTransition(
          sizeFactor: expandAnim,
          child: Column(
            children: [
              _NavTile(
                item: SellerNavItem.daftarProduk,
                selected: selectedItem == SellerNavItem.daftarProduk,
                onTap: () => onSelect(SellerNavItem.daftarProduk),
                padding:
                    const EdgeInsets.only(left: 52, right: 16),
              ),
              _NavTile(
                item: SellerNavItem.tambahProduk,
                selected: selectedItem == SellerNavItem.tambahProduk,
                onTap: () => onSelect(SellerNavItem.tambahProduk),
                padding:
                    const EdgeInsets.only(left: 52, right: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
