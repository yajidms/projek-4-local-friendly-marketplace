// lib/main.dart
//
// ⚠️ MODE TESTING — Main diubah sementara untuk test Seller Module.
// Untuk restore ke versi asli, uncomment bagian "ORIGINAL" dan hapus
// bagian "TESTING" di bawah ini.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/presentation/features/seller/bloc/product_bloc.dart';
import 'app/presentation/features/seller/bloc/seller_registration_bloc.dart';
import 'app/presentation/features/seller/bloc/transaction_bloc.dart';
import 'app/presentation/features/seller/views/seller_dashboard_view.dart';
import 'app/presentation/features/seller/views/seller_registration_view.dart';
import 'app/theme/seller_theme.dart';
import 'data/local/hive_init.dart';
import 'data/local/repositories/hive_product_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'testing/hive_seeder.dart';
import 'testing/mock_repositories.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi locale Bahasa Indonesia untuk DateFormat
  await initializeDateFormatting('id', null);

  // 2. Inisialisasi Hive (register adapter)
  await initHive();

  // 3. Seed data faker (100 produk) ke Hive — skip otomatis jika sudah ada
  await seedFakerDataToHive();

  // 4. Buka Hive box & siapkan ProductRepository
  final ProductRepository productRepo = await HiveProductRepository.open();

  // 5. Jalankan app dengan repo yang sudah siap
  runApp(PaDeTestApp(productRepository: productRepo));
}

/// ════════════════════════════════════════════════════════
/// APP TESTING — wraps BLoC providers + navigator
/// ════════════════════════════════════════════════════════
class PaDeTestApp extends StatelessWidget {
  /// Repository produk yang sudah disiapkan (Hive)
  final ProductRepository productRepository;

  const PaDeTestApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provider SellerRegistrationBloc dengan mock repository
        BlocProvider<SellerRegistrationBloc>(
          create: (_) => SellerRegistrationBloc(
            sellerRepository: MockSellerRepository(),
          ),
        ),
        // Provider ProductBloc dengan HIVE repository (data persisten)
        BlocProvider<ProductBloc>(
          create: (_) => ProductBloc(
            productRepository: productRepository,
          )..add(MuatProdukPenjual(sellerId: kMainSellerId)),
        ),
        // Provider TransactionBloc dengan mock repository + langsung load
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            orderRepository: MockOrderRepository(),
          )..add(MuatTransaksiPenjual(sellerId: kMainSellerId)),
        ),
      ],
      child: MaterialApp(
        title: 'PaDe — Test Seller',
        debugShowCheckedModeBanner: true, // banner "DEBUG" tetap tampil
        theme: SellerTheme.sellerThemeData,
        // Landing page: pilih screen mana yang mau ditest
        home: const _TestingLaunchPad(),
      ),
    );
  }
}

/// Halaman pilihan untuk testing — tekan tombol untuk buka screen
class _TestingLaunchPad extends StatelessWidget {
  const _TestingLaunchPad();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text('PaDe — Testing Seller UI'),
        backgroundColor: SellerTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / ikon placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SellerTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_rounded,
                  size: 44,
                  color: SellerTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PaDe Seller Module',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih layar yang ingin diuji:',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 40),

              // ── Tombol 1: Registrasi Toko ──────────────────────────────
              _TestButton(
                icon: Icons.storefront_rounded,
                label: 'Registrasi Toko',
                subtitle: 'Form "Info Toko" (Figma Ch 3.5.2)',
                color: SellerTheme.primaryGreen,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<SellerRegistrationBloc>(),
                      child: const SellerRegistrationView(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Tombol 2: Seller Dashboard ─────────────────────────────
              _TestButton(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard Penjual',
                subtitle: 'Daftar Produk, Tambah, Inventaris & Transaksi',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                            value: context.read<ProductBloc>()),
                        BlocProvider.value(
                            value: context.read<TransactionBloc>()),
                      ],
                      child: const SellerDashboardView(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Info storage Hive
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: SellerTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          SellerTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storage_rounded,
                        size: 16, color: SellerTheme.primaryGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data produk tersimpan lokal (Hive). Transaksi menggunakan data mock.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol navigasi testing yang konsisten
class _TestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TestButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          // NFR-OPR-01: min height 48dp
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
