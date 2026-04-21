import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

import '../../../../config.dart';

class TorontoPackageLayout extends StatelessWidget {
  const TorontoPackageLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, HomeScreenProvider>(
        builder: (context, lang, value, child) {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: homeServicePackagesList.length,
          itemBuilder: (context, index) {
            return Container(
              width: Sizes.s223,
              margin: EdgeInsets.only(
                  left: lang.locale?.languageCode == "ar" ? 0 : Insets.i15,
                  right: lang.locale?.languageCode == "ar" ? Insets.i15 : 0),
              decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 10, cornerSmoothing: 1)),
                  color: homeServicePackagesList[index].hexaCode != null
                      ? fromHex(homeServicePackagesList[index].hexaCode!)
                      : appColor(context).primary.withOpacity(0.8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: Sizes.s35,
                    width: Sizes.s35,
                    padding: const EdgeInsets.all(7),
                    child: homeServicePackagesList[index].media != null &&
                            homeServicePackagesList[index].media!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: homeServicePackagesList[index]
                                .media![0]
                                .originalUrl!,
                            errorWidget: (context, url, error) =>
                                Image.asset(eImageAssets.noImageFound1),
                            placeholder: (context, url) =>
                                Image.asset(eImageAssets.noImageFound1),
                          )
                        : Image.asset(eImageAssets.noImageFound1),
                  ).decorated(
                      border: Border.all(
                          color: homeServicePackagesList[index].hexaCode != null
                              ? fromHex(
                                      homeServicePackagesList[index].hexaCode!)
                                  .withOpacity(0.8)
                              : appColor(context).primary.withOpacity(0.8)),
                      color: appColor(context).whiteColor,
                      shape: BoxShape.circle),
                  Image.asset(
                    eImageAssets.linePackage,
                    height: 70,
                  ).padding(horizontal: Insets.i10, vertical: Insets.i7),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(homeServicePackagesList[index].title!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: appCss.dmDenseMedium12
                                    .textColor(appColor(context).whiteColor))
                            .padding(right: 10),
                        Text(
                            symbolPosition
                                ? "${getSymbol(context)}${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}"
                                : "${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}${getSymbol(context)}",
                            style: appCss.dmDenseBold14
                                .textColor(appColor(context).whiteColor)),
                      ],
                    ),
                  ),
                  Container(
                      height: Sizes.s30,
                      width: Sizes.s30,
                      padding: const EdgeInsets.all(5),
                      child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(270 / 360),
                          child: SvgPicture.asset(
                            eSvgAssets.arrowDown,
                            colorFilter: ColorFilter.mode(
                                appColor(context).whiteColor, BlendMode.srcIn),
                          ))).decorated(
                      border: Border.all(
                          width: 3,
                          color: appColor(context)
                              .whiteColor
                              .withValues(alpha: 0.12)),
                      color:
                          appColor(context).whiteColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                ],
              ).inkWell(onTap: () {
                if (homeServicePackagesList[index].id != null &&
                    homeServicePackagesList[index].id! > 0) {
                  route.pushNamed(
                    context,
                    routeName.packageDetailsScreen,
                    arg: {"packageId": homeServicePackagesList[index].id},
                  );
                } else {
                  log("Invalid serviceId for package: ${homeServicePackagesList[index].title}");
                  Fluttertoast.showToast(msg: "Unable to load package details");
                }
                // route.pushNamed(context, routeName.packageDetailsScreen,
                //     arg: {"services": homeServicePackagesList[index]});
                // log("dash.servicePackagesList::${homeServicePackagesList[index].id}");
              }).padding(horizontal: Sizes.s10),
            );
          });
    });
  }
}
