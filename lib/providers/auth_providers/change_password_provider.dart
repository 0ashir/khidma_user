import 'dart:convert';
import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordProvider extends ChangeNotifier {
  TextEditingController txtOldPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();
  bool isNewPassword = true, isConfirmPassword = true, isOldPassword = true;
  String? email, otp;
  Future<ui.Image>? loadingImage;
  final FocusNode oldPasswordFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  UserModel? userModel;
  double slider = 4.0;

  //old password see tap
  oldPasswordSeenTap() {
    isOldPassword = !isOldPassword;
    notifyListeners();
  }

  //new password see tap
  newPasswordSeenTap() {
    isNewPassword = !isNewPassword;
    notifyListeners();
  }

  //confirm password see tap
  confirmPasswordSeenTap() {
    isConfirmPassword = !isConfirmPassword;
    notifyListeners();
  }
bool isLoader =false;
  updatePassword(context) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (resetFormKey.currentState!.validate()) {
      resetPassword(context);
    }
  }

  resetPassword(context) async {
    isLoader =true;
    // showLoading(context);
    notifyListeners();

    var body = {
      "current_password": txtOldPassword.text,
      "password": txtNewPassword.text,
      "password_confirmation": txtConfirmPassword.text,
    };

    try {
      await apiServices
          .putApi(api.updatePassword, body, isToken: true)
          .then((value) {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          isLoader=false;
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).primary);
        } else {
          isLoader =false;
          log("VVVV : ${value.message}");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      isLoader=false;
      Fluttertoast.showToast(
          msg: e.toString(), backgroundColor: appColor(context).red);
      // hideLoading(context);
      notifyListeners();
    }
  }

  static getDisposableProviders(BuildContext context) {
    return [
      Provider.of<LoginProvider>(context, listen: false),
      //...other disposable providers
    ];
  }

  static void disposeAllDisposableProviders(BuildContext context) {
    getDisposableProviders(context).forEach((disposableProvider) {
      disposableProvider.dispose();
    });
  }

  getArg(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      email = data['email'];
      otp = data['otp'];
    } else {
      userModel =
          UserModel.fromJson(json.decode(preferences.getString(session.user)!));
      email = userModel!.email;
    }
    notifyListeners();
  }

  Future<ui.Image> loadImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
}
