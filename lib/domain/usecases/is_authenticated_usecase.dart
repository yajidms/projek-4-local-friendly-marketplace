import '../../domain/repositories/auth_repository.dart';

/// Use case to check if user is authenticated
class IsAuthenticatedUseCase {
  final AuthRepository authRepository;

  IsAuthenticatedUseCase(this.authRepository);

  Future<bool> call() {
    return authRepository.isAuthenticated();
  }
}
