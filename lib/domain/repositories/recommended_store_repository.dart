import '../entities/index.dart';

/// Abstract repository for location-based store recommendations
abstract class RecommendedStoreRepository {
  /// Get nearby stores within specified radius
  /// [userLocation] - buyer's current location
  /// [radiusKm] - search radius in kilometers
  /// [categoryFilter] - optional category filter
  Future<List<RecommendedStore>> getNearbyStores({
    required Location userLocation,
    required double radiusKm,
    String? categoryFilter,
  });

  /// Search stores by category
  Future<List<RecommendedStore>> searchStoresByCategory({
    required String category,
    Location? userLocation,
    int limit = 20,
  });

  /// Get recommended stores for user (personalized)
  Future<List<RecommendedStore>> getRecommendedStores({
    required String userId,
    Location? userLocation,
    int limit = 10,
  });

  /// Cache recommendations for offline use
  Future<void> cacheRecommendations(List<RecommendedStore> stores);

  /// Get cached recommendations
  Future<List<RecommendedStore>> getCachedRecommendations({
    String? categoryFilter,
  });

  /// Check if cached recommendations are fresh
  Future<bool> areCachesFresh();

  /// Clear old cached recommendations
  Future<void> clearOldCache();

  /// Save a single recommended store
  Future<void> saveRecommendedStore(RecommendedStore store);

  /// Delete a recommended store from cache
  Future<void> deleteRecommendedStore(String storeId);

  /// Sync recommendations from server
  Future<List<RecommendedStore>> syncRecommendationsFromServer({
    required Location userLocation,
  });
}
