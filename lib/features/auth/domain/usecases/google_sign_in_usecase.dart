import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUsecase {
  final AuthRepository _authRepository;

  GoogleSignInUsecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<UserEntity> call() async {
    return await _authRepository.signInWithGoogle();
  }
}
