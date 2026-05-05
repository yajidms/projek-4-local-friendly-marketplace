import '../entities/index.dart';
import '../repositories/recommended_store_repository.dart';

/// Use case for getting cached recommendations for offline use
class GetCachedRecommendationsUseCase {
  final RecommendedStoreRepository repository;

  GetCachedRecommendationsUseCase({required this.repository});

  /// Get cached recommendations for offline use
  ///
  /// [categoryFilter] - optional category to filter recommendations
  ///
  /// Returns cached recommendations without needing network connection
  Future<List<RecommendedStore>> call({String? categoryFilter}) async {
    try {
      final cached = await repository.getCachedRecommendations(
        categoryFilter: categoryFilter,
      );

      if (cached.isEmpty) {
        throw Exception('No cached recommendations available');
      }

      return cached;
    } catch (e) {
      throw Exception('Failed to get cached recommendations: $e');
    }
  }

  /// Check if cache is fresh (within 24 hours)
  Future<bool> isCacheFresh() async {
    try {
      return await repository.areCachesFresh();
    } catch (e) {
      return false;
    }
  }

  /// Clear old cached data
  Future<void> clearOldCache() async {
    try {
      await repository.clearOldCache();
    } catch (e) {
      throw Exception('Failed to clear old cache: $e');
    }
  }
}
