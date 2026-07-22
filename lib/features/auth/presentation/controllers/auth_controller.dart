import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/usecases/auth_status_usecases.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/delete_account_usercase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_in_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_up_uscecase.dart';

class AuthController extends GetxController {
  final SignUpUscecase _signUpUscecase;
  final SignInUsecase _signInUsecase;
  final SignOutUsecase _signOutUsecase;
  final DeleteAccountUsecase _deleteAccountUsercase;
  final AuthStatusUsecase _authStatusUsecase;

  AuthController({
    required SignUpUscecase signUpUsecase,
    required SignInUsecase signInUsecase,
    required SignOutUsecase signOutUsecase,
    required DeleteAccountUsecase deleteAccountUsecase,
    required AuthStatusUsecase authStatusUsecase,
  }) : _authStatusUsecase = authStatusUsecase,
       _signUpUscecase = signUpUsecase,
       _signInUsecase = signInUsecase,
       _signOutUsecase = signOutUsecase,
       _deleteAccountUsercase = deleteAccountUsecase;

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  //type cast with =<> , and init with null(first time app open or after sign out or delete).
  Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);

  @override
  void onInit() {
    super.onInit();

    //1st ensure currUser Rx var is tiead/joined to fb>DM>UEn? (from UC)Stream

    currentUser.bindStream(_authStatusUsecase.call());
  }

  @override
  void onReady() {
    super.onReady();

    //in dish stack we cannot add a half incomplete dish
    //ensure dish is completely made the add/remove
    //Ensure Page is ready and then only do Navigation<-- custom func

    ever(currentUser, _setInitialScreen);
  }

  //custom function to route according to auth Status
  void _setInitialScreen(UserEntity? user) {
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
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
}
