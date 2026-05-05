import '../../models/recommended_store_model.dart';
import '../../models/location_model.dart';

/// Abstract remote data source for RecommendedStore operations (API calls)
abstract class RecommendedStoreRemoteDataSource {
  /// Get nearby stores
  Future<List<RecommendedStoreModel>> getNearbyStores({
    required LocationModel userLocation,
    required double radiusKm,
    String? categoryFilter,
  });

  /// Search stores by category
  Future<List<RecommendedStoreModel>> searchStoresByCategory({
    required String category,
    LocationModel? userLocation,
    int limit = 20,
  });

  /// Get recommended stores for user (personalized)
  Future<List<RecommendedStoreModel>> getRecommendedStores({
    required String userId,
    LocationModel? userLocation,
    int limit = 10,
  });

  /// Get trending stores
  Future<List<RecommendedStoreModel>> getTrendingStores({
    LocationModel? userLocation,
  });

  /// Get top rated stores
  Future<List<RecommendedStoreModel>> getTopRatedStores({
    LocationModel? userLocation,
    int limit = 10,
  });
}
