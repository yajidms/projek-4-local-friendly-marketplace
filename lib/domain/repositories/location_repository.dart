import '../entities/index.dart';

/// Abstract repository for Location operations
abstract class LocationRepository {
  /// Get user's current location
  Future<Location> getCurrentLocation();

  /// Request location permission
  Future<bool> requestLocationPermission();

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted();

  /// Get cached user location
  Future<Location?> getCachedLocation();

  /// Save user location to cache
  Future<void> cacheLocation(Location location);

  /// Get location from address
  Future<Location?> getLocationFromAddress(String address);

  /// Get address from location coordinates
  Future<String?> getAddressFromLocation(Location location);

  /// Calculate distance between two locations
  double calculateDistance(Location from, Location to);

  /// Track seller location updates
  Future<void> trackSellerLocation(String sellerId, Location location);

  /// Get seller location history
  Future<List<Location>> getSellerLocationHistory(String sellerId);

  /// Start location updates (real-time tracking)
  Future<void> startLocationUpdates({
    required Function(Location) onLocationUpdate,
    double? distanceFilter,
  });

  /// Stop location updates
  Future<void> stopLocationUpdates();
}
