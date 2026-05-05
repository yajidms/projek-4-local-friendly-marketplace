import '../../models/seller_model.dart';
import '../../models/location_model.dart';

/// Abstract remote data source for Seller operations (API calls)
abstract class SellerRemoteDataSource {
  /// Get seller by ID from server
  Future<SellerModel> getSellerById(String id);

  /// Get seller by user ID
  Future<SellerModel?> getSellerByUserId(String userId);

  /// Get all sellers
  Future<List<SellerModel>> getAllSellers();

  /// Get sellers by category
  Future<List<SellerModel>> getSellersByCategory(String category);

  /// Create seller
  Future<SellerModel> createSeller(SellerModel seller);

  /// Update seller
  Future<SellerModel> updateSeller(SellerModel seller);

  /// Update seller location
  Future<void> updateSellerLocation(String sellerId, LocationModel location);

  /// Update seller online status
  Future<void> updateSellerOnlineStatus(String sellerId, bool isOnline);

  /// Delete seller
  Future<void> deleteSeller(String sellerId);

  /// Sync sellers (batch update)
  Future<void> syncSellers(List<SellerModel> sellers);
}
