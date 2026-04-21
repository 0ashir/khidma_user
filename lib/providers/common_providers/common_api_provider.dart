// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/appernce_model.dart';
import 'package:fixit_user/models/dashboard_user_model.dart';
import 'package:fixit_user/models/zone_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../models/app_setting_model.dart';
import '../../models/dashboard_user_model_2.dart';
import '../../screens/app_pages_screens/server_error_screen/server_error.dart';

class CommonApiProvider extends ChangeNotifier {
  //self api
  Future<void> selfApi(BuildContext context) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final response = await apiServices.getApi(api.self, [], isToken: true);

      if (response.isSuccess!) {
        if (response.data is Map<String, dynamic>) {
          userModel = UserModel.fromJson(response.data);

          FirebaseMessaging messaging = FirebaseMessaging.instance;
          messaging.subscribeToTopic("user_${userModel?.id}");
          messaging.subscribeToTopic("createProvider");
          messaging.subscribeToTopic("users");
          log("jhdfashjdga ${messaging.subscribeToTopic("user_${userModel?.id}")}");

          log("ajksfhajksfhasfjkahsfas fa      ----   user_${userModel?.id}");
          log("usermodel::${response.data}");
          try {
            final jsonString = json.encode(userModel!.toJson());
            await pref.setString(session.user, jsonString);
          } catch (e) {
            final tempMap = userModel!.toJson();
            for (var key in tempMap.keys) {
              try {
                json.encode({key: tempMap[key]});
              } catch (_) {}
            }
            throw Exception("Failed to encode UserModel: $e");
          }

          notifyListeners();
        } else {
          log("selfApi: API request failed with success: false");
          Fluttertoast.showToast(
              msg: response.message, backgroundColor: Colors.red);
          // await Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const ServerErrorScreen()),
          // );
          log("selfApi: Invalid response format: ${response.data.runtimeType}");
          throw Exception("Invalid API response format");
        }
      } else {
        log("selfApi: API request failed with success: false");

        // if (context.mounted) {
        //   await Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const ServerErrorScreen()),
        //   );
        // }
      }
    } catch (e, stackTrace) {
      log("selfApi: Error: $e", error: e, stackTrace: stackTrace);
      // if (context.mounted) {
      //   await Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const ServerErrorScreen()),
      //   );
      // }
      notifyListeners();
    }
  }

  Future<bool> checkForAuthenticate() async {
    bool isAuth = false;
    try {
      await apiServices.getApi(api.address, [], isToken: true).then((value) {
        log("sdhfjsdkhf :");
        if (value.isSuccess!) {
          isAuth = true;
          notifyListeners();
          return isAuth;
        } else {
          if (value.message.toLowerCase() == "unauthenticated.") {
            isAuth = false;
            notifyListeners();
            return isAuth;
          } else {
            isAuth = false;
            notifyListeners();
            return isAuth;
          }
        }
      });
    } catch (e) {
      log("EEE homeStatisticApi :$e");
      return isAuth;
    }
    log("isAuth:$isAuth");
    return isAuth;
  }

  getPaymentMethodList(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String apiUrl;
    if (pref.getString(session.zoneIds) == true) {
      apiUrl =
          "${api.paymentMethod}?zone_ids=${pref.getString(session.zoneIds)}";
    } else {
      apiUrl = api.paymentMethod;
    }
    try {
      await apiServices
          .getApi(apiUrl /* api.paymentMethod */, []).then((value) {
        if (value.isSuccess!) {
          paymentMethods = [];
          log("value.isSuccess:::${value.data}");
          for (var d in value.data) {
            paymentMethods.add(PaymentMethods.fromJson(d));
          }

          notifyListeners();
        }

        notifyListeners();
      });
    } catch (e, s) {
      log("EEEE getPaymentMethodList:$e ---- $s");
      notifyListeners();
    }
  }

  Future<void> getZoneList() async {
    zoneList = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      await apiServices.getApi(api.zone, []).then((value) {
        if (value.isSuccess!) {
          for (var data in value.data) {
            if (!zoneList.contains(Datum.fromJson(data))) {
              zoneList.add(Datum.fromJson(data));
            }

            notifyListeners();
          }
          notifyListeners();
        }
      });
    } catch (e, s) {
      log("ERRROEEE getZoneList $e ====> $s");
      notifyListeners();
    }
  }

  bool isLoading = false;

  getCategoryById(context, id) async {
    // print("object=================");
    isLoading = true;
    notifyListeners();
    CategoryModel? categoryModel;
    try {
      await apiServices
          .getApi("${api.category}/$id", [], isData: true, isMessage: false)
          .then((value) {
        log("CCCCC :${value.data}");
        if (value.isSuccess!) {
          categoryModel = CategoryModel.fromJson(value.data[0]);

          isLoading = false;
          notifyListeners();
          route.pushNamed(context, routeName.categoriesDetailsScreen,
              arg: categoryModel);
        }
      });
    } catch (e) {
      isLoading = false;
      log("ERRROEEE getCategoryById : $e");
      notifyListeners();
    }
  }

  /* //all category list
  getAllCategory({search}) async {
    // notifyListeners();
    try {
      await apiServices.getApi(api.categoryList, []).then((value) {
        if (value.isSuccess!) {
          allCategoryList = [];
          List category = value.data;
          for (var data in category.reversed.toList()) {
            if (!allCategoryList.contains(CategoryModel.fromJson(data))) {
              allCategoryList.add(CategoryModel.fromJson(data));
            }
            notifyListeners();
          }
        }
      });
    } catch (e) {
      log("EEEE AllCategory:::$e");
      notifyListeners();
    }
  }*/

  final dioo = Dio();
  DashboardModel? dashboardModel;
  DashboardModel2? dashboardModel2;
  CategoryModel? categoryModel;
  bool isLoadingDashboard = false;
  List<String> mediaUrls = [];
  List<String> videoUrls = [];

  // BlogModel? blogModel;
  // String local = appSettingModel!.general!.defaultLanguage!.locale!;
  Future getDashboardHome(BuildContext context) async {
    log("message=-=-=-=-=-=-LLLL::$zoneIds");
    isLoadingDashboard = true;
    notifyListeners();

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      String? lang = pref.getString("selectedLocale");
      // log("message=-=-=-=-=-=-LLLL::$zoneIds");
      // log("message=-=-=-=-=-=-LLLL::'${api.dashboardHome}?zone_ids=${pref.getString(session.zoneIds)}");
      final String? savedZoneIds = pref.getString(session.zoneIds);
      final String effectiveZoneIds = (savedZoneIds != null && savedZoneIds.isNotEmpty)
          ? savedZoneIds
          : zoneIds;
      final String dashboardUrl = '${api.dashboardHome}?zone_ids=${effectiveZoneIds.isNotEmpty ? effectiveZoneIds : '7'}';
      final response = await dioo.get(
        dashboardUrl,
        options: Options(headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Lang': lang,
          'Authorization': 'Bearer $token', // Uncomment if token is required
        }),
      );

      log("URL Name For Call: ${response.realUri}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("message=-=-=-=-=-=-LLLL::${response.data}");
        // Parse the response into DashboardModel
        dashboardModel = DashboardModel.fromJson(response.data);

        // Populate homeCategoryList (assuming CategoryModel is Category or compatible)
        homeCategoryList = dashboardModel!.categories?.map((category) {
              // If CategoryModel is different, ensure it has a fromJson method
              return CategoryModel.fromJson(category.toJson());
            }).toList() ??
            [];
        //log("message=-=-=-=-=-=-LLLL::${homeCategoryList}");

        // Populate homeServicePackagesList (assuming ServicePackageModel is ServicePackage or compatible)
        homeServicePackagesList =
            dashboardModel!.servicePackages?.map((package) {
                  return ServicePackageModel.fromJson(package.toJson());
                }).toList() ??
                [];
        // Populate homeFeaturedService (assuming FeaturedServices is FeaturedService or compatible)
        homeFeaturedService =
            dashboardModel!.featuredServices?.reversed.map((service) {
                  return Services.fromJson(service.toJson());
                }).toList() ??
                [];

        // log("Dashboard data loaded: ${dashboardModel!.featuredServices}");
        notifyListeners();
        isLoadingDashboard = false;
      } else if (response.statusCode == 500) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServerErrorScreen()),
        );

        isLoadingDashboard = false;
        notifyListeners();
        log("Failed to fetch dashboard: ${response.statusMessage}");
      } else {
        isLoadingDashboard = false;

        notifyListeners();
        log("Failed to fetch dashboard: ${response.statusMessage}");
      }
    } catch (e, s) {
      isLoadingDashboard = false;
      notifyListeners();
      log("Error fetching dashboard: $e\nStack: $s");
    }
  }

  Future getDashboardHome2(BuildContext context) async {
    isLoadingDashboard = true;
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      String? lang = pref.getString("selectedLocale");
      final String? savedZoneIds2 = pref.getString(session.zoneIds);
      final String effectiveZoneIds2 = (savedZoneIds2 != null && savedZoneIds2.isNotEmpty)
          ? savedZoneIds2
          : zoneIds;
      final String dashboardUrl2 = '${api.dashboardHome1}?zone_ids=${effectiveZoneIds2.isNotEmpty ? effectiveZoneIds2 : '7'}';
      final response = await dioo.get(
        dashboardUrl2,
        options: Options(headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          "Accept-Lang": lang,
          'Authorization': 'Bearer $token', // Uncomment if token is required
        }),
      );
      log("URL Name For Call: ${response.realUri}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("zone id message api response is ------>, $response");
        isLoadingDashboard = false;
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is Map<String, dynamic>) {
          dashboardModel2 = DashboardModel2.fromJson(response.data['data']);

          notifyListeners();
        } else {
          isLoadingDashboard = false;
          //  log("Unexpected data format: ${response.data}");
          dashboardModel2 = DashboardModel2.fromJson(response.data);
          // categoryModel = CategoryModel.fromJson(response.data['categories']);

          var data = response.data['home_banner_advertisements'];

          mediaUrls = [];
          for (var ad in data) {
            for (var media in ad['media']) {
              mediaUrls.add(media['original_url']);
            }
          }

          videoUrls = [];
          for (var ad in data) {
            if (ad['video_link'] != null && ad['video_link'] != "") {
              videoUrls.add(ad['video_link']);
            }
          }
          // log("data::${data}");
          homeProvider.clear();

          homeProvider =
              dashboardModel2!.highestRatedProviders!.reversed.map((package) {
            return ProviderModel.fromJson(package.toJson());
          }).toList();
          /*  List provider = response.data['highestRatedProviders'];
          for (var data in provider.toList()) {
            if (homeProvider.contains(ProviderModel.fromJson(data))) {
              homeProvider.add(ProviderModel.fromJson(data));
            }

            notifyListeners();
          } */
          // log("message===========${homeProvider.first.id}");

          notifyListeners();
          print(
              'Full Response: dashboardModel2==> ${dashboardModel2!.highestRatedProviders}}');
          print(
            'Full Response: dashboardModel2 ==> 1234'
            '${dashboardModel2!.highestRatedProviders?.map((e) => e.toJson()).toList()}',
          );
        }
      } else {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const ServerErrorScreen()),
        );
        isLoadingDashboard = false;
        notifyListeners();
        log("Failed to fetch service details: ${response.statusMessage}");
      }
    } catch (e, s) {
      isLoadingDashboard = false;
      notifyListeners();
      log("Error fetching dashboard home: $e ======> $s");
    }
  }

  // AppearanceModel? appearance;
  bool isColorLoading = true;

  Future<void> fetchAppearanceData() async {
    try {
      final response = await Dio().get(
        api.appearance,
      );
      log("URL Name For Call: ${response.realUri}");
      appearance = AppearanceModel.fromJson(response.data);
      log("message=-=-=-=-$appearance");
      isColorLoading = false;
      notifyListeners();
    } catch (e, s) {
      print('Error fetching appearance: $e=====$s');
      isColorLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchOnboardingScreens() async {
  //   try {
  //     var response = await Dio().get(
  //       api.onboardingScreens,
  //     );
  //     if (response.statusCode == 200) {
  //       onboardingScreens = (response.data as Map<String, dynamic>)
  //           .values
  //           .map((e) => OnboardingModel.fromJson(e))
  //           .toList();
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print('Error fetching onboarding screens: $e');
  //   }
  // }

  List<YoutubePlayerController> videoControllers = [];

  initializeVideoControllers(List<String> videoUrls) {
    videoControllers = videoUrls.map((url) {
      return YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url) ?? '',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }).toList();
    notifyListeners();

    // Defer notifyListeners to after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void disposeControllers() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    videoControllers.clear();
  }
}

class MediaItem {
  final String url;
  final bool isVideo;

  MediaItem({required this.url, required this.isVideo});
}
