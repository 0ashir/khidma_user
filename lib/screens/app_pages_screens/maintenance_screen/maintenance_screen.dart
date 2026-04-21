import 'package:fixit_user/config.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(language(context, translations!.maintenanceMode),
                textAlign: TextAlign.center,
                style: appCss.dmDenseBold18
                    .textColor(appColor(context).darkText))),
        body: EmptyLayout(
            title: appSettingModel?.maintenance?.title ??
                language(context, translations!.maintenanceMode),
            subtitle: appSettingModel?.maintenance?.description ??
                language(context, translations!.maintenanceModeContent),
            isButtonShow: false,
            widget: Stack(children: [
              CachedNetworkImage(
                height: Sizes.s346,
                imageUrl: "${appSettingModel?.maintenance?.image}",
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                placeholder: (context, url) => Image.asset(
                  eImageAssets.noImageFound1,
                  fit: BoxFit.fill,
                  height: Sizes.s346, /* width: Sizes.s22 */
                ).paddingAll(Insets.i18),
                errorWidget: (context, url, error) => Image.asset(
                  eImageAssets.maintenanceImage,
                  fit: BoxFit.fill,
                  height: Sizes.s346, /*  width: Sizes.s22 */
                ).paddingAll(Insets.i18),
              ),
            ])));
  }
}
