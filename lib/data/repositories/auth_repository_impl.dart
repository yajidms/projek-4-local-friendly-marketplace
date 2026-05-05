import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Auth> login(String email, String password) async {
    try {
      // Call remote API to authenticate
      final authModel = await remoteDataSource.login(email, password);

      // Save auth session locally
      await localDataSource.saveAuthSession(authModel);

      return authModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Auth> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Call remote API to register
      final authModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Save auth session locally
      await localDataSource.saveAuthSession(authModel);

      return authModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Auth> refreshToken(String refreshToken) async {
    try {
      // Call remote API to refresh token
      final authModel = await remoteDataSource.refreshToken(refreshToken);

      // Update auth session locally
      await localDataSource.saveAuthSession(authModel);

      return authModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Auth?> getCurrentAuth() async {
    try {
      final authModel = await localDataSource.getAuthSession();
      return authModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAuth(Auth auth) async {
    try {
      final authModel = AuthModel.fromEntity(auth);
      await localDataSource.saveAuthSession(authModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAuth() async {
    try {
      await localDataSource.clearAuthSession();
      await remoteDataSource.logout();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await localDataSource.hasAuthSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await localDataSource.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await localDataSource.getRefreshToken();
    } catch (e) {
      return null;
    }
  }
}
