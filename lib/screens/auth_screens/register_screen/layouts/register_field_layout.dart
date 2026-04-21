import '../../../../config.dart';

class RegisterFieldLayout extends StatelessWidget {
  final BuildContext? buildContext;

  const RegisterFieldLayout({super.key, this.buildContext});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
        builder: (registerContext, register, child) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerWithTextLayout(title: translations!.userName),
            const VSpace(Sizes.s8),
            TextFieldCommon(
                    controller: register.txtName,
                    hintText: translations!.enterName!,
                    focusNode: register.nameFocus,
                    onFieldSubmitted: (value) => validation.fieldFocusChange(
                        context, register.nameFocus, register.emailFocus),
                    prefixIcon: eSvgAssets.user,
                    validator: (value) =>
                        validation.nameValidation(context, value))
                .paddingSymmetric(horizontal: Insets.i20),
            const VSpace(Sizes.s15),
            ContainerWithTextLayout(
                title: language(context, translations!.email)),
            const VSpace(Sizes.s8),
            TextFieldCommon(
                    controller: register.txtEmail,
                    hintText: language(context, translations!.enterEmail),
                    focusNode: register.emailFocus,
                    onFieldSubmitted: (value) => validation.fieldFocusChange(
                        context, register.emailFocus, register.phoneFocus),
                    prefixIcon: eSvgAssets.email,
                    validator: (value) =>
                        validation.emailValidation(context, value))
                .paddingSymmetric(horizontal: Insets.i20),
            const VSpace(Sizes.s15),
            ContainerWithTextLayout(
                title: language(context, translations!.phoneNo)),
            const VSpace(Sizes.s10),
            RegisterWidgetClass().phoneTextBox(
                context, register.txtPhone, register.phoneFocus,
                dialCode: "+${appSettingModel?.general?.countryCode ?? 1}",
                onChanged: (CountryCodeCustom? code) =>
                    register.changeDialCode(code!),
                onFieldSubmitted: (value) => validation.fieldFocusChange(
                    context, register.phoneFocus, register.passwordFocus)),
            const VSpace(Sizes.s15),
            ContainerWithTextLayout(
                title: language(context, translations!.password)),
            const VSpace(Sizes.s8),
            TextFieldCommon(
                    obscureText: register.isNewPassword,
                    controller: register.txtPass,
                    hintText: language(context, translations!.enterPassword),
                    focusNode: register.passwordFocus,
                    prefixIcon: eSvgAssets.lock,
                    suffixIcon: SvgPicture.asset(
                            register.isNewPassword
                                ? eSvgAssets.hide
                                : eSvgAssets.eye,
                            fit: BoxFit.scaleDown)
                        .inkWell(onTap: () => register.newPasswordSeenTap()),
                    validator: (value) =>
                        validation.passValidation(context, value))
                .paddingSymmetric(horizontal: Insets.i20),
            const VSpace(Sizes.s15),
            ContainerWithTextLayout(title: translations!.confirmPassword),
            const VSpace(Sizes.s8),
            TextFieldCommon(
                hintText: translations!.enterConfirmPassword!,
                obscureText: register.isConfirmPassword,
                controller: register.txtConfirmPass,
                focusNode: register.confirmPasswordFocus,
                suffixIcon: SvgPicture.asset(
                        register.isConfirmPassword
                            ? eSvgAssets.hide
                            : eSvgAssets.eye,
                        fit: BoxFit.scaleDown)
                    .inkWell(onTap: () => register.confirmPasswordSeenTap()),
                prefixIcon: eSvgAssets.lock,
                validator: (value) => validation.confirmPassValidation(
                    context, value, register.txtPass.text)).paddingSymmetric(
                horizontal: Insets.i20),
            const VSpace(Sizes.s15),
            ContainerWithTextLayout(
                title:
                    "${translations!.referralCode} (${translations!.optional})"),
            const VSpace(Sizes.s8),
            TextFieldCommon(
              controller: register.refCode,
              hintText: translations!.enterReferralCode ??
                  "", // translations!.enterRefCode!,
              focusNode: register.referCodeFocus,
              prefixIcon: eSvgAssets.discount,
            ).paddingSymmetric(horizontal: Insets.i20), //translations!.refCode
            const VSpace(Sizes.s8),
            const TermsLayout(),
            const VSpace(Sizes.s35),
            ButtonCommon(
                    title: translations!.signUp!,
                    onTap: () => register.signUp(buildContext!))
                .paddingSymmetric(horizontal: Insets.i20),
            const VSpace(Sizes.s15),
            RegisterWidgetClass().notMember(context)
          ]).paddingSymmetric(vertical: Insets.i20);
    });
  }
}
