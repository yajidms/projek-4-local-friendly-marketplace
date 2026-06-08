import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/location_model.dart';
import '../../models/seller_model.dart';
import '../../services/token_manager.dart';
import 'seller_remote_datasource.dart';

class HttpSellerRemoteDataSource implements SellerRemoteDataSource {
  HttpSellerRemoteDataSource({http.Client? client})
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

  List<SellerModel> _parseList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  SellerModel _parseSingle(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return SellerModel.fromJson(data);
    }
    throw Exception('Unexpected response format');
  }

  @override
  Future<List<SellerModel>> getAllSellers() async {
    final response = await _client.get(
      _token.uri('/sellers'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseList(_readBody(response));
    }
    throw Exception('Failed to get sellers: ${response.statusCode}');
  }

  @override
  Future<SellerModel> getSellerById(String id) async {
    final response = await _client.get(
      _token.uri('/sellers/$id'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to get seller: ${response.statusCode}');
  }

  @override
  Future<SellerModel?> getSellerByUserId(String userId) async {
    final all = await getAllSellers();
    try {
      return all.firstWhere((s) => s.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SellerModel>> getSellersByCategory(String category) async {
    final all = await getAllSellers();
    return all.where((s) => s.categories.contains(category)).toList();
  }

  @override
  Future<SellerModel> createSeller(SellerModel seller) async {
    final response = await _client.post(
      _token.uri('/sellers'),
      headers: _token.authHeaders,
      body: jsonEncode(seller.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to create seller: ${response.statusCode}');
  }

  @override
  Future<SellerModel> updateSeller(SellerModel seller) async {
    final response = await _client.put(
      _token.uri('/sellers/${seller.id}'),
      headers: _token.authHeaders,
      body: jsonEncode(seller.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseSingle(_readBody(response));
    }
    throw Exception('Failed to update seller: ${response.statusCode}');
  }

  @override
  Future<void> updateSellerLocation(
      String sellerId, LocationModel location) async {
    final response = await _client.put(
      _token.uri('/sellers/$sellerId'),
      headers: _token.authHeaders,
      body: jsonEncode(location.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Failed to update location: ${response.statusCode}');
  }

  @override
  Future<void> updateSellerOnlineStatus(
      String sellerId, bool isOnline) async {
    final response = await _client.put(
      _token.uri('/sellers/$sellerId'),
      headers: _token.authHeaders,
      body: jsonEncode({'isOnline': isOnline}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Failed to update online status: ${response.statusCode}');
  }

  @override
  Future<void> deleteSeller(String sellerId) async {
    final response = await _client.delete(
      _token.uri('/sellers/$sellerId'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Failed to delete seller: ${response.statusCode}');
  }

  @override
  Future<void> syncSellers(List<SellerModel> sellers) async {
    for (final seller in sellers) {
      await updateSeller(seller);
    }
  }
}
