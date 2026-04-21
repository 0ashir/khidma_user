// ignore_for_file: deprecated_member_use, prefer_is_empty

import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berlin_package_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_categories.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_job_request.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_today_offiers.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berlin_coupon_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_services.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/horizontal_blog_list.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/special_offers_layout.dart';

class BerlinBody extends StatelessWidget {
  const BerlinBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<DashboardProvider, HomeScreenProvider, CommonApiProvider,
            ProfileProvider>(
        builder: (context3, dash, value, commonApi, profile, child) {
      return StatefulWrapper(
          onInit: () {},
          child: Column(
            children: [
              Container(
                  padding:
                      const EdgeInsets.only(bottom: Sizes.s13, top: Sizes.s18),
                  decoration: ShapeDecoration(
                      color: appColor(context).primary,
                      shape: const SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                              bottomLeft: SmoothRadius(
                                  cornerRadius: 20, cornerSmoothing: 2),
                              bottomRight: SmoothRadius(
                                  cornerRadius: 20, cornerSmoothing: 1)))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const HSpace(Sizes.s20),
                          SizedBox(
                              height: Sizes.s40,
                              width: Sizes.s40,
                              child: CachedNetworkImage(
                                  imageUrl: userModel != null &&
                                          userModel!.media != [] &&
                                          userModel!.media.isNotEmpty
                                      ? userModel!.media[0].originalUrl
                                      : "",
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                          height: Sizes.s88,
                                          width: Sizes.s88,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                              border: Border.all(
                                                  color: appColor(context)
                                                      .whiteBg
                                                      .withOpacity(0.75),
                                                  width: 4,
                                                  style: BorderStyle.solid))),
                                  placeholder: (context, url) => Container(
                                      height: Sizes.s88,
                                      width: Sizes.s88,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image:
                                              DecorationImage(image: AssetImage(eImageAssets.noImageFound3), fit: BoxFit.cover),
                                          border: Border.all(color: appColor(context).whiteBg.withOpacity(0.75), width: 4, style: BorderStyle.solid))),
                                  errorWidget: (context, url, error) => Container(height: Sizes.s88, width: Sizes.s88, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(eImageAssets.noImageFound3), fit: BoxFit.cover), border: Border.all(color: appColor(context).whiteBg.withOpacity(0.75), width: 4, style: BorderStyle.solid)))).inkWell(onTap: () {
                                if (profile.isGuest) {
                                  hideLoading(context);
                                  route.pushNamed(context, routeName.login);
                                  log("value::::$value");
                                } else {
                                  hideLoading(context);
                                }
                              })),
                          const HSpace(Sizes.s10),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userModel?.name ?? "Guest",
                                    overflow: TextOverflow.ellipsis,
                                    style: appCss.dmDenseBold14.textColor(
                                        appColor(context).whiteColor)),
                                SizedBox(
                                  width: Sizes.s180,
                                  child: Text(
                                      maxLines: 1,
                                      setPrimaryAddress == null
                                          ? street != null
                                              ? street.toString()
                                              : language(context,
                                                  translations!.currentLocation)
                                          : setPrimaryAddress == -1
                                              ? language(context,
                                                  translations!.currentLocation)
                                              : userPrimaryAddress?.type == null
                                                  ? ""
                                                  : capitalizeFirstLetter(
                                                      userPrimaryAddress
                                                              ?.type ??
                                                          "") /* capitalizeFirstLetter(
                                                  userPrimaryAddress!.type) */
                                      ,
                                      style: appCss.dmDenseRegular13.textColor(
                                          appColor(context)
                                              .whiteColor
                                              .withOpacity(0.81))),
                                ),
                              ]).inkWell(onTap: () {
                            if (profile.isGuest) {
                              hideLoading(context);
                              route.pushNamed(context, routeName.login);

                              log("value::::$value");
                            } else {
                              route.pushNamed(context, routeName.myLocation);
                              hideLoading(context);
                            }
                          })
                        ]),
                        Row(children: [
                          SvgPicture.asset(
                            eSvgAssets.search,
                            color: appColor(context).whiteColor,
                          ).inkWell(onTap: () {
                            route.pushNamed(context, routeName.search);
                          }),
                          const HSpace(Sizes.s15),
                          Consumer<NotificationProvider>(
                              builder: (context1, notification, child) {
                            return Container(
                                    alignment: Alignment.center,
                                    child: Stack(
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
                                        ]))
                                .inkWell(
                                    onTap: () => value.notificationTap(context))
                                .paddingOnly(
                                    right: rtl(context) ? 0 : Insets.i20,
                                    left: rtl(context) ? Insets.i20 : 0);
                          })
                        ])
                      ])),
              Expanded(
                child: ListView(
                  children: [
                    const VSpace(Sizes.s15),
                    const SizedBox(
                            height: Sizes.s100, child: BerlineCategories())
                        .padding(left: Insets.i20),
                    Column(children: [
                      if (commonApi.dashboardModel != null &&
                          commonApi.dashboardModel!.banners!.isNotEmpty)
                        BannerLayout(
                            isBerlin: true,
                            isDubai: true,
                            bannerList: commonApi.dashboardModel!.banners,
                            onPageChanged: (index, reason) =>
                                value.onSlideBanner(index),
                            onTap: commonApi.isLoading == true
                                ? (type, id) {
                                    print("object=-===-=-=-=-=-=-=-=-=");
                                  }
                                : (type, id) =>
                                    value.onBannerTap(context, type, id)),
                    ]),
                    if (commonApi.dashboardModel != null &&
                        commonApi.dashboardModel!.banners!.isNotEmpty)
                      const VSpace(Sizes.s25),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (commonApi.dashboardModel != null &&
                              commonApi.dashboardModel!.coupons!.isNotEmpty)
                            HeadingRowCommon(
                                title: translations!.coupons,
                                isTextSize: true,
                                onTap: () {
                                  dash.getCoupons();
                                  route.pushNamed(
                                      context, routeName.couponListScreen,
                                      arg: true);
                                }).paddingSymmetric(horizontal: Insets.i20),
                          if (commonApi.dashboardModel != null &&
                              commonApi.dashboardModel!.coupons!.isNotEmpty)
                            const VSpace(Sizes.s10),
                          if (commonApi.dashboardModel != null &&
                              commonApi.dashboardModel!.coupons!.isNotEmpty)
                            SizedBox(
                                height: Sizes.s70,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: commonApi
                                        .dashboardModel!.coupons!.length,
                                    itemBuilder: (context, index) {
                                      return BerlinCouponLayout(
                                          data: commonApi
                                              .dashboardModel!.coupons![index]);
                                    })).paddingDirectional(bottom: Sizes.s20)
                        ]),
                    const DubaiServices(),
                    const VSpace(Sizes.s25),
                    const SizedBox(height: 180, child: BerlinPackageLayout()),
                    if (commonApi.dashboardModel2 != null &&
                        commonApi.dashboardModel2!.homeServicesAdvertisements!
                            .isNotEmpty &&
                        commonApi.dashboardModel2!.homeServicesAdvertisements !=
                            [])
                      const VSpace(Sizes.s25),
                    if (commonApi.dashboardModel2 != null &&
                        commonApi.dashboardModel2!.homeServicesAdvertisements!
                            .isNotEmpty &&
                        commonApi.dashboardModel2!.homeServicesAdvertisements !=
                            [])
                      const Column(
                        children: [
                          SizedBox(height: 270, child: SpecialOffersLayout()),
                          VSpace(Sizes.s25),
                        ],
                      ),
                    if (commonApi.dashboardModel2?.homeBannerAdvertisements
                            ?.isNotEmpty ??
                        false)
                      const Column(
                        children: [
                          BerlineTodayOffers(),
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
                                      arg: {
                                        'providerId': homeProvider[index].id
                                      });
                                });
                          },
                        )
                      ])
                          .paddingSymmetric(
                              horizontal: Insets.i20, vertical: Insets.i25)
                          .backgroundColor(appColor(context).fieldCardBg),
                    const VSpace(Sizes.s25),
                    if (commonApi.dashboardModel != null)
                    if (appSettingModel != null &&
                        appSettingModel?.serviceRequest?.status == "1")
                      const BerlinJobRequest(),
                    const VSpace(Sizes.s25),
                    if (appSettingModel != null &&
                        appSettingModel!.activation!.blogsEnable == "1")
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (commonApi.dashboardModel2 != null &&
                                commonApi.dashboardModel2!.blogs!.isNotEmpty)
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
                  ],
                ),
              ),
            ],
          ));
    });
  }
}
