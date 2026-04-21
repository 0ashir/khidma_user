import 'dart:developer';

import 'package:fixit_user/config.dart';

class ProviderDetailsProvider with ChangeNotifier {
  int selectIndex = 0;
  int selectProviderIndex = 0;
  double widget1Opacity = 0.0;
  List<CategoryModel> categoryList = [];
  List<Services> serviceList = [];
  List<Services> allServices = [];
  bool visible = true;
  int val = 1;
  double loginWidth = 100.0;
  int providerId = 0;
  ProviderModel? provider;
  bool isProviderLoading = false;
  bool isCategoriesLoadeer = false;
  bool isAlert = false;
  List<Map<String, dynamic>> bannerAds = [];
  List<String> bannerImageUrls = [];

  // Fetch banners
  Future<void> fetchBannerAdsData(context, {required int providerId}) async {
    try {
      final response = await apiServices.getApi(
        '${api.advertisement}?providerId=$providerId',
        [],
        isToken: true,
      );
      if (response.isSuccess!) {
        bannerAds =
            List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        bannerImageUrls = [];
        for (var ad in bannerAds) {
          final media = ad['media'] as List<dynamic>?;
          if (media != null && media.isNotEmpty) {
            bannerImageUrls.add(media.first['original_url'] as String);
          }
        }
        log("Banner ads: $bannerAds");
        log("Banner image URLs: $bannerImageUrls");
      } else {
        log("Failed to fetch banner ads: ${response.message}");
      }
    } catch (e, s) {
      log("Error fetching banner ads: $e ======> $s");
    }
    notifyListeners();
  }

  // Local filtering for category selection
  void onSelectService(context, index, id) {
    selectIndex = index;
    log("Selected category ID: $id, Index: $index");

    // Filter allServices locally
    if (id == 0) {
      // "All" category: show all services
      serviceList = List.from(allServices);
    } else {
      serviceList = allServices.where((service) {
        final categories = service.categories ?? [];
        final hasCategory = categories.any((cat) => cat.id == id);
        log("Service: ${service.title}, Categories: ${categories.map((c) => c.id).toList()}, Matches: $hasCategory");
        return hasCategory;
      }).toList();
    }

    log("Filtered serviceList: ${serviceList.map((s) => s.title).toList()}");
    notifyListeners();
  }

  void onChooseService(index) {
    selectProviderIndex = index;
    notifyListeners();
    log("message selectProviderIndex:: $selectProviderIndex");
  }

  void onAddService() {
    if (!visible) {
      visible = !visible;
      loginWidth = 100.0;
    } else {
      val = ++val;
    }
    notifyListeners();
  }

  void onBack(context, isBack) {
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }

  Future<void> onReady(context, {id}) async {
    notifyListeners();
    dynamic data;
    if (id != null) {
      data = id;
    } else {
      data = ModalRoute.of(context)!.settings.arguments;
      if (data['providerId'] != null) {
        data = data['providerId'];
      } else {
        provider = data['provider'];
        data = provider?.id;
      }
    }
    providerId = data;
    selectIndex = 0;
    notifyListeners();
    await getProviderById(context, data);
    await getCategory(context, data);
    // await fetchBannerAdsData(context, providerId: data);
    notifyListeners();
  }

  void onRemoveService(context, index) async {
    if ((serviceList[index].selectedRequiredServiceMan!) == 1) {
      route.pop(context);
      isAlert = false;
      notifyListeners();
    } else {
      if ((serviceList[index].requiredServicemen!) ==
          (serviceList[index].selectedRequiredServiceMan!)) {
        isAlert = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);
        isAlert = false;
        notifyListeners();
      } else {
        isAlert = false;
        notifyListeners();
        serviceList[index].selectedRequiredServiceMan =
            ((serviceList[index].selectedRequiredServiceMan!) - 1);
      }
    }
    notifyListeners();
  }

  void onAdd(index) {
    isAlert = false;
    notifyListeners();
    int count = (serviceList[index].selectedRequiredServiceMan!);
    count++;
    serviceList[index].selectedRequiredServiceMan = count;
    notifyListeners();
  }

  Future<void> getProviderById(context, id) async {
    isProviderLoading = true;
    try {
      await apiServices
          .getApi("${api.provider}/$id", [], isData: true, isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          isProviderLoading = false;
          provider = ProviderModel.fromJson(value.data['data']);
          log("Provider data: ${value.data['data']}");
          notifyListeners();
        }
        isProviderLoading = false;
      });
    } catch (e, s) {
      isProviderLoading = false;
      log("Error getProviderById: $e ===> $s");
      notifyListeners();
    }
  }

  Future<void> getCategory(context, id) async {
    try {
      String apiURL = "${api.category}?providerId=$id";
      if (zoneIds.isNotEmpty) {
        apiURL = "${api.category}?providerId=$id&zone_ids=$zoneIds";
      }

      await apiServices.getApi(apiURL, []).then((value) {
        if (value.isSuccess!) {
          List category = value.data;
          categoryList = [];
          categoryList.add(CategoryModel(id: 0, title: 'All'));
          for (var data in category.reversed.toList()) {
            if (!categoryList.contains(CategoryModel.fromJson(data))) {
              categoryList.add(CategoryModel.fromJson(data));
            }
          }
          // Fetch services for all categories
          getAllServices(context, id);
        }
      });
    } catch (e) {
      log("Error getCategory: $e");
      notifyListeners();
    }
  }

  Future<void> onRefresh(context) async {
    showLoading(context);
    await getAllServices(context, providerId);
    hideLoading(context);
    notifyListeners();
  }

  // Fetch services for each category
  Future<void> getAllServices(context, int providerId) async {
    isCategoriesLoadeer = true;
    showLoading(context);
    notifyListeners();

    try {
      allServices = [];
      serviceList = [];

      // Fetch services for each category
      for (var category in categoryList.where((cat) => cat.id != 0)) {
        String apiUrl =
            "${api.service}?providerIds=$providerId&categoryIds=${category.id}";
        if (zoneIds.isNotEmpty) {
          apiUrl += "&zone_ids=$zoneIds";
        }
        log("Fetching services for category ${category.id}: $apiUrl");
        await apiServices.getApi(apiUrl, []).then((value) {
          if (value.isSuccess!) {
            for (var data in value.data) {
              final serviceJson = Map<String, dynamic>.from(data);
              // Assign the category
              serviceJson['categories'] = [
                {'id': category.id, 'title': category.title}
              ];
              log("Modified serviceJson: $serviceJson");
              Services service = Services.fromJson(serviceJson);
              if (!allServices.any((s) => s.id == service.id)) {
                allServices.add(service);
              }
            }
          }
        });
      }

      // If no services were fetched, try fetching all services without category filter
      if (allServices.isEmpty) {
        String apiUrl = "${api.service}?providerIds=$providerId";
        if (zoneIds.isNotEmpty) {
          apiUrl += "&zone_ids=$zoneIds";
        }
        log("Fetching all services (fallback): $apiUrl");
        await apiServices.getApi(apiUrl, []).then((value) {
          if (value.isSuccess!) {
            for (var data in value.data) {
              final serviceJson = Map<String, dynamic>.from(data);
              // Assign a default category if none provided
              serviceJson['categories'] = [
                {
                  'id': categoryList
                      .firstWhere((cat) => cat.id != 0,
                          orElse: () => CategoryModel(id: 1, title: 'Default'))
                      .id,
                  'title': categoryList
                      .firstWhere((cat) => cat.id != 0,
                          orElse: () => CategoryModel(id: 1, title: 'Default'))
                      .title
                }
              ];
              log("Modified serviceJson (fallback): $serviceJson");
              Services service = Services.fromJson(serviceJson);
              if (!allServices.any((s) => s.id == service.id)) {
                allServices.add(service);
              }
            }
          }
        });
      }

      serviceList = List.from(allServices);
      log("All services fetched: ${allServices.map((s) => s.title).toList()}");
      log("Service categories: ${allServices.map((s) => s.categories?.map((c) => c.id).toList() ?? []).toList()}");
      if (selectIndex != 0) {
        serviceList = allServices.where((service) {
          final categories = service.categories ?? [];
          final hasCategory =
              categories.any((cat) => cat.id == categoryList[selectIndex].id);
          log("Service: ${service.title}, Categories: ${categories.map((c) => c.id).toList()}, Matches: $hasCategory");
          return hasCategory;
        }).toList();
      }
      isCategoriesLoadeer = false;
      // hideLoading(context);
      notifyListeners();
    } catch (e, s) {
      isCategoriesLoadeer = false;
      log("Error getAllServices: $e ===> $s");
      hideLoading(context);
      notifyListeners();
    }
  }
}
