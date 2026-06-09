import '../../models/auth_model.dart';

/// Abstract remote data source for Auth operations (API calls)
abstract class AuthRemoteDataSource {
  /// Login user with email and password
  Future<AuthModel> login(String email, String password);

  /// Register new user
  Future<AuthModel> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  });

  /// Refresh access token using refresh token
  Future<AuthModel> refreshToken(String refreshToken);

  /// Logout user
  Future<void> logout();
}
