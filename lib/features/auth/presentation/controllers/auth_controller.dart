import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/usecases/auth_status_usecases.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/delete_account_usercase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_in_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_up_uscecase.dart';
import 'package:note_app/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/phone_otp_usecases/send_otp_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/phone_otp_usecases/verify_otp_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/sign_in_anonymously.dart';

class AuthController extends GetxController {
  final SignUpUscecase _signUpUscecase;
  final SignInUsecase _signInUsecase;
  final SignOutUsecase _signOutUsecase;
  final DeleteAccountUsecase _deleteAccountUsercase;
  final AuthStatusUsecase _authStatusUsecase;
  final GoogleSignInUsecase _googleSignInUsecase;
  final SendOtpUsecase _sendOtpUsecase;
  final VerifyOtpUsecase _verifyOtpUsecase;
  final SignInAnonymouslyUsecase _signInAnonymouslyUsecase;

  AuthController({
    required SignUpUscecase signUpUsecase,
    required SignInUsecase signInUsecase,
    required SignOutUsecase signOutUsecase,
    required DeleteAccountUsecase deleteAccountUsecase,
    required AuthStatusUsecase authStatusUsecase,
    required GoogleSignInUsecase googleSignInUsecase,
    required SendOtpUsecase sendOtpUsecase,
    required VerifyOtpUsecase verifyOtpUsecase,
    required SignInAnonymouslyUsecase signInAnonymouslyUsecase,
  }) : _authStatusUsecase = authStatusUsecase,
       _signUpUscecase = signUpUsecase,
       _signInUsecase = signInUsecase,
       _signOutUsecase = signOutUsecase,
       _deleteAccountUsercase = deleteAccountUsecase,
       _googleSignInUsecase = googleSignInUsecase,
       _sendOtpUsecase = sendOtpUsecase,
       _verifyOtpUsecase = verifyOtpUsecase,
       _signInAnonymouslyUsecase = signInAnonymouslyUsecase;

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  //type cast with =<> , and init with null(first time app open or after sign out or delete).
  Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  RxString verificationId = ''.obs;

  /* @override
  void onInit() {
    super.onInit();

    //1st ensure currUser Rx var is tiead/joined to fb>DM>UEn? (from UC)Stream


//Challenge Error Learning:
//Null-To-Null Trap , to be efficient and have Best performance
//GetX donot updates its Rx Var if old==new (Rx deaf <>(Null) == fb new null)
//there sore custom Nav Func not called by 'ever' since no change
////Nav screen Stuck
///SOLUTION:Dart inbuilt .listen method to listen which byPass this == rule
///   
    
    //currentUser.bindStream(_authStatusUsecase.call());
  } */

  @override
  void onReady() {
    super.onReady();

    //Null to Null error:so this is cancelled
    //in dish stack we cannot add a half incomplete dish
    //ensure dish is completely made the add/remove
    //Ensure Page is ready and then only do Navigation<-- custom func

    //ever(currentUser, _setInitialScreen);

    //Dart listener:

    _authStatusUsecase.call().listen((UserEntity? userEntity) {
      debugPrint('change listned in aut ctr>._authStUC.listen');
      currentUser.value = userEntity;
      _setInitialScreen(userEntity);
    });
  }

  //custom function to route according to auth Status
  void _setInitialScreen(UserEntity? userEntity) {
    if (userEntity == null) {
      debugPrint("Auth Stream: User is null -> Routing to Login");
      Get.offAllNamed(AppRoutes.login);
    } else {
      debugPrint("Auth Stream: User active -> Routing to Home");
      Get.offAllNamed(AppRoutes.home);
    }
  }

  //using Try-Catch since we have to do some thing with that error (errmsg ,snackB), not just bubble up.
  Future<void> signUp({required String email, required String password}) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      debugPrint('auth>presentation>ctrl>SignUp Started');

      final UserEntity user = await _signUpUscecase.call(
        email: email,
        password: password,
      );
      currentUser.value = user;

      Get.snackbar(
        "Account created",
        'Welcome to Note App',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint("Auth>pres>ctr>sign up SUCCESSFUL : email : ${user.email} ");

      isLoading.value = false;
    } catch (e) {
      debugPrint("Caught Exception in auth ctr signUP : $e");

      errorMessage.value = e.toString();

      Get.snackbar(
        "Sign-up failed!",
        'Error:$errorMessage',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      debugPrint('auth>presentation>ctrl>SignIn Started');

      final user = await _signInUsecase.call(email: email, password: password);

      currentUser.value = user;

      Get.snackbar(
        "Sign-in Successful",
        'Welcome Back to Note App',
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint("auth>pres>ctrl>signIn Successfull : $currentUser");
    } catch (e) {
      debugPrint("Error: $e");
      errorMessage.value = e.toString();
      Get.snackbar(
        "Sign-in failed!",
        'Error:$errorMessage',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint("auth>ctrl>signOut Starting");
      await _signOutUsecase.call();

      //State clear from UI variable currentUser . if not then flutter thinks there's user still alive and stuck on HomeScreen.
      currentUser.value = null;

      debugPrint("signOut Successful");

      Get.snackbar(
        "Signed Out",
        'See you soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("Error:$e");
      errorMessage.value = e.toString();
      Get.snackbar(
        "Sign-out failed!",
        'Error:$errorMessage',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      debugPrint("Auth>pres>ctr>Delete() Started");
      await _deleteAccountUsercase.call();
      debugPrint("Deleted Successfully");

      //State Clearance
      currentUser.value = null;

      Get.snackbar("Account deleted", '', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint("Error :$e");
      errorMessage.value = e.toString();
      Get.snackbar(
        "Deleting failed!",
        'Error:$errorMessage',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      debugPrint("auth>pres>ctrl>googleSignIn started");
      isLoading.value = true;
      errorMessage.value = '';

      final UserEntity user = await _googleSignInUsecase.call();
      currentUser.value = user;
      Get.snackbar(
        "Google Sign-In Successful",
        'Welcome Back, ${user.email}!',
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint("auth>pres>ctrl>googleSignIn Successful : ${user.email}");
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("auth>pres>ctrl>googleSignIn catched Error :$e");
      Get.snackbar(
        "Google Sign-In failed!",
        'Error: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //since send otp has callbacks that would terminate at different point of time,
  //we've puten isLoading false at their respective termination points
  //not pn finally
  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      debugPrint("Auth>pres>ctrl>sendOtp started for $phoneNumber");

      await _sendOtpUsecase.call(
        phoneNumber: phoneNumber,
        onCodeSent: (String verId) {
          debugPrint("Auth>pres>ctrl>OTP Sent! Ticket ID: $verId");
          verificationId.value = verId;
          isLoading.value = false;
          Get.snackbar(
            "OTP sent",
            "Please check your phone for 6-digit code",
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.toNamed(AppRoutes.otpView);
        },
        onVerificationFailed: (String errorMsg) {
          debugPrint("Auth>pres>ctrl>sendOtp Failed: $errorMsg");
          isLoading.value = false;
          errorMessage.value = errorMsg;
          Get.snackbar(
            "Verification Failed",
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } catch (e) {
      debugPrint("Auth>pres>ctrl>sendOtp Exception: $e");
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //no callbacks here , execute chronologcal therefore finally here.
  Future<void> verifyOtp(String smsCode) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      debugPrint("Auth>pres>ctrl>verifyOtp started with code: $smsCode");

      if (verificationId.value.isEmpty) {
        throw Exception("Session expired : please request new otp");
      }

      final UserEntity userEntity = await _verifyOtpUsecase(
        smsCode: smsCode,
        verificationId: verificationId.value,
      );

      currentUser.value = userEntity;

      Get.snackbar(
        "Phone Verified",
        "Welcome to Note App",
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint(
        "Auth>pres>ctrl>verifyOtp Successful for user: ${userEntity.id}",
      );
    } catch (e) {
      debugPrint("Auth>pres>ctrl>verifyOtp Exception: $e");
      isLoading.value = false;
      errorMessage.value = e.toString();

      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      debugPrint(
        "Auth>pres>ctrl>verifyOtp finally >Exception: ${errorMessage.value}",
      );
      isLoading.value = false;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      debugPrint('auth ctr>signInAnonymously>started');
      isLoading.value = true;
      errorMessage.value = "";
      UserEntity userEntity = await _signInAnonymouslyUsecase
          .signInAnonymouslyUseCase();

      currentUser.value = userEntity;
      debugPrint('auth ctr>signInAnonymously>successful $userEntity ');
    } catch (e) {
      debugPrint('auth ctr>signInAnonymously>catched Error ==> $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
