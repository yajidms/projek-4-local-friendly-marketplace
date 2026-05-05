import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';

/// Use case to refresh JWT token
class RefreshTokenUseCase {
  final AuthRepository authRepository;

  RefreshTokenUseCase(this.authRepository);

  Future<Auth> call(String refreshToken) {
    return authRepository.refreshToken(refreshToken);
  }
}
