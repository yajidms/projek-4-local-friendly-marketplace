import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/admin_dashboard_stats.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/seller.dart';
import '../../../domain/entities/store_category.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/verification_request.dart';
import '../../../../config/env.dart';

class HttpAdminRemoteDatasource {
  final http.Client client;

  HttpAdminRemoteDatasource({http.Client? client}) : client = client ?? http.Client();

  String get _baseUrl => Env.backendUrl;

  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/dashboard'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return AdminDashboardStats(
        totalUsers: data['totalUsers'] ?? 0,
        totalSellers: data['totalSellers'] ?? 0,
        totalProducts: data['totalProducts'] ?? 0,
        totalOrders: data['totalOrders'] ?? 0,
        pendingVerifications: data['pendingVerifications'] ?? 0,
        totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
        orderTrends: (data['orderTrends'] as List?)?.map((e) => OrderTrend(
          date: DateTime.parse(e['date']),
          orderCount: e['orderCount'],
          revenue: (e['revenue']).toDouble(),
        )).toList() ?? [],
        categoryDistribution: Map<String, int>.from(data['categoryDistribution'] ?? {}),
        activeSellers: data['activeSellers'] ?? 0,
        verifiedSellers: data['verifiedSellers'] ?? 0,
      );
    }
    throw Exception('Failed to load dashboard stats');
  }

  Future<List<VerificationRequest>> getVerificationRequests({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/verifications$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      return data.map((e) => VerificationRequest(
        id: e['id'],
        seller: Seller(
          id: e['seller']['id'],
          userId: e['seller']['userId'],
          shopName: e['seller']['shopName'],
          categories: [],
          rating: 0,
          totalReviews: 0,
          totalProducts: 0,
          isVerified: e['seller']['isVerified'] ?? false,
          isActive: true,
          isOnline: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        owner: User(
          id: e['owner']['id'] ?? '',
          name: e['owner']['name'] ?? '',
          email: e['owner']['email'] ?? '',
          roles: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        businessType: e['businessType'] ?? '',
        status: VerificationStatusExtension.fromString(e['status'] ?? 'pending'),
        submittedAt: e['submittedAt'] != null ? DateTime.parse(e['submittedAt']) : DateTime.now(),
      )).toList();
    }
    throw Exception('Failed to load verification requests');
  }

  Future<VerificationRequest> getVerificationDetail(String id) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/verifications/$id'));
    if (response.statusCode == 200) {
      final e = json.decode(response.body)['data'];
      return VerificationRequest(
        id: e['id'],
        seller: Seller(
          id: e['seller']['id'],
          userId: e['seller']['userId'],
          shopName: e['seller']['shopName'],
          categories: [],
          rating: 0,
          totalReviews: 0,
          totalProducts: 0,
          isVerified: e['seller']['isVerified'] ?? false,
          isActive: true,
          isOnline: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        owner: User(
          id: e['owner']['id'] ?? '',
          name: e['owner']['name'] ?? '',
          email: e['owner']['email'] ?? '',
          roles: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        businessType: e['businessType'] ?? '',
        status: VerificationStatusExtension.fromString(e['status'] ?? 'pending'),
        submittedAt: e['submittedAt'] != null ? DateTime.parse(e['submittedAt']) : DateTime.now(),
      );
    }
    throw Exception('Failed to load verification detail');
  }

  Future<void> approveStore(String sellerId) async {
    final response = await client.post(Uri.parse('$_baseUrl/api/admin/verifications/$sellerId/approve'));
    if (response.statusCode != 200) throw Exception('Failed to approve store');
  }

  Future<void> rejectStore(String sellerId, String reason) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/admin/verifications/$sellerId/reject'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'reason': reason}),
    );
    if (response.statusCode != 200) throw Exception('Failed to reject store');
  }

  Future<List<User>> getUsers({String? role, String? search}) async {
    String query = '?';
    if (role != null) query += 'role=$role&';
    if (search != null) query += 'search=$search';
    final response = await client.get(Uri.parse('$_baseUrl/api/users$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      return data.map((e) => User(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
        email: e['email'] ?? '',
        roles: (e['roles'] as List?)?.map((r) => RoleExtension.fromString(r)).toList() ?? [],
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
        isSynced: true,
      )).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<User> getUserDetail(String id) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/users/$id'));
    if (response.statusCode == 200) {
      final e = json.decode(response.body)['data'];
      return User(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
        email: e['email'] ?? '',
        roles: (e['roles'] as List?)?.map((r) => RoleExtension.fromString(r)).toList() ?? [],
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
        isSynced: true,
      );
    }
    throw Exception('Failed to load user detail');
  }

  Future<void> updateUserStatus(String id, bool isActive) async {
    final response = await client.put(
      Uri.parse('$_baseUrl/api/admin/users/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isActive': isActive}),
    );
    if (response.statusCode != 200) throw Exception('Failed to update user status');
  }

  Future<List<Seller>> getSellers({bool? isVerified, String? search}) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/sellers'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      List<Seller> sellers = data.map((e) => Seller(
        id: e['id'] ?? '',
        userId: e['userId'] ?? '',
        shopName: e['shopName'] ?? '',
        categories: List<String>.from(e['categories'] ?? []),
        rating: (e['rating'] ?? 0).toDouble(),
        totalReviews: e['totalReviews'] ?? 0,
        totalProducts: e['totalProducts'] ?? 0,
        isVerified: e['isVerified'] ?? false,
        isActive: e['isActive'] ?? true,
        isOnline: e['isOnline'] ?? true,
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
        isSynced: true,
      )).toList();
      
      if (isVerified != null) {
        sellers = sellers.where((s) => s.isVerified == isVerified).toList();
      }
      if (search != null && search.isNotEmpty) {
        sellers = sellers.where((s) => s.shopName.toLowerCase().contains(search.toLowerCase())).toList();
      }
      return sellers;
    }
    throw Exception('Failed to load sellers');
  }

  Future<Seller> getSellerDetail(String id) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/sellers/$id'));
    if (response.statusCode == 200) {
      final e = json.decode(response.body)['data'];
      return Seller(
        id: e['id'] ?? '',
        userId: e['userId'] ?? '',
        shopName: e['shopName'] ?? '',
        categories: List<String>.from(e['categories'] ?? []),
        rating: (e['rating'] ?? 0).toDouble(),
        totalReviews: e['totalReviews'] ?? 0,
        totalProducts: e['totalProducts'] ?? 0,
        isVerified: e['isVerified'] ?? false,
        isActive: e['isActive'] ?? true,
        isOnline: e['isOnline'] ?? true,
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
        isSynced: true,
      );
    }
    throw Exception('Failed to load seller detail');
  }

  Future<List<Product>> getAllProducts({String? category, String? search}) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/products'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      List<Product> products = data.map((e) => Product(
        id: e['id'] ?? '',
        sellerId: e['sellerId'] ?? '',
        name: e['name'] ?? '',
        description: e['description'] ?? '',
        price: (e['price'] ?? 0).toDouble(),
        quantity: e['stock'] ?? e['quantity'] ?? 0,
        category: e['category'] ?? '',
        images: List<String>.from(e['images'] ?? []),
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
        isSynced: true,
      )).toList();
      
      if (category != null && category.isNotEmpty) {
        products = products.where((p) => p.category == category).toList();
      }
      if (search != null && search.isNotEmpty) {
        products = products.where((p) => p.name.toLowerCase().contains(search.toLowerCase())).toList();
      }
      return products;
    }
    throw Exception('Failed to load products');
  }

  // --- Orders ---
  Future<List<Order>> getAllOrders({String? status}) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/orders'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      List<Order> orders = data.map((e) => _mapOrder(e)).toList();
      if (status != null && status.isNotEmpty) {
        final statusEnum = OrderStatusExtension.fromString(status);
        orders = orders.where((o) => o.status == statusEnum).toList();
      }
      return orders;
    }
    throw Exception('Failed to load orders');
  }

  Future<Order> getOrderDetail(String id) async {
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/orders/$id'));
    if (response.statusCode == 200) {
      return _mapOrder(json.decode(response.body)['data']);
    }
    throw Exception('Failed to load order detail');
  }

  Order _mapOrder(Map<String, dynamic> e) {
    return Order(
      id: e['id'] ?? '',
      userId: e['userId'] ?? e['buyerId'] ?? '',
      sellerId: e['sellerId'] ?? '',
      items: (e['items'] as List?)?.map((i) => OrderItem(
        id: i['id'] ?? '',
        orderId: e['id'] ?? '',
        productId: i['productId'] ?? '',
        product: Product(
          id: i['productId'] ?? '',
          sellerId: e['sellerId'] ?? '',
          name: i['productName'] ?? '',
          description: '',
          price: (i['price'] ?? 0).toDouble(),
          quantity: i['quantity'] ?? 0,
          category: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: i['quantity'] ?? 0,
        unitPrice: (i['price'] ?? 0).toDouble(),
        subtotal: (i['price'] ?? 0).toDouble() * (i['quantity'] ?? 0),
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
        updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
      )).toList() ?? [],
      subtotal: (e['subtotal'] ?? e['totalAmount'] ?? 0).toDouble(),
      tax: (e['tax'] ?? 0).toDouble(),
      shippingCost: (e['shippingCost'] ?? 0).toDouble(),
      total: (e['total'] ?? e['totalAmount'] ?? 0).toDouble(),
      status: OrderStatusExtension.fromString(e['status'] ?? 'pending'),
      createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
      updatedAt: e['updatedAt'] != null ? DateTime.parse(e['updatedAt']) : DateTime.now(),
      isSynced: true,
    );
  }

  Future<List<StoreCategory>> getCategories() async {
    final response = await client.get(Uri.parse('$_baseUrl/api/admin/categories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'] ?? [];
      return data.map((e) => StoreCategory(
        id: e['id'] ?? '',
        name: e['name'] ?? '',
        icon: e['icon'],
        description: e['description'],
        productCount: e['productCount'] ?? 0,
        createdAt: e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now(),
      )).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<void> createCategory(StoreCategory category) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/api/admin/categories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': category.name,
        'icon': category.icon,
        'description': category.description,
      }),
    );
    if (response.statusCode != 201) throw Exception('Failed to create category');
  }

  Future<void> updateCategory(StoreCategory category) async {
    final response = await client.put(
      Uri.parse('$_baseUrl/api/admin/categories/${category.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': category.name,
        'icon': category.icon,
        'description': category.description,
      }),
    );
    if (response.statusCode != 200) throw Exception('Failed to update category');
  }

  Future<void> deleteCategory(String id) async {
    final response = await client.delete(Uri.parse('$_baseUrl/api/admin/categories/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete category');
  }
}
