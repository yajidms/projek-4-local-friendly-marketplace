import '../../domain/entities/index.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_datasource.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<User?> getUserById(String userId) async {
    try {
      // Try to fetch from remote first
      final remoteUser = await remoteDataSource.getUserById(userId);
      // Save to local for offline use
      await localDataSource.saveUser(remoteUser);
      return remoteUser.toEntity();
    } catch (e) {
      // Fallback to local cache if offline
      final cachedUser = await localDataSource.getUserById(userId);
      return cachedUser?.toEntity();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Get from local cache first
      final cachedUser = await localDataSource.getCurrentUser();
      return cachedUser?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> createUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    // Save locally first
    await localDataSource.saveUser(userModel);
    // Then sync with server
    final remoteUser = await remoteDataSource.register(
      name: user.name,
      email: user.email,
      password: 'placeholder', // Password should be handled securely
    );
    await localDataSource.saveCurrentUser(remoteUser);
    return remoteUser.toEntity();
  }

  @override
  Future<User> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    // Update locally
    await localDataSource.updateUser(userModel);
    // Sync with server
    final remoteUser = await remoteDataSource.updateUser(userModel);
    return remoteUser.toEntity();
  }

  @override
  Future<User> addRoleToUser(String userId, Role role) async {
    // Add role on server
    final remoteUser = await remoteDataSource.addRoleToUser(userId, role.value);
    // Update local cache
    await localDataSource.updateUser(remoteUser);
    return remoteUser.toEntity();
  }

  @override
  Future<User> removeRoleFromUser(String userId, Role role) async {
    // Remove role on server
    final remoteUser =
        await remoteDataSource.removeRoleFromUser(userId, role.value);
    // Update local cache
    await localDataSource.updateUser(remoteUser);
    return remoteUser.toEntity();
  }

  @override
  Future<User?> authenticate(String email, String password) async {
    try {
      // Authenticate on server
      final remoteUser = await remoteDataSource.authenticate(email, password);
      // Save as current user locally
      await localDataSource.saveCurrentUser(remoteUser);
      return remoteUser.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Register on server
    final remoteUser = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
    // Save locally
    await localDataSource.saveUser(remoteUser);
    return remoteUser.toEntity();
  }

  @override
  Future<void> updateLastSyncedAt(String userId) async {
    try {
      final user = await localDataSource.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          lastSyncedAt: DateTime.now(),
          isSynced: true,
        );
        await localDataSource.updateUser(updatedUser);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      // Clear local cache
      await localDataSource.clearAll();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> cacheUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.saveUser(userModel);
  }

  @override
  Future<User?> getCachedUser() async {
    final cachedUser = await localDataSource.getCurrentUser();
    return cachedUser?.toEntity();
  }
}
