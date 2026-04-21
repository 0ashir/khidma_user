// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fixit_user/common_tap.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config.dart';

class DashboardProvider with ChangeNotifier {
  List<BannerModel> bannerList = [];
  List<OfferModel> offerList = [];
  List<ProviderModel> highestRateList = [];
  List<CurrencyModel> currencyList = [];
  List<CouponModel> couponList = [];
  List<CategoryModel> categoryList = [];
  List<ServicePackageModel> servicePackagesList = [];
  List<ServicePackageModel> firstThreeServiceList = [];
  List<Services> featuredServiceList = [];
  static const pageSize = 1;
  SharedPreferences? pref;

  // List dashboardList = [];

  List<Services> firstTwoFeaturedServiceList = [];
  List<ProviderModel> firstTwoHighRateList = [];
  List<BlogModel> blogList = [];
  List<BlogModel> BlogDetailsList = [];
  List<ProviderModel> providerList = [];
  List<BookingStatusModel> bookingStatusList = [];
  List<JobRequestModel> jobRequestList = [];
  bool expanded = false;
  int selectIndex = 0, backCounter = 0;
  int? topSelected;
  bool isTap = false, isSearchData = false;

  void initDashboardData(BuildContext context) async {
    final value = Provider.of<DashboardProvider>(context, listen: false);

    // Provider.of<SearchProvider>(context, listen: false).getCategory();
    Provider.of<CartProvider>(context, listen: false).onReady(context);
    // final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
    /*  value.getServicePackage(); */
    /* value.getCoupons(); */
    /* value.getHighestRate(); */
    /* value.getFeaturedPackage(1); */
    value.getOffer();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    log("preferences.getBool(session.isContinueAsGuest) == false::${preferences.getBool(session.isContinueAsGuest) == false}");
    if (preferences.getBool(session.isContinueAsGuest) == false) {
      await getJobRequest();
      getBookingHistory(context);
      // Provider.of<CategoriesDetailsProvider>(context, listen: false)
      //     .fetchBannerAdsData(context);
      // commonApi.selfApi(context);
    }

    var locationCtrl = Provider.of<LocationProvider>(context, listen: false);

    Permission.location.serviceStatus.isEnabled.then((isEnabled) async {
      if (isEnabled) {
        locationCtrl.getUserCurrentLocation(context);
        locationCtrl.getLocationList(context);
      } else {
        await Permission.location.request();
      }
    });

    // Call booking after everything is ready
    // bookingCtrl.onReady(context, value);
  }

  final List<Widget> pages = [
    const HomeScreen(),
    const BookingScreen(),
    const OfferScreen(),
    const ProfileScreen()
  ];

  List dashboardList(context) => [...appArray.dashboardList(context)];

  // List<DashboardList> get dashboardList => [];
  onTap(index, context) async {
    selectIndex = index;
    expanded = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    expanded = false;
    if (selectIndex != 0) {
      final homeCtrl = Provider.of<HomeScreenProvider>(context, listen: false);
      homeCtrl.animationController!.stop();
      homeCtrl.notifyListeners();
    } else {
      if (selectIndex == 3) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
        if (isGuest == false) {
          final homeCtrl =
              Provider.of<HomeScreenProvider>(context, listen: false);

          homeCtrl.animationController!.reset();
          homeCtrl.notifyListeners();
        } else {
          route.pushAndRemoveUntil(context);
        }
      } else {
        if (context.mounted) {
          final homeCtrl =
              Provider.of<HomeScreenProvider>(context, listen: false);
          homeCtrl.animationController?.reset();
          homeCtrl.notifyListeners();
        }
      }
    }
    if (selectIndex != 1) {
      final booking = Provider.of<BookingProvider>(context, listen: false);
      if (booking.animationController != null) {
        if (booking.animationController != null) {
          booking.animationController!.stop();
          booking.notifyListeners();
        }
      }
      // final data = Provider.of<DashboardProvider>(context, listen: false);
      // data.getBookingHistory(context);
      final book = Provider.of<BookingProvider>(context, listen: false);

      book.clearTap(context, isBack: false);
    } else if (selectIndex == 1) {
      /*  isGuest == true ? const LoginScreen() : const BookingScreen(); */
      final booking = Provider.of<BookingProvider>(context, listen: false);
      // booking.animationController!.reset();
      booking.notifyListeners();
    }
    notifyListeners();
  }

  //on back
  onBack(context) async {
    if (selectIndex != 0) {
      selectIndex = 0;
      notifyListeners();
      Fluttertoast.showToast(
          msg: language(context, translations!.pressBackAgain));
    } else {
      if (backCounter == 0) {
        Fluttertoast.showToast(
            msg: language(context, translations!.pressBackAgain));
        backCounter++;
        notifyListeners();
      } else {
        backCounter = 0;
        notifyListeners();
        SystemNavigator.pop();
      }
    }
  }

  onRefresh(context) async {
    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);
    final splashCtrl = Provider.of<SplashProvider>(context, listen: false);
    final categori =
        Provider.of<CategoriesDetailsProvider>(context, listen: false);

    final common = Provider.of<CommonApiProvider>(context, listen: false);
    // await locationCtrl.getZoneId();

    await splashCtrl.getAppSettingList(context);
    common.getDashboardHome(context);
    common.getDashboardHome2(context);
    await getJobRequest();

    /*   getOffer(); */

    categori.getCategoryService();
    categori.getService();
    // getCategory();
    /* getServicePackage(); */
    getProvider();

    getFeaturedPackage(1);
    getHighestRate();
    getBlog();
  }

  //banner list
  bool isBannerLoader = false;

  Future getBanner() async {
    isBannerLoader = true;
    try {
      //log("zoneIds :$zoneIds");
      String apiUrl = "${api.banner}?zone_ids=$zoneIds";
      if (zoneIds.isNotEmpty) {
        apiUrl = "${api.banner}?zone_ids=$zoneIds";
      } else {
        apiUrl = api.banner;
      }

      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          isBannerLoader = false;
          bannerList = [];
          for (var data in value.data) {
            bannerList.add(BannerModel.fromJson(data));
            notifyListeners();
          }
        }
        log("BANNER : ${bannerList.length}");
      });
    } catch (e) {
      isBannerLoader = false;
      log("EEEE getBanner : $e");
      notifyListeners();
    }
  }

  bool isLoading = false;

  //offer list
  Future<void> getOffer() async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.banner}?banner_type=true", []).then((value) {
        offerList = [];
        if (value.isSuccess!) {
          isLoading = false;
          notifyListeners();
          for (var data in value.data) {
            offerList.add(OfferModel.fromJson(data));
            notifyListeners();
          }
        } else {}
        notifyListeners();
      });
    } catch (e) {
      isLoading = false;
      log("EEEE getOffer : $e");
      notifyListeners();
    }
  }

  //highest rate provider list
  bool isHidhestRate = false;

  Future<void> getHighestRate() async {
    isHidhestRate = true;
    try {
      await apiServices
          .getApi(api.highestRating, [], isData: true, isMessage: true)
          .then((value) {
        if (value.isSuccess!) {
          isHidhestRate = false;
          highestRateList = [];
          firstTwoHighRateList = [];
          // debugPrint("HIGHH :${value.data}");
          for (var data in value.data['data']) {
            highestRateList.add(ProviderModel.fromJson(data));
            //debugPrint("highestRateList :$data");
            notifyListeners();
          }

          if (highestRateList.length >= 3) {
            firstTwoHighRateList = highestRateList.getRange(0, 3).toList();
          }

          // debugPrint("firstTwoHighRateList :${firstTwoHighRateList.length}");
          notifyListeners();
        }
      });
    } catch (e, s) {
      isHidhestRate = false;
      debugPrint("getHighestRate ::$e==> $s");
      notifyListeners();
    }
  }

//currency list
  Future getCurrency() async {
    try {
      await apiServices.getApi(api.currency, []).then((value) {
        if (value.isSuccess!) {
          currencyList = [];
          debugPrint("fbhgfvhg:${value.data}");
          for (var data in value.data) {
            currencyList.add(CurrencyModel.fromJson(data));
            notifyListeners();
          }
        }
      });
    } catch (e) {
      debugPrint("getCurrency ::$e}");

      notifyListeners();
    }
  }

//coupons list
  bool isCoupons = false;

  getCoupons() async {
    isCoupons = true;
    log("CHHHH======> COUPON CALLING");
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      await apiServices.getApi(
          "${api.coupon}?zone_ids=${pref.getString(session.zoneIds)}",
          []).then((value) {
        if (value.isSuccess!) {
          isCoupons = false;
          couponList = [];
          if (value.data != null) {
            //  log("COUPN :${value.data}");
            for (var data in value.data) {
              couponList.add(CouponModel.fromJson(data));
              notifyListeners();
            }
          }
        }
        notifyListeners();
      });
    } catch (e) {
      isCoupons = false;
      debugPrint("EEEE getCoupons: $e");
      notifyListeners();
    }
  }

  //category list

  bool isCategory = false;

  getCategory({search}) async {
    isCategory = true;
    // notifyListeners();
    debugPrint("zoneIds zoneIds:$zoneIds");
    try {
      String apiUrl = "${api.category}?zone_ids=$zoneIds";
      if (zoneIds.isNotEmpty) {
        if (search != null) {
          apiUrl = "${api.category}?search=$search&zone_ids=$zoneIds";
        } else {
          apiUrl = "${api.category}?zone_ids=$zoneIds";
        }
      } else {
        if (search != null) {
          apiUrl = "${api.category}?search=$search";
        } else {
          apiUrl = api.category;
        }
      }

      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          isCategory = false;
          List category = value.data;
          categoryList = [];
          for (var data in category.reversed.toList()) {
            CategoryModel categoryModel = CategoryModel.fromJson(data);
            /*   log("categoryModel :#${categoryModel.hasSubCategories!.length}"); */
            if (!categoryList.contains(categoryModel)) {
              categoryList.add(CategoryModel.fromJson(data));
            }
            notifyListeners();
          }
        }
      });
    } catch (e, s) {
      isCategory = false;
      notifyListeners();
      log("EEEE getCategory : $e=======>$s");
    }
  }

  //service package list
  bool isServiceList = false;

  Future<void> getServicePackage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    isServiceList = true;
    debugPrint("SERR :$zoneIds");
    try {
      String apiUrl = api.servicePackages;
      if (zoneIds.isNotEmpty) {
        apiUrl =
            "${api.servicePackages}?zone_ids=${pref.getString(session.zoneIds)}";
      } else {
        apiUrl = api.servicePackages;
      }
      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          isServiceList = false;
          List service = value.data;
          servicePackagesList = [];
          for (var data in service.reversed.toList()) {
            servicePackagesList.add(ServicePackageModel.fromJson(data));
            debugPrint(
                "servicePackagesList LEN: ${servicePackagesList[0].title}");
            notifyListeners();
          }
          if (servicePackagesList.length >= 3) {
            firstThreeServiceList = servicePackagesList.getRange(0, 3).toList();
          }
          notifyListeners();
        }
      });
    } catch (e) {
      isServiceList = false;
      notifyListeners();
      log("EEEE getServicePackage s: $e");
    }
  }

  //all job request list
  getJobRequest() async {
    // notifyListeners();
    log("zoneIds ss:$zoneIds");
    try {
      // String apiUrl = api.serviceRequest;
      // if (zoneIds.isNotEmpty) {
      //   apiUrl = api.serviceRequest;
      // } else {
      //   apiUrl = api.serviceRequest;
      // }
      await apiServices
          .getApi(api.serviceRequest, [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          //   log("DATA JOB::${value.data}");
          List category = value.data;
          jobRequestList = [];
          for (var data in category.reversed.toList()) {
            if (!jobRequestList.contains(JobRequestModel.fromJson(data))) {
              jobRequestList.add(JobRequestModel.fromJson(data));
            }
            notifyListeners();
          }
        } else {
          // Fluttertoast.showToast(
          //     msg: value.message, backgroundColor: Colors.red);
        }
      });
    } catch (e, s) {
      log("EEEE SERVICE JOB :::$e --- $s");
      notifyListeners();
    }
  }

  //featured package list
  bool isFeaturedServiceList = false;

  Future<void> getFeaturedPackage(page) async {
    isFeaturedServiceList = true;
    try {
      await apiServices.getApi(api.featuredServices, []).then((value) {
        if (value.isSuccess!) {
          isFeaturedServiceList = false;
          featuredServiceList = [];
          firstTwoFeaturedServiceList = [];
          List service = value.data;
          for (var data in service.reversed.toList()) {
            if (!featuredServiceList.contains(Services.fromJson(data))) {
              featuredServiceList.add(Services.fromJson(data));
            }
            notifyListeners();
          }
          if (featuredServiceList.length >= 2) {
            firstTwoFeaturedServiceList =
                featuredServiceList.getRange(0, 2).toList();
          }
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
        // log("FA :${featuredServiceList.length}");
      });
    } catch (e, s) {
      isFeaturedServiceList = false;
      notifyListeners();
      log("EEEE getFeaturedPackage : $e ----- $s");
    }
  }

  //blog list
  bool isBlogList = false;

/*
final dio = Dio();
  getBlogDetails({dynamic id}) async {
    isBlogList = true;
    log("id::$id");
    try {
      var response =await dio.get("${api.blog}/$id", data: [], options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Language': 'en',
        },
      ));
      if (response.statusCode == 200 || response.statusCode == 201) {
        isBlogList = false;
        BlogDetailsList = [];
        var service = response.data;
        log("value.data::${response.data}");

        BlogDetailsList.add(BlogModel.fromJson(response.data));
          notifyListeners();
      }

    } catch (e,s) {
      isBlogList = false;
      log("EEEE getBlog : $e DATA////$s");
      notifyListeners();
    }
  }
*/

  Future getBlog({dynamic id}) async {
    isBlogList = true;
    log("id::$id");
    try {
      await apiServices.getApi(api.blog, []).then((value) {
        // log("value.isSuccess::bllloooggg${value.data}");
        if (value.isSuccess!) {
          isBlogList = false;
          blogList = [];
          List service = value.data;
          for (var data in service.reversed.toList()) {
            blogList.add(BlogModel.fromJson(data));
            notifyListeners();
          }

          notifyListeners();
        }
        debugPrint("firstTwoBlogList :$blogList");
      });
    } catch (e, s) {
      isBlogList = false;
      log("EEEE getBlog : $e////$s");
      notifyListeners();
    }
  }

  //provider list
  Future getProvider() async {
    try {
      await apiServices.getApi(api.provider, []).then((value) {
        if (value.isSuccess!) {
          List provider = value.data;
          providerList = [];
          for (var data in provider.reversed.toList()) {
            providerList.add(ProviderModel.fromJson(data));
            notifyListeners();
          }

          notifyListeners();
          debugPrint("providerList ::${providerList.length}");
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }

  //booking history list
  getBookingHistoryList() async {
    providerList = [];
    try {
      await apiServices.getApi(api.provider, []).then((value) {
        if (value.isSuccess!) {
          List provider = value.data;

          for (var data in provider.reversed.toList()) {
            providerList.add(ProviderModel.fromJson(data));
            notifyListeners();
          }

          notifyListeners();
          debugPrint("providerList ::${providerList.length}");
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }

  onRemoveService(BuildContext context, int index) async {
    isAlert = false;
    log("onRemoveService called for index: $index, featuredServiceList count: ${featuredServiceList[index].selectedRequiredServiceMan}, service ID: ${featuredServiceList[index].id}");
    int count = featuredServiceList[index].selectedRequiredServiceMan ?? 1;
    int minServicemen = featuredServiceList[index].requiredServicemen ?? 1;
    if (count <= minServicemen) {
      Fluttertoast.showToast(
        msg: "Minimum $minServicemen servicemen required",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      log("Minimum limit reached: $minServicemen, popping screen");
    } else {
      count--;
      featuredServiceList[index].selectedRequiredServiceMan = count;
      // Sync with firstTwoFeaturedServiceList
      if (firstTwoFeaturedServiceList.isNotEmpty) {
        final serviceId = featuredServiceList[index].id;
        final subIndex =
            firstTwoFeaturedServiceList.indexWhere((s) => s.id == serviceId);
        if (subIndex != -1) {
          firstTwoFeaturedServiceList[subIndex].selectedRequiredServiceMan =
              count;
        }
      }
      log("Decremented to: $count for service ID: ${featuredServiceList[index].id}");
    }
    notifyListeners();
  }

  void onAdd(int index) {
    isAlert = false;

    final currentItem = featuredServiceList[index];
    int required = currentItem.requiredServicemen ?? 1;
    int current = currentItem.selectedRequiredServiceMan ?? required;

    // Set initial selected if not already set
    if (currentItem.selectedRequiredServiceMan == null) {
      currentItem.selectedRequiredServiceMan = required;
      current = required;
    }

    current++; // Increment by 1
    currentItem.selectedRequiredServiceMan = current;

    // Sync with firstTwoFeaturedServiceList if needed
    if (firstTwoFeaturedServiceList.isNotEmpty) {
      final serviceId = currentItem.id;
      final subIndex =
          firstTwoFeaturedServiceList.indexWhere((s) => s.id == serviceId);
      if (subIndex != -1) {
        firstTwoFeaturedServiceList[subIndex].selectedRequiredServiceMan =
            current;
      }
    }

    log("Service ID: ${currentItem.id}, Required: $required, Selected: $current");
    notifyListeners();
  }

  onAddTap(context, Services? service, index, inCart) {
    if (inCart) {
      route.pushNamed(context, routeName.cartScreen);
    } else {
      final providerDetail =
          Provider.of<ProviderDetailsProvider>(context, listen: false);
      providerDetail.selectProviderIndex = 0;
      providerDetail.notifyListeners();
      onBook(context, service!, provider: service.user, addTap: () {
        onAdd(index);
        notifyListeners();
      }, minusTap: () {
        onRemoveService(context, index);
        notifyListeners();
      }).then((e) {
        featuredServiceList[index].selectedRequiredServiceMan =
            featuredServiceList[index].selectedRequiredServiceMan;
        notifyListeners();
      });
    }
  }

  //booking status list
  Future getBookingStatus() async {
    try {
      await apiServices
          .getApi(api.bookingStatus, [], isToken: true)
          .then((value) {
        // debugPrint("STATYS L ${value.data}");
        if (value.isSuccess!) {
          for (var data in value.data) {
            bookingStatusList.add(BookingStatusModel.fromJson(data));
            notifyListeners();
          }
        }
      });

      notifyListeners();

      // debugPrint("STATYS Lss ${bookingStatusList.length}");
      int cancelIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "cancel" ||
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "cancelled");
      if (cancelIndex >= 0) {
        // debugPrint("CANCEl :${bookingStatusList[cancelIndex].slug}");
        translations!.cancel = bookingStatusList[cancelIndex].slug!;
      }
      int acceptedIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "accepted" ||
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "accept");
      if (acceptedIndex >= 0) {
        // debugPrint("ACCEPTEF :${bookingStatusList[acceptedIndex].slug}");
        translations!.accepted = bookingStatusList[acceptedIndex].slug!;
      }

      int assignedIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "assign" ||
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "assigned");
      if (assignedIndex >= 0) {
        // debugPrint("ASSIGNED :${bookingStatusList[assignedIndex].slug}");
        appFonts.assigned = bookingStatusList[assignedIndex].slug!;
      }

      int onTheWayIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
              .toLowerCase()
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("_", "") ==
          "ontheway");
      if (onTheWayIndex >= 0) {
        // debugPrint("ON THE WAY :${bookingStatusList[onTheWayIndex].slug}");
        appFonts.ontheway = bookingStatusList[onTheWayIndex].slug!;
      }

      int onGoingIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
              .toLowerCase()
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("_", "") ==
          "ongoing");
      if (onGoingIndex >= 0) {
        // debugPrint("ONGOING :${bookingStatusList[onGoingIndex].slug}");
        appFonts.onGoing = bookingStatusList[onGoingIndex].slug!;
      }

      int onHoldIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
              .toLowerCase()
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("_", "") ==
          "onhold");
      if (onHoldIndex >= 0) {
        // debugPrint("onHOLD :${bookingStatusList[onHoldIndex].slug}");
        appFonts.onHold = bookingStatusList[onHoldIndex].slug!;
      }

      int restartIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
              .toLowerCase()
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("_", "") ==
          "restart");
      if (restartIndex >= 0) {
        debugPrint("RESTART :${bookingStatusList[restartIndex].slug}");
        translations!.restart = bookingStatusList[restartIndex].slug!;
      }

      int startAgainIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
              .toLowerCase()
              .replaceAll("-", "")
              .replaceAll(" ", "")
              .replaceAll("_", "") ==
          "startagain");
      if (startAgainIndex >= 0) {
        debugPrint("START AGAIN :${bookingStatusList[startAgainIndex].slug}");
        appFonts.startAgain = bookingStatusList[startAgainIndex].slug!;
      }

      int completedIndex = bookingStatusList.indexWhere((element) =>
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "completed" ||
          element.slug!
                  .toLowerCase()
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .replaceAll("_", "") ==
              "complete");
      if (completedIndex >= 0) {
        debugPrint("COMPLETED:${bookingStatusList[completedIndex].slug}");
        translations!.completed = bookingStatusList[completedIndex].slug!;
      }

      notifyListeners();

      debugPrint("APPP ;${appFonts.ontheway}");
    } catch (e) {
      log("EEEE getBookingStatus: $e");
      notifyListeners();
    }
  }

  int count = 0;

  //booking history list
  bool isLoadingForBookingHistory = false;
  bool isBookingLoading = false;

  Future getBookingHistory(BuildContext context,
      {String? search, bool isLoadMore = false, String? timeFilter}) async {
    final booking = Provider.of<BookingProvider>(context, listen: false);
    // final bokkingProvider = Provider.of<BookingProvider>(context,listen: false);
    // Early return if no more data or already loading more
    if (isLoadMore && (!booking.hasMoreData || booking.isLoadingMore)) return;

    // Set loading states
    if (isLoadMore) {
      booking.setLoadingMore(true);
    } else {
      booking.resetPagination();
      isBookingLoading = true;
      isLoadingForBookingHistory = true;
    }
    notifyListeners();

    try {
      // Prepare query parameters
      Map<String, dynamic> data = {
        /*  "page": booking.currentPage.toString(),
        "paginate": "5", */
        if (search != null && search.isNotEmpty) "search": search,
      };

      // Show loading only for initial fetch
      if (!isLoadMore) showLoading(context);

      // Make API call
      final response = await apiServices.getApi(
        timeFilter != null
            ? "${api.booking}?time_filter=${timeFilter.toLowerCase()}"
            : search != null && search.isNotEmpty
                ? "${api.booking}?search=$search"
                : api.booking,
        /* "${api.booking}?paginate=5", */
        [],
        isToken: true,
      );
      log("response::$response");
      if (response.isSuccess!) {
        booking.resetPagination();
        List<BookingModel> newBookings = (response.data as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
        booking.isLoadingForBookingHistory = false;
        // Update booking list
        if (isLoadMore) {
          booking.bookingList.addAll(newBookings);
        } else {
          booking.bookingList = newBookings;
        }

        // Update pagination state
        booking.currentPage++;
        booking.hasMoreData =
            newBookings.length == 5; // Assume full page means more data exists

        // Save to local storage
        await saveBookingsToLocal(booking.bookingList);
      } else {
        booking.isLoadingForBookingHistory = false;
        // Handle unsuccessful response
        if (!isLoadMore) booking.bookingList = [];
        booking.hasMoreData = false;
        if (context.mounted) {
          Fluttertoast.showToast(
              msg: "Failed to fetch bookings", backgroundColor: Colors.red);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Failed to fetch bookings")),
          // );
        }
      }
    } catch (e, s) {
      booking.isLoadingForBookingHistory = false;
      debugPrint("Error in getBookingHistory: $e\n$s");
      if (!isLoadMore) booking.bookingList = [];
      booking.hasMoreData = false;
      if (context.mounted) {
        Fluttertoast.showToast(
            msg: "An error occurred", backgroundColor: Colors.red);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("An error occurred")),
        // );
      }
    } finally {
      isBookingLoading = false;
      isLoadingForBookingHistory = false;
      booking.setLoadingMore(false);
      booking.setInitialLoading(false);
      if (context.mounted && !isLoadMore) hideLoading(context);
      booking.widget1Opacity = 1;
      notifyListeners();
      booking.notifyListeners();
    }
  }

  /// Save bookings to SharedPreferences
  Future<void> saveBookingsToLocal(List<BookingModel> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    String bookingsJson = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await prefs.setString('booking_history', bookingsJson);
  }

  Future<void> loadBookingsFromLocal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final booking = Provider.of<BookingProvider>(context, listen: false);

    String? bookingsJson = prefs.getString('booking_history');
    if (bookingsJson != null) {
      List<dynamic> decodedList = jsonDecode(bookingsJson);
      List<BookingModel> storedBookings =
          decodedList.map((json) => BookingModel.fromJson(json)).toList();

      booking.bookingList = storedBookings;
      // log("booking.bookingList::${booking.bookingList}");
      notifyListeners();
    }
  }

/*  getBookingHistory(context, {search, pageKey = 1}) async {
    log("dfnfjdhskfbdshfbAAAA");
    isLoading = true;
    notifyListeners();
    final booking = Provider.of<BookingProvider>(context, listen: false);
    booking.widget1Opacity = 0.0;

    dynamic data;

    if (booking.selectedCategory.isNotEmpty &&
        booking.rangeStart != null &&
        booking.statusIndex != null) {
      data = {
        "status": bookingStatusList[booking.statusIndex!].slug,
        "start_date": booking.rangeStart,
        "end_date": booking.rangeEnd,
        "category_ids": booking.selectedCategory,
        "search": search
      };
    } else if (booking.selectedCategory.isNotEmpty &&
        booking.rangeStart != null) {
      data = {
        "start_date": booking.rangeStart,
        "end_date": booking.rangeEnd,
        "category_ids": booking.selectedCategory,
        "search": search
      };
    } else if (booking.selectedCategory.isNotEmpty) {
      data = {"category_ids": booking.selectedCategory};
    } else if (booking.selectedCategory.isNotEmpty &&
        booking.statusIndex != null) {
      data = {
        "status": bookingStatusList[booking.statusIndex!].slug,
        "category_ids": booking.selectedCategory,
        "search": search
      };
    } else if (booking.statusIndex != null) {
      data = {
        "status": bookingStatusList[booking.statusIndex!].slug,
        "search": search
      };
    } else if (booking.rangeStart != null && booking.statusIndex != null) {
      data = {
        "status": bookingStatusList[booking.statusIndex!].slug,
        "start_date": booking.rangeStart,
        "end_date": booking.rangeEnd,
        "search": search
      };
    } else if (booking.rangeStart != null) {
      data = {
        "start_date": booking.rangeStart.toString(),
        "end_date": booking.rangeEnd.toString(),
        // "search": search ?? ""
      };
    } else if (search != null) {
      data = {"search": search};
    }

    debugPrint("BD:: $data");
    try {
      showLoading(context);
      await apiServices
          .getApi("${api.booking}?paginate=50", data ?? [], isToken: true)
          .then((value) {
        count++;
        // debugPrint("datadata :${value.data}");
        if (value.isSuccess!) {
          isLoading = false;
          isSearchData = false;
          if(context.mounted){
          hideLoading(context);}
          booking.bookingList = [];
          for (var data in value.data) {
            if (!booking.bookingList.contains(BookingModel.fromJson(data))) {
              booking.bookingList.add(BookingModel.fromJson(data));
            }
            booking.notifyListeners();
          }
          if (booking.bookingList.isEmpty) {
            if (search != null) {
              isSearchData = true;
              // booking.searchText.text = "";
              booking.notifyListeners();
            } else {
              isSearchData = false;
            }
          } else {
            isSearchData = false;
          }
          isLoading = false;
          notifyListeners();
          booking.widget1Opacity = 1;
          booking.notifyListeners();
        } else {
          booking.bookingList = [];
          isLoading = false;
          notifyListeners();
          booking.widget1Opacity = 1;
          hideLoading(context);
          booking.notifyListeners();
        }
        if (booking.bookingList.isEmpty) {
          isLoading = false;
          notifyListeners();
          booking.widget1Opacity = 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              clearChat(context);
            }
          });
        }
      });
   if(context.mounted){
     hideLoading(context);
   }
      log("booking.bookingList :${booking.bookingList.length}");
    } catch (e, s) {
      isLoading = false;
      notifyListeners();
      booking.widget1Opacity = 1;
      hideLoading(context);
      debugPrint("EEEE getBookingHistory ::$e=====> $s");
      notifyListeners();
    }
  }*/

  clearChat(context) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.chats)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          value.docs.asMap().entries.forEach((element) {
            FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(userModel!.id.toString())
                .collection(collectionName.chatWith)
                .doc(userModel!.id.toString() ==
                        element.value['senderId'].toString()
                    ? element.value['receiverId'].toString()
                    : element.value['senderId'].toString())
                .collection(collectionName.booking)
                .doc(element.value['bookingId'].toString())
                .collection(collectionName.chat)
                .get()
                .then((v) {
              for (var d in v.docs) {
                FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(userModel!.id.toString())
                    .collection(collectionName.chatWith)
                    .doc(userModel!.id.toString() ==
                            element.value['senderId'].toString()
                        ? element.value['receiverId'].toString()
                        : element.value['senderId'].toString())
                    .collection(collectionName.booking)
                    .doc(element.value['bookingId'].toString())
                    .collection(collectionName.chat)
                    .doc(d.id)
                    .delete();
              }
            }).then((a) {
              FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .doc(userModel!.id.toString())
                  .collection(collectionName.chats)
                  .doc(value.docs[0].id)
                  .delete();
            }).then((value) {
              final chat =
                  Provider.of<ChatHistoryProvider>(context, listen: false);
              chat.onReady(context);
            });
          });
        }

        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }

  onFeatured(context, Services? services, id, {inCart}) async {
    /* if (inCart) {
      route.pushNamed(context, routeName.cartScreen);
    } else {*/
    final providerDetail =
        Provider.of<ProviderDetailsProvider>(context, listen: false);
    providerDetail.selectProviderIndex = 0;
    providerDetail.notifyListeners();
    onBook(context, services!, provider: services.user, addTap: () {
      if (id < featuredServiceList.length) {
        Provider.of<DashboardProvider>(context, listen: false).onAdd(id);
        notifyListeners();
      }
    }, minusTap: () {
      if (id < featuredServiceList.length) {
        onRemoveService(context, id);
        notifyListeners();
      }
    })!
        .then((e) {
      if (id < featuredServiceList.length) {
        featuredServiceList[id].selectedRequiredServiceMan =
            featuredServiceList[id].requiredServicemen;
        notifyListeners();
      }
    });
    // }
  }

  onBannerTap(context, id) {
    final commonApi = Provider.of<CommonApiProvider>(context, listen: false);
    commonApi.getCategoryById(context, id);
  }

  cartTap(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
    if (isGuest == false) {
      final cartCtrl = Provider.of<CartProvider>(context, listen: false);
      debugPrint("dg :");
      cartCtrl.checkout(context);
      getCoupons();
/*      cartCtrl.cartList = [];
      cartCtrl.notifyListeners();*/
      route.pushNamed(context, routeName.cartScreen);
    } else {
      route.pushNamed(context, routeName.login);
      // route.pushAndRemoveUntil(context);
      hideLoading(context);
    }
  }

  //update status
  zoneUpdate() async {
    if (position != null) {
      Position position1 = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      log("AAAA ${userModel?.locationCordinates!.latitude} || ${position1.latitude}");
      if (position1.latitude != position!.latitude) {
        try {
          dynamic data = {
            "location": {"lat": position!.latitude, "lng": position!.longitude}
          };

          await apiServices
              .putApi(api.zoneUpdate, data, isToken: true, isData: true)
              .then((value) {
            if (value.isSuccess!) {
              log("SUCCCC");
            } else {
              log("SSS :${value.data} // ${value.message}");
            }
          });
        } catch (e) {
          log("EEEE zoneUpdate :$e");

          notifyListeners();
        }
      }
    }
  }

  AnimationController? animationController;

  onAnimateOfficer(TickerProvider sync, context) {
    /* getOffer(); */
    animationController = AnimationController(
        vsync: sync, duration: const Duration(milliseconds: 1200));
    _runAnimation(context);
    notifyListeners();
  }

  void _runAnimation(BuildContext context) {
    if (animationController == null || !context.mounted) return;
    animationController!
        .repeat(reverse: true); // Automatically repeats forward and reverse
  }

  @override
  void dispose() {
    animationController?.stop(); // Stop the repeating animation
    animationController?.dispose();
    super.dispose();
  }
}
