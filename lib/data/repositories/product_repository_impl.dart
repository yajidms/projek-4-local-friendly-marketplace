import '../../domain/entities/index.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      final remoteProduct = await remoteDataSource.getProductById(productId);
      await localDataSource.saveProduct(remoteProduct);
      return remoteProduct.toEntity();
    } catch (e) {
      final cachedProduct = await localDataSource.getProductById(productId);
      return cachedProduct?.toEntity();
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final remoteProducts =
          await remoteDataSource.getProductsBySeller(sellerId);
      await localDataSource.saveProducts(remoteProducts);
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      final cachedProducts =
          await localDataSource.getProductsBySeller(sellerId);
      return cachedProducts.map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final remoteProducts =
          await remoteDataSource.getProductsByCategory(category);
      await localDataSource.saveProducts(remoteProducts);
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      final cachedProducts =
          await localDataSource.getProductsByCategory(category);
      return cachedProducts.map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      return (await remoteDataSource.searchProducts(query))
          .map((p) => p.toEntity())
          .toList();
    } catch (e) {
      return (await localDataSource.searchProducts(query))
          .map((p) => p.toEntity())
          .toList();
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    await localDataSource.saveProduct(productModel);
    try {
      final remoteProduct = await remoteDataSource.createProduct(productModel);
      return remoteProduct.toEntity();
    } catch (e) {
      // Mark as local-only if sync fails
      final localOnly =
          productModel.copyWith(isLocalOnly: true, isSynced: false);
      await localDataSource.updateProduct(localOnly);
      return localOnly.toEntity();
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    await localDataSource.updateProduct(productModel);
    try {
      final remoteProduct = await remoteDataSource.updateProduct(productModel);
      return remoteProduct.toEntity();
    } catch (e) {
      final unsynced = productModel.copyWith(isSynced: false);
      await localDataSource.updateProduct(unsynced);
      return unsynced.toEntity();
    }
  }

  @override
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    try {
      await remoteDataSource.updateProductQuantity(productId, newQuantity);
      await localDataSource.updateProductQuantity(productId, newQuantity);
    } catch (e) {
      await localDataSource.updateProductQuantity(productId, newQuantity);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
      await localDataSource.deleteProduct(productId);
    } catch (e) {
      await localDataSource.deleteProduct(productId);
    }
  }

  @override
  Future<List<Product>> getUnSyncedProducts() async {
    final unsyncedProducts = await localDataSource.getUnSyncedProducts();
    return unsyncedProducts.map((p) => p.toEntity()).toList();
  }

  @override
  Future<void> syncProducts() async {
    try {
      final unsyncedProducts = await localDataSource.getUnSyncedProducts();
      if (unsyncedProducts.isNotEmpty) {
        await remoteDataSource.syncProducts(unsyncedProducts);
        for (var product in unsyncedProducts) {
          final synced = product.copyWith(isSynced: true, isLocalOnly: false);
          await localDataSource.updateProduct(synced);
        }
      }
    } catch (e) {
      // Handle sync error
    }
  }

  @override
  Future<List<Product>> getCachedProducts() async {
    final cached = await localDataSource.getAllProducts();
    return cached.map((p) => p.toEntity()).toList();
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final models = products.map((p) => ProductModel.fromEntity(p)).toList();
    await localDataSource.saveProducts(models);
  }
}
