import '../../models/product_model.dart';
import '../../models/seller_model.dart';
import '../../models/user_model.dart';
import 'product_local_datasource.dart';
import 'seller_local_datasource.dart';
import 'user_local_datasource.dart';

class InMemoryProductLocalDataSource implements ProductLocalDataSource {
  final Map<String, ProductModel> _store = {};

  @override
  Future<ProductModel?> getProductById(String id) async => _store[id];

  @override
  Future<List<ProductModel>> getAllProducts() async => _store.values.toList();

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async =>
      _store.values.where((p) => p.sellerId == sellerId).toList();

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async =>
      _store.values.where((p) => p.category == category).toList();

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final q = query.toLowerCase();
    return _store.values
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ProductModel>> getUnSyncedProducts() async =>
      _store.values.where((p) => !p.isSynced).toList();

  @override
  Future<List<ProductModel>> getLocalOnlyProducts() async =>
      _store.values.where((p) => p.isLocalOnly).toList();

  @override
  Future<void> saveProduct(ProductModel product) async {
    _store[product.id] = product;
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    for (final p in products) {
      _store[p.id] = p;
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    _store[product.id] = product;
  }

  @override
  Future<void> updateProductQuantity(String productId, int quantity) async {
    final existing = _store[productId];
    if (existing != null) {
      _store[productId] = existing.copyWith(quantity: quantity);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }
}

class InMemorySellerLocalDataSource implements SellerLocalDataSource {
  final Map<String, SellerModel> _store = {};

  @override
  Future<SellerModel?> getSellerById(String id) async => _store[id];

  @override
  Future<SellerModel?> getSellerByUserId(String userId) async {
    try {
      return _store.values.firstWhere((s) => s.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SellerModel>> getAllSellers() async => _store.values.toList();

  @override
  Future<List<SellerModel>> getSellersByCategory(String category) async =>
      _store.values.where((s) => s.categories.any((c) => c == category)).toList();

  @override
  Future<void> saveSeller(SellerModel seller) async {
    _store[seller.id] = seller;
  }

  @override
  Future<void> saveSellers(List<SellerModel> sellers) async {
    for (final s in sellers) {
      _store[s.id] = s;
    }
  }

  @override
  Future<void> updateSeller(SellerModel seller) async {
    _store[seller.id] = seller;
  }

  @override
  Future<void> deleteSeller(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<SellerModel>> getUnSyncedSellers() async =>
      _store.values.where((s) => !s.isSynced).toList();

  @override
  Future<void> clearAll() async {
    _store.clear();
  }
}

class InMemoryUserLocalDataSource implements UserLocalDataSource {
  final Map<String, UserModel> _store = {};
  UserModel? _currentUser;

  @override
  Future<UserModel?> getUserById(String id) async => _store[id];

  @override
  Future<List<UserModel>> getAllUsers() async => _store.values.toList();

  @override
  Future<void> saveUser(UserModel user) async {
    _store[user.id] = user;
  }

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    for (final u in users) {
      _store[u.id] = u;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    _store[user.id] = user;
  }

  @override
  Future<void> deleteUser(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    _currentUser = user;
    _store[user.id] = user;
  }
}
