import '../entities/index.dart';
import '../repositories/recommended_store_repository.dart';

/// Use case for getting nearby stores based on user's GPS location
class GetNearbyStoresUseCase {
  final RecommendedStoreRepository repository;

  GetNearbyStoresUseCase({required this.repository});

  /// Get nearby stores within specified radius
  ///
  /// [userLocation] - buyer's current GPS location
  /// [radiusKm] - search radius in kilometers (default 5km)
  /// [categoryFilter] - optional product category filter
  ///
  /// Returns list of recommended stores sorted by distance
  Future<List<RecommendedStore>> call({
    required Location userLocation,
    double radiusKm = 5.0,
    String? categoryFilter,
  }) async {
    try {
      return await repository.getNearbyStores(
        userLocation: userLocation,
        radiusKm: radiusKm,
        categoryFilter: categoryFilter,
      );
    } catch (e) {
      throw Exception('Failed to get nearby stores: $e');
    }
  }
}
