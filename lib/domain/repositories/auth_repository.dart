import '../entities/index.dart';

/// Abstract repository for Auth operations
abstract class AuthRepository {
  /// Login user with email and password, returns Auth with JWT tokens
  Future<Auth> login(String email, String password);

  /// Register new user and get Auth with JWT tokens
  Future<Auth> register({
    required String name,
    required String email,
    required String password,
  });

  /// Refresh access token using refresh token
  Future<Auth> refreshToken(String refreshToken);

  /// Get current stored auth session
  Future<Auth?> getCurrentAuth();

  /// Save auth session locally
  Future<void> saveAuth(Auth auth);

  /// Clear auth session (logout)
  Future<void> clearAuth();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();
}
