// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

import '../../../../config.dart';

class DubaiPackageLayout extends StatelessWidget {
  const DubaiPackageLayout({
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
                child: Stack(children: [
                  Image.asset(
                    eImageAssets.dubai1,
                    height: 80,
                    width: 35,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    eImageAssets.dubai2,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                            color: homeServicePackagesList[index].hexaCode !=
                                    null
                                ? fromHex(homeServicePackagesList[index]
                                        .hexaCode!)
                                    .withOpacity(0.8)
                                : appColor(context).primary.withOpacity(0.8)),
                        color: appColor(context).whiteColor,
                        borderRadius: BorderRadius.circular(Insets.i9)),
                    const HSpace(Insets.i10),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(homeServicePackagesList[index].title!,
                                  overflow: TextOverflow.ellipsis,
                                  style: appCss.dmDenseMedium12
                                      .textColor(appColor(context).whiteColor))
                              .padding(right: 10),
                          Text(
                              symbolPosition
                                  ? "${getSymbol(context)}${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}"
                                  : "${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}${getSymbol(context)}",
                              style: appCss.dmDenseBold14
                                  .textColor(appColor(context).whiteColor))
                        ]))
                  ]).padding(
                      left: lang.getLocal() == "ar" ? 0 : Sizes.s25,
                      right: lang.getLocal() == "ar" ? Sizes.s25 : 0)
                ])).inkWell(onTap: () {
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
            });
          });
    });
  }
}
