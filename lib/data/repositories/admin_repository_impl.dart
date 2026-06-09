import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/store_category.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/remote/http_admin_remote_datasource.dart';

/// Implementation of [AdminRepository] backed by [HttpAdminRemoteDatasource].
class AdminRepositoryImpl implements AdminRepository {
  final HttpAdminRemoteDatasource _datasource;

  AdminRepositoryImpl({HttpAdminRemoteDatasource? datasource})
      : _datasource = datasource ?? HttpAdminRemoteDatasource();

  // ─── Dashboard ───────────────────────────────────────────

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    return _datasource.getDashboardStats();
  }

  // ─── Verification ────────────────────────────────────────

  @override
  Future<List<VerificationRequest>> getVerificationRequests({String? status}) async {
    return _datasource.getVerificationRequests(status: status);
  }

  @override
  Future<VerificationRequest> getVerificationDetail(String id) async {
    return _datasource.getVerificationDetail(id);
  }

  @override
  Future<void> approveStore(String sellerId) async {
    return _datasource.approveStore(sellerId);
  }

  @override
  Future<void> rejectStore(String sellerId, String reason) async {
    return _datasource.rejectStore(sellerId, reason);
  }

  // ─── Users ───────────────────────────────────────────────

  @override
  Future<List<User>> getUsers({String? role, String? search}) async {
    return _datasource.getUsers(role: role, search: search);
  }

  @override
  Future<User> getUserDetail(String id) async {
    return _datasource.getUserDetail(id);
  }

  @override
  Future<void> updateUserStatus(String id, bool isActive) async {
    return _datasource.updateUserStatus(id, isActive);
  }

  // ─── Sellers ─────────────────────────────────────────────

  @override
  Future<List<Seller>> getSellers({bool? isVerified, String? search}) async {
    return _datasource.getSellers(isVerified: isVerified, search: search);
  }

  @override
  Future<Seller> getSellerDetail(String id) async {
    return _datasource.getSellerDetail(id);
  }

  // ─── Products ────────────────────────────────────────────

  @override
  Future<List<Product>> getAllProducts({String? category, String? search}) async {
    return _datasource.getAllProducts(category: category, search: search);
  }

  // ─── Orders ──────────────────────────────────────────────

  @override
  Future<List<Order>> getAllOrders({String? status}) async {
    return _datasource.getAllOrders(status: status);
  }

  @override
  Future<Order> getOrderDetail(String id) async {
    return _datasource.getOrderDetail(id);
  }

  // ─── Categories ──────────────────────────────────────────

  @override
  Future<List<StoreCategory>> getCategories() async {
    return _datasource.getCategories();
  }

  @override
  Future<void> createCategory(StoreCategory category) async {
    return _datasource.createCategory(category);
  }

  @override
  Future<void> updateCategory(StoreCategory category) async {
    return _datasource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    return _datasource.deleteCategory(id);
  }
}
