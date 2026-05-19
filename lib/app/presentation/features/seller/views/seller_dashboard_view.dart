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
import '../../../../../domain/entities/index.dart';
import '../bloc/product_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/seller_nav_drawer.dart';
import 'inventory_view.dart';
import 'product_form_view.dart';
import 'product_list_view.dart';
import 'transaction_list_view.dart';

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
        shopName: 'PaDe Seller',
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
        return const TransactionListView(key: ValueKey('penjualan'));
      case SellerNavItem.inventaris:
        return const InventoryView(key: ValueKey('inventaris'));
      case SellerNavItem.daftarProduk:
        return const ProductListView(key: ValueKey('daftar'));
      case SellerNavItem.tambahProduk:
        return const _TambahProdukContent(key: ValueKey('tambah'));
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
          _GreetingBanner(),
          const SizedBox(height: 20),

          Text('Ringkasan Toko', style: SellerTheme.subHeadingStyle),
          const SizedBox(height: 12),

          // Kartu 1 — Total Produk
          BlocBuilder<ProductBloc, ProductState>(
            builder: (_, state) {
              final total = state is ProductTertampil ? state.products.length : 0;
              final belumSinkron = state is ProductTertampil ? state.jumlahBelumSinkron : 0;
              return DashboardStatCard(
                title: 'Total Produk',
                value: '$total',
                subtitle: belumSinkron > 0 ? '$belumSinkron belum sinkron' : 'Semua tersinkron ✓',
                icon: Icons.inventory_2_rounded,
                accentColor: SellerTheme.primaryGreen,
              );
            },
          ),
          const SizedBox(height: 12),

          // Kartu 2 — Penjualan Hari Ini (dari TransactionBloc)
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (_, state) {
              double salesToday = 0;
              int countToday = 0;
              if (state is TransaksiTertampil) {
                final today = DateTime.now();
                final todayOrders = state.semuaTransaksi.where((o) {
                  final sameDay = o.createdAt.year == today.year &&
                      o.createdAt.month == today.month &&
                      o.createdAt.day == today.day;
                  return sameDay && o.status == OrderStatus.delivered;
                });
                salesToday = todayOrders.fold(0.0, (sum, o) => sum + o.total);
                countToday = todayOrders.length;
              }
              return DashboardStatCard(
                title: 'Penjualan Hari Ini',
                value: salesToday > 0 ? _fmtRp(salesToday) : 'Rp 0',
                subtitle: '$countToday transaksi selesai',
                icon: Icons.shopping_bag_rounded,
                accentColor: const Color(0xFF1565C0),
              );
            },
          ),
          const SizedBox(height: 12),

          // Kartu 3 — Pesanan Menunggu (dari TransactionBloc)
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (_, state) {
              final pending = state is TransaksiTertampil ? state.jumlahMenunggu : 0;
              return DashboardStatCard(
                title: 'Pesanan Menunggu',
                value: '$pending',
                subtitle: pending > 0 ? 'Segera konfirmasi!' : 'Semua pesanan terproses ✓',
                icon: Icons.pending_actions_rounded,
                accentColor: const Color(0xFFE65100),
              );
            },
          ),
          const SizedBox(height: 12),

          // Kartu 4 — Rating Toko (placeholder)
          DashboardStatCard(
            title: 'Rating Toko',
            value: '—',
            subtitle: 'Belum ada ulasan',
            icon: Icons.star_rounded,
            accentColor: const Color(0xFFF57F17),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Aksi Cepat', style: SellerTheme.subHeadingStyle),
          const SizedBox(height: 12),
          _QuickActions(),
          const SizedBox(height: 20),

          _SyncInfoBanner(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static String _fmtRp(double v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    final s = v.toInt().toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
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
                const Text('PaDe Seller',
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

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionBtn(
          icon: Icons.add_box_rounded,
          label: 'Tambah\nProduk',
          color: SellerTheme.primaryGreen,
          onTap: () {
            final bloc = context.read<ProductBloc>();
            Navigator.of(context).push(PageRouteBuilder<void>(
              pageBuilder: (_, a, __) => BlocProvider.value(
                value: bloc,
                child: const ProductFormView(),
              ),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
                child: child,
              ),
              transitionDuration: SellerTheme.pageTransitionDuration,
            ));
          },
        ),
        const SizedBox(width: 10),
        _QuickActionBtn(
          icon: Icons.receipt_long_rounded,
          label: 'Lihat\nTransaksi',
          color: const Color(0xFF1565C0),
          onTap: () {
            // Navigate to penjualan tab — find _DashboardBodyState above
            final state = context.findAncestorStateOfType<_DashboardBodyState>();
            state?._onNavItemSelected(SellerNavItem.penjualan);
          },
        ),
        const SizedBox(width: 10),
        _QuickActionBtn(
          icon: Icons.warehouse_rounded,
          label: 'Inventaris',
          color: const Color(0xFF6A1B9A),
          onTap: () {
            final state = context.findAncestorStateOfType<_DashboardBodyState>();
            state?._onNavItemSelected(SellerNavItem.inventaris);
          },
        ),
        const SizedBox(width: 10),
        _QuickActionBtn(
          icon: Icons.list_alt_rounded,
          label: 'Katalog',
          color: const Color(0xFF00838F),
          onTap: () {
            final state = context.findAncestorStateOfType<_DashboardBodyState>();
            state?._onNavItemSelected(SellerNavItem.daftarProduk);
          },
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ]),
        ),
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

/// Halaman "Tambah Produk" dalam konteks dashboard — menampilkan
/// tombol yang membuka ProductFormView sebagai halaman baru.
class _TambahProdukContent extends StatelessWidget {
  const _TambahProdukContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: SellerTheme.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_box_rounded,
                  size: 44, color: SellerTheme.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tambah Produk Baru',
              style: SellerTheme.subHeadingStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Isi informasi produk yang ingin Anda jual di katalog PaDe.',
              style: SellerTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  final bloc = context.read<ProductBloc>();
                  Navigator.of(context).push(PageRouteBuilder<void>(
                    pageBuilder: (_, a, __) => BlocProvider.value(
                      value: bloc,
                      child: const ProductFormView(),
                    ),
                    transitionsBuilder: (_, a, __, child) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: a, curve: Curves.easeInOut)),
                      child: child,
                    ),
                    transitionDuration: SellerTheme.pageTransitionDuration,
                  ));
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Mulai Tambah Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SellerTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

