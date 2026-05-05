import '../entities/index.dart';

/// Abstract repository for Seller-related operations
abstract class SellerRepository {
  /// Get seller by ID
  Future<Seller?> getSellerById(String sellerId);

  /// Get all sellers (for sync/offline cache)
  Future<List<Seller>> getAllSellers();

  /// Get seller by user ID
  Future<Seller?> getSellerByUserId(String userId);

  /// Create new seller
  Future<Seller> createSeller(Seller seller);

  /// Update seller information
  Future<Seller> updateSeller(Seller seller);

  /// Update seller location (GPS coordinates)
  Future<void> updateSellerLocation(String sellerId, Location location);

  /// Update seller online status
  Future<void> updateSellerOnlineStatus(String sellerId, bool isOnline);

  /// Get sellers by category
  Future<List<Seller>> getSellersByCategory(String category);

  /// Delete seller
  Future<void> deleteSeller(String sellerId);

  /// Sync unsynced sellers with server
  Future<void> syncUnSyncedSellers();
}
