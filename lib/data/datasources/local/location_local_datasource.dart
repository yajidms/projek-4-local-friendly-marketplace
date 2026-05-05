import '../../models/location_model.dart';

/// Abstract local data source for Location operations
abstract class LocationLocalDataSource {
  /// Get cached user location
  Future<LocationModel?> getCachedLocation();

  /// Save user location to cache
  Future<void> cacheLocation(LocationModel location);

  /// Get seller location history
  Future<List<LocationModel>> getSellerLocationHistory(String sellerId);

  /// Save seller location to history
  Future<void> saveSellerLocation(String sellerId, LocationModel location);

  /// Clear old location history (older than X days)
  Future<void> clearOldLocationHistory(int daysOld);

  /// Clear all cached locations
  Future<void> clearAll();
}
