import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:note_app/core/services/local_storage_service.dart';
import 'package:note_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:note_app/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/delete_account_usercase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_in_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_up_uscecase.dart';
import 'package:note_app/features/auth/presentation/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    //since Core, put Instance before app Created .
    Get.put(StorageService());
    
    //here is the 1st actual instance (FB.instance) .(source of Waterfall)
    //else is waterfall
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<AuthRemoteDatasource>(
      AuthRemoteDatasourceImpl(firebaseAuth: Get.find<FirebaseAuth>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(authRemoteDS: Get.find<AuthRemoteDatasource>()),
      permanent: true,
    );
    Get.put<SignUpUscecase>(
      SignUpUscecase(authRepo: Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<SignInUsecase>(
      SignInUsecase(authRepo: Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<SignOutUsecase>(
      SignOutUsecase(authRepo: Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<DeleteAccountUsecase>(
      DeleteAccountUsecase(authRepo: Get.find<AuthRepository>()),
    );

    Get.put<AuthController>(
      AuthController(
        signUpUsecase: Get.find<SignUpUscecase>(),
        signInUsecase: Get.find<SignInUsecase>(),
        signOutUsecase: Get.find<SignOutUsecase>(),
        deleteAccountUsecase: Get.find<DeleteAccountUsecase>(),
      ),
      permanent: true,
    );
  }
}
