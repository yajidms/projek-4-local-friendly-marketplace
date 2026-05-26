// lib/testing/hive_seeder.dart
//
// ⚠️ TESTING ONLY — Seeder data faker ke Hive local database.
//
// Fungsi [seedFakerDataToHive] akan:
//   1. Membuka box Hive 'products'
//   2. Mengisi dengan 100 produk yang digenerate oleh mock_repositories.dart
//   3. Idempotent: skip jika data sudah ada (cek jumlah record)
//
// Panggil di main() setelah initHive(), hanya dalam mode testing.

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/entities/product.dart';
import 'mock_repositories.dart';

/// Nama box Hive untuk produk (harus sama dengan yang dipakai ProductHiveRepository)
const _kProductBox = 'products';

/// Seed 100 data produk faker ke Hive.
///
/// [forceReseed] — jika true, hapus semua data lama sebelum seed ulang.
/// Default false: hanya seed jika box kosong.
Future<void> seedFakerDataToHive({bool forceReseed = false}) async {
  // Buka box produk (auto-close dihandle oleh caller / main)
  final box = await Hive.openBox<Product>(_kProductBox);

  if (!forceReseed && box.isNotEmpty) {
    // Sudah ada data — skip agar tidak duplikat setiap hot-restart
    debugPrint(
        '[HiveSeeder] Box "$_kProductBox" sudah berisi ${box.length} record. Skip seed.');
    return;
  }

  if (forceReseed) {
    await box.clear();
    debugPrint('[HiveSeeder] Box "$_kProductBox" dikosongkan untuk seed ulang.');
  }

  // Ambil data dari getter publik faker (lazy singleton dari mock_repositories)
  final products = generatedProducts;

  // Tulis ke Hive menggunakan product.id sebagai key
  for (final product in products) {
    await box.put(product.id, product);
  }

  debugPrint(
      '[HiveSeeder] ✅ Berhasil seed ${products.length} produk ke Hive box "$_kProductBox".');
}

/// Hapus semua data produk di Hive (untuk reset/testing)
Future<void> clearHiveProductData() async {
  if (Hive.isBoxOpen(_kProductBox)) {
    final box = Hive.box<Product>(_kProductBox);
    await box.clear();
  } else {
    final box = await Hive.openBox<Product>(_kProductBox);
    await box.clear();
  }
  debugPrint('[HiveSeeder] 🗑️ Semua data produk di Hive dihapus.');
}

// ignore: avoid_print
void debugPrint(String message) => print(message);
