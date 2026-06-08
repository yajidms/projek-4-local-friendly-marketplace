// lib/testing/mock_repositories.dart
//
// ⚠️ MODE TESTING — Implementasi mock untuk SellerRepository & ProductRepository.
// File ini HANYA digunakan saat testing UI di main.dart.
// Jangan di-import di luar konteks testing.

import '../domain/entities/index.dart';
import '../domain/repositories/order_repository.dart';
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
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockProducts);
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

// ─── Mock Order Repository ────────────────────────────────────────────────────

class MockOrderRepository implements OrderRepository {
  // Helper produk mini untuk order items
  static Product _p(String id, String name, double price) => Product(
        id: id,
        sellerId: 'mock-seller-001',
        name: name,
        description: '',
        price: price,
        quantity: 10,
        category: 'Sembako',
        isAvailable: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime.now(),
        isSynced: true,
        isLocalOnly: false,
      );

  static OrderItem _item(
      String itemId, String orderId, String prodId, String name, double price,
      int qty) {
    return OrderItem(
      id: itemId,
      orderId: orderId,
      productId: prodId,
      product: _p(prodId, name, price),
      quantity: qty,
      unitPrice: price,
      subtotal: price * qty,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  late final List<Order> _orders = [
    Order(
      id: 'order-001',
      userId: 'buyer-001',
      sellerId: 'mock-seller-001',
      items: [_item('item-001', 'order-001', 'prod-001', 'Beras Premium 5kg', 75000, 2)],
      status: OrderStatus.pending,
      subtotal: 150000,
      tax: 0,
      shippingCost: 10000,
      total: 160000,
      notes: 'Mohon dikirim pagi hari',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isSynced: true,
    ),
    Order(
      id: 'order-002',
      userId: 'buyer-002',
      sellerId: 'mock-seller-001',
      items: [
        _item('item-002', 'order-002', 'prod-002', 'Minyak Goreng 2L', 32000, 3),
        _item('item-003', 'order-002', 'prod-004', 'Teh Botol Sosro', 5000, 6),
      ],
      status: OrderStatus.confirmed,
      subtotal: 126000,
      tax: 0,
      shippingCost: 8000,
      total: 134000,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      isSynced: true,
    ),
    Order(
      id: 'order-003',
      userId: 'buyer-003',
      sellerId: 'mock-seller-001',
      items: [_item('item-004', 'order-003', 'prod-005', 'Kopi Sachet', 22000, 1)],
      status: OrderStatus.processing,
      subtotal: 22000,
      tax: 0,
      shippingCost: 5000,
      total: 27000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      isSynced: true,
    ),
    Order(
      id: 'order-004',
      userId: 'buyer-004',
      sellerId: 'mock-seller-001',
      items: [_item('item-005', 'order-004', 'prod-001', 'Beras Premium 5kg', 75000, 1)],
      status: OrderStatus.shipped,
      subtotal: 75000,
      tax: 0,
      shippingCost: 12000,
      total: 87000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isSynced: true,
    ),
    Order(
      id: 'order-005',
      userId: 'buyer-005',
      sellerId: 'mock-seller-001',
      items: [
        _item('item-006', 'order-005', 'prod-002', 'Minyak Goreng 2L', 32000, 2),
        _item('item-007', 'order-005', 'prod-003', 'Gula Pasir 1kg', 17000, 3),
      ],
      status: OrderStatus.delivered,
      subtotal: 115000,
      tax: 0,
      shippingCost: 10000,
      total: 125000,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isSynced: true,
    ),
    Order(
      id: 'order-006',
      userId: 'buyer-006',
      sellerId: 'mock-seller-001',
      items: [_item('item-008', 'order-006', 'prod-004', 'Teh Botol Sosro', 5000, 12)],
      status: OrderStatus.delivered,
      subtotal: 60000,
      tax: 0,
      shippingCost: 7000,
      total: 67000,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      isSynced: true,
    ),
    Order(
      id: 'order-007',
      userId: 'buyer-007',
      sellerId: 'mock-seller-001',
      items: [_item('item-009', 'order-007', 'prod-001', 'Beras Premium 5kg', 75000, 1)],
      status: OrderStatus.cancelled,
      subtotal: 75000,
      tax: 0,
      shippingCost: 10000,
      total: 85000,
      notes: 'Pembeli membatalkan pesanan',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isSynced: true,
    ),
    Order(
      id: 'order-008',
      userId: 'buyer-001',
      sellerId: 'mock-seller-001',
      items: [_item('item-010', 'order-008', 'prod-005', 'Kopi Sachet', 22000, 2)],
      status: OrderStatus.pending,
      subtotal: 44000,
      tax: 0,
      shippingCost: 5000,
      total: 49000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isSynced: true,
    ),
  ];

  @override
  Future<List<Order>> getOrdersByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((o) => o.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<Order>> getOrdersBySeller(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _orders.where((o) => o.sellerId == sellerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      return _orders[idx];
    }
    throw Exception('Order tidak ditemukan: $orderId');
  }

  @override
  Future<List<Order>> getOrdersByStatus(String sellerId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders
        .where((o) => o.sellerId == sellerId && o.status == status)
        .toList();
  }
}

