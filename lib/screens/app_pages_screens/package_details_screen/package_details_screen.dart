// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:fixit_user/screens/app_pages_screens/service_packages_screen/service_package_shimmer/service_package_shimmer.dart';

import '../../../config.dart';

class PackageDetailsScreen extends StatelessWidget {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesPackageDetailsProvider>(
      builder: (context1, packageCtrl, child) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            packageCtrl.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
            onInit: () => Future.delayed(DurationClass.ms150)
                .then((_) => packageCtrl.onReady(context)),
            child: RefreshIndicator(
              onRefresh: () => packageCtrl.onRefresh(context),
              child: Scaffold(
                appBar: AppBarCommon(
                  title: translations!.packageDetails,
                  onTap: () => packageCtrl.onBack(context, true),
                ),
                body: packageCtrl.isServicesPackageLoader ||
                        packageCtrl.service == null
                    ? const ServicePackageShimmer()
                    : SingleChildScrollView(
                        controller: packageCtrl.scrollController,
                        child: Column(children: [
                          SizedBox(
                              child: Column(children: [
                            PackageTopLayout(
                                packageModel: packageCtrl.service!),
                            const VSpace(Sizes.s15),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        language(context,
                                            translations!.profileDetails),
                                        style: appCss.dmDenseMedium12.textColor(
                                            appColor(context).lightText)),
                                    Row(
                                      children: [
                                        Text(
                                          language(context, translations!.view),
                                          style: appCss.dmDenseMedium12
                                              .textColor(
                                                  appColor(context).primary),
                                        ),
                                        const HSpace(Sizes.s4),
                                        SvgPicture.asset(
                                          eSvgAssets.anchorArrowRight,
                                          colorFilter: ColorFilter.mode(
                                            appColor(context).primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ],
                                    ).inkWell(
                                      onTap: packageCtrl.service!.user != null
                                          ? () => route.pushNamed(
                                                context,
                                                routeName.providerDetailsScreen,
                                                arg: {
                                                  'provider':
                                                      packageCtrl.service!.user
                                                },
                                              )
                                          : null,
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: Insets.i15),
                                Divider(
                                        height: 1,
                                        color: appColor(context).stroke)
                                    .paddingSymmetric(vertical: Insets.i15),
                                if (packageCtrl.service!.user != null)
                                  ProviderDetailLayout(
                                    image: packageCtrl.service!.user!.media !=
                                                null &&
                                            packageCtrl.service!.user!.media!
                                                .isNotEmpty &&
                                            packageCtrl.service!.user!.media![0]
                                                    .originalUrl !=
                                                null &&
                                            packageCtrl.service!.user!.media![0]
                                                .originalUrl!.isNotEmpty
                                        ? packageCtrl.service!.user!.media![0]
                                            .originalUrl!
                                        : eImageAssets.noImageFound1,
                                    name: packageCtrl.service!.user!.name ??
                                        'Unknown Provider',
                                    rate: packageCtrl
                                                .service!.user!.reviewRatings !=
                                            null
                                        ? packageCtrl
                                            .service!.user!.reviewRatings!
                                            .toStringAsFixed(2)
                                        : "0.0",
                                    star: eSvgAssets.star1,
                                  )
                                else
                                  Text(
                                    language(
                                        context, translations!.noDataFound),
                                    style: appCss.dmDenseRegular14
                                        .textColor(appColor(context).lightText),
                                  ).paddingAll(Insets.i15),
                              ],
                            )
                                .paddingSymmetric(vertical: Insets.i15)
                                .boxShapeExtension(
                                    color: appColor(context).fieldCardBg),
                            Text(
                              language(context, translations!.includedService),
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).darkText),
                            )
                                .paddingOnly(
                                    top: Insets.i15, bottom: Insets.i10)
                                .alignment(Alignment.centerLeft),
                            if (packageCtrl.service!.services != null &&
                                packageCtrl.service!.services!.isNotEmpty)
                              Column(
                                children: packageCtrl.service!.services!
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => IncludedServiceLayout(
                                        data: e.value,
                                        index: e.key,
                                        list: packageCtrl.service!.services!,
                                      ),
                                    )
                                    .toList(),
                              ).paddingAll(Insets.i15).boxShapeExtension(
                                  color: appColor(context).fieldCardBg)
                            else
                              Text(
                                language(context, translations!.noDataFound),
                                style: appCss.dmDenseRegular14
                                    .textColor(appColor(context).lightText),
                              ).paddingAll(Insets.i15),
                            const DottedLines()
                                .paddingSymmetric(vertical: Insets.i15),
                            DisclaimerLayout(
                              title: translations!.servicePackageDisclaimer,
                              color: appColor(context).red,
                            )
                          ])).paddingAll(Insets.i15).boxBorderExtension(context,
                              isShadow: true, radius: AppRadius.r12),
                          const VSpace(Sizes.s30),
                        ]).paddingSymmetric(horizontal: Insets.i20),
                      ),
                bottomNavigationBar: packageCtrl.service != null
                    ? ButtonCommon(
                            margin: Insets.i20,
                            title: translations!.addToCart!,
                            onTap: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              if (pref.getBool(session.isContinueAsGuest) ==
                                  true) {
                                route.pushNamedAndRemoveUntil(
                                    context, routeName.login);
                              } else {
                                route.pushNamed(
                                  context,
                                  routeName.selectServiceScreen,
                                  arg: {
                                    "services": packageCtrl.service,
                                    "id": packageCtrl.service!.id ?? 0,
                                  },
                                );
                              }
                            })
                        .marginOnly(bottom: Insets.i20)
                        .backgroundColor(appColor(context).whiteBg)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/*
import 'dart:developer';

import 'package:fixit_user/screens/app_pages_screens/service_packages_screen/service_package_shimmer/service_package_shimmer.dart';
import 'package:flutter/rendering.dart';

import '../../../config.dart';

class PackageDetailsScreen extends StatelessWidget {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesPackageDetailsProvider>(
        builder: (context1, packageCtrl, child) {
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            packageCtrl.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
              onInit: () => Future.delayed(DurationClass.ms150)
                  .then((_) => packageCtrl.onReady(context)),
              child: RefreshIndicator(
                onRefresh: () {
                  return packageCtrl.onRefresh(context);
                },
                child: Stack(children: [
                  packageCtrl
                          .isServicesPackageLoader */
/* widget1Opacity == 0.0 */ /*

                      ? const ServicePackageShimmer()
                      : Scaffold(
                          appBar: AppBarCommon(
                              title: translations!.packageDetails,
                              onTap: () => packageCtrl.onBack(context, true)),
                          body: packageCtrl.serviceList == null
                              ? Container()
                              : Stack(children: [
                                  SingleChildScrollView(
                                      controller: packageCtrl.scrollController,
                                      child: Column(children: [
                                        SizedBox(
                                                child: Column(children: [
                                          PackageTopLayout(
                                              packageModel:
                                                  packageCtrl.serviceList),
                                          const VSpace(Sizes.s15),
                                          Column(children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      language(
                                                          context,
                                                          translations!
                                                              .profileDetails),
                                                      style: appCss
                                                          .dmDenseMedium12
                                                          .textColor(
                                                              appColor(context)
                                                                  .lightText)),
                                                  Row(children: [
                                                    Text(
                                                        language(context,
                                                            translations!.view),
                                                        style: appCss
                                                            .dmDenseMedium12
                                                            .textColor(appColor(
                                                                    context)
                                                                .primary)),
                                                    const HSpace(Sizes.s4),
                                                    SvgPicture.asset(
                                                        eSvgAssets
                                                            .anchorArrowRight,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                appColor(
                                                                        context)
                                                                    .primary,
                                                                BlendMode
                                                                    .srcIn))
                                                  ]).inkWell(
                                                      onTap: () => route.pushNamed(
                                                              context,
                                                              routeName
                                                                  .providerDetailsScreen,
                                                              arg: {
                                                                'provider':
                                                                    packageCtrl
                                                                        .serviceList!
                                                                        .user!
                                                              }))
                                                ]).paddingSymmetric(
                                                horizontal: Insets.i15),
                                            Divider(
                                                    height: 1,
                                                    color: appColor(context)
                                                        .stroke)
                                                .paddingSymmetric(
                                                    vertical: Insets.i15),
                                            if (packageCtrl.serviceList!.user != null)
                                              ProviderDetailLayout(
                                                  image: packageCtrl
                                                                  .serviceList!
                                                                  .user!
                                                                  .media !=
                                                              null &&
                                                          packageCtrl
                                                              .serviceList!
                                                              .user!
                                                              .media!
                                                              .isNotEmpty
                                                      ? packageCtrl
                                                          .serviceList!
                                                          .user!
                                                          .media![0]
                                                          .originalUrl!
                                                      : null,
                                                  name: packageCtrl
                                                      .serviceList!.user!.name,
                                                  rate: packageCtrl
                                                              .serviceList!
                                                              .user!
                                                              .reviewRatings !=
                                                          null
                                                      ? packageCtrl.serviceList!
                                                          .user!.reviewRatings
                                                          .toString()
                                                      : "0",
                                                  star: eSvgAssets.star3)
                                          ])
                                              .paddingSymmetric(
                                                  vertical: Insets.i15)
                                              .boxShapeExtension(
                                                  color: appColor(context)
                                                      .fieldCardBg),
                                          Text(
                                                  language(
                                                      context,
                                                      translations!
                                                          .includedService),
                                                  style: appCss.dmDenseMedium14
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText))
                                              .paddingOnly(
                                                  top: Insets.i15,
                                                  bottom: Insets.i10)
                                              .alignment(Alignment.centerLeft),
                                          if (packageCtrl.serviceList!.services !=
                                              null)
                                            Column(
                                                    children: packageCtrl
                                                        .serviceList!.services!
                                                        .asMap()
                                                        .entries
                                                        .map((e) =>
                                                            IncludedServiceLayout(
                                                                data: e.value,
                                                                index: e.key,
                                                                list: packageCtrl
                                                                    .serviceList!
                                                                    .services!))
                                                        .toList())
                                                .paddingAll(Insets.i15)
                                                .boxShapeExtension(
                                                    color: appColor(context)
                                                        .fieldCardBg),
                                          const DottedLines().paddingSymmetric(
                                              vertical: Insets.i15),
                                          DisclaimerLayout(
                                              title: translations!
                                                  .servicePackageDisclaimer,
                                              color: appColor(context).red)
                                        ]))
                                            .paddingAll(Insets.i15)
                                            .boxBorderExtension(context,
                                                isShadow: true,
                                                radius: AppRadius.r12),
                                        const VSpace(Sizes.s100),
                                      ]).paddingSymmetric(
                                          horizontal: Insets.i20)),
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: ButtonCommon(
                                              margin: Insets.i20,
                                              title: translations!.addToCart,
                                              onTap: () =>
                                                  route
                                                      .pushNamed(
                                                          context,
                                                          routeName
                                                              .selectServiceScreen,
                                                          arg: {
                                                        "services":
                                                            packageCtrl.serviceList,
                                                        "id": packageCtrl
                                                            .serviceList!.id
                                                      }))
                                          .marginOnly(bottom: Insets.i20)
                                          .backgroundColor(
                                              appColor(context).whiteBg))

                                  */
/* Align(
                                      alignment: Alignment.bottomCenter,
                                      child: AnimatedBuilder(
                                          animation:
                                              packageCtrl.scrollController,
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                height: packageCtrl
                                                            .scrollController
                                                            .position
                                                            .userScrollDirection ==
                                                        ScrollDirection.reverse
                                                    ? 0
                                                    : 70,
                                                child: child);
                                          },
                                          child: ButtonCommon(
                                                  margin: Insets.i20,
                                                  title: translations!.addToCart,
                                                  onTap: () => route
                                                          .pushNamed(
                                                              context,
                                                              routeName
                                                                  .selectServiceScreen,
                                                              arg: {
                                                            "services":
                                                                packageCtrl
                                                                    .service,
                                                            "id": packageCtrl
                                                                .service!.id
                                                          }))
                                              .marginOnly(bottom: Insets.i20)
                                              .backgroundColor(
                                                  appColor(context).whiteBg))) */ /*

                                ]))
                ]),
              )));
    });
  }
}
*/
