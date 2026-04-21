// ignore_for_file: deprecated_member_use

import '../../../config.dart';

class AppSettingScreen extends StatelessWidget {
  const AppSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSettingProvider, ThemeService>(
        builder: (context, settingCtrl, theme, child) {
      return LoadingComponent(
          child: StatefulWrapper(
              onInit: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    hideLoading(context);
                  }
                });
              },
              child: Scaffold(
                  appBar: AppBar(
                      elevation: 0,
                      centerTitle: true,
                      leadingWidth: 80,
                      leading: CommonArrow(
                              arrow: rtl(context)
                                  ? eSvgAssets.arrowRight
                                  : eSvgAssets.arrowLeft1,
                              onTap: () => route.pushReplacementNamed(context,
                                  routeName.dashboard) /* route.pop(context) */)
                          .paddingAll(Insets.i8),
                      title: Text(language(context, translations!.appSetting),
                          style: appCss.dmDenseBold18
                              .textColor(appColor(context).darkText))),
                  body: const AppSettingLayout())));
    });
  }
}
