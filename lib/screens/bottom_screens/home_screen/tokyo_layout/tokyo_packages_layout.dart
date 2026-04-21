// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TokyoPackagesLayout extends StatelessWidget {
  const TokyoPackagesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    var lang = Provider.of<LanguageProvider>(context);
    var dash = Provider.of<DashboardProvider>(context);
    var serviceCtrl = Provider.of<ServicesPackageDetailsProvider>(context);
    return Column(
      children: [
        HeadingRowCommon(
                title: translations!.servicePackage,
                isTextSize: true,
                onTap: () =>
                    route.pushNamed(context, routeName.servicePackagesScreen))
            .padding(horizontal: Insets.i20),
        const VSpace(Sizes.s10),
        Expanded(
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: homeServicePackagesList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  decoration: ShapeDecoration(
                      color: homeServicePackagesList[index].hexaCode != null
                          ? fromHex(homeServicePackagesList[index].hexaCode!)
                              .withOpacity(0.11)
                          : appColor(context).primary.withOpacity(0.8),
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 8, cornerSmoothing: 1),
                          side: BorderSide(
                              color: homeServicePackagesList[index].hexaCode !=
                                      null
                                  ? fromHex(homeServicePackagesList[index]
                                          .hexaCode!)
                                      .withOpacity(0.11)
                                  : appColor(context)
                                      .primary
                                      .withOpacity(0.8)))),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            eImageAssets.tokyoPackageBg,
                            color: homeServicePackagesList[index].hexaCode !=
                                    null
                                ? fromHex(
                                    homeServicePackagesList[index].hexaCode!)
                                : appColor(context)
                                    .primary
                                    .withValues(alpha: 0.8),
                          ),
                          Center(
                                  child: Container(
                                          height: Sizes.s35,
                                          width: Sizes.s35,
                                          padding: const EdgeInsets.all(7),
                                          child: homeServicePackagesList[index]
                                                          .media !=
                                                      null &&
                                                  homeServicePackagesList[index]
                                                      .media!
                                                      .isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      homeServicePackagesList[
                                                              index]
                                                          .media!
                                                          .first
                                                          .originalUrl!,
                                                  // color: appColor(context)
                                                  //     .whiteColor,
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Image.asset(eImageAssets
                                                          .noImageFound1),
                                                  placeholder: (context, url) =>
                                                      Image.asset(eImageAssets
                                                          .noImageFound1),
                                                )
                                              : Image.asset(
                                                  eImageAssets.noImageFound1))
                                      .decorated(
                                          color: homeServicePackagesList[index]
                                                      .hexaCode !=
                                                  null
                                              ? fromHex(
                                                  homeServicePackagesList[index]
                                                      .hexaCode!)
                                              : appColor(context)
                                                  .primary
                                                  .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(Insets.i9)))
                              .padding(top: 32)
                        ],
                      ),
                      const VSpace(Sizes.s5),
                      Text(homeServicePackagesList[index].title!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: appCss.dmDenseMedium12
                                  .textColor(appColor(context).darkText))
                          .padding(horizontal: 8),
                      const VSpace(Sizes.s5),
                      Text(
                              symbolPosition
                                  ? "${getSymbol(context)}${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}"
                                  : "${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}${getSymbol(context)}",
                              style: appCss.dmDenseBold14
                                  .textColor(appColor(context).primary))
                          .padding(bottom: Sizes.s10),
                    ],
                  ),
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
                    Fluttertoast.showToast(
                        msg: "Unable to load package details");
                  }
                  /* route.pushNamed(context, routeName.packageDetailsScreen,
                      arg: {"services": homeServicePackagesList[index]});
                    log("dash.servicePackagesList::${homeServicePackagesList[index].id}");
*/
                }).paddingOnly(
                    left: lang.locale?.languageCode == "ar" ? 0 : 20,
                    right: lang.locale?.languageCode == "ar" ? 20 : 0);
              }),
        )
      ],
    );
  }
}
