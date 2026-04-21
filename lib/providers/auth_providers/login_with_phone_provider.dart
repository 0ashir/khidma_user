import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config.dart';

class LoginWithPhoneProvider with ChangeNotifier {
  TextEditingController numberController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FocusNode phoneFocus = FocusNode();
  String? verificationCode;
  String? uid;

  onTapOtp(context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (globalKey.currentState!.validate()) {
      await sendOtp(context);
    }
  }

  sendOtp(context) async {
    showLoading(context);
    notifyListeners();

    if (appSettingModel!.general!.defaultSmsGateway == "firebase") {
      await auth.verifyPhoneNumber(
        phoneNumber: "$dialCode${numberController.text.trim()}",
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only) — Firebase handles OTP silently
          try {
            final userCredential = await auth.signInWithCredential(credential);
            uid = userCredential.user?.uid;
            hideLoading(context);
            notifyListeners();
            route.pushNamed(context, routeName.verifyOtp, arg: {
              "phone": numberController.text.trim(),
              "dialCode": dialCode,
              "verificationCode": verificationCode,
              "uid": uid
            });
          } catch (e) {
            hideLoading(context);
            log("Auto-verification sign-in failed: $e");
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          hideLoading(context);
          log("Verification failed: ${e.code} - ${e.message}");
          Fluttertoast.showToast(
              msg: e.message ?? "Verification failed. Please try again.");
          notifyListeners();
        },

        codeSent: (String verificationId, int? resendToken) {
          // KEY FIX: just save verificationId — do NOT sign in here.
          // The user will enter the SMS code on the next screen,
          // and you'll combine verificationId + that code to sign in.
          verificationCode = verificationId;
          hideLoading(context);
          notifyListeners();
          log("OTP sent. verificationCode (verificationId): $verificationCode");

          route.pushNamed(context, routeName.verifyOtp, arg: {
            "phone": numberController.text.trim(),
            "dialCode": dialCode,
            "verificationCode": verificationCode, // long token, NOT the SMS code
            "uid": uid
          });
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Update in case it changed during auto-retrieval timeout
          verificationCode = verificationId;
          notifyListeners();
          log("Auto retrieval timeout. verificationId: $verificationId");
        },
      );
    } else {
      // Non-Firebase SMS gateway (your own API)
      try {
        final body = {
          "dial_code": dialCode.replaceAll("+", ""),
          "phone": numberController.text.trim()
        };
        final formData = dio.FormData.fromMap(body);

        await apiServices.postApi(api.sendOtp, formData).then((value) {
          hideLoading(context);
          notifyListeners();
          if (value.isSuccess!) {
            route.pushNamed(context, routeName.verifyOtp, arg: {
              "phone": numberController.text.trim(),
              "dialCode": dialCode,
              "verificationCode": null, // API handles verification server-side
              "uid": uid
            });
          } else {
            Fluttertoast.showToast(msg: value.message);
          }
        });
      } catch (e) {
        hideLoading(context);
        notifyListeners();
        log("CATCH sendOtp: $e");
      }
    }
  }

  changeDialCode(CountryCodeCustom country) {
    dialCode = country.dialCode!;
    notifyListeners();
  }
}