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

  /// Header wajib untuk bypass ngrok interstitial page.
  Map<String, String> get _headers => {
        ..._token.authHeaders,
        'ngrok-skip-browser-warning': 'true',
      };

  List<OrderModel> _parseList(dynamic body) {
    // Support {data: [...]} and flat [...]
    final raw = (body is Map) ? (body['data'] ?? body) : body;
    final list = raw is List ? raw : (raw is Map ? (raw['orders'] ?? []) : []);
    return (list as List)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  OrderModel _parseSingle(dynamic body) {
    final data = (body is Map) ? (body['data'] ?? body) : body;
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    final response = await _client.get(
      _token.uri('/orders/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch order: ${response.statusCode}');
  }

  @override
  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final response = await _client.get(
      _token.uri('/orders/user/$userId'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch orders: ${response.statusCode}');
  }

  @override
  Future<List<OrderModel>> getOrdersBySellerId(String sellerId) async {
    // Endpoint: GET /orders/seller/{sellerId}
    final response = await _client.get(
      _token.uri('/orders/seller/$sellerId'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(jsonDecode(response.body));
    }
    throw Exception(
        'Failed to fetch seller orders: ${response.statusCode} ${response.body}');
  }

  @override
  Future<List<OrderModel>> getOrdersByBuyer(String userId) async {
    final response = await _client.get(
      _token.uri('/orders/user/$userId'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch buyer orders: ${response.statusCode}');
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final response = await _client.post(
      _token.uri('/orders'),
      headers: _headers,
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(jsonDecode(response.body));
    }
    final errorBody = response.body.isNotEmpty ? response.body : '(empty)';
    throw Exception(
        'Failed to create order: ${response.statusCode} — $errorBody');
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    // Endpoint: PATCH /orders/{orderId}/status
    final response = await _client.patch(
      _token.uri('/orders/$orderId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(jsonDecode(response.body));
    }
    throw Exception(
        'Failed to update order status: ${response.statusCode} ${response.body}');
  }
}
