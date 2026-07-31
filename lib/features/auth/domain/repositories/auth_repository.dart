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

  Future<UserEntity> signInWithGoogle();

  Future<void> signOut();
  Future<void> deleteAccount();

  Stream<UserEntity?> get authStatusStream;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId)
    onCodeSent, //nav to otp filling page
    required Function(String errorMessage)
    onVerificationFailed, //if phone number invalid
  });

  //rule for verifying otp
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode, //otp
  }); 

  Future<UserEntity> signInAnonymously();
}
