import 'package:note_app/features/auth/domain/entity/user_entity.dart';
import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository _authRepository;
  VerifyOtpUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<UserEntity> call({
    required String verificationId,
    required String smsCode,
    required String verifiedPhone
  }) {
    return _authRepository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode, phone: verifiedPhone,
    );
  }
}
