// lib/data/local/repositories/hive_product_repository.dart
//
// Implementasi nyata ProductRepository menggunakan Hive sebagai storage.
// Data disimpan ke disk lokal — persisten meski app ditutup dan dibuka ulang.
//
// Gunakan kelas ini sebagai pengganti MockProductRepository di main.dart.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

/// Nama box Hive yang digunakan untuk menyimpan produk.
/// Harus konsisten di seluruh app — jangan diubah setelah data tersimpan.
const String kProductBoxName = 'products';

/// Implementasi [ProductRepository] menggunakan Hive sebagai local offline DB.
///
/// Semua operasi CRUD dilakukan secara langsung ke Hive Box di disk.
/// Data persisten setelah app ditutup dan dibuka kembali.
class HiveProductRepository implements ProductRepository {
  /// Box Hive yang sudah dibuka (harus sudah `await Hive.openBox()` sebelum digunakan).
  /// Gunakan [HiveProductRepository.open()] untuk memastikan box sudah siap.
  final Box<Product> _box;

  HiveProductRepository._(this._box);

  /// Factory async: membuka box.
  ///
  /// Panggil ini di main() sebelum membuat BlocProvider.
  static Future<HiveProductRepository> open() async {
    final box = await Hive.openBox<Product>(kProductBoxName);
    return HiveProductRepository._(box);
  }

  // ─── Read Operations ────────────────────────────────────────────────────────

  @override
  Future<Product?> getProductById(String productId) async {
    return _box.get(productId);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    return _box.values.toList();
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    return _box.values
        .where((p) => p.sellerId == sellerId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    return _box.values
        .where((p) => p.category == category && p.isAvailable)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _box.values.toList();
    return _box.values
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    return _box.values.toList();
  }

  @override
  Future<List<Product>> getUnSyncedProducts() async {
    return _box.values.where((p) => !p.isSynced).toList();
  }

  // ─── Write Operations ───────────────────────────────────────────────────────

  @override
  Future<Product> createProduct(Product product) async {
    // Buat ID baru menggunakan UUID jika ID masih kosong
    final id = product.id.isEmpty
        ? 'prod-${const Uuid().v4().substring(0, 8)}'
        : product.id;

    final newProduct = product.copyWith(
      id: id,
      isSynced: false,
      isLocalOnly: true,
    );

    await _box.put(newProduct.id, newProduct);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final updated = product.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false, // tandai perlu sync ulang setelah diubah
    );
    await _box.put(updated.id, updated);
    return updated;
  }

  @override
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    final existing = _box.get(productId);
    if (existing == null) return;

    final updated = existing.copyWith(
      quantity: newQuantity,
      // Otomatis tandai tidak tersedia jika stok habis
      isAvailable: newQuantity > 0 ? existing.isAvailable : false,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _box.put(productId, updated);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _box.delete(productId);
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final map = <String, Product>{
      for (final p in products) p.id: p,
    };
    await _box.putAll(map);
  }

  // ─── Sync (placeholder — untuk integrasi backend di masa depan) ─────────────

  @override
  Future<void> syncProducts() async {
    // Tandai semua produk lokal sebagai sudah disinkronkan
    // (implementasi nyata akan POST ke API)
    final unsynced = _box.values.where((p) => !p.isSynced).toList();
    for (final p in unsynced) {
      await _box.put(
        p.id,
        p.copyWith(
          isSynced: true,
          isLocalOnly: false,
          lastSyncedAt: DateTime.now(),
        ),
      );
    }
  }
}
