import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';

String? isValidMobileNumber({
  required final String number,
  required final BuildContext context,
}) {
  if (number.isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  } else if (number.length < UiUtils.minimumMobileNumberDigit ||
      number.length > UiUtils.maximumMobileNumberDigit) {
    return "mobileNumberShouldBeBetween6And15Numbers".translate(
      context: context,
    );
  }

  return null;
}

String? isValidEmail({
  required final String email,
  required BuildContext context,
}) {
  if (RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(email)) {
    return null;
  }
  return "pleaseEnterValidEmail".translate(context: context);
}

String? isTextFieldEmpty({
  required final String? value,
  required final BuildContext context,
}) {
  if (value!.isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  }

  return null;
}

/// Validate password with all requirements
///
String? isValidPassword({
  required final String password,
  required BuildContext context,
}) {
  final loginSettings = context.read<SystemSettingCubit>().loginSettings;

  if (password.trim().isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  }
  if (loginSettings != null) {
    if (loginSettings.minumumPasswordLength != null) {
      if (password.length < loginSettings.minumumPasswordLength!) {
        return "${"passwordMustBeAtLeastChars".translate(context: context)} ${loginSettings.minumumPasswordLength!} ${"characterLong".translate(context: context)}";
      }
    }
    if (loginSettings.requireAtLeastOneUppercase == true) {
      if (!RegExp('[A-Z]').hasMatch(password)) {
        return "passwordMustHaveUppercase".translate(context: context);
      }
    }
    if (loginSettings.requireAtLeastOneLowercase == true) {
      if (!RegExp('[a-z]').hasMatch(password)) {
        return "passwordMustHaveLowercase".translate(context: context);
      }
    }
    if (loginSettings.requireAtLeastOneNumber == true) {
      if (!RegExp('[0-9]').hasMatch(password)) {
        return "passwordMustHaveNumber".translate(context: context);
      }
    }
    if (loginSettings.requireAtLeastOneSpecialCharacter == true) {
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        return "passwordMustHaveSpecialChar".translate(context: context);
      }
    }
  }
  return null;
}

String? confirmPasswordValidator({
  required final String password,
  required final String confirmPassword,
  required BuildContext context,
}) {
  if (confirmPassword.isEmpty) {
    return "fieldMustNotBeEmpty".translate(context: context);
  }
  if (password != confirmPassword) {
    return "passwordsDoNotMatch".translate(context: context);
  }
  return null;
}

String filterAddressString(String text) {
  // Reverse geocoders often omit postal codes or neighbourhoods. Interpolated
  // nulls must not appear in the location label, and single-letter units are
  // valid address parts rather than duplicate commas.
  return text
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part.toLowerCase() != 'null')
      .join(', ');
}
