import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/store_category.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/local/admin_mock_datasource.dart';

/// Implementation of [AdminRepository] backed by [AdminMockDatasource].
/// Swap this with an HTTP-based implementation when the backend API is ready.
class AdminRepositoryImpl implements AdminRepository {
  final AdminMockDatasource _datasource;

  AdminRepositoryImpl({AdminMockDatasource? datasource})
      : _datasource = datasource ?? AdminMockDatasource();

  // ─── Dashboard ───────────────────────────────────────────

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _datasource.getDashboardStats();
  }

  // ─── Verification ────────────────────────────────────────

  @override
  Future<List<VerificationRequest>> getVerificationRequests({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<VerificationRequest> requests = _datasource.verificationRequests.toList();
    if (status != null && status.isNotEmpty) {
      requests = requests.where((r) => r.status.value == status).toList();
    }
    return requests;
  }

  @override
  Future<VerificationRequest> getVerificationDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _datasource.verificationRequests.firstWhere((VerificationRequest r) => r.id == id);
  }

  @override
  Future<void> approveStore(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would call the API
  }

  @override
  Future<void> rejectStore(String sellerId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would call the API
  }

  // ─── Users ───────────────────────────────────────────────

  @override
  Future<List<User>> getUsers({String? role, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<User> users = _datasource.users.toList();
    if (role != null && role.isNotEmpty) {
      final roleEnum = RoleExtension.fromString(role);
      users = users.where((u) => u.roles.contains(roleEnum)).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      users = users
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
    return users;
  }

  @override
  Future<User> getUserDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _datasource.users.firstWhere((User u) => u.id == id);
  }

  @override
  Future<void> updateUserStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ─── Sellers ─────────────────────────────────────────────

  @override
  Future<List<Seller>> getSellers({bool? isVerified, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<Seller> sellers = _datasource.sellers.toList();
    if (isVerified != null) {
      sellers = sellers.where((s) => s.isVerified == isVerified).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      sellers = sellers
          .where((s) => s.shopName.toLowerCase().contains(q))
          .toList();
    }
    return sellers;
  }

  @override
  Future<Seller> getSellerDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _datasource.sellers.firstWhere((Seller s) => s.id == id);
  }

  // ─── Products ────────────────────────────────────────────

  @override
  Future<List<Product>> getAllProducts({String? category, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<Product> products = _datasource.products.toList();
    if (category != null && category.isNotEmpty) {
      products = products.where((p) => p.category == category).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    }
    return products;
  }

  // ─── Orders ──────────────────────────────────────────────

  @override
  Future<List<Order>> getAllOrders({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<Order> orders = _datasource.orders.toList();
    if (status != null && status.isNotEmpty) {
      final statusEnum = OrderStatusExtension.fromString(status);
      orders = orders.where((o) => o.status == statusEnum).toList();
    }
    return orders;
  }

  @override
  Future<Order> getOrderDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _datasource.orders.firstWhere((Order o) => o.id == id);
  }

  // ─── Categories ──────────────────────────────────────────

  @override
  Future<List<StoreCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _datasource.categories;
  }

  @override
  Future<void> createCategory(StoreCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updateCategory(StoreCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
