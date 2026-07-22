import 'package:note_app/features/auth/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<void> deleteAccount();

  Stream<UserEntity?> get authStatusStream;
}
