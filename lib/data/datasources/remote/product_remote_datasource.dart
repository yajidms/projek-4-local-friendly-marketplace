import '../../models/product_model.dart';

/// Abstract remote data source for Product operations (API calls)
abstract class ProductRemoteDataSource {
  /// Get product by ID
  Future<ProductModel> getProductById(String id);

  /// Get all products
  Future<List<ProductModel>> getAllProducts();

  /// Get products by seller
  Future<List<ProductModel>> getProductsBySeller(String sellerId);

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category);

  /// Search products
  Future<List<ProductModel>> searchProducts(String query);

  /// Create product
  Future<ProductModel> createProduct(ProductModel product);

  /// Update product
  Future<ProductModel> updateProduct(ProductModel product);

  /// Update product quantity
  Future<void> updateProductQuantity(String productId, int quantity);

  /// Delete product
  Future<void> deleteProduct(String productId);

  /// Sync products (batch update)
  Future<void> syncProducts(List<ProductModel> products);

  /// Delete multiple products
  Future<void> deleteProducts(List<String> productIds);
}
