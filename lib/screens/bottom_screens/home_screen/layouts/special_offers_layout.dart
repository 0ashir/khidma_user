
import 'package:fixit_user/config.dart';

class SpecialOffersLayout extends StatelessWidget {
  const SpecialOffersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ServicesDetailsProvider, CommonApiProvider,
            DashboardProvider>(
        builder: (context, serviceDetails, commonApi, dash, child) {
      return commonApi.dashboardModel2!.homeServicesAdvertisements!.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: [
                HeadingRowCommon(
                        title: language(context, translations?.specialOffers),
                        isTextSize: true,
                        isViewAll: false,
                        onTap:
                            () {} /* => route.pushNamed(
                            context, routeName.expertServiceScreen) */
                        )
                    .padding(bottom: Sizes.s16, horizontal: Insets.i20),
                if (commonApi.dashboardModel2 != null &&
                    commonApi.dashboardModel2!.homeServicesAdvertisements!
                        .isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: commonApi.dashboardModel2!
                                .homeServicesAdvertisements!.isNotEmpty
                            ? commonApi
                                .dashboardModel2
                                ?.homeServicesAdvertisements /* ![0]
                                .services
                                ? */
                                ?.length
                            : 0,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          // log("commonApi.dashboardModel2?.homeServicesAdvertisements?::${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[index]}");
                          return Container(
                                  // height: Sizes.s198,
                                  width: Sizes.s205,
                                  margin: const EdgeInsets.all(Insets.i10),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            // Check if media list exists and is not empty
                                            if (commonApi
                                                        .dashboardModel2
                                                        ?.homeServicesAdvertisements?[
                                                            index]
                                                        .services?[0]
                                                        .media !=
                                                    null &&
                                                commonApi
                                                        .dashboardModel2
                                                        ?.homeServicesAdvertisements?[
                                                            index]
                                                        .services?[0]
                                                        .media!
                                                        .isNotEmpty ==
                                                    true)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Insets.i7),
                                                child: CommonImageLayout(
                                                  tlRadius: 0,
                                                  tRRadius: 0,
                                                  blRadius: 0,
                                                  bRRadius: 0,
                                                  isAllBorderRadius: false,
                                                  image: commonApi
                                                          .dashboardModel2!
                                                          .homeServicesAdvertisements![
                                                              index]
                                                          .services![0]
                                                          .media![0]
                                                          .originalUrl ??
                                                      '',
                                                  boxFit: BoxFit.cover,
                                                  height: Sizes.s110,
                                                  assetImage: eImageAssets
                                                      .noImageFound2,
                                                ),
                                              )
                                            else
                                              CommonCachedImage(
                                                tlRadius: 0,
                                                tRRadius: 0,
                                                blRadius: 0,
                                                bRRadius: 0,
                                                isAllBorderRadius: false,
                                                height: Sizes.s110,
                                                image:
                                                    eImageAssets.noImageFound2,
                                              ),

                                            // commonApi
                                            //                 .dashboardModel2
                                            //                 ?.homeServicesAdvertisements?[
                                            //                     index]
                                            //                 .services?[index]
                                            //                 .media !=
                                            //             null &&
                                            //         commonApi
                                            //                 .dashboardModel2
                                            //                 ?.homeServicesAdvertisements?[
                                            //                     index]
                                            //                 .services?[index]
                                            //                 .media !=
                                            //             [] &&
                                            //         commonApi
                                            //             .dashboardModel2
                                            //             ?.homeServicesAdvertisements?[
                                            //                 index]
                                            //             .services?[index]
                                            //             .media?[index]
                                            //     ? ClipRRect(
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //                 Insets.i7),
                                            //         child: CommonImageLayout(
                                            //             tlRadius: 0,
                                            //             tRRadius: 0,
                                            //             blRadius: 0,
                                            //             bRRadius: 0,
                                            //             isAllBorderRadius:
                                            //                 false,
                                            //             image: commonApi
                                            //                 .dashboardModel2
                                            //                 ?.homeServicesAdvertisements?[
                                            //                     index]
                                            //                 .services?[index]
                                            //                 .media?[index]
                                            //                 .originalUrl,
                                            //             boxFit: BoxFit.cover,
                                            //             height: Sizes.s110,
                                            //             assetImage: eImageAssets
                                            //                 .noImageFound2),
                                            //       )
                                            //     : CommonCachedImage(
                                            //         tlRadius: 0,
                                            //         tRRadius: 0,
                                            //         blRadius: 0,
                                            //         bRRadius: 0,
                                            //         isAllBorderRadius: false,
                                            //         height: Sizes.s110,
                                            //         image: eImageAssets
                                            //             .noImageFound2),
                                            if (commonApi
                                                        .dashboardModel2
                                                        ?.homeServicesAdvertisements?[
                                                            index]
                                                        .services?[0]
                                                        .discount !=
                                                    null &&
                                                commonApi
                                                        .dashboardModel2
                                                        ?.homeServicesAdvertisements?[
                                                            index]
                                                        .services?[0]
                                                        .discount !=
                                                    0)
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Text(
                                                      "${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].discount}%",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const VSpace(Sizes.s10),
                                        Text(
                                            textAlign: TextAlign.start,
                                            "${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].title}",
                                            overflow: TextOverflow.ellipsis,
                                            style: appCss.dmDenseSemiBold15
                                                .textColor(appColor(context)
                                                    .darkText)),
                                        const VSpace(Sizes.s5),
                                        IntrinsicHeight(
                                            child: Row(children: [
                                          SvgPicture.asset(eSvgAssets.clock),
                                          const HSpace(Sizes.s5),
                                          Text(
                                              "${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].duration ?? ""}${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].durationUnit.toString().replaceAll("DurationUnit.", "").toLowerCase()}",
                                              style: appCss.dmDenseSemiBold12
                                                  .textColor(appColor(context)
                                                      .online)),
                                          VerticalDivider(
                                                  indent: 4,
                                                  endIndent: 4,
                                                  width: 1,
                                                  color:
                                                      appColor(context).online)
                                              .padding(
                                                  left: Insets.i5,
                                                  right: Sizes.s3),
                                          SvgPicture.asset(
                                              eSvgAssets.servicemenIcon,
                                              height: Sizes.s16,
                                              colorFilter: ColorFilter.mode(
                                                  appColor(context).online,
                                                  BlendMode.srcIn)),
                                          const HSpace(Sizes.s5),
                                          Text(
                                              "${commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].requiredServicemen}",
                                              style: appCss.dmDenseSemiBold12
                                                  .textColor(
                                                      appColor(context).online))
                                        ])),
                                        const VSpace(Sizes.s5),
                                        IntrinsicHeight(
                                            child: Row(children: [
                                          Text(
                                              symbolPosition
                                                  ? "${getSymbol(context)}${(currency(context).currencyVal * (commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].price ?? 0).toDouble()).round()}"
                                                  : "${(currency(context).currencyVal * (commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].price ?? 0).toDouble()).round()}${getSymbol(context)}",
                                              style: appCss.dmDenseRegular11
                                                  .textColor(appColor(context)
                                                      .lightText)
                                                  .lineThrough),
                                          const HSpace(Sizes.s5),
                                          Text(
                                              symbolPosition
                                                  ? "${getSymbol(context)}${((currency(context).currencyVal * (commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].serviceRate ?? 0).toDouble() /*  homeFeaturedService[index].serviceRate! */).toStringAsFixed(2))}"
                                                  : "${((currency(context).currencyVal * (commonApi.dashboardModel2?.homeServicesAdvertisements?[index].services?[0].serviceRate ?? 0).toDouble() /*  homeFeaturedService[index].serviceRate! */).toStringAsFixed(2))}${getSymbol(context)}",
                                              style: appCss.dmDenseBold14
                                                  .textColor(appColor(context)
                                                      .darkText)),
                                          const Spacer(),
                                          /*     isInCart(
                                                  context,
                                                  commonApi
                                                      .dashboardModel2
                                                      ?.homeServicesAdvertisements?[
                                                          index]
                                                      .services?[index]
                                                      .id)
                                              ? AddedButtonCommon(
                                                  onTap: () => dash.onFeatured(
                                                      context,
                                                      commonApi
                                                          .dashboardModel2
                                                          ?.homeServicesAdvertisements?[
                                                              index]
                                                          .services?[index],
                                                      index,
                                                      inCart: isInCart(
                                                          context,
                                                          commonApi
                                                              .dashboardModel2
                                                              ?.homeServicesAdvertisements?[
                                                                  index]
                                                              .services?[index]
                                                              .id)))
                                              : */
                                          AddButtonCommon(onTap: () {
                                            dash.onFeatured(
                                                context,
                                                commonApi
                                                    .dashboardModel2
                                                    ?.homeServicesAdvertisements?[
                                                        index]
                                                    .services?[0],
                                                index,
                                                inCart: isInCart(
                                                    context,
                                                    commonApi
                                                        .dashboardModel2
                                                        ?.homeServicesAdvertisements?[
                                                            index]
                                                        .services?[0]
                                                        .id));
                                          })
                                        ]))
                                      ]))
                              .inkWell(
                                onTap: () {
                                  final serviceId = commonApi
                                      .dashboardModel2
                                      ?.homeServicesAdvertisements?[index]
                                      .services?[index]
                                      .id;
                                  serviceDetails.getServiceById(
                                      context, serviceId);
                                  route.pushNamed(
                                      context, routeName.servicesDetailsScreen,
                                      arg: {
                                        'serviceId': serviceId,
                                      });
                                },
                              )
                              .decorated(
                                  color: appColor(context).whiteBg,
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 3,
                                        spreadRadius: 2,
                                        color: appColor(context)
                                            .darkText
                                            .withOpacity(0.06))
                                  ],
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r8),
                                  border: Border.all(
                                      color: appColor(context).stroke))
                              .padding(left: Insets.i15);
                        }),
                  ),
              ],
            );
    });
  }
}
