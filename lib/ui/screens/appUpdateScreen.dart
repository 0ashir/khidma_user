import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({required this.isForceUpdate, final Key? key})
    : super(key: key);
  final bool isForceUpdate;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) =>
          AppUpdateScreen(isForceUpdate: arguments["isForceUpdate"]),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSizedBox(
                  height: context.screenHeight * 0.6,
                  width: context.screenWidth * 0.9,
                  child: Lottie.asset(
                    'assets/animation/maintenance_mode.json',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomText(
                    'updateAppTitle'.translate(context: context),
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomText(
                    isForceUpdate
                        ? 'compulsoryUpdateSubTitle'.translate(context: context)
                        : 'normalUpdateSubTitle'.translate(context: context),
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomRoundedButton(
                    onTap: () async {
                      final String launchURL = context
                          .read<SystemSettingCubit>()
                          .getCustomerAppURL;

                      final bool canLaunch = await canLaunchUrl(
                        Uri.parse(launchURL),
                      );
                      if (!context.mounted) return;
                      if (canLaunch) {
                        launchUrl(
                          Uri.parse(launchURL),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        UiUtils.showMessage(
                          context,
                          'somethingWentWrong'.translate(context: context),
                          ToastificationType.error,
                        );
                      }
                    },
                    widthPercentage: 1,
                    backgroundColor: context.colors.backgroundBrand,
                    showBorder: false,
                    buttonTitle: 'update'.translate(context: context),
                    titleColor: context.colors.textInverseLight,
                  ),
                ),
                if (!isForceUpdate)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomRoundedButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      widthPercentage: 1,
                      backgroundColor: context.colors.backgroundSecondary,
                      showBorder: true,
                      borderColor: context.colors.textPrimary,
                      buttonTitle: 'notNow'.translate(context: context),
                      titleColor: context.colors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
