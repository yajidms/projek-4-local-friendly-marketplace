// File: lib/app/presentation/features/seller/views/seller_dashboard_view.dart
//
// SRS Ch 3.5.2 — PaDe Seller Dashboard
// Design: Northern Lights palette — dark header + neon green accents
// NFR-OPR-01: Semua tombol/ikon ≥ 48×48 dp.
// NFR-ATR-03: Transisi konten ≤ 300ms.
// NFR-UND-02: Semua label Bahasa Indonesia.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/index.dart';
import '../bloc/product_bloc.dart';
import '../bloc/seller_cubit.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/seller_nav_drawer.dart';
import '../widgets/seller_theme_toggle.dart';
import 'inventory_view.dart';
import 'product_form_view.dart';
import 'product_list_view.dart';
import 'seller_settings_view.dart';
import 'transaction_list_view.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  static Route<void> route() => PageRouteBuilder<void>(
        pageBuilder: (_, a, __) => const SellerDashboardView(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity:
              CurvedAnimation(parent: a, curve: SellerTheme.animationCurve),
          child: child,
        ),
        transitionDuration: SellerTheme.pageTransitionDuration,
      );

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder memastikan seluruh dashboard rebuild
    // saat toggle light/dark ditekan.
    return ValueListenableBuilder<bool>(
      valueListenable: sellerIsDarkNotifier,
      builder: (_, isDark, __) => Theme(
        data: isDark ? SellerTheme.darkThemeData : SellerTheme.lightThemeData,
        child: const _DashboardBody(),
      ),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  SellerNavItem _activeItem = SellerNavItem.beranda;
  // Nama toko diambil dari SellerCubit; nilai ini sebagai fallback awal
  String _shopName = 'PaDe Seller';

  @override
  void initState() {
    super.initState();
    // Muat profil penjual dari API pada saat dashboard pertama dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerCubit>().muatProfil();
    });
  }

  void _onNavItemSelected(SellerNavItem item) {
    setState(() => _activeItem = item);
  }

  void _onShopNameChanged(String name) {
    if (name.trim().isNotEmpty) {
      setState(() => _shopName = name.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerCubit, SellerState>(
      listener: (context, state) {
        if (state is SellerTertampil) {
          // Perbarui nama toko dari data API
          setState(() => _shopName = state.seller.shopName);
          final sellerId = state.seller.id;
          // Trigger muat produk & transaksi dengan sellerId yang sebenarnya
          context.read<ProductBloc>().add(MuatProdukPenjual(sellerId: sellerId));
          context.read<TransactionBloc>().add(MuatTransaksiPenjual(sellerId: sellerId));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: SellerTheme.headerGradient),
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Buka menu',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SellerTheme.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: SellerTheme.neonGreen.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'PaDe',
                  style: TextStyle(
                      color: SellerTheme.neonGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Seller',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          actions: [
            // Tombol toggle light/dark mode
            const SellerThemeModeButton(),
            // Tombol sinkron — sellerId diambil dari SellerCubit
            BlocBuilder<SellerCubit, SellerState>(
              builder: (ctx, sellerState) {
                final sellerId = sellerState is SellerTertampil
                    ? sellerState.seller.id
                    : '';
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (ctx, state) {
                    final isSyncing = state is ProductSedangSinkron;
                    return IconButton(
                      icon: isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SellerTheme.neonGreen,
                              ),
                            )
                          : const Icon(Icons.sync_rounded, color: Colors.white),
                      tooltip: 'Sinkronkan data',
                      onPressed: (isSyncing || sellerId.isEmpty)
                          ? null
                          : () => ctx.read<ProductBloc>().add(
                                SinkronkanProduk(sellerId: sellerId),
                              ),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: SellerTheme.neonGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Notifikasi',
              onPressed: () {},
            ),
          ],
        ),
        drawer: SellerNavDrawer(
          selectedItem: _activeItem,
          onItemSelected: _onNavItemSelected,
          shopName: _shopName,
        ),
        body: BlocBuilder<SellerCubit, SellerState>(
          builder: (context, sellerState) {
            // Tampilkan loading saat pertama kali profil dimuat
            if (sellerState is SellerInitial || sellerState is SellerMemuat) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: SellerTheme.neonGreen),
                    SizedBox(height: 16),
                    Text('Memuat profil toko...',
                        style: TextStyle(color: Color(0xFF9E9E9E))),
                  ],
                ),
              );
            }
            if (sellerState is SellerGagal) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 56, color: SellerTheme.errorRed),
                    const SizedBox(height: 12),
                    Text(sellerState.pesan, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<SellerCubit>().muatProfil(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: SellerTheme.primaryGreen,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              );
            }
            return AnimatedSwitcher(
              duration: SellerTheme.animationDuration,
              switchInCurve: SellerTheme.animationCurve,
              switchOutCurve: SellerTheme.animationCurve,
              child: _buildContent(_activeItem),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(SellerNavItem item) {
    // Ambil seller dari cubit untuk diteruskan ke sub-view yang membutuhkan sellerId
    final sellerState = context.read<SellerCubit>().state;
    final seller = sellerState is SellerTertampil ? sellerState.seller : null;

    switch (item) {
      case SellerNavItem.beranda:
        return _BerandaContent(key: const ValueKey('beranda'), shopName: _shopName);
      case SellerNavItem.penjualan:
        return const TransactionListView(key: ValueKey('penjualan'));
      case SellerNavItem.inventaris:
        return const InventoryView(key: ValueKey('inventaris'));
      case SellerNavItem.daftarProduk:
        return const ProductListView(key: ValueKey('daftar'));
      case SellerNavItem.tambahProduk:
        return _TambahProdukContent(
            key: const ValueKey('tambah'), seller: seller);
      case SellerNavItem.statistik:
        return _PlaceholderContent(
            key: const ValueKey('statistik'),
            label: 'Statistik',
            icon: Icons.bar_chart_rounded);
      case SellerNavItem.pengaturan:
        return SellerSettingsView(
          key: const ValueKey('pengaturan'),
          initialShopName: _shopName,
          onShopNameChanged: _onShopNameChanged,
          seller: seller,
        );
    }
  }
}

// ─── Beranda Content ─────────────────────────────────────────────────────────

class _BerandaContent extends StatelessWidget {
  final String shopName;
  const _BerandaContent({super.key, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner ───────────────────────────────────────────────────
          _HeroBanner(shopName: shopName),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Ringkasan
                _SectionTitle(title: 'Ringkasan Toko', icon: Icons.insights_rounded),
                const SizedBox(height: 12),
                _StatGrid(),
                const SizedBox(height: 24),

                // Section: Aksi Cepat
                _SectionTitle(title: 'Aksi Cepat', icon: Icons.flash_on_rounded),
                const SizedBox(height: 12),
                _QuickActions(),
                const SizedBox(height: 24),

                // Section: Pesanan Terbaru
                _SectionTitle(title: 'Aktivitas Terkini', icon: Icons.history_rounded),
                const SizedBox(height: 12),
                _RecentActivity(),
                const SizedBox(height: 24),

                // Sync Info
                _SyncInfoBanner(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: SellerTheme.neonGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: SellerTheme.subHeadingStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String shopName;
  const _HeroBanner({required this.shopName});

  @override
  Widget build(BuildContext context) {
    final hour = TimeOfDay.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi ☀️'
        : hour < 15
            ? 'Selamat Siang 🌤️'
            : hour < 19
                ? 'Selamat Sore 🌅'
                : 'Selamat Malam 🌙';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: SellerTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SellerTheme.neonGreen.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SellerTheme.tealGreen.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(shopName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(height: 16),
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (_, state) {
                    final total =
                        state is ProductTertampil ? state.products.length : 0;
                    return Row(
                      children: [
                        _HeroBadge(
                          value: '$total',
                          label: 'Produk',
                          icon: Icons.inventory_2_rounded,
                        ),
                        const SizedBox(width: 12),
                        BlocBuilder<TransactionBloc, TransactionState>(
                          builder: (_, txState) {
                            final pending = txState is TransaksiTertampil
                                ? txState.jumlahMenunggu
                                : 0;
                            return _HeroBadge(
                              value: '$pending',
                              label: 'Menunggu',
                              icon: Icons.pending_actions_rounded,
                              highlight: pending > 0,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool highlight;

  const _HeroBadge({
    required this.value,
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? SellerTheme.neonGreen.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? SellerTheme.neonGreen.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color:
                  highlight ? SellerTheme.neonGreen : Colors.white70),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: highlight ? SellerTheme.neonGreen : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat Grid (2×2) ─────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (_, pState) {
        final totalProduk =
            pState is ProductTertampil ? pState.products.length : 0;
        final belumSinkron =
            pState is ProductTertampil ? pState.jumlahBelumSinkron : 0;
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (_, tState) {
            double salesToday = 0;
            int countToday = 0;
            int pending = 0;
            if (tState is TransaksiTertampil) {
              final today = DateTime.now();
              final todayOrders = tState.semuaTransaksi.where((o) {
                return o.createdAt.year == today.year &&
                    o.createdAt.month == today.month &&
                    o.createdAt.day == today.day &&
                    o.status == OrderStatus.delivered;
              });
              salesToday =
                  todayOrders.fold(0.0, (s, o) => s + o.total);
              countToday = todayOrders.length;
              pending = tState.jumlahMenunggu;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Produk',
                        value: '$totalProduk',
                        subtitle: belumSinkron > 0
                            ? '$belumSinkron belum sinkron'
                            : 'Semua tersinkron ✓',
                        icon: Icons.inventory_2_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF072623), Color(0xFF0D4A3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        accentColor: SellerTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Penjualan Hari Ini',
                        value: salesToday > 0 ? _fmtRp(salesToday) : 'Rp 0',
                        subtitle: '$countToday transaksi selesai',
                        icon: Icons.shopping_bag_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF283593)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        accentColor: const Color(0xFF82B1FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Pesanan Menunggu',
                        value: '$pending',
                        subtitle: pending > 0
                            ? 'Segera proses!'
                            : 'Semua terproses ✓',
                        icon: Icons.pending_actions_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A1000), Color(0xFF7B1F00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        accentColor: const Color(0xFFFF6E40),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Rating Toko',
                        value: '—',
                        subtitle: 'Belum ada ulasan',
                        icon: Icons.star_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3E1D00), Color(0xFF5D2E00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        accentColor: const Color(0xFFFFD740),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    final actions = [
      _QAction(
        icon: Icons.add_box_rounded,
        label: 'Tambah\nProduk',
        gradient: const LinearGradient(
            colors: [SellerTheme.darkTeal, Color(0xFF0D4A3A)]),
        accentColor: SellerTheme.neonGreen,
        onTap: () {
          final bloc = context.read<ProductBloc>();
          // Ambil sellerId dari SellerCubit agar produk baru terikat ke toko yang benar
          final sellerState = context.read<SellerCubit>().state;
          final sellerId = sellerState is SellerTertampil
              ? sellerState.seller.id
              : null;
          Navigator.of(context).push(PageRouteBuilder<void>(
            pageBuilder: (_, a, __) => BlocProvider.value(
              value: bloc,
              child: ProductFormView(sellerId: sellerId),
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
      _QAction(
        icon: Icons.receipt_long_rounded,
        label: 'Transaksi',
        gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)]),
        accentColor: const Color(0xFF82B1FF),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_DashboardBodyState>();
          state?._onNavItemSelected(SellerNavItem.penjualan);
        },
      ),
      _QAction(
        icon: Icons.warehouse_rounded,
        label: 'Inventaris',
        gradient: const LinearGradient(
            colors: [Color(0xFF3E1D00), Color(0xFF5D2E00)]),
        accentColor: const Color(0xFFFFD740),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_DashboardBodyState>();
          state?._onNavItemSelected(SellerNavItem.inventaris);
        },
      ),
      _QAction(
        icon: Icons.list_alt_rounded,
        label: 'Katalog',
        gradient: const LinearGradient(
            colors: [Color(0xFF4A0E4E), Color(0xFF6A1B9A)]),
        accentColor: const Color(0xFFCE93D8),
        onTap: () {
          final state =
              context.findAncestorStateOfType<_DashboardBodyState>();
          state?._onNavItemSelected(SellerNavItem.daftarProduk);
        },
      ),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: a == actions.last ? 0 : 10),
                  child: _QuickActionBtn(action: a),
                ),
              ))
          .toList(),
    );
  }
}

class _QAction {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Color accentColor;
  final VoidCallback onTap;
  const _QAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
  });
}

class _QuickActionBtn extends StatelessWidget {
  final _QAction action;
  const _QuickActionBtn({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: action.gradient,
          borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: action.accentColor, size: 26),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Activity ─────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (_, state) {
        if (state is! TransaksiTertampil || state.semuaTransaksi.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
              border: Border.all(
                  color: Theme.of(context).dividerColor),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    color: Color(0xFFBDBDBD), size: 28),
                SizedBox(width: 12),
                Text('Belum ada transaksi',
                    style: TextStyle(color: Color(0xFF9E9E9E))),
              ],
            ),
          );
        }

        final recent = state.semuaTransaksi.take(3).toList();
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
            border: Border.all(
                color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: recent.asMap().entries.map((e) {
              final order = e.value;
              final isLast = e.key == recent.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _statusColor(order.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_statusIcon(order.status),
                              color: _statusColor(order.status), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pembeli #${order.userId.substring(0, 6)}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                              Text(_statusLabel(order.status),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _statusColor(order.status))),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${_fmtK(order.total)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 68),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return SellerTheme.syncPending;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return SellerTheme.tealGreen;
      case OrderStatus.shipped:
        return SellerTheme.accentBlue;
      case OrderStatus.delivered:
        return SellerTheme.neonGreen;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return SellerTheme.errorRed;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.access_time_rounded;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.done_all_rounded;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Icons.cancel_outlined;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Menunggu konfirmasi';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dalam pengiriman';
      case OrderStatus.delivered:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Dikembalikan';
    }
  }

  String _fmtK(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toInt().toString();
  }
}

// ─── Sync Info Banner ─────────────────────────────────────────────────────────

class _SyncInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(SellerTheme.borderRadiusSmall),
        border: Border.all(
            color: SellerTheme.neonGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: SellerTheme.neonGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storage_rounded,
                color: cs.primary, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data produk tersimpan lokal di HP. Sambungkan internet untuk sinkronisasi.',
              style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder & Tambah Produk ──────────────────────────────────────────────

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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SellerTheme.darkTeal.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xFFBDBDBD)),
          ),
          const SizedBox(height: 16),
          Text(label,
              style: SellerTheme.subHeadingStyle
                  .copyWith(color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 8),
          const Text('Fitur ini akan segera hadir.',
              style: TextStyle(color: Color(0xFFBDBDBD))),
        ],
      ),
    );
  }
}

class _TambahProdukContent extends StatelessWidget {
  /// Seller bisa null saat profil masih dimuat.
  final Seller? seller;
  const _TambahProdukContent({super.key, this.seller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SellerTheme.darkTeal, Color(0xFF0D4A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: SellerTheme.neonGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add_box_rounded,
                  size: 48, color: SellerTheme.neonGreen),
            ),
            const SizedBox(height: 24),
            const Text('Tambah Produk Baru',
                style: SellerTheme.subHeadingStyle),
            const SizedBox(height: 8),
            const Text(
              'Isi informasi produk yang ingin Anda jual di katalog PaDe.',
              style: SellerTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: SellerTheme.neonGradient,
                  borderRadius:
                      BorderRadius.circular(SellerTheme.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: SellerTheme.neonGreen.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final bloc = context.read<ProductBloc>();
                    Navigator.of(context).push(PageRouteBuilder<void>(
                      pageBuilder: (_, a, __) => BlocProvider.value(
                        value: bloc,
                        child: ProductFormView(sellerId: seller?.id),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SellerTheme.borderRadius),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Mulai Tambah Produk',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// expose for quick action
const accentBlue = SellerTheme.accentBlue;
