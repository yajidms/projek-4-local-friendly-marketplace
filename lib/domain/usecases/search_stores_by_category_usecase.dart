import '../entities/index.dart';
import '../repositories/recommended_store_repository.dart';

/// Use case for searching stores by product category
class SearchStoresByCategoryUseCase {
  final RecommendedStoreRepository repository;

  SearchStoresByCategoryUseCase({required this.repository});

  /// Search for stores by category
  ///
  /// [category] - product category to search (e.g., "Electronics", "Food")
  /// [userLocation] - optional user location for distance sorting
  /// [limit] - maximum number of results (default 20)
  ///
  /// Returns list of stores that sell products in the specified category
  Future<List<RecommendedStore>> call({
    required String category,
    Location? userLocation,
    int limit = 20,
  }) async {
    try {
      if (category.isEmpty) {
        throw Exception('Category cannot be empty');
      }

      return await repository.searchStoresByCategory(
        category: category,
        userLocation: userLocation,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to search stores by category: $e');
    }
  }
}
