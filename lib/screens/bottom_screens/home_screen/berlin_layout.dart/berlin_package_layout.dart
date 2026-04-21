// ignore_for_file: deprecated_member_use

import 'package:fixit_user/config.dart';

class BerlinPackageLayout extends StatelessWidget {
  const BerlinPackageLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LanguageProvider, HomeScreenProvider,DashboardProvider>(
        builder: (context, lang, value,dash, child) {
      return Column(
        children: [
          HeadingRowCommon(
              title: language(context, translations?.servicePackage),
              isTextSize: true,
              onTap: () {
                dash.getServicePackage();
                route.pushNamed(context, routeName.servicePackagesScreen);
              }).padding(bottom: Sizes.s16, horizontal: Sizes.s20),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: homeServicePackagesList.length,
                itemBuilder: (context, index) {
                  return Container(
                    // height: 100,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.s8),
                        color: homeServicePackagesList[index].hexaCode != null
                            ? fromHex(homeServicePackagesList[index].hexaCode!)
                            : appColor(context).primary.withOpacity(0.8)),
                    child: Stack(
                      children: [
                        Image.asset(eImageAssets.berlinPackage,
                            height: 40,
                            fit: BoxFit.cover,
                            color:
                                appColor(context).whiteColor.withOpacity(0.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: Sizes.s40,
                              width: Sizes.s40,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: appColor(context).whiteColor),
                              child: homeServicePackagesList[index].media !=
                                          null &&
                                      homeServicePackagesList[index]
                                          .media!
                                          .isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: homeServicePackagesList[index]
                                          .media![0]
                                          .originalUrl!,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              eImageAssets.noImageFound1),
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              eImageAssets.noImageFound1),
                                    )
                                  : Image.asset(eImageAssets.noImageFound1),
                            ),
                          ],
                        ).paddingDirectional(top: Sizes.s20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(homeServicePackagesList[index].title!,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: appCss.dmDenseMedium12
                                    .textColor(appColor(context).whiteColor)),
                            const VSpace(Sizes.s5),
                            Text(
                                symbolPosition
                                    ? "${getSymbol(context)}${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}"
                                    : "${(currency(context).currencyVal * homeServicePackagesList[index].price!).toStringAsFixed(2)}${getSymbol(context)}",
                                style: appCss.dmDenseBold15
                                    .textColor(appColor(context).whiteColor)),
                          ],
                        ).center().padding(top: Sizes.s65),
                      ],
                    ),
                  ).inkWell(onTap: () {
                    route.pushNamed(context, routeName.packageDetailsScreen,
                        arg: {"packageId": homeServicePackagesList[index].id});
                  }).paddingOnly(left: 15);
                }),
          )
        ],
      );
    });
  }
}
