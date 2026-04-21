// ignore_for_file: use_build_context_synchronously, deprecated_member_use, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:developer';

import '../../../config.dart';
import '../category_provider_services_screen/category_provider_services_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginProvider, ServicesDetailsProvider,
            CategoriesDetailsProvider>(
        builder: (context1, login, serviceCtrl, value, child) {
      return StatefulWrapper(
          onInit: () => Future.delayed(DurationClass.ms150)
              .then((val) => value.onReady(context)),
          child: PopScope(
              canPop: true,
              onPopInvoked: (didPop) {
                value.onBack(context, false);
                if (didPop) return;
              },
              child: Scaffold(
                  appBar: AppBarCommon(
                      title: value.categoryModel != null
                          ? value.categoryModel!.title
                          : "DATA",
                      onTap: () => value.onBack(context, true)),
                  body: RefreshIndicator(
                      onRefresh: () => value.onRefresh(context),
                      child: ListView(padding: EdgeInsets.zero, children: [
                        SearchTextFieldCommon(
                          controller: value.searchCtrl,
                          focusNode: value.searchFocus,
                          onChanged: (text) {
                            if (text.isEmpty) {
                              value.getService(
                                  id: value.categoryModel!.id); // Show all
                            } else if (text.isNotEmpty) {
                              value.getService(
                                  id: value.categoryModel!.id,
                                  search: text.trim()); // Perform search
                            }
                          },
                          onFieldSubmitted: (text) {
                            if (text.isEmpty) {
                              value.getService(
                                  id: value.categoryModel!.id); // Show all
                            } else if (text.isNotEmpty) {
                              value.getService(
                                  id: value.categoryModel!.id,
                                  search: text.trim()); // Perform search
                            }
                          },
                          /* onFieldSubmitted: (v) =>
                              value.getService(id: value.categoryModel!.id), */
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (value.searchCtrl.text.isNotEmpty)
                                Icon(Icons.cancel,
                                        color: appColor(context).darkText)
                                    .inkWell(onTap: () {
                                  value.searchCtrl.text = "";
                                  value.notifyListeners();
                                  value.getService(id: value.categoryModel!.id);
                                }),
                              FilterIconCommon(
                                  selectedFilter:
                                      value.totalCountFilter().toString(),
                                  onTap: () => value.onBottomSheet(context)),
                            ],
                          ),
                        ).paddingSymmetric(horizontal: Insets.i20),
                        const VSpace(Sizes.s20),
                        (login.pref?.getBool(session.isContinueAsGuest) != true)
                            ? value.isServiceLoading && value.mediaUrls.isEmpty
                                ? const CommonSkeleton(
                                    height: Sizes.s128,
                                    radius: 0,
                                  ).paddingDirectional(horizontal: Sizes.s20)
                                : value.mediaUrls.isNotEmpty
                                    ? SizedBox(
                                        height: Sizes.s128,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: value.mediaUrls.length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Sizes.s9),
                                              child: CachedNetworkImage(
                                                width: 320,
                                                imageUrl:
                                                    value.mediaUrls[index],
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
                                                    const CommonSkeleton(
                                                  height: Sizes.s128,
                                                  radius: 0,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  eImageAssets.noImageFound2,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ).inkWell(
                                                onTap: () {
                                                  route.pushNamed(
                                                    context,
                                                    routeName
                                                        .providerDetailsScreen,
                                                    arg: {
                                                      "providerId":
                                                          fetchBannerAds
                                                              ?.data?[index]
                                                              .providerId
                                                    },
                                                  );
                                                  log("Tapped ID: ${fetchBannerAds?.data?[index].providerId}");
                                                },
                                              ),
                                            ).padding(right: Sizes.s10);
                                          },
                                        ).paddingSymmetric(
                                            horizontal: Sizes.s20),
                                      )
                                    : const SizedBox.shrink()
                            : const SizedBox.shrink(),
                        // if (value.isServiceLoading == false ||
                        //     value.isLoader && value.demoList.isNotEmpty)
                        value.isServiceLoading && value.mediaUrls.isEmpty
                            /* value.isLoading == true && value.isServiceLoading */
                            ? const ServicesShimmer(count: 0)
                                .padding(horizontal: Insets.i20)
                            : value.demoList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language(context,
                                            translations!.subCategories),
                                        style: appCss.dmDenseBold16.textColor(
                                            appColor(context).darkText),
                                      ).paddingOnly(
                                        top: Insets.i15,
                                        left: rtl(context) ? 0 : Insets.i20,
                                        right: rtl(context) ? Insets.i20 : 0,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: value.demoList
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return TopCategoriesLayout(
                                                index: e.key,
                                                isCategories: true,
                                                data: e.value,
                                                selectedIndex:
                                                    value.selectedIndex,
                                                onTap: () =>
                                                    value.onSubCategories(
                                                        context,
                                                        e.key,
                                                        e.value.id),
                                              );
                                            }).toList(),
                                          ).padding(
                                              vertical: Insets.i15,
                                              left: Insets.i20),
                                        ),
                                      ),
                                    ],
                                  )
                                    .decorated(
                                        color: appColor(context).fieldCardBg)
                                    .paddingOnly(
                                        top: Insets.i10, bottom: Insets.i25)
                                : const SizedBox.shrink(),
                        value.isServiceLoading
                            ? const ServicesShimmer(count: 2)
                                .padding(horizontal: Insets.i20)
                            : value.categoryProviders.isEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language(context,
                                            translations!.provider),
                                        style: appCss.dmDenseBold16.textColor(
                                            appColor(context).darkText),
                                      ).paddingOnly(
                                        left: rtl(context) ? 0 : Insets.i20,
                                        right: rtl(context) ? Insets.i20 : 0,
                                      ),
                                      EmptyLayout(
                                        title: translations!.noDataFound,
                                        subtitle: translations!.noDataFoundDesc,
                                        buttonText: translations!.refresh,
                                        isButtonShow: false,
                                        widget: Image.asset(
                                          eImageAssets.emptyCart,
                                          height: Sizes.s230,
                                        ),
                                      ).marginOnly(top: Sizes.s50),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language(context,
                                            translations!.provider),
                                        style: appCss.dmDenseBold16.textColor(
                                            appColor(context).darkText),
                                      ).paddingOnly(
                                        left: rtl(context) ? 0 : Insets.i20,
                                        right: rtl(context) ? Insets.i20 : 0,
                                        top: Insets.i15,
                                      ),
                                      ...value.categoryProviders
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        return ExpertServiceLayout(
                                          data: e.value,
                                          isHome: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CategoryProviderServicesScreen(
                                                  provider: e.value,
                                                  services: value
                                                      .servicesForProvider(
                                                          e.value.id!),
                                                  categoryName: value
                                                      .categoryModel!.title!,
                                                ),
                                              ),
                                            );
                                          },
                                        ).paddingSymmetric(
                                            horizontal: Insets.i20);
                                      }),
                                    ],
                                  ).marginOnly(top: Insets.i15),
                      ])))));
    });
  }
}

// import 'dart:developer';
//
// import '../../../config.dart';
//
// class CategoryDetailScreen extends StatelessWidget {
//   const CategoryDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer3<LoginProvider, ServicesDetailsProvider,
//             CategoriesDetailsProvider>(
//         builder: (context1, login, serviceCtrl, value, child) {
//       return StatefulWrapper(
//           onInit: () => Future.delayed(DurationClass.ms150)
//               .then((val) => value.onReady(context)),
//           child: PopScope(
//               canPop: true,
//               onPopInvoked: (didPop) {
//                 value.onBack(context, false, value.subCategoryId);
//                 if (didPop) return;
//               },
//               child: Scaffold(
//                   appBar: AppBarCommon(
//                     title: value.categoryModel != null
//                         ? value.categoryModel!.title
//                         : "DATA",
//                     onTap: () =>
//                         value.onBack(context, true, value.subCategoryId),
//                   ),
//                   body: RefreshIndicator(
//                       onRefresh: () => value.onRefresh(context),
//                       child: ListView(children: [
//                         SearchTextFieldCommon(
//                           controller: value.searchCtrl,
//                           focusNode: value.searchFocus,
//                           onChanged: (text) {
//                             if (text.isEmpty) {
//                               value.getService(
//                                   id: value.categoryModel!.id); // Show all
//                             } else if (text.length > 2) {
//                               value.getService(
//                                   id: value.categoryModel!.id,
//                                   search: text); // Perform search
//                             }
//                           },
//                           onFieldSubmitted: (v) =>
//                               value.getService(id: value.categoryModel!.id),
//                           suffixIcon: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (value.searchCtrl.text.isNotEmpty)
//                                 Icon(Icons.cancel,
//                                         color: appColor(context).darkText)
//                                     .inkWell(onTap: () {
//                                   value.searchCtrl.text = "";
//                                   value.notifyListeners();
//                                   value.getService(id: value.categoryModel!.id);
//                                 }),
//                               FilterIconCommon(
//                                   selectedFilter:
//                                       value.totalCountFilter().toString(),
//                                   onTap: () => value.onBottomSheet(context)),
//                             ],
//                           ),
//                         ).paddingSymmetric(horizontal: Insets.i20),
//                         const VSpace(Sizes.s20),
//                         if (login.pref?.getBool(session.isContinueAsGuest) !=
//                             true)
//                           value.isLoading == false && value.mediaUrls.isNotEmpty
//                               ? value.mediaUrls.isNotEmpty
//                                   ? SizedBox(
//                                       height: Sizes.s128,
//                                       child: ListView.builder(
//                                         scrollDirection: Axis.horizontal,
//                                         itemCount: value.mediaUrls.length,
//                                         itemBuilder: (context, index) {
//                                           return ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       Sizes.s9),
//                                               child: CachedNetworkImage(
//                                                   width: 320,
//                                                   imageUrl:
//                                                       value.mediaUrls[index],
//                                                   imageBuilder:
//                                                       (context, imageProvider) =>
//                                                           Container(
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               image:
//                                                                   DecorationImage(
//                                                                 image:
//                                                                     imageProvider,
//                                                                 fit:
//                                                                     BoxFit.fill,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                   placeholder: (context, url) =>
//                                                       Container(
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           image: DecorationImage(
//                                                               image: AssetImage(
//                                                                   eImageAssets
//                                                                       .noImageFound2),
//                                                               fit: BoxFit
//                                                                   .fitWidth),
//                                                         ),
//                                                       ),
//                                                   errorWidget: (context, url,
//                                                           error) =>
//                                                       Image.asset(
//                                                           eImageAssets
//                                                               .noImageFound2,
//                                                           fit: BoxFit
//                                                               .fitWidth)).inkWell(
//                                                   onTap: () {
//                                                 route.pushNamed(
//                                                     context,
//                                                     routeName
//                                                         .providerDetailsScreen,
//                                                     arg: {
//                                                       "providerId":
//                                                           fetchBannerAds
//                                                               ?.data?[index]
//                                                               .providerId
//                                                     });
//                                                 log("dsddddd${fetchBannerAds?.data?[index].providerId}");
//                                               })).padding(right: Sizes.s10);
//                                         },
//                                       ).paddingSymmetric(horizontal: Sizes.s20),
//                                     )
//                                   : const SizedBox.shrink()
//                               : const CommonSkeleton(
//                                       height: Sizes.s128, radius: 0)
//                                   .paddingDirectional(horizontal: Sizes.s20),
//                         if (value.isLoading == false &&
//                             value.demoList.isNotEmpty)
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 language(context, translations!.subCategories),
//                                 style: appCss.dmDenseBold16
//                                     .textColor(appColor(context).darkText),
//                               ).paddingOnly(
//                                 top: Insets.i15,
//                                 left: rtl(context) ? 0 : Insets.i20,
//                                 right: rtl(context) ? Insets.i20 : 0,
//                               ),
//                               SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: IntrinsicHeight(
//                                   child: Row(
//                                     children:
//                                         value.demoList.asMap().entries.map((e) {
//                                       return TopCategoriesLayout(
//                                         index: e.key,
//                                         isCategories: true,
//                                         data: e.value,
//                                         selectedIndex: value.selectedIndex,
//                                         onTap: () => value.onSubCategories(
//                                             context, e.key, e.value.id),
//                                       );
//                                     }).toList(),
//                                   ).padding(
//                                       vertical: Insets.i15, left: Insets.i20),
//                                 ),
//                               ),
//                             ],
//                           )
//                               .decorated(color: appColor(context).fieldCardBg)
//                               .paddingOnly(top: Insets.i10, bottom: Insets.i25),
//                         value.isLoading
//                             ? const ServicesShimmer(count: 3)
//                                 .padding(horizontal: Insets.i20)
//                             : value.isLoading && value.serviceList.isEmpty
//                                 ? Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         language(
//                                             context, translations!.services),
//                                         style: appCss.dmDenseBold16.textColor(
//                                             appColor(context).darkText),
//                                       ).paddingOnly(
//                                         left: rtl(context) ? 0 : Insets.i20,
//                                         right: rtl(context) ? Insets.i20 : 0,
//                                       ),
//                                       EmptyLayout(
//                                         title: translations!.noDataFound,
//                                         subtitle: translations!.noDataFoundDesc,
//                                         buttonText: translations!.refresh,
//                                         isButtonShow: false,
//                                         // buttonTap: () => value.getService(
//                                         //     id: value.categoryModel!.id),
//                                         widget: Image.asset(
//                                           eImageAssets.emptyCart,
//                                           height: Sizes.s230,
//                                         ),
//                                       ).marginOnly(top: Sizes.s50),
//                                     ],
//                                   )
//                                 : value.isLoading ||
//                                         value.filteredServices.isEmpty
//                                     ? Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             language(context,
//                                                 translations!.services),
//                                             style: appCss.dmDenseBold16
//                                                 .textColor(
//                                                     appColor(context).darkText),
//                                           ).paddingOnly(
//                                             left: rtl(context) ? 0 : Insets.i20,
//                                             right:
//                                                 rtl(context) ? Insets.i20 : 0,
//                                           ),
//                                           EmptyLayout(
//                                             title: translations!.noDataFound,
//                                             subtitle:
//                                                 translations!.noDataFoundDesc,
//                                             buttonText: translations!.refresh,
//                                             isButtonShow: false,
//                                             // buttonTap: () => value.getService(
//                                             //     id: value.categoryModel!.id),
//                                             widget: Image.asset(
//                                               eImageAssets.emptyCart,
//                                               height: Sizes.s230,
//                                             ),
//                                           ).marginOnly(top: Sizes.s50),
//                                         ],
//                                       )
//                                     : Consumer<CartProvider>(
//                                         builder: (context2, cart, child) {
//                                           return Column(
//                                             children: value.filteredServices
//                                                 .asMap()
//                                                 .entries
//                                                 .map((e) {
//                                               return FeaturedServicesLayout(
//                                                 data: e.value,
//                                                 isProvider: false,
//                                                 inCart: isInCart(
//                                                     context, e.value.id),
//                                                 addTap: value.isProviderLoading
//                                                     ? () {
//                                                         log("Provider Loading");
//                                                       }
//                                                     : () async {
//                                                         SharedPreferences pref =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         if (pref.getBool(session
//                                                                 .isContinueAsGuest) ==
//                                                             true) {
//                                                           route
//                                                               .pushNamedAndRemoveUntil(
//                                                                   context,
//                                                                   routeName
//                                                                       .login);
//                                                         } else {
//                                                           value.getProviderById(
//                                                               context,
//                                                               e.value.id!,
//                                                               e.key,
//                                                               e.value);
//                                                         }
//                                                       },
//                                                 onTap: value.isAlert
//                                                     ? () {}
//                                                     : () {
//                                                         serviceCtrl
//                                                             .getServiceById(
//                                                                 context,
//                                                                 e.value.id);
//                                                         route.pushNamed(
//                                                             context,
//                                                             routeName
//                                                                 .servicesDetailsScreen,
//                                                             arg: {
//                                                               'serviceId':
//                                                                   e.value.id,
//                                                             });
//                                                       },
//                                               ).paddingSymmetric(
//                                                   horizontal: Insets.i20);
//                                             }).toList(),
//                                           ).marginOnly(top: Insets.i15);
//                                         },
//                                       ),
//                       ]).paddingDirectional(top: Sizes.s20)))));
//     });
//   }
// }
