import '../../models/product_model.dart';

/// Abstract local data source for Product operations
abstract class ProductLocalDataSource {
  /// Get product by ID
  Future<ProductModel?> getProductById(String id);

  /// Get all products
  Future<List<ProductModel>> getAllProducts();

  /// Get products by seller
  Future<List<ProductModel>> getProductsBySeller(String sellerId);

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category);

  /// Search products
  Future<List<ProductModel>> searchProducts(String query);

  /// Get unsynced products
  Future<List<ProductModel>> getUnSyncedProducts();

  /// Get local-only products (created offline)
  Future<List<ProductModel>> getLocalOnlyProducts();

  /// Save product
  Future<void> saveProduct(ProductModel product);

  /// Save multiple products
  Future<void> saveProducts(List<ProductModel> products);

  /// Update product
  Future<void> updateProduct(ProductModel product);

  /// Update product quantity
  Future<void> updateProductQuantity(String productId, int quantity);

  /// Delete product
  Future<void> deleteProduct(String id);

  /// Clear all products
  Future<void> clearAll();
}
