import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:note_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> deleteAccount();

  //null if SignOut or Delete. else user
  Stream<UserModel?> get authStateStream;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDatasourceImpl({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    //FBA built-in meth.gives UserCerdobject

    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //since ucerCred.user can be null , we have to you !Bang operator
      //null check it before
      //if user is null , but due to any issue server sent successful userCredential obj instead of throwing error.

      if (userCredential.user == null) {
        debugPrint("auth>data>signUp Error :  User is null");
        throw Exception("Authentication failed: User is null");
      }
      final UserModel userModel = UserModel.fromFireBaseUser(
        firebaseUser: userCredential.user!,
      );
      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint("auth>data>signUp Firebase Error :$e");
      rethrow;
    } catch (e) {
      debugPrint("auth>data>signUp catch Error :Data Processing Error");
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user == null) {
        debugPrint("auth>data>signIn Error :  User is null");
        throw Exception("Authentication failed :user is null");
      }

      final UserModel userModel = UserModel.fromFireBaseUser(
        firebaseUser: userCredential.user!,
      );
      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint("auth>data>signUp> error : $e");
      rethrow;
    } catch (e) {
      debugPrint("auth>data>signUp> error : $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint("auth>data>signOut > FB Exception :$e");
      rethrow;
    } catch (e) {
      debugPrint("auth>data>signOut > Data processing error:$e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      //Delete requires current session , to avoid deleting from stolen phone
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('auth>data>deletAcc > FB Exception:$e');
      rethrow;
    } catch (e) {
      debugPrint("auth>data>delete> error:$e");
      rethrow;
    }
  }

  @override
  Stream<UserModel?> get authStateStream {
    //raw stream of nullable FBUser sent by firebase
    Stream<User?> firebaseUserStram = _firebaseAuth.authStateChanges();

    //converting that stream into stream of nullable UserModel & store it in var
    Stream<UserModel?> userModelStream = firebaseUserStram.map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFireBaseUser(firebaseUser: firebaseUser);
    });

    return userModelStream;
  }
}
