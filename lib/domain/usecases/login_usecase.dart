import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';

/// Use case to login user
class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Auth> call(String email, String password) {
    return authRepository.login(email, password);
  }
}
