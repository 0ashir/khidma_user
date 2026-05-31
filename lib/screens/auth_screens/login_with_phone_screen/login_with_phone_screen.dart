import 'package:flutter/gestures.dart';
import '../../../config.dart';

class LoginWithPhoneScreen extends StatelessWidget {
  const LoginWithPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginWithPhoneProvider>(
        builder: (context, value, child) {
      return LoadingComponent(
        child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = constraints.maxHeight * 0.39 + 10;
              return Stack(
                children: [
                  // Top section background + centered image with padding
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight,
                    child: Container(
                      color: appColor(context).fieldCardBg,
                      padding: const EdgeInsets.only(
                          left: Insets.i70,
                          right: Insets.i70,
                          top: Insets.i55,
                          bottom: Insets.i38),
                      child: Image.asset(
                        eImageAssets.loginWithPhone,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // White rounded card
                  Positioned(
                    top: imageHeight - Sizes.s30,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: appColor(context).whiteBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.r28),
                          topRight: Radius.circular(AppRadius.r28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.i24, vertical: Insets.i30),
                        child: Form(
                          key: value.globalKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language(
                                    context, translations!.loginWithPhone),
                                style: appCss.dmDenseBold24
                                    .textColor(appColor(context).darkText),
                              ),
                              const VSpace(Sizes.s8),
                              Text(
                                language(context,
                                    translations!.enterYourRegisterPhone),
                                style: appCss.dmDenseMedium14.textColor(
                                    appColor(context).lightText),
                              ),
                              const VSpace(Sizes.s28),
                              Text(
                                language(context, translations!.phoneNo),
                                style: appCss.dmDenseSemiBold14
                                    .textColor(appColor(context).darkText),
                              ),
                              const VSpace(Sizes.s10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: appColor(context).stroke),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r12),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: Insets.i8,
                                          right: Insets.i4),
                                      child: CountryListLayout(
                                        dialCode: value.dialCode,
                                        onChanged: (country) =>
                                            value.changeDialCode(country!),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: Sizes.s30,
                                        color: appColor(context).stroke),
                                    Expanded(
                                      child: TextFieldCommon(
                                        keyboardType:
                                            TextInputType.number,
                                        validator: (phone) =>
                                            Validation().phoneValidation(
                                                context, phone),
                                        controller:
                                            value.numberController,
                                        isNumber: true,
                                        focusNode: value.phoneFocus,
                                        hintText: language(context,
                                            translations!.enterPhoneNumber),
                                        fillColor:
                                            appColor(context).whiteBg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const VSpace(Sizes.s30),
                              ButtonCommon(
                                title: translations!.sendOtp!,
                                onTap: () => value.onTapOtp(context),
                              ),
                              if (appSettingModel != null &&
                                  appSettingModel!.activation!
                                          .socialLoginEnable ==
                                      "1") ...[
                                const VSpace(Sizes.s20),
                                _OutlinedSocialButton(
                                  logo: eImageAssets.google,
                                  title: language(context,
                                      translations!.continueWithGoogle),
                                  onTap: () => context
                                      .read<LoginProvider>()
                                      .signInWithGoogle(context),
                                ),
                                const VSpace(Sizes.s12),
                                _OutlinedSocialButton(
                                  logo: eImageAssets.mobile,
                                  title: language(context,
                                      translations!.continueWithEmail),
                                  onTap: () => route.pushNamed(
                                      context, routeName.loginWithPhone),
                                ),
                              ],
                              const VSpace(Sizes.s16),
                              RichText(
                                text: TextSpan(
                                  text: language(
                                      context, translations!.notMember),
                                  style: appCss.dmDenseMedium14
                                      .textColor(appColor(context).lightText),
                                  children: [
                                    TextSpan(
                                      text: language(
                                          context, translations!.signUp),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => route.pushNamed(
                                            context, routeName.registerUser),
                                      style: appCss.dmDenseSemiBold14
                                          .textColor(appColor(context).primary),
                                    ),
                                  ],
                                ),
                              ).alignment(Alignment.center),
                              const VSpace(Sizes.s24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Back arrow over the image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: CommonArrow(
                          arrow: rtl(context)
                              ? eSvgAssets.arrowRight
                              : eSvgAssets.arrowLeft1,
                          onTap: () => route.pop(context),
                        ).paddingOnly(
                            left: Insets.i10, top: Insets.i8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

class _OutlinedSocialButton extends StatelessWidget {
  final String logo;
  final String title;
  final VoidCallback? onTap;

  const _OutlinedSocialButton(
      {required this.logo, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: Insets.i14, horizontal: Insets.i20),
        decoration: BoxDecoration(
          color: appColor(context).whiteBg,
          border: Border.all(color: appColor(context).stroke),
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logo, height: Sizes.s22, width: Sizes.s22),
            const SizedBox(width: 10),
            Text(
              title,
              style: appCss.dmDenseMedium14
                  .textColor(appColor(context).darkText),
            ),
          ],
        ),
      ),
    );
  }
}
