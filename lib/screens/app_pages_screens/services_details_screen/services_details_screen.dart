// ignore_for_file: deprecated_member_use, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, use_build_context_synchronously

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/models/service_details_model.dart';
import 'package:fixit_user/screens/app_pages_screens/services_details_screen/layouts/service_faq.dart';
import 'package:fixit_user/screens/app_pages_screens/services_details_screen/layouts/services_add_on.dart';
import 'package:fixit_user/screens/app_pages_screens/services_details_screen/service_detail_shimmer/services_details_shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../config.dart';

import 'dart:developer';

class ServicesDetailsScreen extends StatelessWidget {
  const ServicesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteListProvider>(builder: (context2, favCtrl, child) {
      return Consumer<ServicesDetailsProvider>(
          builder: (context1, serviceCtrl, child) {
        log("service:::${serviceCtrl.service?.id}");
        return Container(
          color: appColor(context).whiteBg,
          child: SafeArea(
            child: StatefulWrapper(
                onInit: () => Future.delayed(DurationClass.ms150)
                    .then((val) => serviceCtrl.onReady(context)),
                child: PopScope(
                    canPop: true,
                    onPopInvoked: (didPop) {
                      // Navigator.pop(context);
                      // serviceCtrl.onBack(context, false);
                      if (didPop) return;
                    },
                    child: RefreshIndicator(
                      onRefresh: () {
                        return serviceCtrl.onRefresh(context);
                      },
                      child: Scaffold(
                          body: serviceCtrl.isLoading == true
                              ? const ServiceDetailShimmer()
                              : AnimatedOpacity(
                                  duration: const Duration(milliseconds: 100),
                                  opacity: serviceCtrl.widget1Opacity,
                                  child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        SingleChildScrollView(
                                            // controller: serviceCtrl.scrollController,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              if (serviceCtrl.service != null)
                                                ServiceImageLayout(
                                                    data: serviceCtrl.service,
                                                    onBack: () =>
                                                        Navigator.pop(context),
                                                    title: serviceCtrl
                                                            .service?.title ??
                                                        '',
                                                    image: serviceCtrl.service!
                                                            .media!.isNotEmpty
                                                        ? serviceCtrl
                                                            .service!
                                                            .media![serviceCtrl
                                                                .selectedIndex]
                                                            .originalUrl!
                                                        : "",
                                                    // rating: serviceCtrl.service!.ratingCount
                                                    //     ?.toString(),
                                                    removeTap: () {
                                                      serviceCtrl.service!
                                                          .isFavourite = 0;
                                                      favCtrl.deleteFav(context,
                                                          isFavId: serviceCtrl
                                                              .service!
                                                              .isFavouriteId,
                                                          id: serviceCtrl
                                                              .service?.id);
                                                    },
                                                    favTap: () {
                                                      // log("FAV : ${serviceCtrl.service!.isFavourite}//}");

                                                      serviceCtrl.service
                                                          ?.isFavourite = 1;
                                                      favCtrl.addFav(
                                                          "service",
                                                          context,
                                                          serviceCtrl
                                                              .service!.id);
                                                    }),
                                              if (serviceCtrl.service != null &&
                                                  serviceCtrl.service!.media!
                                                      .isNotEmpty &&
                                                  serviceCtrl
                                                          .service!
                                                          .media![serviceCtrl
                                                              .selectedIndex]
                                                          .originalUrl!
                                                          .length >
                                                      1)
                                                const VSpace(Sizes.s12),
                                              if (serviceCtrl.service != null &&
                                                  serviceCtrl.service!.media!
                                                          .length >
                                                      1)
                                                const VSpace(Sizes.s12),
                                              if (serviceCtrl.service != null &&
                                                  serviceCtrl.service!.media!.length >
                                                      1)
                                                serviceCtrl.service!.media!
                                                            .isNotEmpty &&
                                                        serviceCtrl
                                                            .service!
                                                            .media!
                                                            .isNotEmpty &&
                                                        serviceCtrl.service!
                                                                .media!.length <
                                                            4
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: serviceCtrl
                                                            .service!.media!
                                                            .asMap()
                                                            .entries
                                                            .map((e) => ServicesImageLayout(
                                                                data: e.value,
                                                                index: e.key,
                                                                selectIndex:
                                                                    serviceCtrl
                                                                        .selectedIndex,
                                                                onTap: () =>
                                                                    serviceCtrl.onImageChange(e.key)))
                                                            .toList())
                                                    : SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: serviceCtrl
                                                                    .service!
                                                                    .media!
                                                                    .asMap()
                                                                    .entries
                                                                    .map((e) => ServicesImageLayout(
                                                                        data: e
                                                                            .value,
                                                                        index: e
                                                                            .key,
                                                                        selectIndex:
                                                                            serviceCtrl
                                                                                .selectedIndex,
                                                                        onTap: () =>
                                                                            serviceCtrl.onImageChange(e.key)))
                                                                    .toList()),
                                                            if (serviceCtrl
                                                                        .service
                                                                        ?.video !=
                                                                    null &&
                                                                serviceCtrl
                                                                        .service
                                                                        ?.video !=
                                                                    "")
                                                              SizedBox(
                                                                height:
                                                                    Sizes.s60,
                                                                width:
                                                                    Sizes.s60,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () =>
                                                                      serviceCtrl
                                                                          .onVideo(),
                                                                  child:
                                                                      AbsorbPointer(
                                                                    child:
                                                                        YoutubePlayer(
                                                                      controller:
                                                                          YoutubePlayerController(
                                                                        initialVideoId:
                                                                            YoutubePlayer.convertUrlToId(serviceCtrl.service?.video ?? '') ??
                                                                                '',
                                                                        flags: const YoutubePlayerFlags(
                                                                            autoPlay:
                                                                                false,
                                                                            mute:
                                                                                false),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ).padding(
                                                                  right:
                                                                      Sizes.s10)
                                                          ],
                                                        ),
                                                      ).paddingOnly(left: Sizes.s20),
                                              Column(children: [
                                                Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                          eImageAssets
                                                              .servicesBg,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                language(
                                                                    context,
                                                                    translations!
                                                                        .amount),
                                                                style: appCss
                                                                    .dmDenseMedium12
                                                                    .textColor(appColor(
                                                                            context)
                                                                        .primary)),
                                                            if (serviceCtrl
                                                                    .service !=
                                                                null)
                                                              Text(
                                                                  symbolPosition
                                                                      ? "${getSymbol(context)}${(currency(context).currencyVal * (serviceCtrl.service?.serviceRate ?? 0.0)).toStringAsFixed(2)}"
                                                                      : "${(currency(context).currencyVal * (serviceCtrl.service?.serviceRate ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                                  style: appCss
                                                                      .dmDenseBold18
                                                                      .textColor(
                                                                          appColor(context)
                                                                              .primary))
                                                          ]).paddingSymmetric(
                                                          horizontal:
                                                              Insets.i20)
                                                    ]).paddingSymmetric(
                                                    vertical: Insets.i15),
                                                ServiceDescription(
                                                    services:
                                                        serviceCtrl.service),
                                              ]).paddingSymmetric(
                                                  horizontal: Insets.i20),
                                              if (appSettingModel!.activation!
                                                      .additionalServices ==
                                                  "1")
                                                if (serviceCtrl.service !=
                                                        null &&
                                                    serviceCtrl
                                                        .service!
                                                        .additionalServices!
                                                        .isNotEmpty)
                                                  const ServicesAddOn(),
                                              if (serviceCtrl
                                                  .serviceFaq.isNotEmpty)
                                                const ServiceFaq(),
                                              if (serviceCtrl.service != null &&
                                                  serviceCtrl
                                                      .service!
                                                      .relatedServices!
                                                      .isNotEmpty &&
                                                  serviceCtrl
                                                      .service!
                                                      .relatedServices!
                                                      .isNotEmpty)
                                                HeadingRowCommon(
                                                  title: translations!
                                                      .alsoProvided,
                                                  onTap: () => route.pushNamed(
                                                      context,
                                                      routeName
                                                          .providerDetailsScreen,
                                                      arg: {
                                                        'providerId':
                                                            serviceCtrl.service!
                                                                .user!.id
                                                      }),
                                                ).padding(
                                                    top: Insets.i25,
                                                    bottom: Insets.i15,
                                                    horizontal: Insets.i20),
                                              if (serviceCtrl.service != null &&
                                                  serviceCtrl
                                                      .service!
                                                      .relatedServices!
                                                      .isNotEmpty)
                                                SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children:
                                                            serviceCtrl.service!
                                                                .relatedServices!
                                                                .asMap()
                                                                .entries
                                                                .map((e) =>
                                                                    ServiceListLayout(
                                                                      data: e
                                                                          .value,
                                                                      favTap:
                                                                          (p0) {
                                                                        log("FAV : ${serviceCtrl.service?.isFavouriteId}");
                                                                        if (p0) {
                                                                          log("e.value:::${e.value}");
                                                                          // ?.isFavourite = 1;
                                                                          favCtrl.addFav(
                                                                              'service',
                                                                              context,
                                                                              e.value.id);
                                                                        } else {
                                                                          log("serviceCtrl.service?.id ${serviceCtrl.service?.id}");
                                                                          log("serviceCtrl.service?.id ${serviceCtrl.service!.isFavouriteId}");
                                                                          favCtrl.deleteFav(
                                                                              context,
                                                                              isFavId: serviceCtrl.service!.isFavouriteId,
                                                                              id: serviceCtrl.service?.id);
                                                                        }
                                                                      },
                                                                      onTap:
                                                                          () async {
                                                                        SharedPreferences
                                                                            pref =
                                                                            await SharedPreferences.getInstance();
                                                                        if (pref.getBool(session.isContinueAsGuest) ==
                                                                            true) {
                                                                          route.pushNamedAndRemoveUntil(
                                                                              context,
                                                                              routeName.login);
                                                                        } else {
                                                                          serviceCtrl.onFeatured(
                                                                              context,
                                                                              e.value,
                                                                              e.key);
                                                                        }
                                                                      },
                                                                      isFav: favCtrl
                                                                          .serviceFavList
                                                                          .where((element) =>
                                                                              element.service!.id != null &&
                                                                              element.service!.id == e.value.id.toString())
                                                                          .isNotEmpty,
                                                                    ).inkWell(
                                                                        onTap:
                                                                            () {
                                                                      serviceCtrl.getServiceById(
                                                                          context,
                                                                          e.value
                                                                              .id);
                                                                      route.pushNamed(
                                                                          context,
                                                                          routeName
                                                                              .servicesDetailsScreen,
                                                                          arg: {
                                                                            'serviceId':
                                                                                e.value.id,
                                                                          });
                                                                    }).paddingOnly(
                                                                        left: Insets
                                                                            .i20))
                                                                .toList())),
                                            ]).marginOnly(bottom: Insets.i100)),
                                        /*                  ButtonCommon(
                                margin: Insets.i20,
                                title: translations!.addToCart,
                                onTap: () => onBook(context, serviceCtrl.service!,
                                        addTap: () => serviceCtrl.onAdd(),
                                        minusTap: () =>
                                            serviceCtrl.onRemoveService(context))
                                    .then((e) {
                                  serviceCtrl
                                          .service!.selectedRequiredServiceMan =
                                      serviceCtrl.service!.requiredServicemen;
                                  serviceCtrl.notifyListeners();
                                }),
                              ).paddingOnly(bottom: Insets.i20).decorated(
                                  color: appColor(context).whiteBg)*/
                                        if (serviceCtrl.service?.status == 1)
                                          ButtonCommon(
                                                  margin: Insets.i20,
                                                  title: translations!.addToCart!,
                                                  onTap: () async {
                                                    SharedPreferences pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    // log("session.booking${pref.getString(session.booking)}");
                                                    // log("==== User IsGuest : ${pref.getBool(session.isContinueAsGuest)}");

                                                    if (pref.getBool(session
                                                            .isContinueAsGuest) ==
                                                        true) {
                                                      if (pref.getString(session
                                                              .booking) ==
                                                          "booking") {
                                                        route.pushNamed(context,
                                                            routeName.login);
                                                      } else {
                                                        final providerDetail =
                                                            Provider.of<
                                                                    ProviderDetailsProvider>(
                                                                context,
                                                                listen: false);
                                                        providerDetail
                                                            .selectProviderIndex = 0;
                                                        providerDetail
                                                            .notifyListeners();
                                                        serviceCtrl.service!
                                                                .selectedAdditionalServices =
                                                            serviceCtrl
                                                                .additionalService
                                                                .cast<
                                                                    AdditionalService>();
                                                        serviceCtrl
                                                            .notifyListeners();
                                                        // Create ProviderModel from User
                                                        ProviderModel? provider;
                                                        if (serviceCtrl.service
                                                                ?.user !=
                                                            null) {
                                                          var user = serviceCtrl
                                                              .service!.user!;
                                                          provider =
                                                              ProviderModel(
                                                            id: user.id,
                                                            name: user.name,
                                                            reviewRatings: double
                                                                .tryParse(user
                                                                    .reviewRatings
                                                                    .toString()),
                                                            experienceInterval:
                                                                user.experienceInterval,
                                                            experienceDuration:
                                                                int.tryParse(user
                                                                    .experienceDuration
                                                                    .toString()),
                                                            served: user.served
                                                                .toString(),
                                                            fcmToken: user
                                                                .fcmToken
                                                                .toString(),
                                                            media: user.media
                                                                .map((e) => Media(
                                                                    originalUrl:
                                                                        e.originalUrl))
                                                                .toList(),
                                                          );
                                                        }

                                                        onBook(
                                                            context,
                                                            serviceCtrl.service!
                                                                as Services,
                                                            provider:
                                                                provider, // Pass provider here
                                                            addTap: () =>
                                                                serviceCtrl
                                                                    .onAdd(),
                                                            minusTap: () => serviceCtrl
                                                                .onRemoveService(
                                                                    context)).then(
                                                            (e) {
                                                          serviceCtrl.service!
                                                                  .selectedRequiredServiceMan =
                                                              serviceCtrl
                                                                  .service!
                                                                  .requiredServicemen;
                                                          serviceCtrl
                                                              .notifyListeners();
                                                        });
                                                      }
                                                    } else {
                                                      final providerDetail =
                                                          Provider.of<
                                                                  ProviderDetailsProvider>(
                                                              context,
                                                              listen: false);
                                                      providerDetail
                                                          .selectProviderIndex = 0;
                                                      providerDetail
                                                          .notifyListeners();
                                                      serviceCtrl.service!
                                                              .selectedAdditionalServices =
                                                          serviceCtrl
                                                              .additionalService
                                                              .cast<
                                                                  AdditionalService>();
                                                      serviceCtrl
                                                          .notifyListeners();

                                                      // Create ProviderModel from User
                                                      ProviderModel? provider;
                                                      if (serviceCtrl
                                                              .service?.user !=
                                                          null) {
                                                        var user = serviceCtrl
                                                            .service!.user!;
                                                        provider =
                                                            ProviderModel(
                                                          id: user.id,
                                                          name: user.name,
                                                          reviewRatings: double
                                                              .tryParse(user
                                                                  .reviewRatings
                                                                  .toString()),
                                                          experienceInterval: user
                                                              .experienceInterval,
                                                          experienceDuration:
                                                              int.tryParse(user
                                                                  .experienceDuration
                                                                  .toString()),
                                                          served: user.served
                                                              .toString(),
                                                          fcmToken: user
                                                              .fcmToken
                                                              .toString(),
                                                          media: user.media
                                                              .map((e) => Media(
                                                                  originalUrl: e
                                                                      .originalUrl))
                                                              .toList(),
                                                        );
                                                      }

                                                      onBook(context,
                                                          serviceCtrl.service!,
                                                          provider:
                                                              provider, // Pass provider here
                                                          addTap: () =>
                                                              serviceCtrl
                                                                  .onAdd(),
                                                          minusTap: () => serviceCtrl
                                                              .onRemoveService(
                                                                  context)).then(
                                                          (e) {
                                                        // log("message errorr ${serviceCtrl.service?.selectedRequiredServiceMan}");
                                                        serviceCtrl.service
                                                                ?.selectedRequiredServiceMan =
                                                            serviceCtrl.service!
                                                                .requiredServicemen;
                                                        // log("message errorr ${serviceCtrl.service?.selectedRequiredServiceMan}");
                                                        serviceCtrl
                                                            .notifyListeners();
                                                      });
                                                    }
                                                  })
                                              .marginOnly(bottom: Insets.i20)
                                              .backgroundColor(
                                                  appColor(context).whiteBg)
                                      ]),
                                )),
                    ))),
          ),
        );
      });
    });
  }
}
