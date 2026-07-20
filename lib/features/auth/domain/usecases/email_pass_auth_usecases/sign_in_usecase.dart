
import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository _authRepository;

  SignInUsecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    final UserEntity userEntity = await _authRepository
        .signInWithEmailAndPassword(email: email, password: password);

    return userEntity;
  }
}
