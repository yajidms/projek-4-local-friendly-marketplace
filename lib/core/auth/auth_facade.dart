import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/index.dart';
import '../../domain/usecases/get_current_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../auth/auth_mode.dart';

class _AuthBundle {
  _AuthBundle(this.repository)
      : loginUseCase = LoginUseCase(repository),
        registerUseCase = RegisterUseCase(repository),
        logoutUseCase = LogoutUseCase(repository),
        getCurrentAuthUseCase = GetCurrentAuthUseCase(repository);

  final AuthRepositoryImpl repository;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentAuthUseCase getCurrentAuthUseCase;
}

class AuthFacade {
  AuthFacade({
    required AuthRepositoryImpl demoRepository,
    required AuthRepositoryImpl remoteRepository,
  })  : _demo = _AuthBundle(demoRepository),
        _remote = _AuthBundle(remoteRepository);

  final _AuthBundle _demo;
  final _AuthBundle _remote;

  _AuthBundle _bundleFor(AuthMode mode) {
    return mode == AuthMode.remote ? _remote : _demo;
  }

  Future<Auth> login({
    required String email,
    required String password,
    required bool useRemote,
  }) {
    return _bundleFor(useRemote ? AuthMode.remote : AuthMode.demo)
        .loginUseCase(email, password);
  }

  Future<Auth> register({
    required String name,
    required String email,
    required String password,
    required bool useRemote,
  }) {
    return _bundleFor(useRemote ? AuthMode.remote : AuthMode.demo)
        .registerUseCase(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void> logout({required bool useRemote}) {
    return _bundleFor(useRemote ? AuthMode.remote : AuthMode.demo)
        .logoutUseCase();
  }

  Future<Auth?> getCurrentSession({required bool useRemote}) {
    return _bundleFor(useRemote ? AuthMode.remote : AuthMode.demo)
        .getCurrentAuthUseCase();
  }

  Future<void> useDemoSession() async {
    await _demo.repository.saveAuth(
      Auth(
        accessToken: 'demo-token',
        refreshToken: 'demo-refresh-token',
        user: User(
          id: 'user_demo',
          name: 'Demo Seller',
          email: 'demo@marketplace.local',
          roles: const [Role.seller],
          marketplaceId: 'marketplace_001',
          sellerId: 'seller_demo',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 365)),
        tokenType: 'Bearer',
      ),
    );
  }
}
