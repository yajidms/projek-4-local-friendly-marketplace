import '../../models/seller_model.dart';

/// Abstract local data source for Seller operations
abstract class SellerLocalDataSource {
  /// Get seller by ID
  Future<SellerModel?> getSellerById(String id);

  /// Get seller by user ID
  Future<SellerModel?> getSellerByUserId(String userId);

  /// Get all sellers
  Future<List<SellerModel>> getAllSellers();

  /// Get sellers by category
  Future<List<SellerModel>> getSellersByCategory(String category);

  /// Save seller to local storage
  Future<void> saveSeller(SellerModel seller);

  /// Save multiple sellers
  Future<void> saveSellers(List<SellerModel> sellers);

  /// Update seller
  Future<void> updateSeller(SellerModel seller);

  /// Delete seller
  Future<void> deleteSeller(String id);

  /// Get unsynced sellers
  Future<List<SellerModel>> getUnSyncedSellers();

  /// Clear all sellers
  Future<void> clearAll();
}
