import '../../../../config.dart';

class TextFieldLayout extends StatelessWidget {
  TextFieldLayout({super.key});
  CountryCodeCustom country = CountryCodeCustom();
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileDetailProvider>(builder: (context1, value, child) {
      return Column(children: [
        ContainerWithTextLayout(title: translations!.userName),
        const VSpace(Sizes.s8),
        TextFieldCommon(
                controller: value.txtName,
                hintText: translations!.enterName!,
                focusNode: value.nameFocus,
                onFieldSubmitted: (values) => validation.fieldFocusChange(
                    context, value.nameFocus, value.emailFocus),
                prefixIcon: eSvgAssets.user,
                validator: (value) => validation.nameValidation(context, value))
            .paddingSymmetric(horizontal: Insets.i20),
        const VSpace(Sizes.s15),
        ContainerWithTextLayout(title: language(context, translations!.email)),
        const VSpace(Sizes.s8),
        TextFieldCommon(
                controller: value.txtEmail,
                hintText: language(context, translations!.enterEmail),
                focusNode: value.emailFocus,
                onFieldSubmitted: (values) => validation.fieldFocusChange(
                    context, value.emailFocus, value.phoneFocus),
                prefixIcon: eSvgAssets.email,
                validator: (value) =>
                    validation.emailValidation(context, value))
            .paddingSymmetric(horizontal: Insets.i20),
        const VSpace(Sizes.s15),
        ContainerWithTextLayout(
            title: language(context, translations!.phoneNo)),
        const VSpace(Sizes.s10),
        RegisterWidgetClass().phoneTextBox(
            dialCode:
                value.dialCode == country.dialCode ? null : value.dialCode,
            context,
            value.txtPhone,
            value.phoneFocus,
            onChanged: (CountryCodeCustom? code) => value.changeDialCode(code!),
            onFieldSubmitted: (values) => validation.fieldFocusChange(
                context, value.phoneFocus, value.phoneFocus))
      ]);
    });
  }
}
