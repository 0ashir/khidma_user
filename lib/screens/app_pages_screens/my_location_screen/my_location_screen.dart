// ignore_for_file: unnecessary_import, deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config.dart';

class MyLocationScreen extends StatefulWidget {
  const MyLocationScreen({
    super.key,
  });

  @override
  State<MyLocationScreen> createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends State<MyLocationScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(builder: (context1, locationCtrl, child) {
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) async {
            locationCtrl.onBack();
            if (didPop) return;
          },
          child: StatefulWrapper(
              onInit: () => Future.delayed(DurationClass.ms50)
                  .then((_) => locationCtrl.onReady(context)),
              child: Scaffold(
                  appBar: AppBar(
                      leadingWidth: 80,
                      title: Text(language(context, translations!.myLocations),
                          style: appCss.dmDenseBold18
                              .textColor(appColor(context).darkText)),
                      centerTitle: true,
                      leading: CommonArrow(
                          arrow: eSvgAssets.arrowLeft,
                          onTap: () {
                            locationCtrl.onBack();
                            route.pop(context);
                          }).paddingAll(Insets.i8),
                      actions: [
                        CommonArrow(
                            arrow: eSvgAssets.add,
                            onTap: () => route
                                .pushNamed(context, routeName.currentLocation)
                                .then((value) => locationCtrl.getLocationList(
                                    context))).paddingSymmetric(
                            horizontal: Insets.i20)
                      ]),
                  body: locationCtrl.isAddLoading
                      ? Image.asset(
                          eGifAssets.loader,
                          height: Sizes.s100,
                          width: Sizes.s100,
                        ).center()
                      : Stack(alignment: Alignment.bottomCenter, children: [
                          RefreshIndicator(
                            onRefresh: () async {
                              return locationCtrl.getLocationList(context);
                            },
                            child: ListView(
                                    controller: locationCtrl.scrollController,
                                    children: [
                                  if (locationCtrl.addressList.isEmpty)
                                    EmptyLayout(
                                        title: translations!.noSaveLocation,
                                        subtitle: translations!.thereAreNo,
                                        buttonText:
                                            translations!.addNewLocation,
                                        inkText: translations!.useMyCurrent,
                                        bTap: () => route.pushNamed(
                                            context, routeName.currentLocation),
                                        isInk: true,
                                        inkOnTap: () async {
                                          await locationCtrl
                                              .getUserCurrentLocation(context);
                                          route.pop(context);
                                        },
                                        widget: Stack(children: [
                                          Image.asset(eImageAssets.notiGirl,
                                              height: Sizes.s346),
                                          if (locationCtrl
                                                  .animationController !=
                                              null)
                                            Positioned(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.035,
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.052,
                                                child: Column(children: [
                                                  Image.asset(
                                                      eImageAssets.noLocation,
                                                      height: Sizes.s40,
                                                      width: Sizes.s40),
                                                  /* RotationTransition(
                                  turns: Tween(begin: 0.05, end: -.01)
                                      .chain(CurveTween(
                                          curve: Curves.elasticInOut))
                                      .animate(value.animationController!),
                                  child: Image.asset(eImageAssets.noLocation,
                                      height: Sizes.s40, width: Sizes.s40)), */
                                                  Image.asset(
                                                      eImageAssets.shadow,
                                                      height: Sizes.s5,
                                                      width: Sizes.s30)
                                                ]))
                                        ])),
                                  /*  const CommonEmpty(), */
                                  if (locationCtrl.addressList.isNotEmpty)
                                    ...locationCtrl.addressList.asMap().entries.map((e) => LocationLayout(
                                            data: e.value,
                                            selectedIndex: e.value.isPrimary == 1
                                                ? true
                                                : locationCtrl.selectedIndex ==
                                                    e.key,
                                            deleteOnTap: () =>
                                                locationCtrl.deleteAccountConfirmation(
                                                    context, this, e.value.id),
                                            editOnTap: () => route.pushNamed(
                                                context, routeName.currentLocation,
                                                arg: {"data": e.value, "isEdit": true}).then((value) => locationCtrl.getLocationList(context)))
                                        .inkWell(onTap: () => locationCtrl.selectAddress(e.key)))
                                ])
                                .paddingSymmetric(vertical: Insets.i20)
                                .marginOnly(bottom: Insets.i50),
                          ),
                          if (locationCtrl.addressList.isNotEmpty)
                            !locationCtrl.isButtonShow
                                ? ButtonCommon(
                                        onTap: () {
                                          log("message-=-=-=-=-==-=-=-=-==-=-=-=-=-=-=-=-=-");
                                          if (locationCtrl.selectedIndex !=
                                              null) {
                                            locationCtrl.setDefault(context);
                                            locationCtrl.getZoneId(context,
                                                isLocation: true,
                                                lan: locationCtrl
                                                    .addressList[locationCtrl
                                                        .selectedIndex!
                                                        .toInt()]
                                                    .longitude,
                                                lat: locationCtrl
                                                    .addressList[locationCtrl
                                                        .selectedIndex!
                                                        .toInt()]
                                                    .latitude);
                                          } else {
                                            locationCtrl.getZoneId(context,
                                                isLocation: true,
                                                lan: locationCtrl
                                                    .addressList[locationCtrl
                                                        .selectedIndex!
                                                        .toInt()]
                                                    .longitude,
                                                lat: locationCtrl
                                                    .addressList[locationCtrl
                                                        .selectedIndex!
                                                        .toInt()]
                                                    .latitude);
                                            Fluttertoast.showToast(
                                                msg: language(
                                                    context,
                                                    translations!
                                                        .pleaseSelectAddress));
                                          }
                                        },
                                        title: setPrimaryAddress == null
                                            ? language(
                                                context,
                                                locationCtrl.selectedIndex ==
                                                        null
                                                    ? translations!
                                                        .selectPrimaryLocation
                                                    : translations!
                                                        .setAsPrimary)
                                            : language(
                                                context,
                                                translations!
                                                    .selectPrimaryLocation),
                                        style: appCss.dmDenseSemiBold16
                                            .textColor(setPrimaryAddress == null
                                                ? locationCtrl.selectedIndex ==
                                                        null
                                                    ? appColor(context).primary
                                                    : appColor(context)
                                                        .whiteColor
                                                : appColor(context).whiteColor),
                                        color: setPrimaryAddress == null
                                            ? locationCtrl.selectedIndex == null
                                                ? appColor(context)
                                                    .primary
                                                    .withOpacity(0.10)
                                                : appColor(context).primary
                                            : appColor(context).primary,
                                        margin: Insets.i20)
                                    .marginOnly(bottom: Insets.i20)
                                : ButtonCommon(
                                        onTap: () {
                                          if (locationCtrl.selectedIndex !=
                                              null) {
                                            route.pop(context,
                                                arg: locationCtrl.addressList[
                                                    locationCtrl
                                                        .selectedIndex!]);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: language(
                                                    context,
                                                    translations!
                                                        .pleaseSelectAddress));
                                          }
                                        },
                                        title: language(context,
                                            translations!.submitLocation),
                                        color:
                                            locationCtrl.selectedIndex != null
                                                ? appColor(context).primary
                                                : appColor(context).fieldCardBg,
                                        margin: Insets.i20)
                                    .marginOnly(bottom: Insets.i20)
                          /*  AnimatedBuilder(
                          animation: locationCtrl.scrollController,
                          builder: (BuildContext context, Widget? child) {
                            return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: locationCtrl.scrollController.position
                                            .userScrollDirection ==
                                        ScrollDirection.reverse
                                    ? 0
                                    : 70,
                                child: child);
                          },
                          child: !locationCtrl.isButtonShow
                              ? ButtonCommon(
                                      onTap: () {
                                        if (locationCtrl.selectedIndex !=
                                            null) {
                                          locationCtrl.setDefault(context);
                                        } else {
                                          snackBarMessengers(context,
                                              message: language(
                                                  context,
                                                  translations!
                                                      .pleaseSelectAddress));
                                        }
                                      },
                                      title: setPrimaryAddress == null
                                          ? language(
                                              context,
                                              locationCtrl.selectedIndex == null
                                                  ? translations!
                                                      .selectPrimaryLocation
                                                  : translations!.setAsPrimary)
                                          : language(
                                              context,
                                              translations!
                                                  .selectPrimaryLocation),
                                      style: appCss.dmDenseSemiBold16.textColor(
                                          setPrimaryAddress == null
                                              ? locationCtrl.selectedIndex ==
                                                      null
                                                  ? appColor(context).primary
                                                  : appColor(context).whiteColor
                                              : appColor(context).whiteColor),
                                      color: setPrimaryAddress == null
                                          ? locationCtrl.selectedIndex == null
                                              ? appColor(context)
                                                  .primary
                                                  .withOpacity(0.10)
                                              : appColor(context).primary
                                          : appColor(context).primary,
                                      margin: Insets.i20)
                                  .marginOnly(bottom: Insets.i20)
                              : ButtonCommon(
                                      onTap: () {
                                        if (locationCtrl.selectedIndex !=
                                            null) {
                                          route.pop(context,
                                              arg: locationCtrl.addressList[
                                                  locationCtrl.selectedIndex!]);
                                        } else {
                                          snackBarMessengers(context,
                                              message: language(
                                                  context,
                                                  translations!
                                                      .pleaseSelectAddress));
                                        }
                                      },
                                      title: language(context,
                                          translations!.submitLocation),
                                      color: locationCtrl.selectedIndex != null
                                          ? appColor(context).primary
                                          : appColor(context).fieldCardBg,
                                      margin: Insets.i20)
                                  .marginOnly(bottom: Insets.i20)) */
                        ]))));
    });
  }
}
