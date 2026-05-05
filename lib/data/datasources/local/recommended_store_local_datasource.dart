import '../../models/recommended_store_model.dart';

/// Abstract local data source for RecommendedStore operations
abstract class RecommendedStoreLocalDataSource {
  /// Get cached recommendations
  Future<List<RecommendedStoreModel>> getCachedRecommendations();

  /// Get recommendations by category
  Future<List<RecommendedStoreModel>> getCachedRecommendationsByCategory(
    String category,
  );

  /// Save recommendations to cache
  Future<void> cacheRecommendations(List<RecommendedStoreModel> stores);

  /// Save single recommendation
  Future<void> saveRecommendedStore(RecommendedStoreModel store);

  /// Delete recommendation from cache
  Future<void> deleteRecommendedStore(String storeId);

  /// Get cache update time (last synced)
  Future<DateTime?> getCacheUpdateTime();

  /// Update cache timestamp
  Future<void> updateCacheTimestamp();

  /// Clear old cache (older than X hours)
  Future<void> clearOldCache(int hoursOld);

  /// Clear all recommendations
  Future<void> clearAll();
}
