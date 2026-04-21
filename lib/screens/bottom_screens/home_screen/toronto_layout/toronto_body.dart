// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, prefer_is_empty

import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_today_offiers.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/horizontal_blog_list.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/special_offers_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_banner_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_coupon_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_package_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_top_categories.dart';

import '../../../../config.dart';

class TorontoBody extends StatelessWidget {
  const TorontoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardProvider, HomeScreenProvider, CommonApiProvider>(
        builder: (context3, dash, value, commonApi, child) {
      return StatefulWrapper(
        onInit: () {},
        child: ListView(children: [
          Column(
            children: [
              const VSpace(Sizes.s16),
              Container(
                width: double.infinity,
                height: Sizes.s50,
                margin: const EdgeInsets.symmetric(horizontal: Insets.i20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SvgPicture.asset(
                    eSvgAssets.locationOutline,
                    fit: BoxFit.scaleDown,
                    colorFilter: ColorFilter.mode(
                        appColor(context).darkText, BlendMode.srcIn),
                  ),
                  const HSpace(Sizes.s10),
                  SizedBox(
                      width: Sizes.s210,
                      child: Text(
                          overflow: TextOverflow.ellipsis,
                          street != null
                              ? street!
                              : setPrimaryAddress == null
                                  ? language(
                                      context, translations!.currentLocation)
                                  : setPrimaryAddress == -1
                                      ? language(context,
                                          translations!.currentLocation)
                                      : capitalizeFirstLetter(
                                          userPrimaryAddress!.type),
                          style: appCss.dmDenseRegular13
                              .textColor(appColor(context).lightText))),
                  const HSpace(Sizes.s20),
                  SvgPicture.asset(eSvgAssets.arrowDown)
                ]).inkWell(onTap: () => value.locationTap(context)),
              ).decorated(
                  color: appColor(context).stroke.withOpacity(0.10),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 3,
                        spreadRadius: 2,
                        color: appColor(context).darkText.withOpacity(0.06))
                  ],
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(color: appColor(context).stroke)),
            ],
          ).padding(horizontal: Insets.i20, bottom: Insets.i20),
          if (commonApi.dashboardModel != null &&
              commonApi.dashboardModel!.banners!.isNotEmpty)
            TorontoBannerLayout(
                    bannerList: commonApi.dashboardModel!.banners,
                    onTap: commonApi.isLoading == true
                        ? (type, id) {
                            print("object=-===-=-=-=-=-=-=-=-=");
                          }
                        : (type, id) => value.onBannerTap(context, type, id))
                .paddingOnly(left: Insets.i20),
          const VSpace(Sizes.s25),
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
                  commonApi.dashboardModel!.coupons!.isNotEmpty)
                const VSpace(Sizes.s15),
              if (commonApi.dashboardModel?.coupons?.isNotEmpty ?? false)
                SizedBox(
                  height: Sizes.s150,
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: commonApi.dashboardModel!.coupons!.length,
                      itemBuilder: (context, index) {
                        return TorontoCouponLayout(
                            data: commonApi.dashboardModel!.coupons![index]);
                      }),
                ),
            ],
          ),
          const TorontoTopCategories(),
          const VSpace(Sizes.s25),
          const BerlineTodayOffers(),
          const VSpace(Sizes.s25),
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
                          addTap: () => dash.onFeatured(
                              context, homeFeaturedService[index], index,
                              inCart: isInCart(
                                  context, homeFeaturedService[index].id)),
                          // inCart:
                          //     isInCart(context, homeFeaturedService[index].id),
                          onTap: () {
                            Provider.of<ServicesDetailsProvider>(context,
                                    listen: false)
                                .getServiceById(
                                    context, homeFeaturedService[index].id);
                            route.pushNamed(
                                context, routeName.servicesDetailsScreen, arg: {
                              'serviceId': homeFeaturedService[index].id
                            }).then((e) {
                              dash.getFeaturedPackage(1);
                            });
                          });
                    }).paddingSymmetric(horizontal: Insets.i20),
            ],
          ),
          const VSpace(Sizes.s25),
          Column(
            children: [
              if (homeServicePackagesList.isNotEmpty)
                HeadingRowCommon(
                        title: translations!.servicePackage,
                        isTextSize: true,
                        onTap: () => route.pushNamed(
                            context, routeName.servicePackagesScreen))
                    .paddingSymmetric(horizontal: Insets.i20),
              if (homeServicePackagesList.isNotEmpty) const VSpace(Sizes.s15),
              const SizedBox(height: Sizes.s75, child: TorontoPackageLayout()),
              const VSpace(Sizes.s25),
              if (commonApi.dashboardModel2?.homeServicesAdvertisements
                      ?.isNotEmpty ??
                  false)
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
                    },
                  )
                ])
                    .paddingSymmetric(
                        horizontal: Insets.i20, vertical: Insets.i25)
                    .backgroundColor(appColor(context).fieldCardBg)
            ],
          ),
          const VSpace(Sizes.s25),
          if (commonApi.dashboardModel != null)
            if (appSettingModel != null &&
                appSettingModel?.serviceRequest?.status == "1")
              Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(eSvgAssets.jobRequestToronto),
                      const HSpace(Sizes.s13),
                      Expanded(
                        flex: 2,
                        child: Text(
                            language(context,
                                translations!.customJobRequestQuestion),
                            maxLines: 2,
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
                        preferences.getBool(session.isContinueAsGuest) ?? false;
                    if (isGuest == false) {
                      route.pushNamed(context, routeName.jobRequestList);
                    } else {
                      route.pushAndRemoveUntil(context);
                      hideLoading(context);
                    }
                  })
                  .paddingAll(Sizes.s20)
                  .boxBorderExtension(context,
                      color: appColor(context).primary.withOpacity(.10),
                      isShadow: true,
                      bColor: appColor(context).primary.withOpacity(.10))
                  .marginSymmetric(horizontal: Sizes.s20),
          if (dash.firstTwoHighRateList.isNotEmpty ||
              dash.highestRateList.isNotEmpty)
            const VSpace(Sizes.s25),
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
          const VSpace(Sizes.s50)
        ]),
      );
    });
  }
}
