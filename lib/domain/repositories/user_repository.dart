import '../entities/index.dart';

/// Abstract repository for User operations
abstract class UserRepository {
  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Get current logged-in user
  Future<User?> getCurrentUser();

  /// Create new user
  Future<User> createUser(User user);

  /// Update user profile
  Future<User> updateUser(User user);

  /// Add role to user (e.g., make buyer a seller)
  Future<User> addRoleToUser(String userId, Role role);

  /// Remove role from user
  Future<User> removeRoleFromUser(String userId, Role role);

  /// Authenticate user
  Future<User?> authenticate(String email, String password);

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  /// Update user last sync time
  Future<void> updateLastSyncedAt(String userId);

  /// Logout user
  Future<void> logout();

  /// Cache user data locally
  Future<void> cacheUser(User user);

  /// Get cached user
  Future<User?> getCachedUser();
}
