import '../../../config.dart';

class LoginWithPhoneScreen extends StatelessWidget {
  const LoginWithPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginWithPhoneProvider>(builder: (context1, value, child) {
      return LoadingComponent(
        child: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CommonArrow(
                            arrow: rtl(context)
                                ? eSvgAssets.arrowRight
                                : eSvgAssets.arrowLeft1,
                            onTap: () => route.pop(context))
                        .paddingSymmetric(vertical: Insets.i20),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AuthTopLayout(
                        image: eImageAssets.loginWithPhone,
                        title: translations!.loginWithPhone,
                        subTitle: translations!.enterYourRegisterPhone,
                        isNumber: false),
                  ),
                ],
              ).width(MediaQuery.of(context).size.width),
              Stack(children: [
                const FieldsBackground(),
                Form(
                    key: value.globalKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const SmallContainer(),
                            const HSpace(Sizes.s20),
                            Text(language(context, translations!.phoneNo),
                                style: appCss.dmDenseSemiBold14
                                    .textColor(appColor(context).darkText))
                          ]),
                          const VSpace(Sizes.s8),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CountryListLayout(
                                    dialCode: value.dialCode,
                                    onChanged: (country) =>
                                        value.changeDialCode(country!)),
                                const HSpace(Sizes.s4),
                                Expanded(
                                    child: TextFieldCommon(
                                        keyboardType: TextInputType.number,
                                        validator: (phone) => Validation()
                                            .phoneValidation(context, phone),
                                        controller: value.numberController,
                                        isNumber: true,
                                        focusNode: value.phoneFocus,
                                        hintText: language(context,
                                            translations!.enterPhoneNumber))),
                              ]).paddingSymmetric(horizontal: Insets.i20),
                          const VSpace(Sizes.s35),
                          ButtonCommon(
                                  title: translations!.sendOtp!,
                                  onTap: () => value.onTapOtp(context))
                              .paddingSymmetric(horizontal: Insets.i20)
                        ]).paddingSymmetric(vertical: Insets.i20))
              ])
            ]).paddingSymmetric(horizontal: Insets.i20)))),
      );
    });
  }
}
