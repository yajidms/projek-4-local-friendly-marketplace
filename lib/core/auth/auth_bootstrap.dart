import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/in_memory_auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/demo_auth_remote_datasource.dart';
import '../../data/datasources/remote/http_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_facade.dart';

class AuthBootstrap {
  static AuthFacade build() {
    final localDataSource = InMemoryAuthLocalDataSource();
    final demoRemoteDataSource = DemoAuthRemoteDataSource();
    final httpRemoteDataSource = HttpAuthRemoteDataSource();

    final demoRepository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: demoRemoteDataSource,
    );

    final remoteRepository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: httpRemoteDataSource,
    );

    return AuthFacade(
      demoRepository: demoRepository,
      remoteRepository: remoteRepository,
    );
  }
}
