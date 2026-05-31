import '../../../config.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(builder: (loginContext, value, child) {
      return LoadingComponent(
        child: Scaffold(
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          CommonArrow(
            arrow: rtl(context)
                ? eSvgAssets.arrowRight
                : eSvgAssets.arrowLeft1,
            onTap: () => route.pop(context),
          ).paddingOnly(left: Insets.i10, top: Insets.i8),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Center(
                  child: SingleChildScrollView(
                    child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            appSettingModel?.general?.splashScreenLogo != null
                ? Image.network(
                    appSettingModel?.general?.splashScreenLogo ?? "",
                    height: Sizes.s34,
                    width: Sizes.s34,
                    fit: BoxFit.cover)
                : Image.asset(eImageAssets.appLogo, height: Insets.i34),
            const HSpace(Sizes.s5),
            Text(language(context, translations!.khidma),
                style:
                    appCss.outfitBold38.textColor(appColor(context).darkText)),
            const VSpace(Sizes.s30)
          ]),
          // Image.asset(eImageAssets.appLogo, height: Insets.i50),
          Form(
              // key: value.formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const VSpace(Sizes.s35),
                Text(language(context, translations!.login),
                    style: appCss.dmDenseBold20
                        .textColor(appColor(context).darkText)),
                const VSpace(Sizes.s15),
                const LoginLayout(),
                const VSpace(Sizes.s20),
                ContinueGuestLayout(
                  onTap: () => value.continueAsGuestTap(context),
                )
              ]).alignment(Alignment.centerLeft))
        ]).paddingSymmetric(horizontal: Insets.i20)))))])),
      ));
    });
  }
}
