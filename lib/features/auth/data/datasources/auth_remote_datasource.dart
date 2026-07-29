import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/features/auth/data/models/user_model.dart';

//Dep Inv from SOLID
abstract class AuthRemoteDatasource {
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<UserModel> signInWithGoogle();
  
  //null if SignOut or Delete. else user
  Stream<UserModel?> get authStateStream;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  //;oose coupling to mock Auth
  AuthRemoteDatasourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

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
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('auth>data>deletAcc > FB Exception:$e');
      rethrow;
    } catch (e) {
      debugPrint("auth>data>delete> error:$e");
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      //1 trigger native UI
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      //Null check since type is Nullable
      if (googleUser == null) {
        throw Exception("Google sign in aborted by user");
      }
      //2 token fetching (2.a ID - authen, 2.b access authoriz)

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final clientAuth = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      if (clientAuth == null) {
        throw Exception("User denied scopes/permissions");
      }
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      //4 hand the tokens packed in authCred wrapper to FB
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(authCredential);

      if (userCredential.user == null) {
        throw Exception('FireBase Auth failed : User is null');
      }

      //5 Data mapping and Modeling
      final UserModel userModel = UserModel.fromFireBaseUser(
        firebaseUser: userCredential.user!,
      );

      return userModel;
    } catch (e) {
      debugPrint("Auth>data>sinInWithGoogle>Error:$e");

      rethrow;
    }
  }

  @override
  Stream<UserModel?> get authStateStream {
    //raw stream of nullable FBUser sent by firebase
    Stream<User?> firebaseUserStream = _firebaseAuth.authStateChanges();

    //converting that stream into stream of nullable UserModel & store it in var
    Stream<UserModel?> userModelStream = firebaseUserStream.map((
      User? firebaseUser,
    ) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFireBaseUser(firebaseUser: firebaseUser);
    });

    return userModelStream;
  }
}
