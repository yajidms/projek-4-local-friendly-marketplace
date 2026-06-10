import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/store_category.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/remote/http_admin_remote_datasource.dart';

/// Implementation of [AdminRepository] backed by [HttpAdminRemoteDatasource].
/// All data is fetched from the real backend API (database).
class AdminRepositoryImpl implements AdminRepository {
  final HttpAdminRemoteDatasource _datasource;

  AdminRepositoryImpl({HttpAdminRemoteDatasource? datasource})
      : _datasource = datasource ?? HttpAdminRemoteDatasource();

  // ─── Dashboard ───────────────────────────────────────────

  @override
  Future<bool> checkApiConnection() async {
    return _datasource.checkApiConnection();
  }

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    return _datasource.getDashboardStats();
  }

  // ─── Verification ────────────────────────────────────────

  @override
  Future<List<VerificationRequest>> getVerificationRequests({String? status}) async {
    final requests = await _datasource.getVerificationRequests();
    if (status != null && status.isNotEmpty) {
      return requests.where((r) => r.status.value == status).toList();
    }
    return requests;
  }

  @override
  Future<VerificationRequest> getVerificationDetail(String id) async {
    return _datasource.getVerificationDetail(id);
  }

  @override
  Future<void> approveStore(String sellerId) async {
    await _datasource.approveSeller(sellerId);
  }

  @override
  Future<void> rejectStore(String sellerId, String reason) async {
    if (reason.isEmpty) {
      throw ArgumentError('Alasan penolakan wajib diisi');
    }
    await _datasource.rejectSeller(sellerId, reason);
  }

  // ─── Users ───────────────────────────────────────────────

  @override
  Future<List<User>> getUsers({String? role, String? search}) async {
    List<User> users = await _datasource.getUsers();
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
    return _datasource.getUserById(id);
  }

  @override
  Future<void> updateUserStatus(String id, bool isActive) async {
    await _datasource.updateUserStatus(id, isActive);
  }

  // ─── Sellers ─────────────────────────────────────────────

  @override
  Future<List<Seller>> getSellers({bool? isVerified, String? search}) async {
    List<Seller> sellers = await _datasource.getSellers();
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
    return _datasource.getSellerById(id);
  }

  // ─── Products ────────────────────────────────────────────

  @override
  Future<List<Product>> getAllProducts({String? category, String? search}) async {
    List<Product> products = await _datasource.getProducts();
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
    List<Order> orders = await _datasource.getOrders();
    if (status != null && status.isNotEmpty) {
      final statusEnum = OrderStatusExtension.fromString(status);
      orders = orders.where((o) => o.status == statusEnum).toList();
    }
    return orders;
  }

  @override
  Future<Order> getOrderDetail(String id) async {
    return _datasource.getOrderById(id);
  }

  // ─── Categories ──────────────────────────────────────────

  @override
  Future<List<StoreCategory>> getCategories() async {
    return _datasource.getCategories();
  }

  @override
  Future<void> createCategory(StoreCategory category) async {
    if (category.name.isEmpty) {
      throw ArgumentError('Nama kategori wajib diisi');
    }
    await _datasource.createCategory(category);
  }

  @override
  Future<void> updateCategory(StoreCategory category) async {
    await _datasource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _datasource.deleteCategory(id);
  }
}
