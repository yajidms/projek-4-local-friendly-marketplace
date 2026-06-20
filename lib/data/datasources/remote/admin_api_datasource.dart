import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../../domain/entities/admin_dashboard_stats.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/seller.dart';
import '../../../domain/entities/store_category.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/verification_request.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/seller_model.dart';
import '../../models/user_model.dart';
import '../../services/token_manager.dart';

class AdminApiDatasource {
  final http.Client _client;

  AdminApiDatasource({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) {
    final baseUrl = Env.backendUrl;
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, String> get _headers {
    final token = TokenManager.instance.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> checkHealth() async {
    try {
      final baseUri = Uri.parse(Env.backendUrl);
      final healthUri = baseUri.replace(path: '/health');
      final response = await _client.get(healthUri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await _client.get(_uri('/admin/dashboard'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      
      final trendsList = (data['orderTrends'] as List?)?.map((t) => OrderTrend(
        date: DateTime.parse(t['date']),
        orderCount: t['orderCount'] as int,
        revenue: (t['revenue'] as num).toDouble(),
      )).toList() ?? [];

      final catMap = <String, int>{};
      if (data['categoryDistribution'] != null) {
        (data['categoryDistribution'] as Map<String, dynamic>).forEach((key, value) {
          catMap[key] = value as int;
        });
      }

      return AdminDashboardStats(
        totalUsers: data['totalUsers'] ?? 0,
        totalSellers: data['totalSellers'] ?? 0,
        totalProducts: data['totalProducts'] ?? 0,
        totalOrders: data['totalOrders'] ?? 0,
        pendingVerifications: data['pendingVerifications'] ?? 0,
        totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        activeSellers: data['activeSellers'] ?? 0,
        verifiedSellers: data['verifiedSellers'] ?? 0,
        orderTrends: trendsList,
        categoryDistribution: catMap,
      );
    }
    throw Exception('Failed to load dashboard stats');
  }

  Future<List<User>> getUsers() async {
    final response = await _client.get(_uri('/users'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List?;
      if (list == null) return [];
      return list.map((e) => UserModel.fromJson(e).toEntity()).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<List<Seller>> getSellers() async {
    final response = await _client.get(_uri('/sellers'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List?;
      if (list == null) return [];
      return list.map((e) => SellerModel.fromJson(e).toEntity()).toList();
    }
    throw Exception('Failed to load sellers');
  }

  Future<List<Product>> getProducts() async {
    final response = await _client.get(_uri('/products'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List?;
      if (list == null) return [];
      return list.map((e) => ProductModel.fromJson(e).toEntity()).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<List<Order>> getOrders() async {
    final response = await _client.get(_uri('/orders'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List?;
      if (list == null) return [];
      return list.map((e) => OrderModel.fromJson(e).toEntity()).toList();
    }
    throw Exception('Failed to load orders');
  }

  Future<List<VerificationRequest>> getVerificationRequests() async {
    // Note: Backend might not have a verifications endpoint yet. 
    // We filter sellers for pending verification on frontend as a fallback.
    try {
      final sellers = await getSellers();
      // Generate mock requests based on sellers
      return sellers
          .where((s) => !s.isVerified)
          .map((s) => VerificationRequest(
                id: 'verif_${s.id}',
                seller: s,
                owner: User(id: s.userId, name: 'Unknown', email: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), roles: []), // Mock owner
                businessType: 'Perorangan',
                idCardUrl: '',
                businessDocUrl: '',
                status: VerificationStatus.pending,
                submittedAt: s.createdAt,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<StoreCategory>> getCategories() async {
    try {
      final products = await getProducts();
      final Map<String, int> counts = {};
      for (final p in products) {
        counts[p.category] = (counts[p.category] ?? 0) + 1;
      }
      
      return counts.entries.map((e) => StoreCategory(
        id: 'cat_${e.key}',
        name: e.key,
        icon: '📦',
        description: 'Kategori ${e.key}',
        productCount: e.value,
        createdAt: DateTime.now(),
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    final response = await _client.get(_uri('/users/$id'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return UserModel.fromJson(body['data']).toEntity();
    }
    return null;
  }

  Future<Seller?> getSellerById(String id) async {
    final response = await _client.get(_uri('/sellers/$id'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return SellerModel.fromJson(body['data']).toEntity();
    }
    return null;
  }

  Future<Order?> getOrderById(String id) async {
    final response = await _client.get(_uri('/orders/$id'), headers: _headers);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return OrderModel.fromJson(body['data']).toEntity();
    }
    return null;
  }

  Future<VerificationRequest?> getVerificationRequestById(String id) async {
    try {
      final requests = await getVerificationRequests();
      return requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
