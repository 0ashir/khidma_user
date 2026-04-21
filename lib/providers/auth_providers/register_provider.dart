import 'dart:convert';
import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterProvider extends ChangeNotifier {
  bool isNewPassword = true, isConfirmPassword = true, isCheck = false;
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  String dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtPass = TextEditingController();
  TextEditingController refCode = TextEditingController();
  TextEditingController txtConfirmPass = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode referCodeFocus = FocusNode();

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

  signUp(context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isCheck == false) {
      Fluttertoast.showToast(
          msg: language(context, translations!.pleaseCheckTerms));
    } else if (registerFormKey.currentState!.validate() && isCheck == true) {
      showLoading(context);
      notifyListeners();
      String token = await getFcmToken();
      var body = {
        "name": txtName.text,
        "email": txtEmail.text,
        "phone": txtPhone.text,
        "code": dialCode,
        "password": txtPass.text,
        "password_confirmation": txtPass.text,
        "fcm_token": token,
        "referral_code": refCode.text
      };

      log("body : $body");

      try {
        await apiServices
            .postApi(api.register, jsonEncode(body))
            .then((value) async {
          hideLoading(context);
          notifyListeners();
          if (value.isSuccess!) {
            final commonApi =
                Provider.of<CommonApiProvider>(context, listen: false);
            await commonApi.selfApi(context);
            txtName.text = "";
            txtEmail.text = "";
            txtPhone.text = "";
            dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
            txtPass.text = "";
            txtConfirmPass.text = "";
            notifyListeners();

            Fluttertoast.showToast(
                msg: "You Are Register Successfully",
                backgroundColor: appColor(context).primary);
            /*   final commonApiProvider =
                Provider.of<CommonApiProvider>(context, listen: false);
            commonApiProvider.selfApi(context); */
            route.pushReplacementNamed(context, routeName.login);
            /*  route.pop(context); */
          } else {
            Fluttertoast.showToast(
                msg: value.message, backgroundColor: appColor(context).red);
          }
        });
      } catch (e) {
        hideLoading(context);
        Fluttertoast.showToast(
            msg: "value.message", backgroundColor: appColor(context).red);
        notifyListeners();
        log("CATCH signUp: $e");
      }
    }
  }

  isCheckBoxCheck(value) {
    isCheck = value;
    notifyListeners();
  }

  onBack() {
    txtName.text = "";
    txtEmail.text = "";
    txtPhone.text = "";
    dialCode = "+${appSettingModel?.general?.countryCode ?? 1}";
    txtPass.text = "";
    txtConfirmPass.text = "";
    notifyListeners();
  }

  changeDialCode(CountryCodeCustom country) {
    dialCode = country.dialCode!;
    notifyListeners();
  }
}
