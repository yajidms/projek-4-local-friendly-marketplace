// lib/testing/mock_repositories.dart
//
// ⚠️ MODE TESTING — Implementasi mock untuk SellerRepository & ProductRepository.
// File ini HANYA digunakan saat testing UI di main.dart.
// Jangan di-import di luar konteks testing.

import '../domain/entities/index.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/seller_repository.dart';

// ─── Mock Seller Repository ───────────────────────────────────────────────────

class MockSellerRepository implements SellerRepository {
  // Data seller mock yang sudah ada
  final Seller _mockSeller = Seller(
    id: 'mock-seller-001',
    userId: 'mock-user-001',
    shopName: 'Warung Bu Sari',
    shopDescription: 'Warung sembako dan kebutuhan sehari-hari',
    shopAddress: 'Jl. Merdeka No. 12, RT 03/RW 05, Kelurahan Sukamaju',
    shopPhone: '081234567890',
    categories: ['Sembako', 'Makanan', 'Minuman'],
    rating: 4.5,
    totalReviews: 12,
    totalProducts: 5,
    isVerified: true,
    isActive: true,
    isOnline: true,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime.now(),
    isSynced: true,
  );

  @override
  Future<Seller?> getSellerById(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (sellerId == _mockSeller.id) return _mockSeller;
    return null;
  }

  @override
  Future<List<Seller>> getAllSellers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [_mockSeller];
  }

  @override
  Future<Seller?> getSellerByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (userId == _mockSeller.userId) return _mockSeller;
    return null;
  }

  @override
  Future<Seller> createSeller(Seller seller) async {
    // Simulasi delay jaringan / local save
    await Future.delayed(const Duration(milliseconds: 800));
    // Kembalikan seller dengan ID yang dibuat seolah dari server
    return seller.copyWith(
      id: 'mock-seller-${DateTime.now().millisecondsSinceEpoch}',
      isSynced: false, // belum disinkronkan ke server
    );
  }

  @override
  Future<Seller> updateSeller(Seller seller) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return seller.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> updateSellerLocation(
      String sellerId, Location location) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // No-op pada mock
  }

  @override
  Future<void> updateSellerOnlineStatus(
      String sellerId, bool isOnline) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // No-op pada mock
  }

  @override
  Future<List<Seller>> getSellersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_mockSeller.categories.contains(category)) return [_mockSeller];
    return [];
  }

  @override
  Future<void> deleteSeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // No-op pada mock
  }

  @override
  Future<void> syncUnSyncedSellers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op pada mock
  }
}

// ─── Mock Product Repository ──────────────────────────────────────────────────

class MockProductRepository implements ProductRepository {
  // Data produk mock — 5 produk milik mock-seller-001
  final List<Product> _mockProducts = [
    Product(
      id: 'prod-001',
      sellerId: 'mock-seller-001',
      name: 'Beras Premium 5kg',
      description: 'Beras putih pulen kualitas premium',
      price: 75000,
      quantity: 50,
      category: 'Sembako',
      isAvailable: true,
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime.now(),
      isSynced: true,
      isLocalOnly: false,
    ),
    Product(
      id: 'prod-002',
      sellerId: 'mock-seller-001',
      name: 'Minyak Goreng 2L',
      description: 'Minyak goreng kelapa sawit 2 liter',
      price: 32000,
      quantity: 30,
      category: 'Sembako',
      isAvailable: true,
      createdAt: DateTime(2024, 2, 5),
      updatedAt: DateTime.now(),
      isSynced: true,
      isLocalOnly: false,
    ),
    Product(
      id: 'prod-003',
      sellerId: 'mock-seller-001',
      name: 'Gula Pasir 1kg',
      description: 'Gula pasir putih kemasan 1 kilogram',
      price: 17000,
      quantity: 0, // Stok habis
      category: 'Sembako',
      isAvailable: false,
      createdAt: DateTime(2024, 2, 10),
      updatedAt: DateTime.now(),
      isSynced: true,
      isLocalOnly: false,
    ),
    Product(
      id: 'prod-004',
      sellerId: 'mock-seller-001',
      name: 'Teh Botol Sosro 500ml',
      description: 'Minuman teh manis dalam botol plastik',
      price: 5000,
      quantity: 24,
      category: 'Minuman',
      isAvailable: true,
      createdAt: DateTime(2024, 3, 1),
      updatedAt: DateTime.now(),
      isSynced: false, // Belum sinkron — akan tampil di badge
      isLocalOnly: false,
    ),
    Product(
      id: 'prod-005',
      sellerId: 'mock-seller-001',
      name: 'Kopi Sachet (renceng)',
      description: 'Kopi instan sachet 1 renceng isi 10',
      price: 22000,
      quantity: 3, // Stok terbatas
      category: 'Makanan',
      isAvailable: true,
      createdAt: DateTime(2024, 3, 15),
      updatedAt: DateTime.now(),
      isSynced: false, // Belum sinkron
      isLocalOnly: true, // Dibuat saat offline
    ),
  ];

  @override
  Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockProducts.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts.where((p) => p.sellerId == sellerId).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts
        .where((p) => p.category == category && p.isAvailable)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _mockProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newProduct = product.copyWith(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      isSynced: false,
      isLocalOnly: true,
    );
    _mockProducts.add(newProduct);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _mockProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      final updated = product.copyWith(updatedAt: DateTime.now());
      _mockProducts[idx] = updated;
      return updated;
    }
    return product;
  }

  @override
  Future<void> updateProductQuantity(
      String productId, int newQuantity) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _mockProducts[idx] =
          _mockProducts[idx].copyWith(quantity: newQuantity);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockProducts.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Product>> getUnSyncedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockProducts.where((p) => !p.isSynced).toList();
  }

  @override
  Future<void> syncProducts() async {
    // Simulasi sinkronisasi — tandai semua produk sebagai tersinkron
    await Future.delayed(const Duration(milliseconds: 1200));
    for (int i = 0; i < _mockProducts.length; i++) {
      _mockProducts[i] = _mockProducts[i].copyWith(
        isSynced: true,
        isLocalOnly: false,
        lastSyncedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_mockProducts);
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    // No-op pada mock — data sudah ada in-memory
  }
}
