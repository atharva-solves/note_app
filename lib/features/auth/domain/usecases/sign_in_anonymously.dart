import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class SignInAnonymouslyUsecase {
  final AuthRepository _authRepository;
  SignInAnonymouslyUsecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<UserEntity> signInAnonymouslyUseCase() async {
    return await _authRepository.signInAnonymously();
  }
}
