// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, prefer_is_empty
import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_categories.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_today_offiers.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/horizontal_blog_list.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/special_offers_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/tokyo_layout/tokyo_coupon_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/tokyo_layout/tokyo_packages_layout.dart';

class TokyoBody extends StatelessWidget {
  const TokyoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer5<DashboardProvider, HomeScreenProvider, CommonApiProvider,
            ProfileProvider, LanguageProvider>(
        builder: (context3, dash, value, commonApi, profile, lang, child) {
      log("homeProvider:$homeProvider");
      return StatefulWrapper(
          onInit: () {},
          child: ListView(
            children: [
              Stack(
                children: [
                  Container(
                      height: Sizes.s158,
                      padding: const EdgeInsets.only(
                          bottom: Sizes.s13, top: Sizes.s18),
                      decoration: ShapeDecoration(
                          color: appColor(context).primary,
                          shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.only(
                                  bottomLeft: SmoothRadius(
                                      cornerRadius: 20, cornerSmoothing: 1),
                                  bottomRight: SmoothRadius(
                                      cornerRadius: 20, cornerSmoothing: 1)))),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const HSpace(Sizes.s20),
                                  CommonArrow(
                                      onTap: () => value.locationTap(context),
                                      arrow: eSvgAssets.location,
                                      svgColor: appColor(context).whiteColor,
                                      color: appColor(context)
                                          .whiteColor
                                          .withOpacity(0.2)),
                                  const HSpace(Sizes.s10),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  setPrimaryAddress == null
                                                      ? language(
                                                          context,
                                                          translations!
                                                              .currentLocation)
                                                      : setPrimaryAddress == -1
                                                          ? language(
                                                              context,
                                                              translations!
                                                                  .currentLocation)
                                                          : capitalizeFirstLetter(
                                                              userPrimaryAddress!
                                                                  .type),
                                                  style: appCss.dmDenseRegular13
                                                      .textColor(appColor(
                                                              context)
                                                          .whiteColor
                                                          .withOpacity(0.8))),
                                              const HSpace(Sizes.s5),
                                              SvgPicture.asset(
                                                  eSvgAssets.arrowDown,
                                                  color: appColor(context)
                                                      .whiteColor)
                                            ]).inkWell(
                                            onTap: () =>
                                                value.locationTap(context)),
                                        if (street != null)
                                          SizedBox(
                                              width: Sizes.s180,
                                              child: Text(street!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: appCss
                                                          .dmDenseBold14
                                                          .textColor(
                                                              appColor(context)
                                                                  .whiteColor))
                                                  .inkWell(
                                                      onTap: () =>
                                                          value.locationTap(
                                                              context)))
                                      ])
                                ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    eSvgAssets.search,
                                    color: appColor(context).whiteColor,
                                  ).inkWell(onTap: () {
                                    route.pushNamed(context, routeName.search);
                                  }),
                                  const HSpace(Sizes.s15),
                                  Consumer<NotificationProvider>(
                                      builder: (context1, notification, child) {
                                    return Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                          SvgPicture.asset(
                                              eSvgAssets.notification,
                                              alignment: Alignment.center,
                                              fit: BoxFit.scaleDown,
                                              colorFilter: ColorFilter.mode(
                                                  appColor(context).whiteColor,
                                                  BlendMode.srcIn)),
                                          if (notification.totalCount() != 0)
                                            Positioned(
                                                top: 2,
                                                right: 2,
                                                child: Icon(Icons.circle,
                                                    size: Sizes.s7,
                                                    color:
                                                        appColor(context).red))
                                        ])
                                        .decorated(shape: BoxShape.circle)
                                        .inkWell(
                                            onTap: () =>
                                                value.notificationTap(context))
                                        .paddingOnly(
                                            right:
                                                rtl(context) ? 0 : Insets.i20,
                                            left:
                                                rtl(context) ? Insets.i20 : 0);
                                  })
                                ])
                          ])),
                  Column(
                    children: [
                      if (commonApi.dashboardModel != null &&
                          commonApi.dashboardModel!.banners!.isNotEmpty &&
                          commonApi.dashboardModel!.banners!
                              .any((banner) => banner.media!.isNotEmpty))
                        BannerLayout(
                            isDubai: true,
                            bannerList: commonApi.dashboardModel!.banners,
                            onPageChanged: (index, reason) =>
                                value.onSlideBanner(index),
                            onTap: commonApi.isLoading == true
                                ? (type, id) {
                                    print("object=-===-=-=-=-=-=-=-=-=");
                                  }
                                : (type, id) {
                                    log("object=-===-=-=-=-=-=-=-=-=");
                                    value.onBannerTap(context, type, id);
                                  }),
                      if (commonApi.dashboardModel != null &&
                          commonApi.dashboardModel!.banners!.length > 1 &&
                          dash.bannerList
                              .any((banner) => banner.media!.isNotEmpty))
                        const VSpace(Sizes.s12),
                      if (commonApi.dashboardModel != null &&
                          commonApi.dashboardModel!.banners!.length > 1 &&
                          commonApi.dashboardModel!.banners!
                              .any((banner) => banner.media!.isNotEmpty))
                        DotIndicator(
                                list: commonApi.dashboardModel!.banners!,
                                selectedIndex: value.selectIndex)
                            .padding(top: Sizes.s12),
                      if (commonApi.dashboardModel != null &&
                          commonApi.dashboardModel!.banners!.isNotEmpty &&
                          commonApi.dashboardModel!.banners!
                              .any((banner) => banner.media!.isNotEmpty))
                        const VSpace(Sizes.s20),
                    ],
                  ).padding(top: Sizes.s75),
                ],
              ),
              // const VSpace(Sizes.s10),
              Column(
                children: [
                  if (commonApi.dashboardModel != null &&
                      commonApi.dashboardModel!.coupons!.isNotEmpty)
                    HeadingRowCommon(
                        title: translations!.coupons,
                        isTextSize: true,
                        onTap: () {
                          dash.getCoupons();
                          route.pushNamed(context, routeName.couponListScreen,
                              arg: true);
                        }).paddingSymmetric(horizontal: Insets.i20),
                  if (commonApi.dashboardModel != null &&
                      commonApi.dashboardModel!.coupons != null &&
                      dash.couponList.isNotEmpty &&
                      commonApi.dashboardModel!.coupons!.length >=
                          dash.couponList.length)
                    const VSpace(Sizes.s15),
                  if (commonApi.dashboardModel != null &&
                      commonApi.dashboardModel!.coupons != null &&
                      dash.couponList.isNotEmpty &&
                      commonApi.dashboardModel!.coupons!.length >=
                          dash.couponList.length)
                    SizedBox(
                      height: Sizes.s100,
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: dash.couponList.length,
                          itemBuilder: (context, index) {
                            return TokyoCouponLayout(
                                data:
                                    commonApi.dashboardModel!.coupons![index]);
                          }),
                    ),
                ],
              ),
              if (commonApi.dashboardModel != null &&
                  commonApi.dashboardModel!.coupons != null &&
                  dash.couponList.isNotEmpty &&
                  commonApi.dashboardModel!.coupons!.length >=
                      dash.couponList.length)
                const VSpace(Sizes.s25),
              if (commonApi.dashboardModel != null &&
                  commonApi.dashboardModel!.categories!.isNotEmpty)
                Column(
                  children: [
                    if (commonApi.dashboardModel!.categories!.isNotEmpty)
                      HeadingRowCommon(
                              title: translations!.topCategories,
                              isTextSize: true,
                              onTap: () => route.pushNamed(
                                  context, routeName.categoriesListScreen))
                          .paddingSymmetric(horizontal: Insets.i20),
                    const VSpace(Sizes.s15),
                    const BerlineCategories(isTokyo: true)
                        .height(Sizes.s100)
                        .padding(
                            left: lang.locale?.languageCode == "ar" ? 0 : 20,
                            right: lang.locale?.languageCode == "ar" ? 20 : 0),
                    const VSpace(Sizes.s25),
                  ],
                ),
              Column(
                children: [
                  if (homeFeaturedService.isNotEmpty)
                    HeadingRowCommon(
                        title: translations!.featuredService,
                        isTextSize: true,
                        onTap: () {
                          dash.getFeaturedPackage(1).then(
                            (value) {
                              route.pushNamed(
                                  context, routeName.featuredServiceScreen);
                            },
                          );
                        }).paddingSymmetric(horizontal: Insets.i20),
                  const VSpace(Sizes.s15),
                  if (homeFeaturedService.isNotEmpty)
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: homeFeaturedService.length,
                        itemBuilder: (context, index) {
                          return FeaturedServicesLayout(
                              data: homeFeaturedService[index],
                              addTap: () async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                log("pref.getBool(session.isContinueAsGuest::${pref.getBool(session.isContinueAsGuest)}");
                                if (pref.getBool(session.isContinueAsGuest) ==
                                    true) {
                                  route.pushNamedAndRemoveUntil(
                                      context, routeName.login);
                                } else {
                                  dash.onFeatured(context,
                                      homeFeaturedService[index], index,
                                      inCart: isInCart(context,
                                          homeFeaturedService[index].id));
                                }
                              },
                              // inCart: isInCart(
                              //     context, homeFeaturedService[index].id),
                              onTap: () {
                                Provider.of<ServicesDetailsProvider>(context,
                                        listen: false)
                                    .getServiceById(
                                        context, homeFeaturedService[index].id);
                                route.pushNamed(
                                    context, routeName.servicesDetailsScreen,
                                    arg: {
                                      'serviceId': homeFeaturedService[index].id
                                    });
                              });
                        }).paddingSymmetric(horizontal: Insets.i20),
                ],
              ),

              const VSpace(Sizes.s25),

              if (commonApi
                      .dashboardModel2?.homeBannerAdvertisements?.isNotEmpty ??
                  false)
                const Column(
                    children: [BerlineTodayOffers(), VSpace(Sizes.s25)]),

              const SizedBox(height: Sizes.s180, child: TokyoPackagesLayout())
                  .padding(bottom: Sizes.s20),
              if (commonApi.dashboardModel2 != null &&
                  commonApi.dashboardModel2!.homeServicesAdvertisements!
                      .isNotEmpty &&
                  commonApi.dashboardModel2!.homeServicesAdvertisements != [])
                const VSpace(Sizes.s25),
              if (commonApi.dashboardModel2 != null &&
                  commonApi.dashboardModel2!.homeServicesAdvertisements!
                      .isNotEmpty &&
                  commonApi.dashboardModel2!.homeServicesAdvertisements != [])
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
                      shrinkWrap: true,
                      itemCount: homeProvider.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ExpertServiceLayout(
                            data: homeProvider[index],
                            onTap: () {
                              Provider.of<ProviderDetailsProvider>(context,
                                      listen: false)
                                  .getProviderById(
                                      context, homeProvider[index].id);

                              route.pushNamed(
                                  context, routeName.providerDetailsScreen,
                                  arg: {'providerId': homeProvider[index].id});
                            });
                      })
                ])
                    .paddingSymmetric(
                        horizontal: Insets.i20, vertical: Insets.i25)
                    .backgroundColor(appColor(context).fieldCardBg),
              const VSpace(Sizes.s25),
              // const BerlineJobRequest(),
              /*   const VSpace(Sizes.s25), */
              if (appSettingModel != null &&
                  appSettingModel!.activation!.blogsEnable == "1")
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (commonApi.dashboardModel2 != null &&
                      commonApi.dashboardModel2!.blogs!.isNotEmpty)
                    HeadingRowCommon(
                      title: translations!.latestBlog,
                      isTextSize: true,
                      onTap: () =>
                          route.pushNamed(context, routeName.latestBlogViewAll),
                    ).paddingSymmetric(horizontal: Insets.i20),
                  if (commonApi.dashboardModel2 != null)
                    HorizontalBlogList(
                      blogList: commonApi.dashboardModel2!.blogs,
                    ),
                  const VSpace(Sizes.s25)
                ]),
              if (commonApi.dashboardModel != null)
              if (appSettingModel != null &&
                  appSettingModel?.serviceRequest?.status == "1")
                Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(eSvgAssets.tokyoJobRequest),
                        Image.asset(
                          eImageAssets.linePackage,
                          color: const Color(0XFF7A8591),
                        ).padding(horizontal: Sizes.s18),
                        /*    const HSpace(Sizes.s13), */
                        Expanded(
                          child: Text(
                              language(context,
                                  translations!.customJobRequestQuestion),
                              textAlign: TextAlign.start,
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).darkText)),
                        ),
                        const HSpace(Sizes.s5),
                        Container(
                          height: Sizes.s32,
                          width: Sizes.s32,
                          padding: const EdgeInsets.all(5),
                          child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(270 / 360),
                            child: SvgPicture.asset(
                              eSvgAssets.arrowDown,
                              color: appColor(context).whiteColor,
                            ),
                          ),
                        ).decorated(
                            color: appColor(context).primary,
                            shape: BoxShape.circle),
                      ],
                    ),
                  ],
                )
                    .inkWell(onTap: () async {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();

                      bool isGuest =
                          preferences.getBool(session.isContinueAsGuest) ??
                              false;
                      if (isGuest == false) {
                        route.pushNamed(context, routeName.jobRequestList);
                      } else {
                        route.pushAndRemoveUntil(context);
                        hideLoading(context);
                      }
                    })
                    .padding(horizontal: Sizes.s18, vertical: Sizes.s13)
                    .boxBorderExtension(context,
                        color: appColor(context).primary.withOpacity(.10),
                        isShadow: false,
                        bColor: appColor(context).primary.withOpacity(.10))
                    .marginSymmetric(horizontal: Sizes.s20),
              if (appSettingModel != null &&
                  appSettingModel?.serviceRequest?.status == "1")
                const VSpace(Sizes.s40),
            ],
          ));
    });
  }
}
