import 'dart:developer';

import 'package:fixit_user/screens/bottom_screens/home_screen/berlin_layout.dart/berline_today_offiers.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_services.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/horizontal_service_package_list.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/layouts/special_offers_layout.dart';

import '../../../../config.dart';

class CategoryFeaturePackageServices extends StatelessWidget {
  final bool isNewYork;

  const CategoryFeaturePackageServices({super.key, this.isNewYork = false});

  @override
  Widget build(BuildContext context) {
    return Consumer6<DashboardProvider, HomeScreenProvider, CartProvider,
            CommonApiProvider, CategoriesDetailsProvider, ChatHistoryProvider>(
        builder: (context3, dash, value, cart, commonApi, categoryDetails,
            chatHistory, child) {
      return Column(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            children: [
              if (commonApi.dashboardModel != null &&
                  commonApi.dashboardModel!.categories!.isNotEmpty)
                HeadingRowCommon(
                        title: translations!.topCategories,
                        isTextSize: true,
                        onTap: () => route.pushNamed(
                            context, routeName.categoriesListScreen))
                    .paddingSymmetric(horizontal: Insets.i20),
              if (commonApi.dashboardModel != null &&
                  commonApi.dashboardModel!.categories!.isNotEmpty)
                const VSpace(Sizes.s15),
              if (commonApi.dashboardModel != null)
                GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
                    itemCount: commonApi.dashboardModel != null &&
                            commonApi.dashboardModel!.categories?.length == 8
                        ? commonApi.dashboardModel!.categories
                            ?.getRange(0, 8)
                            .length
                        : commonApi.dashboardModel!.categories?.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent: Sizes.s110,
                            mainAxisSpacing: Sizes.s10,
                            crossAxisSpacing: Sizes.s10),
                    itemBuilder: (context, index) {
                      return TopCategoriesLayout(
                        isExapnded: false,
                        index: index,
                        selectedIndex: dash.topSelected,
                        data: homeCategoryList[index],
                        onTap: () async {
                          log("loader state ${categoryDetails.isNavigatingToCategory}");
                          if (categoryDetails.isNavigatingToCategory) return;

                          categoryDetails.setIsNavigatingToCategory(true);

                          showLoading(context);

                          try {
                            categoryDetails.demoList = [];
                            await categoryDetails.fetchBannerAdsData(context);

                            await categoryDetails.getServiceByCategoryId(
                              context,
                              id: homeCategoryList[index].id,
                            );

                            hideLoading(context);

                            await route.pushNamed(
                              context,
                              routeName.categoriesDetailsScreen,
                              arg: homeCategoryList[index],
                            );
                          } catch (e, s) {
                            hideLoading(context);
                            log("Navigation error: $s");
                          } finally {
                            // 🔥 ALWAYS reset
                            categoryDetails.setIsNavigatingToCategory(false);
                          }
                        },
                      );
                    }),
            ],
          ),
          const VSpace(Sizes.s25),
          Column(
            children: [
              if (homeServicePackagesList.isNotEmpty)
                HeadingRowCommon(
                    title: translations?.servicePackage,
                    isTextSize: true,
                    onTap: () {
                      log("=-=-=-=-=-=");
                      dash.getServicePackage();
                      route.pushNamed(context, routeName.servicePackagesScreen);
                    }).paddingSymmetric(horizontal: Insets.i20),
              if (homeServicePackagesList.isNotEmpty) const VSpace(Sizes.s15),
              HorizontalServicePackageList(
                  rotationAnimation: value.rotationAnimation,
                  servicePackagesList: homeServicePackagesList),
            ],
          ),
          const VSpace(Sizes.s20),
          if (commonApi.dashboardModel2 != null &&
              commonApi.dashboardModel2!.homeBannerAdvertisements!.isNotEmpty &&
              commonApi.dashboardModel2!.homeBannerAdvertisements != null)
            const Column(
              children: [
                BerlineTodayOffers(),
                VSpace(Sizes.s20),
              ],
            ),
          if (commonApi.dashboardModel2 != null &&
              commonApi
                  .dashboardModel2!.homeServicesAdvertisements!.isNotEmpty &&
              commonApi.dashboardModel2!.homeServicesAdvertisements != [])
            const SizedBox(height: 269, child: SpecialOffersLayout()),
          const VSpace(Sizes.s20),
          if (isNewYork != true)
            Column(children: [
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
                          isShowAdd: false,
                          addTap: () => dash.addToCartDirect(
                              context, homeFeaturedService[index]),
                          onTap: () {
                            log("homeFeaturedService[index].id::${homeFeaturedService[index].id}");
                            var serviceDetails =
                                Provider.of<ServicesDetailsProvider>(context);
                            serviceDetails.getServiceById(
                                context, homeFeaturedService[index].id);

                            route.pushNamed(
                                context, routeName.servicesDetailsScreen,
                                arg: {
                                  'serviceId': homeFeaturedService[index].id,
                                });
                          });
                    }).paddingSymmetric(horizontal: Insets.i20)
            ])
        ]).padding(bottom: Insets.i10),
        if (homeProvider.isNotEmpty)
          Column(
            children: [
              Column(children: [
                HeadingRowCommon(
                    title: translations?.expertService ?? '',
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
                          onTap: () async {
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
                  .backgroundColor(appColor(context).fieldCardBg)
            ],
          ),
        if (isNewYork == true)
          Column(children: [
            if (homeProvider.isNotEmpty) const VSpace(Sizes.s20),
            const DubaiServices(),
          ])
      ]);
    });
  }
}
