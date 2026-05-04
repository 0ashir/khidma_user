
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final String? id;

  const ProviderDetailsScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavouriteListProvider, ServicesDetailsProvider>(
        builder: (context1, favCtrl, categories, child) {
      return Consumer<ProviderDetailsProvider>(
          builder: (context, value, child) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            value.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
            onInit: () => Future.delayed(DurationClass.ms150)
                .then((_) => value.onReady(context, id: id)),
            child: RefreshIndicator(
              onRefresh: () => value.onRefresh(context),
              child: Scaffold(
                appBar: AppBar(
                  leadingWidth: 80,
                  title: Text(language(context, translations!.providerDetails),
                      style: appCss.dmDenseBold18
                          .textColor(appColor(context).darkText)),
                  centerTitle: true,
                  leading: CommonArrow(
                          arrow: eSvgAssets.arrowLeft,
                          onTap: () => value.onBack(context, true))
                      .paddingAll(Insets.i8),
                  actions: [
                    if (value.provider != null)
                      value.provider!.isFavourite == 1
                          ? SvgPicture.asset(eSvgAssets.heart,
                                  height: Sizes.s35, width: Sizes.s35)
                              .inkWell(
                              onTap: () {
                                value.provider!.isFavourite = 0;
                                favCtrl.deleteFav(
                                  context,
                                  isFavId: value.provider!.isFavouriteId,
                                  id: value.provider!.id,
                                );
                              },
                            ).paddingOnly(right: Insets.i20)
                          : CommonArrow(
                              arrow: eSvgAssets.like,
                              svgColor: appColor(context).primary,
                              color: appColor(context)
                                  .primary
                                  .withValues(alpha: 0.15),
                              onTap: () {
                                value.provider!.isFavourite = 1;
                                favCtrl.addFav(
                                    "provider", context, value.provider!.id);
                              },
                            ).paddingOnly(right: Insets.i20),
                  ],
                ),
                body: value.isProviderLoading
                    ? const ProviderDetailShimmer()
                    : value.provider == null
                        ? EmptyLayout(
                            title: translations!.noDataFound,
                            subtitle: translations!.noDataFoundDesc,
                            buttonText: translations!.refresh,
                            isButtonShow: true,
                            // onButtonTap: () => value.onRefresh(context),
                            widget: Image.asset(eImageAssets.emptyCart,
                                height: Sizes.s230),
                          ).marginOnly(top: Sizes.s50)
                        : Consumer<CartProvider>(
                            builder: (context2, cart, child) {
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ProviderTopLayout(),
                                    // Banner Section
                                    if (value.bannerImageUrls.isNotEmpty)
                                      SizedBox(
                                        height: Sizes.s128,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              value.bannerImageUrls.length,
                                          itemBuilder: (context, index) {
                                            final ad = value.bannerAds[index];
                                            final imageUrl =
                                                value.bannerImageUrls[index];
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Sizes.s9),
                                              child: CachedNetworkImage(
                                                width: 320,
                                                imageUrl: imageUrl,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          eImageAssets
                                                              .noImageFound2),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  eImageAssets.noImageFound2,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                ),
                                              ).inkWell(
                                                onTap: () {
                                                  final providerId =
                                                      ad['provider_id'] as int?;
                                                  if (providerId != null) {
                                                    if (providerId ==
                                                        value.providerId) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Already viewing this provider");
                                                    } else {
                                                      route.pushNamed(
                                                        context,
                                                        routeName
                                                            .providerDetailsScreen,
                                                        arg: {
                                                          'providerId':
                                                              providerId
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "No provider associated with this banner");
                                                  }
                                                },
                                              ),
                                            ).padding(right: Sizes.s10);
                                          },
                                        ).paddingSymmetric(
                                            horizontal: Sizes.s20,
                                            vertical: Insets.i15),
                                      ),
                                    // Categories Section
                                    if (value.categoryList.isNotEmpty ||
                                        value.isCategoriesLoadeer)
                                      Text(
                                        language(context,
                                            translations!.provideServiceIn),
                                        style: appCss.dmDenseSemiBold16
                                            .textColor(
                                                appColor(context).darkText),
                                      ).paddingOnly(top: Insets.i25),

                                    if (value.categoryList.isNotEmpty ||
                                        value.isCategoriesLoadeer)
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: value.categoryList
                                              .asMap()
                                              .entries
                                              .map((e) => TopCategoriesLayout(
                                                    index: e.key,
                                                    data: e.value,
                                                    isExapnded: false,
                                                    selectedIndex:
                                                        value.selectIndex,
                                                    rPadding: Insets.i20,
                                                    onTap: () =>
                                                        value.onSelectService(
                                                            context,
                                                            e.key,
                                                            e.value.id),
                                                  ).marginOnly(
                                                    right: rtl(context)
                                                        ? 0
                                                        : Sizes.s10,
                                                    left: rtl(context)
                                                        ? Sizes.s10
                                                        : 0,
                                                  ))
                                              .toList(),
                                        ).padding(vertical: Insets.i15),
                                      ),
                                    // Services Section
                                    if (value.categoryList.isNotEmpty ||
                                        value.isCategoriesLoadeer)
                                      value.categoryList.isEmpty ||
                                              value.isCategoriesLoadeer
                                          ? const ServicesShimmer(count: 1)
                                          : value.serviceList.isEmpty
                                              ? EmptyLayout(
                                                  title:
                                                      translations!.noDataFound,
                                                  subtitle: translations!
                                                      .noDataFoundDesc,
                                                  buttonText:
                                                      translations!.refresh,
                                                  isButtonShow: true,
                                                  // onButtonTap: () => value.onRefresh(context),
                                                  widget: Image.asset(
                                                      eImageAssets.emptyCart,
                                                      height: Sizes.s230),
                                                ).marginOnly(top: Sizes.s50)
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      value.serviceList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final service = value
                                                        .serviceList[index];
                                                    return FeaturedServicesLayout(
                                                      data: service,
                                                      isProvider: true,
                                                      isShowAdd: false,
                                                      // inCart: isInCart(
                                                      //     context, service.id),
                                                      onTap: () {
                                                        categories
                                                            .getServiceById(
                                                                context,
                                                                service.id);
                                                        route.pushNamed(
                                                          context,
                                                          routeName
                                                              .servicesDetailsScreen,
                                                          arg: {
                                                            'serviceId':
                                                                service.id
                                                          },
                                                        );
                                                      },
                                                      addTap: () => Provider.of<DashboardProvider>(
                                                              context,
                                                              listen: false)
                                                          .addToCartDirect(
                                                              context, service),
                                                    );
                                                  },
                                                ),
                                  ],
                                ).paddingAll(Sizes.s20),
                              );
                            },
                          ),
              ),
            ),
          ),
        );
      });
    });
  }
}
