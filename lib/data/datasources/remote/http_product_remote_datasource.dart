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

  /// Header wajib untuk bypass ngrok interstitial page.
  Map<String, String> get _headers => {
        ..._token.authHeaders,
        'ngrok-skip-browser-warning': 'true',
      };

  Map<String, dynamic> _readBody(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }

  List<ProductModel> _parseList(Map<String, dynamic> body) {
    // Support both {data: [...]} and direct [...]
    final data = body['data'] ?? body;
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  ProductModel _parseSingle(Map<String, dynamic> body) {
    final data = body['data'] ?? body;
    if (data is Map<String, dynamic>) {
      return ProductModel.fromJson(data);
    }
    throw Exception('Unexpected response format');
  }

  /// Buat payload JSON yang hanya berisi field yang dikenali backend.
  /// Field internal (isSynced, isLocalOnly, lastSyncedAt) TIDAK dikirim.
  Map<String, dynamic> _productPayload(ProductModel p) {
    return {
      'sellerId': p.sellerId,
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'quantity': p.quantity,
      'category': p.category,
      if (p.images != null && p.images!.isNotEmpty) 'images': p.images,
      if (p.sku != null) 'sku': p.sku,
      if (p.weight != null) 'weight': p.weight,
      if (p.unit != null) 'unit': p.unit,
      'isAvailable': p.isAvailable,
    };
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final response = await _client.get(
      _token.uri('/products'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(_readBody(response));
    }
    throw Exception('Failed to get products: ${response.statusCode} ${response.body}');
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await _client.get(
      _token.uri('/products/$id'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to get product: ${response.statusCode}');
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    // Backend tidak memiliki endpoint filter sellerId — ambil semua lalu filter.
    // Jika volume besar, pertimbangkan endpoint dedicated di backend.
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
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client.post(
      _token.uri('/products'),
      headers: _headers,
      body: jsonEncode(_productPayload(product)),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    final errorBody = response.body.isNotEmpty ? response.body : '(empty)';
    throw Exception('Failed to create product: ${response.statusCode} — $errorBody');
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final payload = {
      ..._productPayload(product),
      // ID tidak ada di payload body umumnya, tapi beberapa backend membutuhkannya
    };
    final response = await _client.put(
      _token.uri('/products/${product.id}'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    final errorBody = response.body.isNotEmpty ? response.body : '(empty)';
    throw Exception('Failed to update product: ${response.statusCode} — $errorBody');
  }

  @override
  Future<void> updateProductQuantity(String productId, int quantity) async {
    // Ambil produk dari cache dulu, lalu kirim PUT dengan payload lengkap +
    // quantity baru. Jika gagal ambil, kirim minimal payload.
    final response = await _client.put(
      _token.uri('/products/$productId'),
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    // Jika partial update tidak didukung, log tapi jangan throw
    // agar inventory view tetap berjalan dengan data lokal.
    throw Exception(
        'Failed to update quantity: ${response.statusCode} ${response.body}');
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final response = await _client.delete(
      _token.uri('/products/$productId'),
      headers: _headers,
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
