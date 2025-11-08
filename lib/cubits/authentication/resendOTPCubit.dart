import 'package:e_demand/app/generalImports.dart';

abstract class ResendOtpState {}

class ResendOtpInitial extends ResendOtpState {}

class ResendOtpInProcess extends ResendOtpState {}

class ResendOtpSuccess extends ResendOtpState {}

class ResendOtpFail extends ResendOtpState {
  ResendOtpFail(this.error);

  final dynamic error;
}

class ResendOtpCubit extends Cubit<ResendOtpState> {
  ResendOtpCubit() : super(ResendOtpInitial());
  final AuthenticationRepository authRepo = AuthenticationRepository();

  Future<void> resendOtp(
      {required final String phoneNumber,
      required final String countryCode,
      required final String authenticationType,
      final VoidCallback? onOtpSent}) async {
    try {
      emit(ResendOtpInProcess());

      if (authenticationType == "sms_gateway") {
        final Map<String, dynamic> response =
            await authRepo.resendOTPUsingSMSGateway(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
        );
        if (response["error"]) {
          emit(ResendOtpFail(response["message"]));
        } else {
          onOtpSent?.call();
          emit(ResendOtpSuccess());
        }
      } else {
        await authRepo.verifyPhoneNumber(
          "$countryCode$phoneNumber",
          onError: (final err) {
            emit(ResendOtpFail(err));
          },
          onCodeSent: () {
            onOtpSent?.call();
            emit(ResendOtpSuccess());
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      emit(ResendOtpFail(error.message));
    } catch (e) {
      emit(ResendOtpFail(e.toString()));
    }
  }

  void setDefaultOtpState() {
    emit(ResendOtpInitial());
  }
}
