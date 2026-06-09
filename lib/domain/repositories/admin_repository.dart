import '../entities/admin_dashboard_stats.dart';
import '../entities/order.dart';
import '../entities/product.dart';
import '../entities/seller.dart';
import '../entities/store_category.dart';
import '../entities/user.dart';
import '../entities/verification_request.dart';

/// Abstract repository defining all admin panel data operations.
/// Implementations can use mock data or real HTTP API calls.
abstract class AdminRepository {
  // ─── Dashboard ───────────────────────────────────────────
  Future<AdminDashboardStats> getDashboardStats();

  // ─── Verification ────────────────────────────────────────
  Future<List<VerificationRequest>> getVerificationRequests({String? status});
  Future<VerificationRequest> getVerificationDetail(String id);
  Future<void> approveStore(String sellerId);
  Future<void> rejectStore(String sellerId, String reason);

  // ─── Users ───────────────────────────────────────────────
  Future<List<User>> getUsers({String? role, String? search});
  Future<User> getUserDetail(String id);
  Future<void> updateUserStatus(String id, bool isActive);

  // ─── Sellers ─────────────────────────────────────────────
  Future<List<Seller>> getSellers({bool? isVerified, String? search});
  Future<Seller> getSellerDetail(String id);

  // ─── Products ────────────────────────────────────────────
  Future<List<Product>> getAllProducts({String? category, String? search});

  // ─── Orders ──────────────────────────────────────────────
  Future<List<Order>> getAllOrders({String? status});
  Future<Order> getOrderDetail(String id);

  // ─── Categories ──────────────────────────────────────────
  Future<List<StoreCategory>> getCategories();
  Future<void> createCategory(StoreCategory category);
  Future<void> updateCategory(StoreCategory category);
  Future<void> deleteCategory(String id);
}
