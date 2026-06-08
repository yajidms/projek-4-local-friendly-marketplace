import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/product_model.dart';
import '../../services/token_manager.dart';
import 'product_remote_datasource.dart';

class HttpProductRemoteDataSource implements ProductRemoteDataSource {
  HttpProductRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final _token = TokenManager.instance;

  Map<String, dynamic> _readBody(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }

  List<ProductModel> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  ProductModel _parseSingle(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return ProductModel.fromJson(data);
    }
    throw Exception('Unexpected response format');
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final response = await _client.get(
      _token.uri('/products'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(_readBody(response));
    }
    throw Exception('Failed to get products: ${response.statusCode}');
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await _client.get(
      _token.uri('/products/$id'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to get product: ${response.statusCode}');
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final all = await getAllProducts();
    return all.where((p) => p.sellerId == sellerId).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final all = await getAllProducts();
    return all.where((p) => p.category == category).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _client.get(
      _token.uri('/products/search?query=${Uri.encodeQueryComponent(query)}'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(_readBody(response));
    }
    throw Exception('Failed to search products: ${response.statusCode}');
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client.post(
      _token.uri('/products'),
      headers: _token.authHeaders,
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to create product: ${response.statusCode}');
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _client.put(
      _token.uri('/products/${product.id}'),
      headers: _token.authHeaders,
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to update product: ${response.statusCode}');
  }

  @override
  Future<void> updateProductQuantity(String productId, int quantity) async {
    final response = await _client.put(
      _token.uri('/products/$productId'),
      headers: _token.authHeaders,
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Failed to update quantity: ${response.statusCode}');
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final response = await _client.delete(
      _token.uri('/products/$productId'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Failed to delete product: ${response.statusCode}');
  }

  @override
  Future<void> syncProducts(List<ProductModel> products) async {
    for (final product in products) {
      if (product.isLocalOnly) {
        await createProduct(product);
      } else {
        await updateProduct(product);
      }
    }
  }

  @override
  Future<void> deleteProducts(List<String> productIds) async {
    for (final id in productIds) {
      await deleteProduct(id);
    }
  }
}
