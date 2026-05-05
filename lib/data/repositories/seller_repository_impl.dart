import '../../domain/entities/index.dart';
import '../../domain/repositories/seller_repository.dart';
import '../datasources/local/seller_local_datasource.dart';
import '../datasources/remote/seller_remote_datasource.dart';
import '../models/seller_model.dart';
import '../models/location_model.dart';

class SellerRepositoryImpl extends SellerRepository {
  final SellerLocalDataSource localDataSource;
  final SellerRemoteDataSource remoteDataSource;

  SellerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Seller?> getSellerById(String sellerId) async {
    try {
      // Try remote first
      final remoteSeller = await remoteDataSource.getSellerById(sellerId);
      // Cache locally
      await localDataSource.saveSeller(remoteSeller);
      return remoteSeller.toEntity();
    } catch (e) {
      // Fallback to local
      final cachedSeller = await localDataSource.getSellerById(sellerId);
      return cachedSeller?.toEntity();
    }
  }

  @override
  Future<List<Seller>> getAllSellers() async {
    try {
      // Fetch from remote
      final remoteSellers = await remoteDataSource.getAllSellers();
      // Cache all locally
      await localDataSource.saveSellers(remoteSellers);
      return remoteSellers.map((s) => s.toEntity()).toList();
    } catch (e) {
      // Fallback to cached
      final cachedSellers = await localDataSource.getAllSellers();
      return cachedSellers.map((s) => s.toEntity()).toList();
    }
  }

  @override
  Future<Seller?> getSellerByUserId(String userId) async {
    try {
      final remoteSeller = await remoteDataSource.getSellerByUserId(userId);
      if (remoteSeller != null) {
        await localDataSource.saveSeller(remoteSeller);
      }
      return remoteSeller?.toEntity();
    } catch (e) {
      final cachedSeller = await localDataSource.getSellerByUserId(userId);
      return cachedSeller?.toEntity();
    }
  }

  @override
  Future<Seller> createSeller(Seller seller) async {
    final sellerModel = SellerModel.fromEntity(seller);
    // Save locally first
    await localDataSource.saveSeller(sellerModel);
    // Sync with remote
    final remoteSeller = await remoteDataSource.createSeller(sellerModel);
    return remoteSeller.toEntity();
  }

  @override
  Future<Seller> updateSeller(Seller seller) async {
    final sellerModel = SellerModel.fromEntity(seller);
    // Update locally
    await localDataSource.updateSeller(sellerModel);
    // Sync with remote
    final remoteSeller = await remoteDataSource.updateSeller(sellerModel);
    return remoteSeller.toEntity();
  }

  @override
  Future<void> updateSellerLocation(String sellerId, Location location) async {
    try {
      final locationModel = LocationModel.fromEntity(location);
      // Update on remote
      await remoteDataSource.updateSellerLocation(sellerId, locationModel);
      // Update locally
      final seller = await localDataSource.getSellerById(sellerId);
      if (seller != null) {
        final updated = seller.copyWith(location: locationModel);
        await localDataSource.updateSeller(updated);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> updateSellerOnlineStatus(String sellerId, bool isOnline) async {
    try {
      // Update on remote
      await remoteDataSource.updateSellerOnlineStatus(sellerId, isOnline);
      // Update locally
      final seller = await localDataSource.getSellerById(sellerId);
      if (seller != null) {
        final updated = seller.copyWith(isOnline: isOnline);
        await localDataSource.updateSeller(updated);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<List<Seller>> getSellersByCategory(String category) async {
    try {
      final remoteSellers =
          await remoteDataSource.getSellersByCategory(category);
      // Cache locally
      await localDataSource.saveSellers(remoteSellers);
      return remoteSellers.map((s) => s.toEntity()).toList();
    } catch (e) {
      final cachedSellers =
          await localDataSource.getSellersByCategory(category);
      return cachedSellers.map((s) => s.toEntity()).toList();
    }
  }

  @override
  Future<void> deleteSeller(String sellerId) async {
    try {
      // Delete from remote
      await remoteDataSource.deleteSeller(sellerId);
      // Delete from local
      await localDataSource.deleteSeller(sellerId);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> syncUnSyncedSellers() async {
    try {
      // Get unsynced sellers from local
      final unsyncedSellers = await localDataSource.getUnSyncedSellers();
      if (unsyncedSellers.isNotEmpty) {
        // Sync with remote
        await remoteDataSource.syncSellers(unsyncedSellers);
        // Mark as synced
        for (var seller in unsyncedSellers) {
          final synced = seller.copyWith(isSynced: true);
          await localDataSource.updateSeller(synced);
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
