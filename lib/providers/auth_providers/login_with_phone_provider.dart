import 'dart:developer';

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

  /// Called when user taps "Send OTP" button.
  onTapOtp(BuildContext context) async {
    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate form (e.g., phone number format)
    if (globalKey.currentState!.validate()) {
      await sendOtp(context);
    }
  }

  /// Send OTP via Firebase Phone Auth.
  sendOtp(BuildContext context) async {
    showLoading(context);
    notifyListeners();

    assert(appSettingModel!.general!.defaultSmsGateway == "firebase");

    await auth.verifyPhoneNumber(
      // Full phone number: dialCode + trimmed input
      phoneNumber: "$dialCode${numberController.text.trim()}",
      timeout: const Duration(seconds: 120),

      // Auto-sign-in events are ignored; user must always type OTP manually
      verificationCompleted: (PhoneAuthCredential credential) {
        log("verificationCompleted fired (ignored — manual OTP required)");
      },

      // Called when Firebase rejects the request (invalid number, quota, etc.)
      verificationFailed: (FirebaseAuthException e) {
        hideLoading(context);
        log("Verification failed: ${e.code} - ${e.message}");
        Fluttertoast.showToast(
          msg: e.message ?? "Verification failed. Please try again.",
        );
        notifyListeners();
      },

      // Called when SMS is successfully sent
      codeSent: (String verificationId, int? resendToken) {
        // Save the Firebase verificationId (long token, NOT the 6‑digit SMS code)
        verificationCode = verificationId;
        hideLoading(context);
        notifyListeners();

        log("OTP sent. verificationCode (verificationId): $verificationCode");

        // Navigate to OTP verification screen
        route.pushNamed(context, routeName.verifyOtp, arg: {
          "phone": numberController.text.trim(),
          "dialCode": dialCode,
          "verificationCode": verificationCode,
          "uid": uid,
        });
      },

      // If auto‑retrieval times out, Firebase may send a new verificationId
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationCode = verificationId;
        notifyListeners();
        log("Auto retrieval timeout. verificationId: $verificationId");
      },
    );
  }

  /// Update dial code when user picks a country.
  changeDialCode(CountryCodeCustom country) {
    dialCode = country.dialCode!;
    notifyListeners();
  }
}