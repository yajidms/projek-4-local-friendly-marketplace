import '../entities/index.dart';
import '../repositories/recommended_store_repository.dart';

/// Use case for getting recommended stores personalized for a user
class GetRecommendedStoresUseCase {
  final RecommendedStoreRepository repository;

  GetRecommendedStoresUseCase({required this.repository});

  /// Get personalized recommended stores for user
  ///
  /// [userId] - ID of the buyer
  /// [userLocation] - optional buyer's current location (for distance sorting)
  /// [limit] - maximum number of recommendations (default 10)
  ///
  /// Returns personalized list of recommended stores based on:
  /// - User's purchase history
  /// - Favorite categories
  /// - Distance from user
  /// - Store ratings and reviews
  Future<List<RecommendedStore>> call({
    required String userId,
    Location? userLocation,
    int limit = 10,
  }) async {
    try {
      return await repository.getRecommendedStores(
        userId: userId,
        userLocation: userLocation,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to get recommended stores: $e');
    }
  }
}
