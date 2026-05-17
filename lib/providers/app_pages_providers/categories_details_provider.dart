import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/category_advertisement_model.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:fixit_user/models/category_service_model.dart'
    as CategoryServices;
import 'package:fixit_user/screens/app_pages_screens/category_detail_screen/layouts/categories_filter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/category_service_model.dart';
import '../../widgets/alert_message_common.dart';

class CategoriesDetailsProvider with ChangeNotifier {
  TextEditingController searchCtrl = TextEditingController();
  TextEditingController filterSearchCtrl = TextEditingController();
  int selectedIndex = 0;
  double widget1Opacity = 0.0;
  Future<ui.Image>? loadingImage;
  final FocusNode searchFocus = FocusNode();
  final FocusNode filterSearchFocus = FocusNode();
  int? exValue = appArray.experienceList[0]["id"];
  String selectedExp = appArray.experienceList[0]["title"];
  List selectedRates = [];
  List<Services> serviceList = [];

  CategoryModel? categoryModel;
  bool val = true;
  double maxPrice = 100.0, minPrice = 0.0, lowerVal = 0.0, upperVal = 100.0;
  Services? services;
  List<ProviderModel> providerList = [];
  List selectedProvider = [];
  List<CategoryModel> hasCategoryList = [];
  int? subCategoryId;
  CategoryServices.CategoryServices? categoryService;
  var dio = Dio();

  List<CategoryServicesCategory> demoList = [
    CategoryServicesCategory(
        id: 0, title: 'All', isChild: false, servicesCount: 0, media: [])
  ];
  List<Service> serviceDemo = [];
  bool isLoading = false;
  bool isServiceLoading = false;
  bool isAlert = false;
  bool isProviderLoading = false;
  bool isLoader = true;
  bool isGridLoader = false;
  bool isNavigatingToCategory = false;

  void setIsNavigatingToCategory(bool val) {
    isNavigatingToCategory = val;
    notifyListeners();
  }

  Future<void> getCategoryService({int? id}) async {
    isGridLoader = true;
    notifyListeners();
    SharedPreferences pref = await SharedPreferences.getInstance();
    final savedZone = pref.getString(session.zoneIds);
    final effectiveZone = (savedZone != null && savedZone.isNotEmpty) ? savedZone : '2';

    log("message=-=-=--=-=-ZONE IDS $savedZone → using: $effectiveZone");

    try {
      demoList = [];
      isLoading = true;
      notifyListeners();
      final url = '${api.categoryService}?category_id=$id&zone_ids=$effectiveZone';
      log('Fetching category service: $url');

// Make the API call using Dio
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Accept-Language': 'en',
          },
        ),
      );
      log("URL Name For Call: ${response.realUri}");
// Check if the response is successful
      if (response.statusCode == 200) {
        log("=-=-=-=-=-=-=-=-=-=SERVICE DATA : ${response.data}");
        // Parse the response data into the CategoryServices model
        categoryService =
            CategoryServices.CategoryServices.fromJson(response.data);

        // Initialize demoList as empty

        // Filter child categories
        final validCategories = categoryService?.categories
            ?.where((category) => category.isChild == false)
            .toList();

        // Only add "All" category if there are valid subcategories
        if (validCategories != null && validCategories.isNotEmpty) {
          demoList.add(
            CategoryServicesCategory(
                id: 0,
                title: 'All',
                isChild: false,
                servicesCount: 0,
                media: [
                  CategoryServices.Media(
                    id: 1,
                    collectionName: CollectionName.IMAGE,
                    originalUrl: eImageAssets.appLogo,
                  ),
                ]),
          );
          isGridLoader = false;
          notifyListeners();
          demoList.addAll(validCategories);
          log('Filtered categories added: ${validCategories.map((c) => c.title).toList()}');
          log("First sub-category: ${demoList[1].title}");
        } else {
          isGridLoader = false;
          notifyListeners();
          isLoading = false;
          notifyListeners();
          log('No valid child categories found. Skipping "All" category.');
        }
        isGridLoader = false;
        notifyListeners();
        isLoading = false;
        log('Category service fetched successfully: ${categoryService!.categories!.map((c) => c.title).toList()}');
      } else {
        isGridLoader = false;
        notifyListeners();
        log('Failed to fetch category service: ${response.statusCode}');
        Fluttertoast.showToast(msg: response.statusMessage!);
        throw Exception(
            'Failed to fetch category service: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      isGridLoader = false;
      notifyListeners();
      isLoading = false;
      log('Error fetching category service: $e',
          error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      isGridLoader = false;
      notifyListeners();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getService({int? id, String? search}) async {
    try {
      isServiceLoading = true;
      notifyListeners();
      serviceDemo.clear();

      SharedPreferences pref = await SharedPreferences.getInstance();
      final savedZone2 = pref.getString(session.zoneIds);
      final effectiveZone2 = (savedZone2 != null && savedZone2.isNotEmpty) ? savedZone2 : '2';

      // Build the API URL with optional search
      String url = '${api.categoryService}?category_id=$id&zone_ids=$effectiveZone2';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }
      if (selectedRates.isNotEmpty) {
        url += "&rating=${selectedRates.join(',')}";
      }
      if (selectedProvider.isNotEmpty) {
        url += "&providerIds=${selectedProvider.join(',')}";
      }
      if (lowerVal != 0 || upperVal != maxPrice) {
        url += "&min=${lowerVal.round()}&max=${upperVal.round()}";
      }
      if (isSelect != null && !isSelect!) {
        url += "&distance=$slider";
      }

      log('Fetching services: $url');

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Accept-Language': 'en',
          },
        ),
      );
      log("URL Name For Call: ${response.realUri}");

      if (response.statusCode == 200) {
        serviceDemo.clear();
        isServiceLoading = false;
        categoryService =
            CategoryServices.CategoryServices.fromJson(response.data);

        if (categoryService!.services != null) {
          serviceDemo.addAll(categoryService!.services!);
          log('Services added: ${serviceDemo.length}');
          if (serviceDemo.isNotEmpty) {
            log('First service: ${serviceDemo.first.title}');
          }
        } else {
          log('No services found.');
        }

        log('Services fetched successfully: ${serviceDemo.length}');
      } else {
        isServiceLoading = false;
        log('Failed to fetch services: ${response.statusCode}');
        throw Exception('Failed to fetch services: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error fetching services: $e', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      isServiceLoading = false;
      notifyListeners();
    }
  }

  void onSubCategories(context, index, id) {
    selectedIndex = index;
    subCategoryId = id;
    notifyListeners();
    log('Selected sub-category ID: $id, Index: $index');

    if (id == 0) {
      // "All" selected — reload with the parent category
      getServiceByCategoryId(context, id: categoryModel?.id);
    } else {
      // Specific subcategory selected — fetch providers for it
      getServiceByCategoryId(context, id: id);
    }
  }

  List<Service> get filteredServices {
    // If searching, return the fetched serviceList directly
    if (searchCtrl.text.isNotEmpty) {
      return serviceDemo;
    }

    // If no subcategory filter, return all demo services
    if (selectedIndex == 0 || subCategoryId == 0) {
      return serviceDemo;
    }

    // Else, filter demo services by selected subcategory
    return serviceDemo
        .where((service) =>
            service.categories!.any((category) => category.id == subCategoryId))
        .toList();
  }

  List<ProviderModel> get categoryProviders {
    final seen = <int>{};
    return serviceList
        .where((s) => s.user != null && s.userId != null && seen.add(s.userId!))
        .map((s) => s.user!)
        .toList();
  }

  List<Services> servicesForProvider(int providerId) {
    return serviceList.where((s) => s.userId == providerId).toList();
  }

  onSwitch(value) {
    val = value;
    notifyListeners();
  }

  onExperience(val) {
    exValue = val;
    selectedExp = appArray.experienceList[val]['title'];
    notifyListeners();
    fetchProviderByFilter();
  }

  String totalCountFilter() {
    int count = 0;
    if (selectedProvider.isNotEmpty) count++;
    if (lowerVal != 0.0 || upperVal < maxPrice) count++;
    if (selectedRates.isNotEmpty) count++;
    if (slider != 0.0) count++;
    if (isSelect != null) count++;
    return count.toString();
  }

  fetchProviderByFilter() async {
    try {
      String val = selectedExp.contains("Highest Experience") ? "high" : "low";
      String val1 = selectedExp.contains("Highest Served") ? "high" : "low";
      String apiUrl = filterSearchCtrl.text.isEmpty
          ? selectedExp.contains("Highest Experience") ||
                  selectedExp.contains("Lowest Experience")
              ? "${api.provider}?experience=$val&search=${filterSearchCtrl.text}"
              : "${api.provider}?served=$val1&search=${filterSearchCtrl.text}"
          : "${api.provider}?search=${filterSearchCtrl.text}";

      log("apiUrl:$apiUrl");
      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          List provider = value.data;
          providerList = [];
          for (var data in provider) {
            if (!providerList.contains(ProviderModel.fromJson(data))) {
              providerList.add(ProviderModel.fromJson(data));
            }
          }
          log("providerList ::${providerList.length}");
          notifyListeners();
        }
      });
    } catch (e, s) {
      log("fetchProviderByFilter error: $e ==> $s");
      notifyListeners();
    }
  }

  bool isProviderFilterLoading = false;

  getProvider() async {
    isProviderFilterLoading = true;
    notifyListeners();
    try {
      await apiServices.getApi(api.provider, []).then((value) {
        if (value.isSuccess!) {
          isProviderFilterLoading = false;
          List provider = value.data;
          providerList = [];
          for (var data in provider.reversed.toList()) {
            providerList.add(ProviderModel.fromJson(data));
          }
          debugPrint("providerList ::${providerList.length}");
          notifyListeners();
        }
        isProviderFilterLoading = false;
        notifyListeners();
      });
    } catch (e) {
      isProviderFilterLoading = false;
      log("ERRROEEE getProvider : $e");
      notifyListeners();
    }
  }

  onCategoryChange(index) {
    if (!selectedProvider.contains(index)) {
      selectedProvider.add(index);
    } else {
      selectedProvider.remove(index);
    }
    notifyListeners();
  }

  int selectIndex = 0;

  onFilter(index) {
    selectIndex = index;
    notifyListeners();
  }

  double slider = 0;
  bool? isSelect;
  int ratingIndex = 0;

  onSliderChange(handlerIndex, lowerValue, upperValue) {
    lowerVal = lowerValue;
    upperVal = upperValue;
    notifyListeners();
  }

  onTapRating(id) {
    log("IDDDD::$id");
    if (!selectedRates.contains(id)) {
      selectedRates.add(id);
    } else {
      selectedRates.remove(id);
    }
    notifyListeners();
  }

  onChange() {
    isSelect = false;
    notifyListeners();
  }

  onChange1() {
    isSelect = true;
    notifyListeners();
  }

  double sliderValue = 0.0;

  onChangeSlider(sVal) {
    sliderValue = sVal;
    notifyListeners();
  }

  Future<ui.FrameInfo> loadImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 30, targetWidth: 30);
    ui.FrameInfo fi = await codec.getNextFrame();
    notifyListeners();
    return fi;
  }

  ui.Image? customImage;

  slidingValue(newValue) {
    slider = newValue;
    notifyListeners();
  }

  onBottomSheet(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const CategoriesFilterLayout();
      },
    );
  }

  onRefresh(context) async {
    showLoading(context);
    await getCategoryService(id: categoryModel!.id);
    await getService(id: categoryModel!.id);
    notifyListeners();
    hideLoading(context);
  }

  onReady(context) async {
    isNavigatingToCategory = false;
    mediaUrls = [];
    demoList = [];
    demoList.clear();
    // isLoading = true;
    isServiceLoading = true;
    widget1Opacity = 1;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
    log("isGuest::$isGuest");
    if (isGuest == false) {
      fetchBannerAdsData(context);
    }

    showLoading(context);
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    categoryModel = data;
    await getCategoryService(id: categoryModel!.id);
    await getService(id: categoryModel!.id);
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    providerList = dash.providerList;

    hideLoading(context);
    notifyListeners();
  }

  onBack(context, isBack) {
    selectedIndex = 0;
    selectIndex = 0;
    selectedProvider = [];
    selectedRates = [];
    lowerVal = 0.0;
    upperVal = maxPrice;
    slider = 0;
    mediaUrls = [];
    demoList = [];
    serviceDemo.clear();
    hasCategoryList = [];
    searchCtrl.text = "";
    widget1Opacity = 0.0;
    isNavigatingToCategory = false;
    notifyListeners();
    if (isBack) {
      route.pop(context);
      // route.pop(context);
    }
  }

  var cachedServiceList = [];

  getServiceByCategoryId(context, {id}) async {
    isLoader = true;
    notifyListeners();
    try {
      final effectiveZone = zoneIds.isNotEmpty ? zoneIds : '2';
      String apiUrl = "${api.service}?categoryIds=$id&zone_ids=$effectiveZone";

      if (selectedRates.isNotEmpty) {
        apiUrl += "&rating=${selectedRates.join(',')}";
      }
      if (selectedProvider.isNotEmpty) {
        apiUrl += "&providerIds=${selectedProvider.join(',')}";
      }
      if (lowerVal != 0 || upperVal != maxPrice) {
        apiUrl += "&min=${lowerVal.round()}&max=${upperVal.round()}";
      }
      if (isSelect != null && !isSelect!) {
        apiUrl += "&distance=$slider";
      }
      if (searchCtrl.text.isNotEmpty) {
        apiUrl += "&search=${searchCtrl.text}";
      }
      log("URRR L: $apiUrl");
      await apiServices.getApi(apiUrl, []).then((value) {
        if (value.isSuccess!) {
          List dataList = value.data;
          log("URRR L: ${value.data}");
          serviceList = [];
          if (dataList.isNotEmpty) {
            for (var data in value.data) {
              Services services = Services.fromJson(data);
              if (!serviceList.contains(services)) {
                serviceList.add(services);
              }
              if (services.price! > maxPrice) {
                maxPrice = services.price!;
              }
            }

            log("message-=-=-=-=-=-=SERVICE LIST $serviceList");
            CategoryService categoryService =
                CategoryService(id: id, serviceList: serviceList);
            if (cachedServiceList.length > 3) {
              cachedServiceList.removeAt(0);
            }
            if (!cachedServiceList.any((element) => element.id == id)) {
              cachedServiceList.add(categoryService);
            }
            upperVal = maxPrice;
          } else {
            maxPrice = 100.0;
            upperVal = 100.0;
          }
        }
        isLoader = false;
        notifyListeners();
      });
    } catch (e, s) {
      isLoader = false;
      maxPrice = 100.0;
      upperVal = 100.0;
      log("ERRROEEE getServiceByCategoryId $e ==> $s");
      notifyListeners();
    }
  }

  onRemoveService(context, index) async {
    if ((serviceList[index].selectedRequiredServiceMan!) == 1) {
      route.pop(context);
      isAlert = false;
    } else {
      if ((serviceList[index].requiredServicemen!) ==
          (serviceList[index].selectedRequiredServiceMan!)) {
        isAlert = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);
        isAlert = false;
      } else {
        isAlert = false;
        serviceList[index].selectedRequiredServiceMan =
            ((serviceList[index].selectedRequiredServiceMan!) - 1);
      }
    }
    notifyListeners();
  }

  onAdd(index) {
    isAlert = false;
    int count = (serviceList[index].selectedRequiredServiceMan!);
    count++;
    serviceList[index].selectedRequiredServiceMan = count;
    notifyListeners();
  }

  clearFilter(context, id) {
    selectedProvider = [];
    selectedRates = [];
    lowerVal = 0.0;
    upperVal = maxPrice;
    slider = 0;
    searchCtrl.text = '';
    searchFocus.unfocus();
    route.pop(context);
    getService(id: id);
    getServiceByCategoryId(context, id: id);
    notifyListeners();
  }

  List<String> mediaUrls = [];
  final dioo = Dio();

  int? loadingServiceId;

  Future<void> getProviderById(
      BuildContext context, int id, int index, dynamic service) async {
    final cartCtrl = Provider.of<CartProvider>(context, listen: false);

    if (cartCtrl.cartList
        .where((element) =>
            element.serviceList != null &&
            element.serviceList!.id == service.id)
        .isNotEmpty) {
      cartCtrl.checkout(context);
      route.pushNamed(context, routeName.cartScreen);
    } else {
      try {
        loadingServiceId = service.id; // 🔄 Set the loading ID
        notifyListeners();

        final response =
            await apiServices.getApi("${api.provider}/$id", [], isData: true);

        if (response.isSuccess!) {
          ProviderModel providerModel = ProviderModel.fromJson(response.data);
          final providerDetail =
              Provider.of<ProviderDetailsProvider>(context, listen: false);
          providerDetail.selectProviderIndex = 0;
          providerDetail.notifyListeners();

          // await onBook(
          //   context,
          //   service,
          //   provider: providerModel,
          //   providerId: providerModel.id,
          //   addTap: () => onAdd(index),
          //   minusTap: () => onRemoveService(context, index),
          // ).then((e) {
          //   if (index >= 0 && index <= serviceList.length) {
          //     serviceList[index].selectedRequiredServiceMan =
          //         serviceList[index].requiredServicemen ?? 1;
          //   } else {
          //     Fluttertoast.showToast(msg: "Unable to update service selection");
          //   }
          //   notifyListeners();
          // });
        } else {
          Fluttertoast.showToast(msg: response.message);
        }
      } catch (e, s) {
        log("ERROR getProviderById: $e == $s");
        snackBarMessengers(context,
            message: "Failed to fetch provider details");
      } finally {
        loadingServiceId = null; // 🔄 Clear loading
        notifyListeners();
      }
    }
  }

  bool isBannerLoader = false;
  Future<void> fetchBannerAdsData(context) async {
    isBannerLoader = true;
    notifyListeners();
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      String? lang = pref.getString("selectedLocale");
      final response = await dioo.get(
        api.advertisement,
        options: Options(headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Lang': lang,
          'Authorization': 'Bearer $token',
        }),
      );
      log("URL Name For Call: ${response.realUri}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchBannerAds = CategoryAdvertisementModel.fromJson(response.data);
        var data = response.data['data'];

        mediaUrls = [];
        for (var ad in data) {
          for (var media in ad['media']) {
            mediaUrls.add(media['original_url']);
          }
        }
        isBannerLoader = false;
        notifyListeners();
        // log("Banner images: $mediaUrls");
      } else {
        isBannerLoader = false;
        notifyListeners();
        log("Failed to fetch banner ads: ${response.statusMessage}");
      }
    } catch (e, s) {
      isBannerLoader = false;
      notifyListeners();
      log("Error fetching banner ads: $e ======> $s");
    }
    notifyListeners();
  }
}
