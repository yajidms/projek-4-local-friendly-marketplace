// File: lib/app/presentation/features/seller/views/seller_dashboard_view.dart
//
// SRS Ch 3.5.2 — PaDe Seller Dashboard
// Header: Hijau dengan teks "PaDe Seller".
// Drawer: SellerNavDrawer dengan 5 item + sub-menu Katalog.
// Konten: 3 kartu placeholder (DashboardStatCard) dengan background abu-abu.
// NFR-OPR-01: Semua tombol/ikon ≥ 48×48 dp.
// NFR-ATR-03: Transisi konten ≤ 300ms.
// NFR-UND-02: Semua label Bahasa Indonesia.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/seller_theme.dart';
import '../bloc/product_bloc.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/seller_nav_drawer.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  /// NFR-ATR-03: Transisi fade ≤ 300ms.
  static Route<void> route() => PageRouteBuilder<void>(
        pageBuilder: (_, a, __) => const SellerDashboardView(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(
              parent: a, curve: SellerTheme.animationCurve),
          child: child,
        ),
        transitionDuration: SellerTheme.pageTransitionDuration,
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: const _DashboardBody(),
    );
  }
}

// ─── State: nav item yang dipilih ─────────────────────────────────────────────

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  SellerNavItem _activeItem = SellerNavItem.beranda;

  void _onNavItemSelected(SellerNavItem item) {
    setState(() => _activeItem = item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),

      // ── AppBar Hijau "PaDe Seller" ─────────────────────────────────────────
      appBar: AppBar(
        // "hamburger" icon — NFR-OPR-01: default IconButton sudah 48×48
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Buka menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('PaDe Seller'),
        actions: [
          // Tombol sinkronisasi — NFR-OPR-01: IconButton ≥ 48dp
          BlocBuilder<ProductBloc, ProductState>(
            builder: (ctx, state) {
              final isSyncing = state is ProductSedangSinkron;
              return IconButton(
                icon: isSyncing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync_rounded),
                tooltip: 'Sinkronkan data',
                // Sinkronkan produk penjual (gunakan ID dummy; ganti dengan
                // ID asli dari sesi autentikasi)
                onPressed: isSyncing
                    ? null
                    : () => ctx.read<ProductBloc>().add(
                          // TODO(auth): Ganti dengan ID dari sesi autentikasi
                          SinkronkanProduk(sellerId: 'mock-seller-001'),
                        ),
              );
            },
          ),
          // Notifikasi — placeholder
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifikasi',
            onPressed: () {},
          ),
        ],
      ),

      // ── Drawer Navigasi ────────────────────────────────────────────────────
      drawer: SellerNavDrawer(
        selectedItem: _activeItem,
        onItemSelected: _onNavItemSelected,
        // TODO(auth): Ganti dengan nama toko dari sesi autentikasi
        shopName: 'Warung Bu Sari',
      ),

      // ── Konten Utama ───────────────────────────────────────────────────────
      body: AnimatedSwitcher(
        // NFR-ATR-03: ≤ 300ms
        duration: SellerTheme.animationDuration,
        switchInCurve: SellerTheme.animationCurve,
        switchOutCurve: SellerTheme.animationCurve,
        child: _buildContent(_activeItem),
      ),
    );
  }

  Widget _buildContent(SellerNavItem item) {
    switch (item) {
      case SellerNavItem.beranda:
        return const _BerandaContent(key: ValueKey('beranda'));
      case SellerNavItem.penjualan:
        return _PlaceholderContent(
            key: const ValueKey('penjualan'),
            label: 'Penjualan',
            icon: Icons.receipt_long_rounded);
      case SellerNavItem.daftarProduk:
        return _PlaceholderContent(
            key: const ValueKey('daftar'),
            label: 'Daftar Produk',
            icon: Icons.list_alt_rounded);
      case SellerNavItem.tambahProduk:
        return _PlaceholderContent(
            key: const ValueKey('tambah'),
            label: 'Tambah Produk',
            icon: Icons.add_box_rounded);
      case SellerNavItem.statistik:
        return _PlaceholderContent(
            key: const ValueKey('statistik'),
            label: 'Statistik',
            icon: Icons.bar_chart_rounded);
      case SellerNavItem.pengaturan:
        return _PlaceholderContent(
            key: const ValueKey('pengaturan'),
            label: 'Pengaturan',
            icon: Icons.settings_rounded);
    }
  }
}

// ─── Konten Beranda (3 kartu placeholder) ─────────────────────────────────────

class _BerandaContent extends StatelessWidget {
  const _BerandaContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SellerTheme.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salam penjual
          _GreetingBanner(),
          const SizedBox(height: 20),

          // ── 3 Placeholder Kartu Dashboard (Figma spec: background abu-abu)
          Text('Ringkasan Toko',
              style: SellerTheme.subHeadingStyle),
          const SizedBox(height: 12),

          // Kartu 1 — Total Produk
          BlocBuilder<ProductBloc, ProductState>(
            builder: (_, state) {
              final total = state is ProductTertampil
                  ? state.products.length
                  : 0;
              final belumSinkron = state is ProductTertampil
                  ? state.jumlahBelumSinkron
                  : 0;
              return DashboardStatCard(
                title: 'Total Produk',
                value: '$total',
                subtitle: belumSinkron > 0
                    ? '$belumSinkron belum sinkron'
                    : 'Semua tersinkron ✓',
                icon: Icons.inventory_2_rounded,
                accentColor: SellerTheme.primaryGreen,
              );
            },
          ),
          const SizedBox(height: 12),

          // Kartu 2 — Penjualan Hari Ini (placeholder)
          DashboardStatCard(
            title: 'Penjualan Hari Ini',
            value: 'Rp 0',
            subtitle: '0 transaksi',
            icon: Icons.shopping_bag_rounded,
            accentColor: const Color(0xFF1565C0),
            onTap: () {},
          ),
          const SizedBox(height: 12),

          // Kartu 3 — Rating Toko (placeholder)
          DashboardStatCard(
            title: 'Rating Toko',
            value: '—',
            subtitle: 'Belum ada ulasan',
            icon: Icons.star_rounded,
            accentColor: const Color(0xFFF57F17),
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // ── Info sinkronisasi (NFR-UND-02) ──────────────────────────────
          _SyncInfoBanner(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Banner sambutan ──────────────────────────────────────────────────────────

class _GreetingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = TimeOfDay.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 19
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SellerTheme.primaryGreen,
            SellerTheme.primaryGreenLight,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13),
                ),
                // TODO(auth): Ganti dengan nama toko dari sesi autentikasi
                const Text('Warung Bu Sari',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner info sinkronisasi ─────────────────────────────────────────────────

class _SyncInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SellerTheme.syncPending.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(SellerTheme.borderRadiusSmall),
        border: Border.all(
            color: SellerTheme.syncPending.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: SellerTheme.syncPending, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // NFR-UND-02: Label Bahasa Indonesia
              'Data produk Tersimpan di HP. Sambungkan internet untuk sinkronisasi.',
              style: SellerTheme.bodyStyle
                  .copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Halaman Placeholder untuk menu lain ─────────────────────────────────────

class _PlaceholderContent extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderContent({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          Text(
            label,
            style: SellerTheme.subHeadingStyle
                .copyWith(color: const Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 8),
          Text(
            'Fitur ini akan segera hadir.',
            style:
                SellerTheme.bodyStyle.copyWith(color: const Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }
}
