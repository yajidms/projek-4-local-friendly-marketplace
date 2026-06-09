import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../../models/location_model.dart';
import '../../models/recommended_store_model.dart';
import '../../models/seller_model.dart';
import '../../services/token_manager.dart';
import 'recommended_store_remote_datasource.dart';

class HttpRecommendedStoreRemoteDataSource
    implements RecommendedStoreRemoteDataSource {
  HttpRecommendedStoreRemoteDataSource({http.Client? client})
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

  List<SellerModel> _parseSellerList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  RecommendedStoreModel _sellerToRecommendedStore(
    SellerModel seller,
    LocationModel userLocation,
  ) {
    final loc = seller.location ??
        LocationModel(latitude: 0, longitude: 0);
    final distance = _haversine(
      userLocation.latitude,
      userLocation.longitude,
      loc.latitude,
      loc.longitude,
    );
    return RecommendedStoreModel(
      id: seller.id,
      sellerId: seller.userId,
      shopName: seller.shopName,
      shopImageUrl: seller.shopImageUrl,
      distance: distance,
      rating: seller.rating,
      totalReviews: seller.totalReviews,
      location: loc,
      categories: seller.categories,
      isOnline: seller.isOnline,
      availableProducts: seller.totalProducts,
      recommendedAt: DateTime.now(),
      cachedAt: DateTime.now(),
      isCached: false,
    );
  }

  double _haversine(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = _sinSquared(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * _sinSquared(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRadians(double deg) => deg * math.pi / 180;
  double _sinSquared(double x) {
    final s = math.sin(x);
    return s * s;
  }

  @override
  Future<List<RecommendedStoreModel>> getNearbyStores({
    required LocationModel userLocation,
    required double radiusKm,
    String? categoryFilter,
  }) async {
    final response = await _client.get(
      _token.uri(
        '/sellers/nearest'
        '?lat=${userLocation.latitude}'
        '&lon=${userLocation.longitude}'
        '&limit=50',
      ),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final sellers = _parseSellerList(_readBody(response));
      var stores = sellers
          .map((s) => _sellerToRecommendedStore(s, userLocation))
          .where((s) => s.distance <= radiusKm)
          .toList();
      if (categoryFilter != null) {
        stores = stores
            .where((s) =>
                s.categories.any((c) =>
                    c.toLowerCase().contains(categoryFilter.toLowerCase())))
            .toList();
      }
      return stores;
    }
    throw Exception('Failed to get nearby stores: ${response.statusCode}');
  }

  @override
  Future<List<RecommendedStoreModel>> searchStoresByCategory({
    required String category,
    LocationModel? userLocation,
    int limit = 20,
  }) async {
    final all = userLocation != null
        ? await getNearbyStores(
            userLocation: userLocation,
            radiusKm: 50,
          )
        : await _getAllAsRecommendedStores();
    return all
        .where((s) =>
            s.categories.any((c) =>
                c.toLowerCase().contains(category.toLowerCase())))
        .take(limit)
        .toList();
  }

  @override
  Future<List<RecommendedStoreModel>> getRecommendedStores({
    required String userId,
    LocationModel? userLocation,
    int limit = 10,
  }) async {
    if (userLocation != null) {
      final nearby = await getNearbyStores(
        userLocation: userLocation,
        radiusKm: 10,
      );
      return nearby.take(limit).toList();
    }
    return (await _getAllAsRecommendedStores()).take(limit).toList();
  }

  @override
  Future<List<RecommendedStoreModel>> getTrendingStores({
    LocationModel? userLocation,
  }) async {
    return getRecommendedStores(
      userId: '',
      userLocation: userLocation,
      limit: 10,
    );
  }

  @override
  Future<List<RecommendedStoreModel>> getTopRatedStores({
    LocationModel? userLocation,
    int limit = 10,
  }) async {
    final all = userLocation != null
        ? await getNearbyStores(userLocation: userLocation, radiusKm: 50)
        : await _getAllAsRecommendedStores();
    all.sort((a, b) => b.rating.compareTo(a.rating));
    return all.take(limit).toList();
  }

  Future<List<RecommendedStoreModel>> _getAllAsRecommendedStores() async {
    final response = await _client.get(
      _token.uri('/sellers'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final sellers = _parseSellerList(_readBody(response));
      return sellers
          .map((s) => _sellerToRecommendedStore(
                s,
                LocationModel(latitude: 0, longitude: 0),
              ))
          .toList();
    }
    throw Exception('Failed to get sellers: ${response.statusCode}');
  }
}
