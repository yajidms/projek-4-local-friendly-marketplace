import 'dart:convert';

import 'package:http/http.dart' as http;

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
import '../../services/token_manager.dart';

/// HTTP-based datasource for admin panel operations.
/// Replaces [AdminMockDatasource] with real API calls.
class HttpAdminRemoteDatasource {
  HttpAdminRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final _token = TokenManager.instance;

  /// Header wajib untuk bypass ngrok interstitial page.
  Map<String, String> get _headers => {
        ..._token.authHeaders,
        'ngrok-skip-browser-warning': 'true',
      };

  // ─── Generic Helpers ──────────────────────────────────────

  dynamic _readBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    final body = jsonDecode(response.body);
    if (body is Map && body['success'] == false) {
      throw Exception(body['message'] ?? 'API Error');
    }
    return body;
  }

  List<Map<String, dynamic>> _parseListBody(dynamic body) {
    final data = (body is Map) ? (body['data'] ?? body) : body;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Map<String, dynamic> _parseSingleBody(dynamic body) {
    final data = (body is Map) ? (body['data'] ?? body) : body;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected response format');
  }

  // ─── User Parsing ─────────────────────────────────────────

  User _parseUser(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final rolesRaw = json['roles'];
    final roles = <Role>[];
    if (rolesRaw is List) {
      for (final r in rolesRaw) {
        final roleStr = r is String ? r : (r is Map ? r['value']?.toString() ?? '' : '');
        try {
          roles.add(RoleExtension.fromString(roleStr));
        } catch (_) {}
      }
    }
    if (roles.isEmpty) {
      roles.add(Role.buyer);
    }

    return User(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      roles: roles,
      marketplaceId: json['marketplaceId']?.toString(),
      sellerId: json['sellerId']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  // ─── Seller Parsing ───────────────────────────────────────

  Seller _parseSeller(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    Location? location;
    if (json['location'] is Map) {
      final loc = json['location'] as Map<String, dynamic>;
      location = Location(
        latitude: (loc['latitude'] ?? loc['lat'] ?? 0).toDouble(),
        longitude: (loc['longitude'] ?? loc['lng'] ?? loc['lon'] ?? 0).toDouble(),
      );
    }

    final categories = <String>[];
    if (json['categories'] is List) {
      categories.addAll((json['categories'] as List).map((e) => e.toString()));
    }

    return Seller(
      id: id,
      userId: json['userId']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      shopDescription: json['shopDescription']?.toString(),
      shopAddress: json['shopAddress']?.toString(),
      shopPhone: json['shopPhone']?.toString(),
      location: location,
      categories: categories,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalProducts: json['totalProducts'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  // ─── Product Parsing ──────────────────────────────────────

  Product _parseProduct(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final images = <String>[];
    if (json['images'] is List) {
      images.addAll((json['images'] as List).map((e) => e.toString()));
    }

    return Product(
      id: id,
      sellerId: json['sellerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] as int? ?? 0,
      category: json['category']?.toString() ?? '',
      images: images,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      isSynced: true,
    );
  }

  // ─── Order Parsing ────────────────────────────────────────

  Order _parseOrder(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Parse items
    final items = <OrderItem>[];
    if (json['items'] is List) {
      for (final itemJson in (json['items'] as List)) {
        if (itemJson is Map<String, dynamic>) {
          items.add(_parseOrderItem(itemJson, id));
        }
      }
    }

    // Parse status
    final statusStr = json['status']?.toString() ?? 'pending';
    OrderStatus status;
    try {
      status = OrderStatusExtension.fromString(statusStr);
    } catch (_) {
      status = OrderStatus.pending;
    }

    // Parse payment
    Payment? payment;
    if (json['payment'] is Map<String, dynamic>) {
      payment = _parsePayment(json['payment'] as Map<String, dynamic>, id);
    }

    // Parse shipment
    Shipment? shipment;
    if (json['shipment'] is Map<String, dynamic>) {
      shipment = _parseShipment(json['shipment'] as Map<String, dynamic>, id);
    }

    final subtotal = (json['subtotal'] ?? 0).toDouble();
    final tax = (json['tax'] ?? 0).toDouble();
    final shippingCost = (json['shippingCost'] ?? 0).toDouble();
    final total = (json['total'] ?? (subtotal + tax + shippingCost)).toDouble();

    return Order(
      id: id,
      userId: json['userId']?.toString() ?? '',
      sellerId: json['sellerId']?.toString() ?? '',
      items: items,
      status: status,
      payment: payment,
      shipment: shipment,
      subtotal: subtotal,
      tax: tax,
      shippingCost: shippingCost,
      total: total,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  OrderItem _parseOrderItem(Map<String, dynamic> json, String orderId) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final productJson = json['product'] ?? json['productId'];
    Product product;
    String productId;

    if (productJson is Map<String, dynamic>) {
      product = _parseProduct(productJson);
      productId = product.id;
    } else {
      productId = productJson?.toString() ?? '';
      product = Product(
        id: productId,
        sellerId: '',
        name: json['productName']?.toString() ?? 'Produk',
        description: '',
        price: (json['unitPrice'] ?? json['price'] ?? 0).toDouble(),
        quantity: 0,
        category: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final qty = json['quantity'] as int? ?? 1;
    final unitPrice = (json['unitPrice'] ?? json['price'] ?? product.price).toDouble();

    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      product: product,
      quantity: qty,
      unitPrice: unitPrice,
      subtotal: (json['subtotal'] ?? (unitPrice * qty)).toDouble(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Payment _parsePayment(Map<String, dynamic> json, String orderId) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? 'pay_$orderId';
    final methodStr = json['method']?.toString() ?? 'cod';
    final statusStr = json['status']?.toString() ?? 'pending';

    PaymentStatus paymentStatus;
    switch (statusStr.toLowerCase()) {
      case 'completed': paymentStatus = PaymentStatus.completed; break;
      case 'failed': paymentStatus = PaymentStatus.failed; break;
      case 'refunded': paymentStatus = PaymentStatus.refunded; break;
      default: paymentStatus = PaymentStatus.pending;
    }

    return Payment(
      id: id,
      orderId: orderId,
      amount: (json['amount'] ?? 0).toDouble(),
      method: PaymentMethodExtension.fromString(methodStr),
      status: paymentStatus,
      paidAt: _parseDate(json['paidAt']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Shipment _parseShipment(Map<String, dynamic> json, String orderId) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? 'ship_$orderId';
    final shipStatusStr = json['status']?.toString() ?? 'pending';
    ShippingStatus shipStatus;
    switch (shipStatusStr.toLowerCase()) {
      case 'processing': shipStatus = ShippingStatus.processing; break;
      case 'shipped': shipStatus = ShippingStatus.shipped; break;
      case 'in_transit': case 'intransit': shipStatus = ShippingStatus.inTransit; break;
      case 'delivered': shipStatus = ShippingStatus.delivered; break;
      case 'failed': shipStatus = ShippingStatus.failed; break;
      default: shipStatus = ShippingStatus.pending;
    }
    return Shipment(
      id: id,
      orderId: orderId,
      method: ShippingMethod.standard,
      status: shipStatus,
      trackingNumber: json['trackingNumber']?.toString(),
      carrier: json['carrier']?.toString(),
      estimatedDeliveryDate: _parseDate(json['estimatedDeliveryDate']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  // ─── Category Parsing ─────────────────────────────────────

  StoreCategory _parseCategory(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    return StoreCategory(
      id: id,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
      productCount: json['productCount'] as int? ?? 0,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  // ─── Date Helpers ─────────────────────────────────────────

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }



  // ═══════════════════════════════════════════════════════════
  // ─── API Operations ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  // ─── System ───────────────────────────────────────────────

  Future<bool> checkApiConnection() async {
    try {
      // Gunakan endpoint public /products karena /health ternyata di-protect oleh auth middleware
      final response = await _client.get(_token.uri('/products'));
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (_) {
      return false;
    }
  }

  // ─── Users ────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    final response = await _client.get(
      _token.uri('/users'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = _parseListBody(_readBody(response));
      return items.map(_parseUser).toList();
    }
    throw Exception('Failed to fetch users: ${response.statusCode}');
  }

  Future<User> getUserById(String id) async {
    final response = await _client.get(
      _token.uri('/users/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseUser(_parseSingleBody(_readBody(response)));
    }
    throw Exception('Failed to fetch user: ${response.statusCode}');
  }

  Future<void> updateUserStatus(String id, bool isActive) async {
    final response = await _client.put(
      _token.uri('/users/$id'),
      headers: _headers,
      body: jsonEncode({'isActive': isActive}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('Failed to update user status: ${response.statusCode}');
  }

  // ─── Sellers ──────────────────────────────────────────────

  Future<List<Seller>> getSellers() async {
    final response = await _client.get(
      _token.uri('/sellers'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = _parseListBody(_readBody(response));
      return items.map(_parseSeller).toList();
    }
    throw Exception('Failed to fetch sellers: ${response.statusCode}');
  }

  Future<Seller> getSellerById(String id) async {
    final response = await _client.get(
      _token.uri('/sellers/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSeller(_parseSingleBody(_readBody(response)));
    }
    throw Exception('Failed to fetch seller: ${response.statusCode}');
  }

  Future<void> approveSeller(String sellerId) async {
    final response = await _client.put(
      _token.uri('/sellers/$sellerId'),
      headers: _headers,
      body: jsonEncode({'isVerified': true}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('Failed to approve seller: ${response.statusCode}');
  }

  Future<void> rejectSeller(String sellerId, String reason) async {
    final response = await _client.put(
      _token.uri('/sellers/$sellerId'),
      headers: _headers,
      body: jsonEncode({
        'isVerified': false,
        'rejectionReason': reason,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('Failed to reject seller: ${response.statusCode}');
  }

  // ─── Products ─────────────────────────────────────────────

  Future<List<Product>> getProducts() async {
    final response = await _client.get(
      _token.uri('/products'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = _parseListBody(_readBody(response));
      return items.map(_parseProduct).toList();
    }
    throw Exception('Failed to fetch products: ${response.statusCode}');
  }

  // ─── Orders ───────────────────────────────────────────────

  Future<List<Order>> getOrders() async {
    try {
      final response = await _client.get(
        _token.uri('/orders'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final items = _parseListBody(_readBody(response));
        return items.map(_parseOrder).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Order> getOrderById(String id) async {
    final response = await _client.get(
      _token.uri('/orders/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseOrder(_parseSingleBody(_readBody(response)));
    }
    throw Exception('Failed to fetch order: ${response.statusCode}');
  }

  // ─── Categories ───────────────────────────────────────────

  Future<List<StoreCategory>> getCategories() async {
    try {
      final response = await _client.get(
        _token.uri('/categories'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final items = _parseListBody(_readBody(response));
        return items.map(_parseCategory).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<StoreCategory> createCategory(StoreCategory category) async {
    final response = await _client.post(
      _token.uri('/categories'),
      headers: _headers,
      body: jsonEncode({
        'name': category.name,
        if (category.icon != null) 'icon': category.icon,
        if (category.description != null) 'description': category.description,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseCategory(_parseSingleBody(_readBody(response)));
    }
    throw Exception('Failed to create category: ${response.statusCode}');
  }

  Future<StoreCategory> updateCategory(StoreCategory category) async {
    final response = await _client.put(
      _token.uri('/categories/${category.id}'),
      headers: _headers,
      body: jsonEncode({
        'name': category.name,
        if (category.icon != null) 'icon': category.icon,
        if (category.description != null) 'description': category.description,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseCategory(_parseSingleBody(_readBody(response)));
    }
    throw Exception('Failed to update category: ${response.statusCode}');
  }

  Future<void> deleteCategory(String id) async {
    final response = await _client.delete(
      _token.uri('/categories/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('Failed to delete category: ${response.statusCode}');
  }

  // ─── Dashboard Stats (Aggregated) ─────────────────────────

  /// Aggregates dashboard statistics from multiple API endpoints.
  /// Falls back to computing stats from raw data if no dedicated endpoint exists.
  Future<AdminDashboardStats> getDashboardStats() async {
    // Fetch all data in parallel
    final results = await Future.wait([
      getUsers(),
      getSellers(),
      getProducts(),
      getOrders(),
      _fetchCategoriesSafe(),
    ]);

    final users = results[0] as List<User>;
    final sellers = results[1] as List<Seller>;
    final products = results[2] as List<Product>;
    final orders = results[3] as List<Order>;
    final categories = results[4] as List<StoreCategory>;

    // Pending verifications = sellers not yet verified
    final pendingCount = sellers.where((s) => !s.isVerified).length;

    // Order trends for last 30 days
    final now = DateTime.now();
    final trends = <OrderTrend>[];
    for (var i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOrders = orders.where((o) {
        return o.createdAt.year == date.year &&
            o.createdAt.month == date.month &&
            o.createdAt.day == date.day;
      }).toList();

      if (dayOrders.isNotEmpty) {
        trends.add(OrderTrend(
          date: date,
          orderCount: dayOrders.length,
          revenue: dayOrders.fold<double>(0, (sum, o) => sum + o.total),
        ));
      } else {
        // If no orders on this day, show 0
        trends.add(OrderTrend(
          date: date,
          orderCount: 0,
          revenue: 0,
        ));
      }
    }

    // Category distribution
    final catDist = <String, int>{};
    for (final cat in categories) {
      catDist[cat.name] = cat.productCount;
    }
    // Also count from products if categories don't have productCount
    if (catDist.values.every((v) => v == 0)) {
      for (final p in products) {
        catDist[p.category] = (catDist[p.category] ?? 0) + 1;
      }
    }

    return AdminDashboardStats(
      totalUsers: users.length,
      totalSellers: sellers.length,
      totalProducts: products.length,
      totalOrders: orders.length,
      pendingVerifications: pendingCount,
      totalRevenue: orders.fold<double>(0, (sum, o) => sum + o.total),
      orderTrends: trends,
      categoryDistribution: catDist,
      activeSellers: sellers.where((s) => s.isActive).length,
      verifiedSellers: sellers.where((s) => s.isVerified).length,
    );
  }

  /// Safely fetch categories — returns empty list if endpoint doesn't exist.
  Future<List<StoreCategory>> _fetchCategoriesSafe() async {
    try {
      return await getCategories();
    } catch (_) {
      return [];
    }
  }

  // ─── Verification Requests (constructed from sellers + users) ──

  /// Constructs verification request objects from sellers and their owner users.
  /// This bridges the gap between the flat seller model and the admin UI's
  /// expectation of VerificationRequest objects.
  Future<List<VerificationRequest>> getVerificationRequests() async {
    final sellers = await getSellers();
    final users = await getUsers();

    final userMap = <String, User>{};
    for (final u in users) {
      userMap[u.id] = u;
    }

    final requests = <VerificationRequest>[];
    for (final seller in sellers) {
      final owner = userMap[seller.userId] ?? User(
        id: seller.userId,
        name: 'Unknown',
        email: '',
        roles: [Role.seller],
        createdAt: seller.createdAt,
        updatedAt: seller.updatedAt,
      );

      VerificationStatus status;
      if (seller.isVerified) {
        status = VerificationStatus.approved;
      } else if (seller.isActive) {
        status = VerificationStatus.pending;
      } else {
        status = VerificationStatus.rejected;
      }

      requests.add(VerificationRequest(
        id: seller.id,
        seller: seller,
        owner: owner,
        businessType: seller.categories.isNotEmpty ? seller.categories.first : 'Umum',
        status: status,
        submittedAt: seller.createdAt,
        reviewedAt: seller.isVerified ? seller.updatedAt : null,
      ));
    }

    return requests;
  }

  Future<VerificationRequest> getVerificationDetail(String id) async {
    final all = await getVerificationRequests();
    return all.firstWhere((r) => r.id == id);
  }
}
