import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';

/// Use case to get current authentication session
class GetCurrentAuthUseCase {
  final AuthRepository authRepository;

  GetCurrentAuthUseCase(this.authRepository);

  Future<Auth?> call() {
    return authRepository.getCurrentAuth();
  }
}
