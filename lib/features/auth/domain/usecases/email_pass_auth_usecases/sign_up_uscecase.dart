import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

//single action a user can take
//Business logic defined here: (if not here then ctr bloat)
//Example : DS mixing (store Ucred in local db as soon as fetched)
//talk only to repo
//Single Responsibility Principle (SOLID)

class SignUpUscecase {
  final AuthRepository _authRepository;
  SignUpUscecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    final UserEntity userentity = await _authRepository
        .signUpWithEmailAndPassword(email: email, password: password);

    return userentity;
  }
}
