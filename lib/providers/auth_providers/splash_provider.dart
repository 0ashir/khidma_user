import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixit_user/models/app_setting_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config.dart';
import '../../helper/notification.dart';

class SplashProvider extends ChangeNotifier {
  double size = 10;
  double roundSize = 10;
  double roundSizeWidth = 10;
  AnimationController? controller;
  Animation<double>? animation;
  AnimationController? controller2;
  Animation<double>? animation2;
  AnimationController? controller3;
  Animation<double>? animation3;
  AnimationController? controllerSlide;
  Animation<Offset>? offsetAnimation;
  AnimationController? popUpAnimationController;

  Future<void> onReady(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    final isAvailable = await isNetworkConnection();
    // getAppSettingList(context);
    getAppSettingList(context);
    if (!isAvailable) {
      onDispose();
      route.pushReplacementNamed(context, routeName.noInternet);
      return;
    }

    /* LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permanent denial
        log("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log("Location permissions are permanently denied");
      return;
    } */

    final loc = Provider.of<LocationProvider>(context, listen: false);
    loc.getZoneId(context);
    final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
    final login = Provider.of<LoginProvider>(context, listen: false);
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    final language = Provider.of<LanguageProvider>(context, listen: false);
    language.getLanguage();
    final bool isIntro = preferences.getBool(session.isIntro) ?? false;
    final String? userData = preferences.getString(session.user);
    CustomNotificationController().initNotification(context);

    bool isAuthenticate = false;
    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);
    locationCtrl.getCountryState();
    if (userData != null) {
      isAuthenticate = await commonApi.checkForAuthenticate();
      await preferences.remove(session.isContinueAsGuest);
    }
    String? token = preferences.getString(session.accessToken);
    log("token token: $token");
    // Handle routing logic based on intro flag and user authentication
    if (isIntro) {
      if (token == null) {
        log("ajkshdjkasdhasd $token");
        /*  final loc = Provider.of<LocationProvider>(context, listen: false); */
        loc.getZoneId(context, isLocation: false);
        preferences.setBool(session.isContinueAsGuest, true);
        log("ajkfhadkjfndjkfbdsfjnbds s ${preferences.getBool(session.isContinueAsGuest)}");
      }

      log("isIntro::$isIntro");
      loadDashboardApis(context);
      if (userData != null && isAuthenticate && token != null) {
        log("ISisAuthenticate $token");
        preferences.setBool(session.isContinueAsGuest, false);
        commonApi.selfApi(context);
        // await loadDashboardApis(context);
        // dash.getBookingHistory(context);
        final isMaintenance =
            appSettingModel?.maintenance?.maintenanceMode == '1';
        final targetRoute =
            isMaintenance ? routeName.maintenance : routeName.dashboard;
        route.pushReplacementNamed(context, targetRoute);
      } else {
        preferences.setBool(session.isContinueAsGuest, true);
        loadDashboardApis(context);
        _handleLogout(preferences);
        login.continueAsGuestTap(context);
      }
    } else {
      loadDashboardApis(context);
      getAppSettingList(context).then((value) {
        route.pushReplacementNamed(context, routeName.onBoarding);
      });
    }
  }

  /// Helper to clear session data and sign out
  Future<void> _handleLogout(SharedPreferences pref) async {
    userModel = null;
    setPrimaryAddress = null;
    userPrimaryAddress = null;

    final dash = Provider.of<DashboardProvider>(navigatorKey.currentContext!,
        listen: false);
    dash.selectIndex = 0;
    dash.notifyListeners();

    await pref.remove(session.user);
    await pref.remove(session.accessToken);
    // await pref.remove(session.isContinueAsGuest);
    await pref.remove(session.isLogin);
    await pref.remove(session.cart);
    await pref.remove(session.recentSearch);

    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.disconnect();
    }
  }

  /*onReady(BuildContext context) async {

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(session.isContinueAsGuest) ?? false;
    final isIntro = prefs.getBool(session.isIntro) ?? false;
    final isAvailable = await isNetworkConnection();

    if (!isAvailable) {
      onDispose();
      route.pushReplacementNamed(context, routeName.noInternet);
      return;
    }

    if (!isIntro) {
      loadDashboardApis(context);
      getAppSettingList(context).then((value) {
        route.pushReplacementNamed(context, routeName.onBoarding);
      });
      return;
    }

    if (isGuest) {
      log("isGuest1111 $isGuest");
      loadDashboardApis(context);
      Future.delayed(const Duration(milliseconds: 150)).then((value) {
        prefs.setBool(session.isContinueAsGuest, true);
        route.pushReplacementNamed(context, routeName.dashboard);
      });
      // route.pushReplacementNamed(context, routeName.dashboard);
    } else {
      final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
      final isAuth = await commonApi.checkForAuthenticate();

      if (isAuth) {
        loadDashboardApis(context);
        route.pushReplacementNamed(context, routeName.dashboard);
      } else {
        await clearSessionPrefs(context, prefs);
        final login = Provider.of<LoginProvider>(context, listen: false);
        login.continueAsGuestTap(context);
      }
    }
  }
*/

  loadDashboardApis(BuildContext context) async {
    final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
    final loc = Provider.of<LocationProvider>(context, listen: false);

    // Future.wait([
    await getAppSettingList(context);
    // loc.getZoneId();
    await commonApi.getDashboardHome(context);
    await commonApi.getDashboardHome2(context);
    // await loc.getCountryState();
    await loc.getUserCurrentLocation(context);
    // loc.getLocationList(context),
    // ]);
  }

  Future<void> clearSessionPrefs(context, SharedPreferences prefs) async {
    await prefs.remove(session.user);
    await prefs.remove(session.accessToken);
    await prefs.remove(session.isContinueAsGuest);
    await prefs.remove(session.isLogin);
    await prefs.remove(session.cart);
    await prefs.remove(session.recentSearch);
    userModel = null;
    setPrimaryAddress = null;
    userPrimaryAddress = null;

    final dash = Provider.of<DashboardProvider>(context, listen: false);
    dash.selectIndex = 0;
    notifyListeners();
  }

  /*onReady(context) async {
    bool isAvailable = await isNetworkConnection();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);

    isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
    final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
    final dashCtrl = Provider.of<DashboardProvider>(context, listen: false);
    bool? isIntro = preferences.getBool(session.isIntro) ?? false;
    bool isAuthenticate = false;
    if (isAvailable) {
      locationCtrl.getZoneId();
      commonApi.getZoneList();
      getAppSettingList(context);
      dashCtrl.getCurrency();
      locationCtrl.getCountryState();
      locationCtrl.getUserCurrentLocation(context);
      locationCtrl.getLocationList(context);

      // dashCtrl.getBookingHistory(context);
      // dashCtrl.getJobRequest();
      if (isIntro) {

        if (isGuest == true) {
          log("guest $isGuest");
          Future.wait([
            commonApi.getDashboardHome(context),
            commonApi.getDashboardHome2(context)
          ]);
        } else {
          log("else eeeeeeee ");
          isAuthenticate = await commonApi.checkForAuthenticate();
          commonApi.selfApi(context);
          commonApi.getDashboardHome(context);
          commonApi.getDashboardHome2(context);
        }

      }
    }

    if (isAvailable) {
      // getPaymentMethodList(context);
      // final appDetails =
      //     Provider.of<AppDetailsProvider>(context, listen: false);
      // appDetails.getAppPages();
      // getAllCategory();

      // SharedPreferences pref = await SharedPreferences.getInstance();
      dynamic userData = preferences.getString(session.user);
      // final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
      //
      // if (userData != null) {
      //
      // }

      // dashCtrl.getCurrency();
      // dashCtrl.getOffer();
      // dashCtrl.getCoupons();
      // dashCtrl.getFeaturedPackage(1);
      // dashCtrl.getHighestRate();

      // if (userData != null) {
      //   log("userData::;");
      //
      //
      //   // final cartCtrl = Provider.of<CartProvider>(context, listen: false);
      //
      //   // cartCtrl.onReady(context);
      //
      //   // await Future.wait([
      //
      //   // ]);
      // }

      */
  /* Provider.of<SplashProvider>(context, listen: false).dispose();
        onDispose(); */
  /*

      // dashCtrl.getCategory();
      // dashCtrl.getServicePackage();

      // bool? isIntro = preferences.getBool(session.isIntro) ?? false;
      if (isIntro) {
        if (userData != null) {
          if (isAuthenticate) {
            if (appSettingModel?.maintenance?.maintenanceMode == '1') {
              route.pushReplacementNamed(context, routeName.maintenance);
            }
            route.pushReplacementNamed(context, routeName.dashboard);
          } else {
            userModel = null;
            setPrimaryAddress = null;
            userPrimaryAddress = null;
            final dash = Provider.of<DashboardProvider>(context, listen: false);
            dash.selectIndex = 0;
            dash.notifyListeners();
            preferences.remove(session.user);
            preferences.remove(session.accessToken);
            preferences.remove(session.isContinueAsGuest);
            preferences.remove(session.isLogin);
            preferences.remove(session.cart);
            preferences.remove(session.recentSearch);

            final auth = FirebaseAuth.instance.currentUser;
            if (auth != null) {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn.instance.disconnect();
            }
            final login = Provider.of<LoginProvider>(context, listen: false);
            login.continueAsGuestTap(context);
          }
        } else {
          final login = Provider.of<LoginProvider>(context, listen: false);
          login.continueAsGuestTap(context);
          // preferences.remove(session.isContinueAsGuest);
        }
      } else {
        Future.delayed(Duration(seconds: 2));
        route.pushReplacementNamed(context, routeName.onBoarding);
      }
      // }
    } else {
      onDispose();
      route.pushReplacementNamed(context, routeName.noInternet);
    }
  }*/

//setting list
  bool isLoading = true;

  Future<void> getAppSettingList(BuildContext context) async {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    try {
      isLoading = true;
      notifyListeners();

      final value = await apiServices.getApi(api.settings, [], isData: true);
      if (value.isSuccess!) {
        appSettingModel = AppSettingModel.fromJson(value.data['values']);
        onboardingScreens = appSettingModel?.onboarding ?? [];
        log("appSettingModel!.general!.defaultLanguage:${appSettingModel!.general!.defaultLanguage!.locale}");
        onUpdate(currencyProvider, appSettingModel!.general!.defaultCurrency!);
        onUpdateLanguage(context, appSettingModel!.general!.defaultLanguage!);

        if (appSettingModel!.maintenance?.maintenanceMode == '1' &&
            context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              route.pushReplacementNamed(context, routeName.maintenance);
            }
          });
        }

        isLoading = false;
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: value.message);
      }
    } catch (e, s) {
      log("EEEE getAppSettingList $e === $s");
      apiServices.dioException(e);
      isLoading = false;
      notifyListeners();
    }
  }

  //all category list
  getAllCategory({search}) async {
    safeNotifyListeners();
    try {
      final response = await apiServices.getApi(api.categoryList, []);
      if (response.isSuccess! && response.data != null) {
        allCategoryList = []; // Clear the existing list
        List category = response.data;

        for (var data in category.reversed) {
          try {
            final categoryItem = CategoryModel.fromJson(data);
            if (!allCategoryList.contains(categoryItem)) {
              allCategoryList.add(categoryItem);
            }
          } catch (e) {
            log("Error parsing category data: $e");
          }
        }
        // Notify listeners once after updating the list
        safeNotifyListeners();
      } else {
        log("API response data is null or unsuccessful.");
      }
    } catch (e) {
      log("Error in getAllCategory: $e");
      safeNotifyListeners();
    }
  }

  bool _isDisposed = false;

  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  //setting list
  getPaymentMethodList(context) async {
    String apiUrl;
    if (zoneIds.isNotEmpty) {
      apiUrl = "${api.paymentMethod}?zone_ids=$zoneIds";
    } else {
      apiUrl = api.paymentMethod;
    }
    try {
      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          for (var d in value.data) {
            paymentMethods.add(PaymentMethods.fromJson(d));
          }
          notifyListeners();
        }

        notifyListeners();
      });
    } catch (e, s) {
      log("EEEE getPaymentMethodList:$e ==> $s");
      notifyListeners();
    }
  }

  Future<void> onUpdate(
      CurrencyProvider currencyData, CurrencyModel data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    double? currencyVal = pref.getDouble(session.currencyVal);
    if (currencyVal != null) {
      final prefCurrency = pref.getString(session.currency);
      currencyData.currencyVal = currencyVal;
      currencyData.currency = CurrencyModel.fromJson(jsonDecode(prefCurrency!));
      currencyData.priceSymbol = pref.getString(session.priceSymbol)!;
      currencyData.notifyListeners();
    } else {
      currencyData.priceSymbol = data.symbol.toString();
      currencyData.currency = data;
      currencyData.currencyVal = data.exchangeRate!;
      currencyData.notifyListeners();
    }

    await pref.setString(session.priceSymbol, currencyData.priceSymbol);
    Map<String, dynamic> cc = await currencyData.currency!.toJson();
    await pref.setString(session.currency, jsonEncode(cc));
    await pref.setDouble(session.currencyVal, currencyData.currencyVal);
  }

  onDispose() async {
    bool isAvailable = await isNetworkConnection();
    if (!isAvailable) {
      popUpAnimationController!.dispose();
      controller2!.dispose();
      controller3!.dispose();
      animation3!.isDismissed;
      controller!.dispose();
      controllerSlide!.dispose();
      popUpAnimationController!.dispose();
    }
  }

  onChangeSize() {
    size = size == 10 ? 115 : 115;
    notifyListeners();
  }

  // onUpdateLanguage(context, DefaultLanguage data) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   final language = Provider.of<LanguageProvider>(context, listen: false);
  //   var selectedLocale = sharedPreferences.getString("selectedLocale");
  //   log("messagedatadatadavdsfsdta::${data.locale}");
  //   log("messagedatadatadavdsfsdta::12${selectedLocale}");
  //
  //   if (pref.getString("selectedLocale") == null) {
  //     await pref.setString('selectedLocale', data.locale!);
  //     language.getLocal();
  //     if (selectedLocale == null) {
  //       language.getLanguageTranslate(context, languageCode: data.locale);
  //     } else {
  //       language.getLanguageTranslate(context,
  //           languageCode: selectedLocale.toString());
  //     }
  //   } else {
  //     log("messagedatadatadavdsfsdta::${data.locale}");
  //     language.getLocal();
  //     if (selectedLocale == null) {
  //       language.getLanguageTranslate(context, languageCode: data.locale);
  //     } else {
  //       language.getLanguageTranslate(context,
  //           languageCode: selectedLocale.toString());
  //     }
  //   }
  // }

  onUpdateLanguage(context, DefaultLanguage data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    log("message-=-=-=-=-=-=-=${data.locale}");
    if (pref.getString("selectedLocale") == null) {
      await pref.setString('selectedLocale', data.locale!);
      final language = Provider.of<LanguageProvider>(context, listen: false);
      language.getLanguageTranslate(context,
          isSelectLanguage: false, languageCode: data.locale);
      log("messagedatadatadata::${data.locale}");
    } else {
      log("messagedatadatadavdsfsdta::${data.locale}");
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // TODO: implement dispose
    onDispose();
    controller2!.dispose();
    controller3!.dispose();
    animation3!.isDismissed;
    controller!.dispose();
    controllerSlide!.dispose();
    popUpAnimationController!.dispose();
    super.dispose();
  }
}
