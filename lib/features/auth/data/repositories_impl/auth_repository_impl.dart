import 'package:note_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

//Bubble err autom
//bcz we dont have to do something with that here
//UC<---repoImpl [Orchestrator] --->Multiple Datasource to full fill UC  req
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource authRemoteDS})
    : _authRemoteDatasource = authRemoteDS;
  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserEntity userEntity = await _authRemoteDatasource.signUpWithEmail(
      email,
      password,
    );
    return userEntity;
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserEntity userEntity = await _authRemoteDatasource.signInWithEmail(
      email,
      password,
    );
    return userEntity;
  }

  @override
  Future<void> signOut() {
    return _authRemoteDatasource.signOut();
  }

  @override
  Future<void> deleteAccount() {
    return _authRemoteDatasource.deleteAccount();
  }

  @override
  Stream<UserEntity?> get authStatusStream =>
      _authRemoteDatasource.authStateStream;

  @override
  Future<UserEntity> signInWithGoogle() async {
    final UserEntity userEntity = await _authRemoteDatasource
        .signInWithGoogle();
    return userEntity;
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onVerificationFailed,
  }) {
    return _authRemoteDatasource.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final UserEntity userEntity = await _authRemoteDatasource.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return userEntity;
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    final UserEntity userEntity = await _authRemoteDatasource
        .signInAnonymously();

    return userEntity;
  }
}
