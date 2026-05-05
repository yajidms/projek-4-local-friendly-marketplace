import '../entities/index.dart';
import '../repositories/recommended_store_repository.dart';
import '../repositories/location_repository.dart';

/// Use case for syncing store recommendations with the server
class SyncRecommendationsUseCase {
  final RecommendedStoreRepository recommendedStoreRepository;
  final LocationRepository locationRepository;

  SyncRecommendationsUseCase({
    required this.recommendedStoreRepository,
    required this.locationRepository,
  });

  /// Sync recommendations from server
  ///
  /// Gets user's current location and fetches latest recommendations
  /// from the server, then caches them locally for offline use.
  ///
  /// Returns list of synced recommendations
  Future<List<RecommendedStore>> call() async {
    try {
      // Get user's current location
      final userLocation = await locationRepository.getCurrentLocation();

      // Sync recommendations from server
      final recommendations =
          await recommendedStoreRepository.syncRecommendationsFromServer(
        userLocation: userLocation,
      );

      // Cache recommendations locally for offline use
      if (recommendations.isNotEmpty) {
        await recommendedStoreRepository.cacheRecommendations(recommendations);
      }

      // Update last synced location
      await locationRepository.cacheLocation(userLocation);

      return recommendations;
    } catch (e) {
      throw Exception('Failed to sync recommendations: $e');
    }
  }

  /// Refresh cache if needed (check if cache is stale)
  Future<List<RecommendedStore>> refreshIfNeeded() async {
    try {
      final isCacheFresh = await recommendedStoreRepository.areCachesFresh();

      if (!isCacheFresh) {
        return await call();
      }

      // Return cached recommendations if fresh
      return await recommendedStoreRepository.getCachedRecommendations();
    } catch (e) {
      throw Exception('Failed to refresh recommendations: $e');
    }
  }
}
