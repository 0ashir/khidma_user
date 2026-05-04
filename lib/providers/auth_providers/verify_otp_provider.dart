import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';

import '../../config.dart';

class VerifyOtpProvider with ChangeNotifier {
  TextEditingController otpController = TextEditingController();
  GlobalKey<FormState> otpKey = GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String? phone, dialCode, verificationCode, min, sec, email, uid;
  bool isCodeSent = false, isCountDown = false, isEmail = false;
  Timer? countdownTimer;
  final FocusNode phoneFocus = FocusNode();
  final FocusNode otpFocusNode = FocusNode();
  Duration myDuration = const Duration(seconds: 60);

  onTapVerify(context) {
    if (otpKey.currentState!.validate()) {
      if (isEmail) {
        verifyOtp(context);
      } else {
        verifyPhoneOtp(context);
      }
    }
  }

  //verify otp
  verifyOtp(context) async {
    showLoading(context);
    notifyListeners();

    var body = {"otp": otpController.text, "email": email};
    log("body : $body");

    try {
      await apiServices.postApi(api.verifyOtp, jsonEncode(body)).then((value) {
        hideLoading(context);
        log("SSSS : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {
          route.pushNamed(context, routeName.resetPass,
              arg: {"otp": otpController.text, "email": email});
        } else {
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("CATCH verifyOtp: $e");
    }
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  //verify phone otp
/*   verifyPhoneOtp(context) async {
    showLoading(context);
    notifyListeners();
    if (appSettingModel!.general!.defaultSmsGateway == "firebase") {
      var body = {"otp": otpController.text, "phone": phone};
      try {
        log("body::1212${body}");
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationCode!,
          smsCode: otpController.text.trim(),
        );

        await auth.signInWithCredential(credential);
        hideLoading(context);
        login(context)
            /* User? user = (await auth.signInWithCredential(credential)).user;
        login(context, user!) */
            ;
        /*   setState(() => isLoading = false); */
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );
      } catch (e, s) {
        log("body::2323${body}");
        log("body::2323$e-=-=-=$s");
        hideLoading(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
      log("body::${body}");
    } else {
      var body = {"otp": otpController.text, "phone": phone};
      log("body : $body");
      dio.FormData formData = dio.FormData.fromMap(body);

      try {
        await apiServices.postApi(api.verifySendOtp, formData).then((value) {
          if (value.isSuccess!) {
            login(context);
          } else {
            Fluttertoast.showToast(
                msg: value.message, backgroundColor: appColor(context).red);
          }
        });
      } catch (e) {
        hideLoading(context);
        notifyListeners();
        log("CATCH verifyOtp: $e");
      }
    }
  } */

  // Future<void> verifyPhoneOtp(BuildContext context) async {
  //   final phoneProvider =
  //       Provider.of<LoginWithPhoneProvider>(context, listen: false);
  //   showLoading(context);
  //   notifyListeners();

  //   if (phoneProvider.verificationCode == null) {
  //     hideLoading(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text("No verification code found. Please resend OTP.")),
  //     );
  //     return;
  //   }

  //   if (appSettingModel!.general!.defaultSmsGateway == "firebase") {
  //     try {
  //       log("OTP verify: ${otpController.text}, phone: $phone, verificationCode: ${phoneProvider.verificationCode}");

  //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //         verificationId: phoneProvider.verificationCode!,
  //         smsCode: otpController.text.trim(),
  //       );

  //       await auth.signInWithCredential(credential);

  //       hideLoading(context);
  //       login(context);
  //     } catch (e, s) {
  //       log("OTP verify error: $e, $s");
  //       hideLoading(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: $e")),
  //       );
  //     }
  //   } else {
  //     var body = {"otp": otpController.text, "phone": phone};
  //     log("body : $body");
  //     dio.FormData formData = dio.FormData.fromMap(body);

  //     try {
  //       await apiServices.postApi(api.verifySendOtp, formData).then((value) {
  //         hideLoading(context);
  //         if (value.isSuccess!) {
  //           login(context);
  //         } else {
  //           Fluttertoast.showToast(
  //               msg: value.message, backgroundColor: appColor(context).red);
  //         }
  //       });
  //     } catch (e) {
  //       hideLoading(context);
  //       notifyListeners();
  //       log("CATCH verifyOtp: $e");
  //     }
  //   }
  // }

  defaultTheme(context) {
    final defaultPinTheme = PinTheme(
        textStyle:
            appCss.dmDenseSemiBold18.textColor(appColor(context).darkText),
        width: Sizes.s55,
        height: Sizes.s48,
        decoration: BoxDecoration(
            color: appColor(context).whiteBg,
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(color: appColor(context).whiteBg)));
    return defaultPinTheme;
  }

getArgument(context) {
  dynamic data = ModalRoute.of(context)!.settings.arguments;
  if (data['email'] != null) {
    isEmail = true;
    email = data["email"].toString();
  } else {
    isEmail = false;
    phone = data["phone"].toString();
    dialCode = data["dialCode"].toString();
    verificationCode = data["verificationCode"]?.toString();
    uid = data["uid"]?.toString();
    log("verificationCode from args: $verificationCode");
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusNode.requestFocus();
    });
  }
  log("ARG : $data");
  notifyListeners();
}

Future<void> verifyPhoneOtp(BuildContext context) async {
  showLoading(context);
  notifyListeners();

  if (appSettingModel!.general!.defaultSmsGateway == "firebase") {
    if (verificationCode == null || verificationCode == 'null') {
      hideLoading(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No verification code found. Please resend OTP.")),
      );
      return;
    }

    try {
      log("OTP verify: ${otpController.text}, verificationCode: $verificationCode");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationCode!,
        smsCode: otpController.text.trim(),
      );

      await auth.signInWithCredential(credential);

      await login(context);
    } catch (e, s) {
      log("OTP verify error: $e, $s");
      hideLoading(context);
      Fluttertoast.showToast(
          msg: "Invalid OTP. Please try again.",
          backgroundColor: Colors.red);
    }
  } else {
    var body = {"otp": otpController.text, "phone": phone};
    dio.FormData formData = dio.FormData.fromMap(body);

    try {
      await apiServices.postApi(api.verifySendOtp, formData).then((value) {
        hideLoading(context);
        if (value.isSuccess!) {
          login(context);
        } else {
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("CATCH verifyOtp: $e");
    }
  }
}

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
    notifyListeners();
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      isCountDown = false;
      countdownTimer!.cancel();
    } else {
      isCountDown = true;
      myDuration = Duration(seconds: seconds);
    }
    notifyListeners();
    String strDigits(int n) => n.toString().padLeft(2, '0');
    min = strDigits(myDuration.inMinutes.remainder(60));
    sec = strDigits(myDuration.inSeconds.remainder(60));
    notifyListeners();
  }

  //resend code
  resendOtp(context) async {
    otpController.clear();
    showLoading(context);
    notifyListeners();

    if (appSettingModel!.general!.defaultSmsGateway == "firebase") {
      try {
        await auth.verifyPhoneNumber(
          phoneNumber: "$dialCode$phone",
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            hideLoading(context);
            log("Resend failed: $e");
            Fluttertoast.showToast(
                msg: e.message ?? "Failed to resend OTP. Please try again.");
          },
          codeSent: (String verificationId, int? resendToken) {
            verificationCode = verificationId;
            hideLoading(context);
            myDuration = const Duration(seconds: 60);
            startTimer();
            notifyListeners();
            Fluttertoast.showToast(
                msg: "OTP resent successfully.",
                backgroundColor: appColor(context).primary);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationCode = verificationId;
            notifyListeners();
          },
          timeout: const Duration(seconds: 60),
        );
      } catch (e) {
        hideLoading(context);
        notifyListeners();
        log("EEEE resendOtp Firebase: $e");
      }
    } else {
      try {
        var body = {"dial_code": dialCode!.replaceAll("+", ""), "phone": phone};
        dio.FormData formData = dio.FormData.fromMap(body);

        log("BODU :$body");

        await apiServices.postApi(api.sendOtp, formData).then((value) async {
          hideLoading(context);
          notifyListeners();
          if (value.isSuccess!) {
            myDuration = const Duration(seconds: 60);
            startTimer();
            Fluttertoast.showToast(
                msg: value.message, backgroundColor: appColor(context).primary);
            notifyListeners();
          } else {
            Fluttertoast.showToast(msg: value.message);
          }
        });
      } catch (e) {
        hideLoading(context);
        notifyListeners();
        log("EEEE sendOTP : $e");
      }
    }
  }

  //login
  login(context) async {
    String token = await getFcmToken() ?? "";
    var body = {
      "login_type": "phone",
      "user": {"phone": phone, "code": dialCode},
      'fcm_token': token
    };

    log("body : $body");

    try {
      await apiServices
          .postApi(api.socialLogin, jsonEncode(body))
          .then((value) async {
        hideLoading(context);
        log("VVVV : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {
          SharedPreferences pref = await SharedPreferences.getInstance();

          pref.setBool(session.isContinueAsGuest, false);
          final commonApi =
              Provider.of<CommonApiProvider>(context, listen: false);
          await commonApi.selfApi(context);
          dynamic userData = pref.getString(session.user);
          if (userData != null) {
            final locationCtrl =
                Provider.of<LocationProvider>(context, listen: false);
            pref.remove(session.isContinueAsGuest);
            locationCtrl.getUserCurrentLocation(context);
            locationCtrl.getLocationList(context);
            locationCtrl.getCountryState();
            final dashCtrl =
                Provider.of<DashboardProvider>(context, listen: false);
            dashCtrl.getJobRequest();

            final cartCtrl = Provider.of<CartProvider>(context, listen: false);
            cartCtrl.onReady(context);
            final notifyCtrl =
                Provider.of<NotificationProvider>(context, listen: false);
            notifyCtrl.getNotificationList(context);
          }
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).primary);
          route.pushReplacementNamed(context, routeName.dashboard);
        } else {
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("CATCH login: $e");
    }
  }
}
