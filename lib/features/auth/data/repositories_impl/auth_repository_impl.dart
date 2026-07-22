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
}
