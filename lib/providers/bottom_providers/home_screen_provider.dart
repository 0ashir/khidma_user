// ignore_for_file: unused_field

import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fixit_user/services/environment.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreenProvider with ChangeNotifier {
  int selectIndex = 0;
  int? cIndex;
  AnimationController? controller;
  Animation? animation;
  bool isSkeleton = true;

  HomeScreenProvider() {
    animationController = AnimationController(
        vsync: _TickerProvider(this), duration: const Duration(seconds: 10))
      ..repeat();
    rotationAnimation =
        Tween<double>(begin: 1, end: 0).animate(animationController!);
  }

  onAnimate(TickerProvider sync, context) async {
    // Provider.of<CategoriesListProvider>(context, listen: false)
    //     .getCategory(context);
    animationController = AnimationController(
        vsync: _TickerProvider(this), duration: const Duration(seconds: 10))
      ..repeat();
    rotationAnimation =
        Tween<double>(begin: 1, end: 0).animate(animationController!);

    await Future.delayed(const Duration(milliseconds: 2500));
    isSkeleton = false;
    notifyListeners();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String buildNumber = packageInfo.buildNumber;

    final minVersion = int.tryParse(
        appSettingModel?.appSettings?.userAppForceUpdate?.minVersionAndroid ??
            "0");
    final currentVersion = int.tryParse(buildNumber);

    log("object=-=-=-=-$minVersion=======$currentVersion");

    if (appSettingModel?.activation?.forceUpdateInApp == "1") {
      if (minVersion != null &&
          currentVersion != null &&
          currentVersion < minVersion) {
        showCustomDialog(context);
      }
    }

    /*  if (appSettingModel?.activation?.forceUpdateInApp == "1") {
      showCustomDialog(context);
    } */
    //notifyListeners();
  }

  /// Update App Dialog
  void showCustomDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language(context, translations!.updateApp)),
          content: Text(language(context, translations!.updateAppContent)),
          actions: [
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(userAppPlayStoreUrl));
                Navigator.of(context).pop();
              },
              child: Text(language(context, translations!.updateNow)),
            ),
          ],
        );
      },
    );
  }

  List service = appArray.servicesList.getRange(1, 3).toList();

  double turns = 0.00;
  Animation<double>? rotationAnimation;
  AnimationController? animationController;

  isEmptyLayout(context) {
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    log("dash.bannerList.isNotEmpty : ${dash.bannerList.length} && ${dash.categoryList.length} && ${dash.servicePackagesList.length} && ${dash.featuredServiceList.length}");
    return dash.bannerList.isNotEmpty ||
        dash.categoryList.isNotEmpty ||
        dash.servicePackagesList.isNotEmpty &&
            dash.featuredServiceList.isNotEmpty;
  }

  //on banner tap
  onBannerTap(context, type, id) {
    log("TYPE : $type / ID : $id");
    if (type == "service") {
      log("message");
      Provider.of<ServicesDetailsProvider>(context, listen: false)
          .getServiceById(context, id);
      route.pushNamed(context, routeName.servicesDetailsScreen,
          arg: {"serviceId": id});
    } else if (type == "category") {
      log("message1");
      final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
      commonApi.getCategoryById(context, id);
    } else {
      log("message2");
      Provider.of<ProviderDetailsProvider>(context, listen: false)
          .getProviderById(context, id);

      route.pushNamed(context, routeName.providerDetailsScreen,
          arg: {'providerId': id});
    }
  }

  //on banner change
  onSlideBanner(index) {
    selectIndex = index;
    notifyListeners();
  }

//location tap
  locationTap(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref = await SharedPreferences.getInstance();
    bool isGuest = pref.getBool(session.isContinueAsGuest) ?? false;
    if (isGuest == false) {
      final location = Provider.of<LocationProvider>(context, listen: false);
      location.getLocationList(context);
      route.pushNamed(context, routeName.myLocation).then((e) {
        animationController!.reset();
        notifyListeners();
      }).then((e) {
        // location.getLocationList(context);
      });
      /*   if (location.addressList.isEmpty) {
        route.pushNamed(context, routeName.location).then((e) {
          animationController!.reset();
          notifyListeners();
        }).then((e) {
          location.getLocationList(context);
        });
      } else {
        route.pushNamed(context, routeName.myLocation).then((e) {
          animationController!.reset();
          notifyListeners();
        }).then((e) {
          location.getLocationList(context);
        });
      } */
      animationController!.stop();
      notifyListeners();
    } else {
      route.pushNamed(context, routeName.login);
      /* route.pushAndRemoveUntil(context); */
    }
  }

  //notification tap
  notificationTap(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref = await SharedPreferences.getInstance();
    bool isGuest = pref.getBool(session.isContinueAsGuest) ?? false;
    if (isGuest == false) {
      route.pushNamed(context, routeName.notifications);
    } else {
      route.pushAndRemoveUntil(context);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController!.dispose();
    notifyListeners();
    super.dispose();
  }
}

class _TickerProvider extends TickerProvider {
  final HomeScreenProvider _notifier;

  _TickerProvider(this._notifier);

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'ticker');
  }
}
