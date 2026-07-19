import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/state_manager.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signupWitEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print(
          'Error in AuthServ:Password is weak (must be atleast 6 characters)',
        );
        rethrow;
      } else if (e.code == 'email-already-in-use') {
        print(
          'Error in AuthServ:Email is already in use ,please use different email',
        );
        rethrow;
      } else if (e.code == 'invalid-email') {
        print('error in AuthServ :email is Invalid');
        rethrow;
      } else {
        //other FBA exception
        print('in AuthServ : Other FBA exception occured');
        rethrow;
      }
    } catch (e) {
      print('in Auth Serv: Unexpected error occured $e');
      rethrow;
    }
  }

  Future<UserCredential> signinUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('login started in Auth Serv');
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      print('AuthServ Successfully logged in : UCred : $userCredential');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('error caught in AuthServ LOGIN :');

      if (e.code == 'user-not-found') {
        print('AuthSer>Login>error :User not found with for that $email ');
        rethrow;
      }
      if (e.code == 'wrong-password') {
        print('AuthServ>Login>error:Wrong password');
        rethrow;
      }
      if (e.code == 'invalid-credentials') {
        print('AuthServ>Login>error: invalid credentials');
        rethrow;
      } else {
        print('Auth Serv>Login>Unexpected FBA Exception throw:$e ');
        rethrow;
      }
    } catch (e) {
      print('AuthServ :Login:Unexpected error other than FBAE Occured : -- $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    //ends current user session on device
    try {
      print('FBAuth Serv : Signing out of the APP');
      await _firebaseAuth.signOut();
    } catch (e) {
      print('AuthServ>Signout>error $e');
      rethrow;
    }
  }

  //bool ,to inform UI is action succ or failed
  Future<void> deleteAccount() async {
    try {
      //check is user signed-in?
      User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        print('User is signed in , NOW DELETING user');
        await currentUser.delete();
      } else {
        print('user is not signed in');
      }
    } catch (e) {
      print('Error Occured in Authserv>delete :- $e');
      rethrow;
    }
  }
}
