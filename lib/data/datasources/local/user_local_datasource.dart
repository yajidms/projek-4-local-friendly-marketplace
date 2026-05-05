import '../../models/user_model.dart';

/// Abstract local data source for User operations
abstract class UserLocalDataSource {
  /// Get user by ID from local storage
  Future<UserModel?> getUserById(String id);

  /// Get all cached users
  Future<List<UserModel>> getAllUsers();

  /// Save user to local storage
  Future<void> saveUser(UserModel user);

  /// Save multiple users
  Future<void> saveUsers(List<UserModel> users);

  /// Update user in local storage
  Future<void> updateUser(UserModel user);

  /// Delete user from local storage
  Future<void> deleteUser(String id);

  /// Clear all users from cache
  Future<void> clearAll();

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser();

  /// Save current user (for session management)
  Future<void> saveCurrentUser(UserModel user);
}
