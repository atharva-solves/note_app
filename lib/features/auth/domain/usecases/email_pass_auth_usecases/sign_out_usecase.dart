import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository _authRepository;

  SignOutUsecase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<void> call() async {
    return await _authRepository.signOut();
  }
}
