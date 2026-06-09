import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';

/// Use case to register new user
class RegisterUseCase {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  Future<Auth> call({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) {
    return authRepository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
