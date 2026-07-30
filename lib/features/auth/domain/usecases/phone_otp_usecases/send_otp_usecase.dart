import 'package:note_app/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUsecase {
  final AuthRepository _authRepository;
  SendOtpUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> call({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onVerificationFailed,
  }) {
    return _authRepository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }
}
