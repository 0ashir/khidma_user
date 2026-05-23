// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, prefer_is_empty

import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_today_offiers.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_categories.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_package_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_services.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/horizontal_blog_list.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/special_offers_layout.dart';

import '../../../../config.dart';
import 'dubai_coupon.dart';

class DubaiBody extends StatelessWidget {
  const DubaiBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardProvider, HomeScreenProvider, CommonApiProvider>(
        builder: (context3, dash, value, commonApi, child) {
      final banners = commonApi.dashboardModel?.banners;
      return StatefulWrapper(
          onInit: () {},
          child: Column(children: [
            const VSpace(Sizes.s35),
            Column(
              children: [
                const VSpace(Sizes.s16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: Sizes.s50,
                        margin:
                            const EdgeInsets.symmetric(horizontal: Insets.i20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                eSvgAssets.search,
                                fit: BoxFit.scaleDown,
                                colorFilter: ColorFilter.mode(
                                    appColor(context).darkText,
                                    BlendMode.srcIn),
                              ),
                              const HSpace(Sizes.s10),
                              SizedBox(
                                  width: Sizes.s115,
                                  child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      translations!.searchHere!,
                                      style: appCss.dmDenseRegular13.textColor(
                                          appColor(context).lightText))),
                              const HSpace(Sizes.s20),
                              SvgPicture.asset(eSvgAssets.arrowDown)
                            ]).inkWell(
                            onTap: () =>
                                route.pushNamed(context, routeName.search)),
                      ).decorated(
                          color: appColor(context).stroke.withOpacity(0.10),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 3,
                                spreadRadius: 2,
                                color: appColor(context)
                                    .darkText
                                    .withOpacity(0.06))
                          ],
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                          border: Border.all(color: appColor(context).stroke)),
                    ),
                    const HSpace(Sizes.s10),
                    CommonArrow(arrow: eSvgAssets.locationOutline).inkWell(
                        onTap: () {
                      value.locationTap(context);
                    }),
                    const HSpace(Sizes.s10),
                    Consumer<NotificationProvider>(
                        builder: (context1, notification, child) {
                      return Container(
                              alignment: Alignment.center,
                              height: Sizes.s40,
                              width: Sizes.s40,
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    SvgPicture.asset(eSvgAssets.notification,
                                        alignment: Alignment.center,
                                        fit: BoxFit.scaleDown,
                                        colorFilter: ColorFilter.mode(
                                            appColor(context).darkText,
                                            BlendMode.srcIn)),
                                    if (notification.totalCount() != 0)
                                      Positioned(
                                          top: 2,
                                          right: 2,
                                          child: Icon(Icons.circle,
                                              size: Sizes.s7,
                                              color: appColor(context).red))
                                  ]))
                          .decorated(
                              shape: BoxShape.circle,
                              color: appColor(context).fieldCardBg)
                          .inkWell(onTap: () => value.notificationTap(context))
                          .paddingOnly(
                              /*   right: rtl(context) ? 0 : Insets.i20, */
                              left: rtl(context) ? Insets.i20 : 0);
                    })
                  ],
                ),
              ],
            ).padding(horizontal: Insets.i20, bottom: Insets.i20),

            Expanded(
              child: commonApi.dashboardModel == null
                  ? const _DubaiLoadingSkeleton()
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    /// Show Home Banners
                    Column(
                      children: [
                        if (banners != null && banners.isNotEmpty)
                          BannerLayout(
                            isDubai: true,
                            bannerList: banners,
                            onPageChanged: (index, reason) =>
                                value.onSlideBanner(index),
                            onTap: commonApi.isLoading == true
                                ? (type, id) {}
                                : (type, id) =>
                                    value.onBannerTap(context, type, id),
                          ),
                        if (dash.bannerList.length > 1 &&
                            dash.bannerList
                                .any((banner) => banner.media?.isNotEmpty == true))
                          const VSpace(Sizes.s12),
                        if (dash.bannerList.length > 1 &&
                            dash.bannerList
                                .any((banner) => banner.media?.isNotEmpty == true))
                          DotIndicator(
                              list: dash.bannerList,
                              selectedIndex: value.selectIndex),
                        if (dash.bannerList.isNotEmpty &&
                            dash.bannerList
                                .any((banner) => banner.media?.isNotEmpty == true))
                          const VSpace(Sizes.s20),
                      ],
                    ),
                    const VSpace(Sizes.s25),

                    /// Top Categories
                    const DubaiCategories(),
                    const VSpace(Sizes.s25),

                    /// Services
                    const DubaiServices(),
                    const VSpace(Sizes.s15),

                    /// Coupons
                    Column(
                      children: [
                        if (commonApi.dashboardModel?.coupons?.isNotEmpty == true)
                          HeadingRowCommon(
                              title: translations!.coupons,
                              isTextSize: true,
                              onTap: () {
                                dash.getCoupons();
                                route.pushNamed(
                                    context, routeName.couponListScreen,
                                    arg: true);
                              }).paddingSymmetric(horizontal: Insets.i20),
                        if (commonApi.dashboardModel?.coupons?.isNotEmpty == true)
                          const VSpace(Sizes.s15),
                        if (commonApi.dashboardModel?.coupons?.isNotEmpty == true)
                          SizedBox(
                            height: Sizes.s150,
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: commonApi.dashboardModel?.coupons?.length ?? 0,
                                itemBuilder: (context, index) {
                                  return DubaiCoupon(
                                    data: commonApi.dashboardModel!.coupons![index],
                                  ).padding(horizontal: 5);
                                }),
                          ).padding(left: Sizes.s10),
                      ],
                    ),
                    const VSpace(Sizes.s25),
                    if (commonApi.dashboardModel2?.homeBannerAdvertisements
                            ?.isNotEmpty ??
                        false)
                      const Column(
                          children: [BerlineTodayOffers(), VSpace(Sizes.s25)]),

                    /// Packages
                    Column(children: [
                      if (homeServicePackagesList.isNotEmpty)
                        HeadingRowCommon(
                                title: translations!.servicePackage,
                                isTextSize: true,
                                onTap: () => route.pushNamed(
                                    context, routeName.servicePackagesScreen))
                            .paddingSymmetric(horizontal: Insets.i20),
                      if (homeServicePackagesList.isNotEmpty)
                        const VSpace(Sizes.s15),
                      const SizedBox(
                          height: Sizes.s75, child: DubaiPackageLayout()),
                      if (commonApi.dashboardModel2?.homeServicesAdvertisements?.isNotEmpty == true)
                        const VSpace(Sizes.s25),
                      if (commonApi.dashboardModel2?.homeServicesAdvertisements?.isNotEmpty == true)
                        const Column(
                          children: [
                            SizedBox(height: 270, child: SpecialOffersLayout()),
                            VSpace(Sizes.s25),
                          ],
                        ),
                      if (homeProvider.length != 0)
                        Column(children: [
                          HeadingRowCommon(
                              title: translations!.expertService,
                              isTextSize: true,
                              onTap: () {
                                dash.getHighestRate().then(
                                  (value) {
                                    route.pushNamed(
                                        context, routeName.expertServiceScreen);
                                  },
                                );
                              }),
                          const VSpace(Sizes.s15),
                          ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: homeProvider.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ExpertServiceLayout(
                                    data: homeProvider[index],
                                    onTap: () => route.pushNamed(context,
                                            routeName.providerDetailsScreen,
                                            arg: {
                                              'provider': homeProvider[index]
                                            }));
                              })
                        ])
                            .paddingSymmetric(
                                horizontal: Insets.i20, vertical: Insets.i25)
                            .backgroundColor(appColor(context).fieldCardBg)
                    ]),

                    if (dash.firstTwoHighRateList.isNotEmpty ||
                        dash.highestRateList.isNotEmpty)
                      const VSpace(Sizes.s25),
                    if (appSettingModel != null &&
                        appSettingModel?.activation?.blogsEnable == "1")
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (commonApi.dashboardModel2?.blogs?.isNotEmpty == true)
                              HeadingRowCommon(
                                title: translations!.latestBlog,
                                isTextSize: true,
                                onTap: () => route.pushNamed(
                                    context, routeName.latestBlogViewAll),
                              ).paddingSymmetric(horizontal: Insets.i20),
                            HorizontalBlogList(
                                blogList: commonApi.dashboardModel2?.blogs),
                            const VSpace(Sizes.s25)
                          ]),

                    if (commonApi.dashboardModel != null &&
                        appSettingModel != null &&
                        appSettingModel?.serviceRequest?.status == "1")
                      Column(children: [
                        Row(children: [
                          SvgPicture.asset(eSvgAssets.jobRequestDubai),
                          Image.asset(
                                  height: Sizes.s100, eImageAssets.dashLines)
                              .padding(left: Sizes.s22, right: Sizes.s13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    language(
                                        context,
                                        translations!
                                            .customJobRequestQuestion),
                                    textAlign: TextAlign.start,
                                    style: appCss.dmDenseMedium13.textColor(
                                        appColor(context).darkText)),
                                const VSpace(Sizes.s10),
                                Text("${translations!.postNewJobRequest}",
                                        style: appCss.dmDenseMedium13
                                            .textColor(
                                                appColor(context).whiteColor))
                                    .paddingDirectional(
                                        vertical: Sizes.s6,
                                        horizontal: Sizes.s7)
                                    .decorated(
                                        color: appColor(context).primary,
                                        borderRadius:
                                            BorderRadius.circular(Sizes.s8))
                              ],
                            ),
                          ),
                        ])
                      ])
                          .inkWell(onTap: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();

                            bool isGuest = preferences
                                    .getBool(session.isContinueAsGuest) ??
                                false;
                            if (isGuest == false) {
                              route.pushNamed(
                                  context, routeName.jobRequestList);
                            } else {
                              route.pushAndRemoveUntil(context);
                              hideLoading(context);
                            }
                          })
                          .paddingDirectional(
                              horizontal: Sizes.s20, vertical: Sizes.s13)
                          .boxBorderExtension(context,
                              color:
                                  appColor(context).primary.withOpacity(.10),
                              isShadow: true,
                              bColor:
                                  appColor(context).primary.withOpacity(.10))
                          .marginSymmetric(horizontal: Sizes.s20),
                    if (appSettingModel != null &&
                        appSettingModel?.serviceRequest?.status == "1")
                      const VSpace(Sizes.s150)
                  ],
                ),
              ),
            ),

            // const VSpace(Sizes.s25),
            // Column(children: [
            //   Row(children: [
            //     SvgPicture.asset(eSvgAssets.jobRequestToronto),
            //     const HSpace(Sizes.s13),
            //     Expanded(
            //       child: Text(
            //           language(context, translations!.customJobRequestQuestion),
            //           textAlign: TextAlign.start,
            //           style: appCss.dmDenseMedium14
            //               .textColor(appColor(context).darkText)),
            //     ),
            //     const HSpace(Sizes.s5),
            //     Container(
            //       height: Sizes.s32,
            //       width: Sizes.s32,
            //       padding: const EdgeInsets.all(5),
            //       child: RotationTransition(
            //         turns: const AlwaysStoppedAnimation(270 / 360),
            //         child: SvgPicture.asset(
            //           eSvgAssets.arrowDown,
            //           color: appColor(context).whiteColor,
            //         ),
            //       ),
            //     ).decorated(
            //         color: appColor(context).primary, shape: BoxShape.circle)
            //   ])
            // ])
            //     .inkWell(onTap: () async {
            //       SharedPreferences preferences =
            //           await SharedPreferences.getInstance();

            //       bool isGuest =
            //           preferences.getBool(session.isContinueAsGuest) ?? false;
            //       if (isGuest == false) {
            //         route.pushNamed(context, routeName.jobRequestList);
            //       } else {
            //         route.pushAndRemoveUntil(context);
            //         hideLoading(context);
            //       }
            //     })
            //     .paddingAll(20)
            //     .boxBorderExtension(context,
            //         color: appColor(context).primary.withOpacity(.10),
            //         isShadow: true,
            //         bColor: appColor(context).primary.withOpacity(.10))
            //     .marginSymmetric(horizontal: Sizes.s20),
          ]));
    });
  }
}

class _DubaiLoadingSkeleton extends StatelessWidget {
  const _DubaiLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Stack(children: [
        const CommonSkeleton(height: Sizes.s158, radius: Sizes.s8)
            .padding(horizontal: Insets.i20),
        const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonWhiteShimmer(width: Sizes.s70),
              VSpace(Sizes.s12),
              CommonWhiteShimmer(width: Sizes.s175),
              VSpace(Sizes.s12),
              CommonWhiteShimmer(width: Sizes.s130)
            ]).paddingSymmetric(horizontal: Sizes.s25, vertical: Sizes.s40)
      ]),
      const VSpace(Sizes.s20),
      const RowText().paddingSymmetric(horizontal: Sizes.s20),
      const VSpace(Sizes.s20),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ...List.generate(4, (index) {
              return Stack(children: [
                const CommonSkeleton(height: Sizes.s41, width: Sizes.s124),
                const Row(children: [
                  CommonWhiteShimmer(width: Sizes.s24),
                  HSpace(Sizes.s5),
                  CommonWhiteShimmer(width: Sizes.s80)
                ]).padding(top: Sizes.s10, left: Sizes.s8)
              ]).padding(left: Insets.i20);
            })
          ])),
      const VSpace(Sizes.s28),
      const RowText().paddingSymmetric(horizontal: Sizes.s20),
      const VSpace(Sizes.s17),
      GridView.builder(
          itemCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: Sizes.s16,
              crossAxisSpacing: Sizes.s16),
          itemBuilder: (context, index) {
            return Container(
                    margin: const EdgeInsets.all(Insets.i10),
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonSkeleton(height: Sizes.s110),
                          VSpace(Sizes.s10),
                          CommonSkeleton(height: Sizes.s12),
                          VSpace(Sizes.s10),
                          CommonSkeleton(height: Sizes.s12, width: 80),
                        ]))
                .decorated(
                    color: appColor(context).whiteBg,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    border: Border.all(color: appColor(context).stroke));
          }).paddingSymmetric(horizontal: Insets.i15),
      const VSpace(Sizes.s25),
      const HomeCouponShimmer(),
      const VSpace(Sizes.s100),
    ]).paddingSymmetric(vertical: Sizes.s20);
  }
}
