import '../../domain/repositories/auth_repository.dart';

/// Use case to logout user
class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<void> call() {
    return authRepository.clearAuth();
  }
}
