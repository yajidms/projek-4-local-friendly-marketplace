import '../../models/auth_model.dart';

/// Abstract local data source for Auth operations (token storage)
abstract class AuthLocalDataSource {
  /// Get stored auth session
  Future<AuthModel?> getAuthSession();

  /// Save auth session with tokens
  Future<void> saveAuthSession(AuthModel auth);

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Save access token
  Future<void> saveAccessToken(String token);

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Save refresh token
  Future<void> saveRefreshToken(String token);

  /// Clear all auth data
  Future<void> clearAuthSession();

  /// Check if auth session exists
  Future<bool> hasAuthSession();
}
