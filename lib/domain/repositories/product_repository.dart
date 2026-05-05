import '../entities/index.dart';

/// Abstract repository for Product operations
abstract class ProductRepository {
  /// Get product by ID
  Future<Product?> getProductById(String productId);

  /// Get all products for a seller
  Future<List<Product>> getProductsBySeller(String sellerId);

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category);

  /// Search products
  Future<List<Product>> searchProducts(String query);

  /// Create new product
  Future<Product> createProduct(Product product);

  /// Update product
  Future<Product> updateProduct(Product product);

  /// Update product quantity (inventory)
  Future<void> updateProductQuantity(String productId, int newQuantity);

  /// Delete product
  Future<void> deleteProduct(String productId);

  /// Get products that need sync
  Future<List<Product>> getUnSyncedProducts();

  /// Sync products with server
  Future<void> syncProducts();

  /// Get cached products for offline use
  Future<List<Product>> getCachedProducts();

  /// Cache products locally
  Future<void> cacheProducts(List<Product> products);
}
