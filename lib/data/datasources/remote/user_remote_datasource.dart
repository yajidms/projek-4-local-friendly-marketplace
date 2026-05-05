import '../../models/user_model.dart';

/// Abstract remote data source for User operations (API calls)
abstract class UserRemoteDataSource {
  /// Authenticate user
  Future<UserModel> authenticate(String email, String password);

  /// Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Get user by ID from server
  Future<UserModel> getUserById(String id);

  /// Update user profile
  Future<UserModel> updateUser(UserModel user);

  /// Add role to user (make buyer a seller)
  Future<UserModel> addRoleToUser(String userId, String role);

  /// Remove role from user
  Future<UserModel> removeRoleFromUser(String userId, String role);

  /// Logout user
  Future<void> logout();

  /// Refresh user session/token
  Future<void> refreshSession();
}
