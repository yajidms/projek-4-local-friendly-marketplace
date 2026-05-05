import '../entities/index.dart';
import '../repositories/seller_repository.dart';
import '../repositories/location_repository.dart';

/// Use case for updating seller's GPS location
class UpdateSellerLocationUseCase {
  final SellerRepository sellerRepository;
  final LocationRepository locationRepository;

  UpdateSellerLocationUseCase({
    required this.sellerRepository,
    required this.locationRepository,
  });

  /// Update seller's location
  ///
  /// [sellerId] - ID of the seller
  /// [location] - new GPS location
  ///
  /// Updates seller location and tracks location history
  Future<void> call({
    required String sellerId,
    required Location location,
  }) async {
    try {
      // Update seller location in repository
      await sellerRepository.updateSellerLocation(sellerId, location);

      // Track location in location history
      await locationRepository.trackSellerLocation(sellerId, location);
    } catch (e) {
      throw Exception('Failed to update seller location: $e');
    }
  }

  /// Start real-time location tracking for seller
  ///
  /// Continuously updates seller location while app is active
  Future<void> startTracking({
    required String sellerId,
  }) async {
    try {
      await locationRepository.startLocationUpdates(
        onLocationUpdate: (location) async {
          await call(sellerId: sellerId, location: location);
        },
        distanceFilter: 100, // Update every 100 meters
      );
    } catch (e) {
      throw Exception('Failed to start location tracking: $e');
    }
  }

  /// Stop real-time location tracking
  Future<void> stopTracking() async {
    try {
      await locationRepository.stopLocationUpdates();
    } catch (e) {
      throw Exception('Failed to stop location tracking: $e');
    }
  }
}
