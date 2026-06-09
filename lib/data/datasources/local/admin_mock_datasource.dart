import 'dart:math';

import '../../../domain/entities/admin_dashboard_stats.dart';
import '../../../domain/entities/location.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/seller.dart';
import '../../../domain/entities/shipment.dart';
import '../../../domain/entities/store_category.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/verification_request.dart';

/// Mock datasource that generates realistic dummy data for the admin panel.
/// This will be swapped with a real HTTP datasource once the backend API is ready.
class AdminMockDatasource {
  static final _random = Random(42);

  // ─── Categories ──────────────────────────────────────────

  static final List<StoreCategory> _categories = [
    StoreCategory(id: 'cat_01', name: 'Sayuran', icon: '🥬', description: 'Sayur-sayuran segar', productCount: 45, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_02', name: 'Buah-buahan', icon: '🍎', description: 'Buah-buahan segar', productCount: 38, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_03', name: 'Daging & Ikan', icon: '🥩', description: 'Daging sapi, ayam, dan ikan segar', productCount: 32, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_04', name: 'Bumbu Dapur', icon: '🌶️', description: 'Rempah dan bumbu masak', productCount: 28, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_05', name: 'Sembako', icon: '🍚', description: 'Beras, minyak, gula, dll', productCount: 52, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_06', name: 'Jajanan Pasar', icon: '🍡', description: 'Kue dan jajanan tradisional', productCount: 24, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_07', name: 'Minuman', icon: '🥤', description: 'Minuman kemasan dan segar', productCount: 18, createdAt: DateTime(2026, 1, 15)),
    StoreCategory(id: 'cat_08', name: 'Olahan', icon: '🫕', description: 'Makanan olahan dan siap saji', productCount: 21, createdAt: DateTime(2026, 1, 15)),
  ];

  List<StoreCategory> get categories => List.unmodifiable(_categories);

  // ─── Users ───────────────────────────────────────────────

  static final List<User> _users = _generateUsers();

  static List<User> _generateUsers() {
    final names = [
      'Ahmad Fauzi', 'Siti Nurhaliza', 'Budi Santoso', 'Dewi Lestari', 'Eko Prasetyo',
      'Fitri Handayani', 'Gunawan Wibisono', 'Hana Pertiwi', 'Irfan Hakim', 'Joko Widodo',
      'Kartini Sari', 'Lukman Hakim', 'Maya Anggraini', 'Nanda Pratama', 'Omar Bakri',
      'Putri Rahayu', 'Qori Ismail', 'Rina Marlina', 'Surya Dharma', 'Tina Wulandari',
      'Umar Said', 'Vera Puspita', 'Wahyu Hidayat', 'Xena Gabriella', 'Yoga Permana',
      'Zahra Amelia', 'Arif Rahman', 'Bella Safitri', 'Cahyo Nugroho', 'Dina Fitriani',
      'Elang Maulana', 'Farah Diba', 'Galih Pratama', 'Hasna Utami', 'Ivan Setiawan',
      'Jasmine Putri', 'Kemal Aziz', 'Laras Ayu', 'Miftah Farid', 'Nisa Aulia',
      'Oscar Tanujaya', 'Pramesti Anindhita', 'Raka Aditya', 'Salma Khoirunnisa', 'Teguh Firmansyah',
      'Umi Kalsum', 'Vino Bastian', 'Winda Khairina', 'Yusuf Maulana', 'Zaki Mubarok',
    ];

    final users = <User>[];
    for (var i = 0; i < names.length; i++) {
      final name = names[i];
      final email = '${name.toLowerCase().replaceAll(' ', '.')}@mail.com';
      List<Role> roles;
      if (i == 0) {
        roles = [Role.admin];
      } else if (i < 20) {
        roles = [Role.seller];
      } else {
        roles = [Role.buyer];
      }

      users.add(User(
        id: 'user_${(i + 1).toString().padLeft(3, '0')}',
        name: name,
        email: email,
        phone: '08${(1000000000 + _random.nextInt(900000000))}',
        roles: roles,
        marketplaceId: roles.contains(Role.seller) ? 'marketplace_001' : null,
        sellerId: roles.contains(Role.seller) ? 'seller_${(i + 1).toString().padLeft(3, '0')}' : null,
        createdAt: DateTime(2026, 1 + _random.nextInt(4), 1 + _random.nextInt(28)),
        updatedAt: DateTime(2026, 4, 1 + _random.nextInt(30)),
      ));
    }
    return users;
  }

  List<User> get users => List.unmodifiable(_users);

  // ─── Sellers ─────────────────────────────────────────────

  static final List<Seller> _sellers = _generateSellers();

  static List<Seller> _generateSellers() {
    final shopNames = [
      'Toko Sayur Pak Budi', 'Warung Bu Siti', 'Ikan Segar Mas Eko',
      'Bumbu Rempah Nusantara', 'Toko Sembako Jaya', 'Kue Tradisional Mbak Dewi',
      'Buah Segar 88', 'Daging Prima', 'Toko Kelontong Abadi',
      'Pasar Segar Mandiri', 'Rempah Asli Solo', 'Sayur Organik Ibu',
      'Ikan Laut Segar', 'Bumbu Dapur Lengkap', 'Toko Beras Makmur',
      'Jajanan Pasar Enak', 'Juice & Smoothie Bar', 'Olahan Rumahan Bu Tina',
      'Toko Tahu Tempe Murni', 'Ayam Potong Segar',
    ];

    final sellers = <Seller>[];
    for (var i = 0; i < shopNames.length; i++) {
      final catIndex = i % _categories.length;
      sellers.add(Seller(
        id: 'seller_${(i + 2).toString().padLeft(3, '0')}',
        userId: 'user_${(i + 2).toString().padLeft(3, '0')}',
        shopName: shopNames[i],
        shopDescription: 'Menyediakan ${_categories[catIndex].name.toLowerCase()} berkualitas dengan harga terjangkau.',
        shopAddress: 'Pasar Tradisional Blok ${String.fromCharCode(65 + (i % 8))}${i + 1}, Bandung',
        shopPhone: '08${(2000000000 + _random.nextInt(800000000))}',
        location: Location(
          latitude: -6.9 + (_random.nextDouble() * 0.1),
          longitude: 107.6 + (_random.nextDouble() * 0.1),
        ),
        categories: [_categories[catIndex].name],
        rating: 3.0 + (_random.nextDouble() * 2.0),
        totalReviews: _random.nextInt(150),
        totalProducts: 5 + _random.nextInt(30),
        isVerified: i < 14,
        isActive: i < 18,
        isOnline: _random.nextBool(),
        createdAt: DateTime(2026, 1 + (i ~/ 7), 1 + _random.nextInt(28)),
        updatedAt: DateTime(2026, 4, 1 + _random.nextInt(30)),
      ));
    }
    return sellers;
  }

  List<Seller> get sellers => List.unmodifiable(_sellers);

  // ─── Products ────────────────────────────────────────────

  static final List<Product> _products = _generateProducts();

  static List<Product> _generateProducts() {
    final productData = <Map<String, dynamic>>[
      {'name': 'Kangkung Segar', 'cat': 'Sayuran', 'price': 5000},
      {'name': 'Bayam Hijau', 'cat': 'Sayuran', 'price': 4000},
      {'name': 'Wortel Import', 'cat': 'Sayuran', 'price': 12000},
      {'name': 'Brokoli', 'cat': 'Sayuran', 'price': 18000},
      {'name': 'Tomat Merah', 'cat': 'Sayuran', 'price': 8000},
      {'name': 'Cabai Rawit', 'cat': 'Bumbu Dapur', 'price': 45000},
      {'name': 'Bawang Merah', 'cat': 'Bumbu Dapur', 'price': 35000},
      {'name': 'Bawang Putih', 'cat': 'Bumbu Dapur', 'price': 30000},
      {'name': 'Jahe Merah', 'cat': 'Bumbu Dapur', 'price': 25000},
      {'name': 'Kunyit Segar', 'cat': 'Bumbu Dapur', 'price': 15000},
      {'name': 'Jeruk Manis', 'cat': 'Buah-buahan', 'price': 20000},
      {'name': 'Apel Malang', 'cat': 'Buah-buahan', 'price': 25000},
      {'name': 'Mangga Harum Manis', 'cat': 'Buah-buahan', 'price': 30000},
      {'name': 'Pisang Ambon', 'cat': 'Buah-buahan', 'price': 15000},
      {'name': 'Semangka', 'cat': 'Buah-buahan', 'price': 22000},
      {'name': 'Daging Sapi Has Dalam', 'cat': 'Daging & Ikan', 'price': 130000},
      {'name': 'Ayam Kampung Utuh', 'cat': 'Daging & Ikan', 'price': 75000},
      {'name': 'Ikan Gurame Segar', 'cat': 'Daging & Ikan', 'price': 55000},
      {'name': 'Udang Windu', 'cat': 'Daging & Ikan', 'price': 85000},
      {'name': 'Ikan Lele', 'cat': 'Daging & Ikan', 'price': 28000},
      {'name': 'Beras Premium 5kg', 'cat': 'Sembako', 'price': 65000},
      {'name': 'Minyak Goreng 2L', 'cat': 'Sembako', 'price': 32000},
      {'name': 'Gula Pasir 1kg', 'cat': 'Sembako', 'price': 16000},
      {'name': 'Tepung Terigu 1kg', 'cat': 'Sembako', 'price': 12000},
      {'name': 'Telur Ayam 1kg', 'cat': 'Sembako', 'price': 28000},
      {'name': 'Onde-onde', 'cat': 'Jajanan Pasar', 'price': 2000},
      {'name': 'Klepon', 'cat': 'Jajanan Pasar', 'price': 1500},
      {'name': 'Lemper Ayam', 'cat': 'Jajanan Pasar', 'price': 3000},
      {'name': 'Risoles', 'cat': 'Jajanan Pasar', 'price': 5000},
      {'name': 'Pastel', 'cat': 'Jajanan Pasar', 'price': 4000},
      {'name': 'Es Cendol', 'cat': 'Minuman', 'price': 8000},
      {'name': 'Jus Alpukat', 'cat': 'Minuman', 'price': 12000},
      {'name': 'Es Kelapa Muda', 'cat': 'Minuman', 'price': 10000},
      {'name': 'Teh Botol', 'cat': 'Minuman', 'price': 5000},
      {'name': 'Kopi Tubruk', 'cat': 'Minuman', 'price': 7000},
      {'name': 'Rendang Padang', 'cat': 'Olahan', 'price': 45000},
      {'name': 'Gudeg Jogja', 'cat': 'Olahan', 'price': 25000},
      {'name': 'Pecel Lele', 'cat': 'Olahan', 'price': 18000},
      {'name': 'Bakso Sapi', 'cat': 'Olahan', 'price': 15000},
      {'name': 'Soto Ayam', 'cat': 'Olahan', 'price': 15000},
    ];

    final products = <Product>[];
    for (var i = 0; i < productData.length; i++) {
      final data = productData[i];
      final sellerIdx = i % _sellers.length;
      products.add(Product(
        id: 'prod_${(i + 1).toString().padLeft(3, '0')}',
        sellerId: _sellers[sellerIdx].id,
        name: data['name'] as String,
        description: '${data['name']} pilihan terbaik dengan kualitas terjamin.',
        price: (data['price'] as int).toDouble(),
        quantity: _random.nextInt(100),
        category: data['cat'] as String,
        images: [],
        isAvailable: _random.nextDouble() > 0.15,
        createdAt: DateTime(2026, 2 + _random.nextInt(3), 1 + _random.nextInt(28)),
        updatedAt: DateTime(2026, 4, 1 + _random.nextInt(30)),
        isSynced: _random.nextDouble() > 0.2,
      ));
    }
    return products;
  }

  List<Product> get products => List.unmodifiable(_products);

  // ─── Orders ──────────────────────────────────────────────

  static final List<Order> _orders = _generateOrders();

  static List<Order> _generateOrders() {
    final statuses = OrderStatus.values;
    final orders = <Order>[];

    for (var i = 0; i < 80; i++) {
      final buyerIdx = 20 + (i % 30); // buyers are indices 20-49
      final sellerIdx = i % _sellers.length;
      final itemCount = 1 + _random.nextInt(4);
      final items = <OrderItem>[];
      double subtotal = 0;

      for (var j = 0; j < itemCount; j++) {
        final prodIdx = _random.nextInt(_products.length);
        final qty = 1 + _random.nextInt(5);
        final product = _products[prodIdx];
        subtotal += product.price * qty;
        items.add(OrderItem(
          id: 'item_${i}_$j',
          orderId: 'order_${(i + 1).toString().padLeft(3, '0')}',
          productId: product.id,
          product: product,
          quantity: qty,
          unitPrice: product.price,
          subtotal: product.price * qty,
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 4, 1),
        ));
      }

      final tax = subtotal * 0.01;
      final shipping = 5000.0 + _random.nextInt(10000);
      final total = subtotal + tax + shipping;
      final status = statuses[_random.nextInt(statuses.length)];
      final createdDate = DateTime(2026, 3 + _random.nextInt(2), 1 + _random.nextInt(28));

      orders.add(Order(
        id: 'order_${(i + 1).toString().padLeft(3, '0')}',
        userId: _users[buyerIdx].id,
        sellerId: _sellers[sellerIdx].id,
        items: items,
        status: status,
        payment: Payment(
          id: 'pay_${(i + 1).toString().padLeft(3, '0')}',
          orderId: 'order_${(i + 1).toString().padLeft(3, '0')}',
          amount: total,
          method: PaymentMethod.cod,
          status: status == OrderStatus.delivered
              ? PaymentStatus.completed
              : (status == OrderStatus.cancelled ? PaymentStatus.failed : PaymentStatus.pending),
          paidAt: createdDate,
          createdAt: createdDate,
          updatedAt: createdDate,
        ),
        shipment: Shipment(
          id: 'ship_${(i + 1).toString().padLeft(3, '0')}',
          orderId: 'order_${(i + 1).toString().padLeft(3, '0')}',
          method: ShippingMethod.standard,
          status: status == OrderStatus.delivered
              ? ShippingStatus.delivered
              : (status == OrderStatus.shipped ? ShippingStatus.inTransit : ShippingStatus.pending),
          trackingNumber: 'TRK${(100000 + i)}',
          carrier: 'Kurir Lokal',
          estimatedDeliveryDate: createdDate.add(const Duration(days: 3)),
          createdAt: createdDate,
          updatedAt: createdDate,
        ),
        subtotal: subtotal,
        tax: tax,
        shippingCost: shipping,
        total: total,
        createdAt: createdDate,
        updatedAt: createdDate,
      ));
    }
    return orders;
  }

  List<Order> get orders => List.unmodifiable(_orders);

  // ─── Verification Requests ───────────────────────────────

  static final List<VerificationRequest> _verificationRequests =
      _generateVerificationRequests();

  static List<VerificationRequest> _generateVerificationRequests() {
    final requests = <VerificationRequest>[];
    for (var i = 0; i < _sellers.length; i++) {
      final seller = _sellers[i];
      final user = _users[i + 1]; // offset by 1 (index 0 is admin)
      VerificationStatus status;
      String? reason;
      DateTime? reviewedAt;

      if (i < 14) {
        status = VerificationStatus.approved;
        reviewedAt = DateTime(2026, 2, 1 + _random.nextInt(28));
      } else if (i < 17) {
        status = VerificationStatus.pending;
      } else {
        status = VerificationStatus.rejected;
        reason = 'Dokumen tidak lengkap atau tidak sesuai.';
        reviewedAt = DateTime(2026, 3, 10 + _random.nextInt(20));
      }

      requests.add(VerificationRequest(
        id: 'verif_${(i + 1).toString().padLeft(3, '0')}',
        seller: seller,
        owner: user,
        businessType: ['Perorangan', 'CV', 'UD'][i % 3],
        idCardUrl: 'https://placehold.co/400x250/1B8C3D/white?text=KTP+${user.name.split(' ').first}',
        businessDocUrl: 'https://placehold.co/400x250/2563eb/white?text=Dokumen+Usaha',
        status: status,
        rejectionReason: reason,
        submittedAt: seller.createdAt,
        reviewedAt: reviewedAt,
        reviewedBy: status != VerificationStatus.pending ? 'user_001' : null,
      ));
    }
    return requests;
  }

  List<VerificationRequest> get verificationRequests =>
      List.unmodifiable(_verificationRequests);

  // ─── Dashboard Stats ─────────────────────────────────────

  AdminDashboardStats getDashboardStats() {
    final pendingCount = _verificationRequests
        .where((v) => v.status == VerificationStatus.pending)
        .length;

    final trends = <OrderTrend>[];
    for (var i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayOrders = 2 + _random.nextInt(12);
      trends.add(OrderTrend(
        date: date,
        orderCount: dayOrders,
        revenue: dayOrders * (25000.0 + _random.nextInt(50000)),
      ));
    }

    final catDist = <String, int>{};
    for (final cat in _categories) {
      catDist[cat.name] = cat.productCount;
    }

    return AdminDashboardStats(
      totalUsers: _users.length,
      totalSellers: _sellers.length,
      totalProducts: _products.length,
      totalOrders: _orders.length,
      pendingVerifications: pendingCount,
      totalRevenue: _orders.fold<double>(0.0, (double sum, Order o) => sum + o.total),
      orderTrends: trends,
      categoryDistribution: catDist,
      activeSellers: _sellers.where((Seller s) => s.isActive).length,
      verifiedSellers: _sellers.where((Seller s) => s.isVerified).length,
    );
  }
}
