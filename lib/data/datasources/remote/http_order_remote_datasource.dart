import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/order_model.dart';
import '../../services/token_manager.dart';
import 'order_remote_datasource.dart';

class HttpOrderRemoteDataSource implements OrderRemoteDataSource {
  final http.Client _client;
  final _token = TokenManager.instance;

  HttpOrderRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<OrderModel> getOrderById(String id) async {
    final response = await _client.get(
      _token.uri('/orders/$id'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body is Map ? (body['data'] ?? body) : body;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch order: ${response.statusCode}');
  }

  @override
  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final response = await _client.get(
      _token.uri('/orders/user/$userId'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body is Map ? (body['data'] ?? body) : body;
      final list = data is List ? data : (data['orders'] ?? []);
      return (list as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch orders: ${response.statusCode}');
  }

  @override
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId) async {
    final response = await _client.get(
      _token.uri('/orders/seller/$sellerId'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body is Map ? (body['data'] ?? body) : body;
      final list = data is List ? data : (data['orders'] ?? []);
      return (list as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch orders: ${response.statusCode}');
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final response = await _client.post(
      _token.uri('/orders'),
      headers: _token.authHeaders,
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body is Map ? (body['data'] ?? body) : body;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to create order: ${response.statusCode}');
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await _client.patch(
      _token.uri('/orders/$orderId/status'),
      headers: _token.authHeaders,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = body is Map ? (body['data'] ?? body) : body;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Failed to update order status: ${response.statusCode}');
  }
}
