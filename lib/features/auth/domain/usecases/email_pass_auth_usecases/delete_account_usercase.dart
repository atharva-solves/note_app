import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUsercase {
  final AuthRepository _authRepository;

  DeleteAccountUsercase({required AuthRepository authRepo})
    : _authRepository = authRepo;

  Future<void> call() async {
    return await _authRepository.deleteAccount();
  }
}
