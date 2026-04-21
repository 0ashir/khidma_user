import 'package:fixit_user/config.dart';
import 'package:flutter/gestures.dart';

class RegisterWidgetClass {
  //not member
  Widget notMember(context) => RichText(
          text: TextSpan(
              text: language(context, translations!.alreadyMember),
              style:
                  appCss.dmDenseMedium14.textColor(appColor(context).lightText),
              children: <TextSpan>[
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => route.pop(context),
                text: " ${language(context, translations!.loginUp)}",
                style: appCss.dmDenseSemiBold16
                    .textColor(appColor(context).primary))
          ])).alignment(Alignment.center);

  //phone textBox
  Widget phoneTextBox(context, controller, focus,
          {Function(CountryCodeCustom?)? onChanged,
          bool isValidator = true,
          ValueChanged<String>? onFieldSubmitted,
          double? hPadding,
          dialCode}) =>
      Consumer2<ProfileDetailProvider, RegisterProvider>(
          builder: (context1, value, register, child) {
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CountryListLayout(
              onChanged: onChanged,
              dialCode: dialCode,
            ),
            const HSpace(Sizes.s4),
            Expanded(
                child: TextFieldCommon(
                    keyboardType: TextInputType.number,
                    validator: isValidator == true
                        ? (phone) =>
                            Validation().phoneValidation(context, phone)
                        : null,
                    controller: controller,
                    onFieldSubmitted: onFieldSubmitted,
                    focusNode: focus,
                    isNumber: true,
                    hintText:
                        language(context, translations!.enterPhoneNumber)))
          ]).paddingSymmetric(horizontal: hPadding ?? Insets.i20),
        );
      });
}
