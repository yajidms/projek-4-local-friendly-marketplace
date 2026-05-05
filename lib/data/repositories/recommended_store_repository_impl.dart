import '../../domain/entities/index.dart';
import '../../domain/repositories/recommended_store_repository.dart';
import '../datasources/local/recommended_store_local_datasource.dart';
import '../datasources/remote/recommended_store_remote_datasource.dart';
import '../models/recommended_store_model.dart';
import '../models/location_model.dart';

class RecommendedStoreRepositoryImpl extends RecommendedStoreRepository {
  final RecommendedStoreLocalDataSource localDataSource;
  final RecommendedStoreRemoteDataSource remoteDataSource;

  RecommendedStoreRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<RecommendedStore>> getNearbyStores({
    required Location userLocation,
    required double radiusKm,
    String? categoryFilter,
  }) async {
    try {
      final locationModel = LocationModel.fromEntity(userLocation);
      final remoteStores = await remoteDataSource.getNearbyStores(
        userLocation: locationModel,
        radiusKm: radiusKm,
        categoryFilter: categoryFilter,
      );
      // Cache results
      await localDataSource.cacheRecommendations(remoteStores,);
      return remoteStores.map((s) => s.toEntity()).toList();
    } catch (e) {
      // Fallback to cached results
      if (categoryFilter != null) {
        final cached = await localDataSource
            .getCachedRecommendationsByCategory(categoryFilter);
        return cached.map((s) => s.toEntity()).toList();
      }
      final cached = await localDataSource.getCachedRecommendations();
      return cached.map((s) => s.toEntity()).toList();
    }
  }

  @override
  Future<List<RecommendedStore>> searchStoresByCategory({
    required String category,
    Location? userLocation,
    int limit = 20,
  }) async {
    try {
      final locationModel =
          userLocation != null ? LocationModel.fromEntity(userLocation) : null;
      final remoteStores = await remoteDataSource.searchStoresByCategory(
        category: category,
        userLocation: locationModel,
        limit: limit,
      );
      await localDataSource.cacheRecommendations(remoteStores);
      return remoteStores.map((s) => s.toEntity()).toList();
    } catch (e) {
      final cached =
          await localDataSource.getCachedRecommendationsByCategory(category);
      return cached.map((s) => s.toEntity()).toList();
    }
  }

  @override
  Future<List<RecommendedStore>> getRecommendedStores({
    required String userId,
    Location? userLocation,
    int limit = 10,
  }) async {
    try {
      final locationModel =
          userLocation != null ? LocationModel.fromEntity(userLocation) : null;
      final remoteStores = await remoteDataSource.getRecommendedStores(
        userId: userId,
        userLocation: locationModel,
        limit: limit,
      );
      await localDataSource.cacheRecommendations(remoteStores);
      return remoteStores.map((s) => s.toEntity()).toList();
    } catch (e) {
      final cached = await localDataSource.getCachedRecommendations();
      return cached.map((s) => s.toEntity()).toList();
    }
  }

  @override
  Future<void> cacheRecommendations(List<RecommendedStore> stores) async {
    final models =
        stores.map((s) => RecommendedStoreModel.fromEntity(s)).toList();
    await localDataSource.cacheRecommendations(models);
  }

  @override
  Future<List<RecommendedStore>> getCachedRecommendations({
    String? categoryFilter,
  }) async {
    if (categoryFilter != null) {
      final cached = await localDataSource
          .getCachedRecommendationsByCategory(categoryFilter);
      return cached.map((s) => s.toEntity()).toList();
    }
    final cached = await localDataSource.getCachedRecommendations();
    return cached.map((s) => s.toEntity()).toList();
  }

  @override
  Future<bool> areCachesFresh() async {
    try {
      final cacheTime = await localDataSource.getCacheUpdateTime();
      if (cacheTime == null) return false;
      final now = DateTime.now();
      final difference = now.difference(cacheTime).inHours;
      return difference < 24;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearOldCache() async {
    await localDataSource.clearOldCache(24); // Clear cache older than 24 hours
  }

  @override
  Future<void> saveRecommendedStore(RecommendedStore store) async {
    final model = RecommendedStoreModel.fromEntity(store);
    await localDataSource.saveRecommendedStore(model);
  }

  @override
  Future<void> deleteRecommendedStore(String storeId) async {
    await localDataSource.deleteRecommendedStore(storeId);
  }

  @override
  Future<List<RecommendedStore>> syncRecommendationsFromServer({
    required Location userLocation,
  }) async {
    try {
      final locationModel = LocationModel.fromEntity(userLocation);
      // Fetch nearby stores as default recommendations
      final remoteStores = await remoteDataSource.getNearbyStores(
        userLocation: locationModel,
        radiusKm: 10.0,
      );
      // Cache them
      final models = remoteStores;
      await localDataSource.cacheRecommendations(models);
      await localDataSource.updateCacheTimestamp();
      return remoteStores.map((s) => s.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to sync recommendations: $e');
    }
  }
}
