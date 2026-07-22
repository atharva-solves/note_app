import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class AuthStatusUsecase {
  final AuthRepository _authRepository;

  AuthStatusUsecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Stream<UserEntity?> call() {
    return _authRepository.authStatusStream;
  }
}
