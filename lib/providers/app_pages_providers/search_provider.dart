import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:fixit_user/config.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

import '../../common_tap.dart';

class SearchProvider with ChangeNotifier {
  AnimationController? animationController;
  SharedPreferences? pref;
  TextEditingController searchCtrl = TextEditingController();
  TextEditingController filterSearchCtrl = TextEditingController();
  List<CategoryModel> categoryList = [];
  final FocusNode searchFocus = FocusNode();
  final FocusNode filterSearchFocus = FocusNode();
  var selectedCategory = [];
  List selectedRates = [];
  List<Services> searchList = [];
  List<Services> recentSearchList = [];
  ui.FrameInfo? image, image1;
  ui.Image? customImage;
  double slider = 0.0,
      minPrice = 0,
      maxPrice = 100,
      lowerVal = 0.0,
      upperVal = 100.0;
  bool? isSelect, isSearch = false, isLoader = false, isSearchLoading = false;
  int ratingIndex = 0,
      selectedFilterCount = 0,
      selectCategoryIndex = 0,
      selectIndex = 0;
  bool isAlert = false;
  Timer? _debounce;

  SearchProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    pref = await SharedPreferences.getInstance();
    getRecentSearch();
    notifyListeners();
  }

  void getRecentSearch() {
    try {
      String? save = pref!.getString(session.recentSearch);
      log("PREF RECENT SEARCH: $save");
      if (save != null && save.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(save);
        recentSearchList =
            jsonData.map<Services>((json) => Services.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      log("Error loading recent searches: $e");
      recentSearchList = [];
      notifyListeners();
    }
  }

  List<String> topServices() => [
        'Pipe Repair and Replacement',
        'Hardwood Floor Installation',
        'Exterior House Painting Service',
        'Commercial Exterior Painting Service',
        'Commercial Electrical Installation Service',
      ];

  void onSliderChange(int handlerIndex, double lowerValue, double upperValue) {
    lowerVal = lowerValue;
    upperVal = upperValue;
    notifyListeners();
  }

  void onBack(context) {
    searchList = [];
    isSearch = false;
    searchCtrl.text = "";
    notifyListeners();
  }

  void onTapRating(int id) {
    if (!selectedRates.contains(id)) {
      selectedRates.add(id);
    } else {
      selectedRates.remove(id);
    }
    notifyListeners();
  }

  void onChange() {
    isSelect = false;
    notifyListeners();
  }

  void onChange1() {
    isSelect = true;
    notifyListeners();
  }

  void slidingValue(double newValue) {
    slider = newValue;
    notifyListeners();
  }

  Future<ui.FrameInfo> loadImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetWidth: 25,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    notifyListeners();
    return fi;
  }

  void onAnimate(BuildContext context, TickerProvider sync) async {
    pref = await SharedPreferences.getInstance();
    getCategory();
    getRecentSearch();
    animationController = AnimationController(
      vsync: sync,
      duration: const Duration(milliseconds: 1200),
    );
    ui.FrameInfo fi = await loadImage(eImageAssets.userSlider);
    customImage = fi.image;
    final dashCtrl = Provider.of<DashboardProvider>(context, listen: false);
    categoryList = dashCtrl.categoryList;
    notifyListeners();
    getMaxPrice(context);
  }

  void onBottomSheet(BuildContext context) {
    getCategory();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => const FilterLayout(),
    ).then((value) {
      log("Bottom sheet closed");
      filterSearchCtrl.text = "";
      notifyListeners();
    });
  }

  Future<void> getCategory({String? search}) async {
    try {
      isLoader = true;

      String apiUrl = api.category;
      if (zoneIds.isNotEmpty) {
        apiUrl = search != null && search.isNotEmpty
            ? "${api.category}?search=$search&zone_ids=$zoneIds"
            : "${api.category}?zone_ids=$zoneIds";
      } else if (search != null && search.isNotEmpty) {
        apiUrl = "${api.category}?search=$search";
      }

      log("Fetching categories: $apiUrl");
      final response = await apiServices.getApi(apiUrl, []);

      if (response.isSuccess!) {
        categoryList = (response.data as List)
            .reversed
            .map((data) => CategoryModel.fromJson(data))
            .toSet()
            .toList();
      } else {
        Fluttertoast.showToast(
            msg: response.message, backgroundColor: Colors.red);
      }
    } catch (e) {
      log("Error fetching categories: $e");
      Fluttertoast.showToast(
          msg: "Failed to load categories", backgroundColor: Colors.red);
    } finally {
      isLoader = false;
      notifyListeners();
    }
    log("categoryList length: ${categoryList.length}");
  }

  void onCategoryChange(BuildContext context, id) {
    if (!selectedCategory.contains(id)) {
      selectedCategory.add(id);
    } else {
      selectedCategory.remove(id);
    }
    notifyListeners();
  }

  String totalCountFilter() {
    int count = 0;
    if (selectedCategory.isNotEmpty) count++;
    if ((lowerVal != 0.0 || upperVal != maxPrice) &&
        (lowerVal != 0.0 || upperVal != 100.0)) {
      count++;
    }
    if (selectedRates.isNotEmpty) count++;
    if (slider != 0.0) count++;
    if (isSelect != null) count++;
    return count.toString();
  }

  void clearFilter(BuildContext context) {
    selectedCategory = [];
    selectedRates = [];
    lowerVal = 0.0;
    upperVal = maxPrice;
    slider = 0;
    isSelect = null;
    recentSearchList = [];
    searchList = [];
    // searchService(context);
    route.pop(context);
    notifyListeners();
  }

  Future<void> searchService(BuildContext context, {bool isPop = false}) async {
    // Check if all inputs are empty or at default
    final isSearchEmpty = searchCtrl.text.trim().isEmpty;
    final isCategoryEmpty = selectedCategory.isEmpty;
    final isRatingEmpty = selectedRates.isEmpty;
    final isPriceDefault = lowerVal == 0 && upperVal == maxPrice;
    final isDistanceDefault = isSelect == null || isSelect == true;
    if (isSearchEmpty && isCategoryEmpty && isRatingEmpty && isPriceDefault && isDistanceDefault) {
      Fluttertoast.showToast(msg: "Please enter search text or apply filters.",backgroundColor: Colors.red);
      return;
    }

    try {
      isSearchLoading = true;
      notifyListeners();

      Map<String, String> queryParams = {'zone_ids': zoneIds};

      if (searchCtrl.text.isNotEmpty) {
        queryParams['search'] = searchCtrl.text;
      }
      if (selectedCategory.isNotEmpty) {
        queryParams['categoryIds'] = selectedCategory.join(',');
      }
      if (selectedRates.isNotEmpty) {
        queryParams['rating'] = selectedRates.join(',');
      }
      if (lowerVal != 0 || upperVal != maxPrice) {
        queryParams['min'] = lowerVal.toString();
        queryParams['max'] = upperVal.toString();
      }
      if (isSelect != null && !isSelect!) {
        queryParams['distance'] = slider.toString();
      }

      String apiUrl =
          "${api.service}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}";
      log("SER: $apiUrl");

      searchList = [];
      notifyListeners();

      final response = await apiServices.getApi(apiUrl, []);

      if (response.isSuccess!) {
        isSearchLoading = false;
        searchList = (response.data as List)
            .map((data) => Services.fromJson(data))
            .toSet()
            .toList();
        isSearch = searchList.isEmpty;
      } else {
        searchList = [];
        isSearch = true;
        Fluttertoast.showToast(msg: response.message);
      }

      if (isPop) {
        route.pop(context);
      }
    } catch (e,s) {
      log("Error in searchService: $e-----$s");
      searchList = [];
      isSearch = true;
      Fluttertoast.showToast(msg: "Failed to load search results");
    } finally {
      isSearchLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value, BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty || value.length > 2) {
        searchService(context);
      }
    });
  }

  void searchClear() {
    searchCtrl.text = "";
    isSearch = false;
    searchList = [];
    notifyListeners();
  }

  void onFeatured(BuildContext context, Services? services, int id,
      {bool inCart = false}) async {
    if (inCart) {
      route.pop(context);
      route.pushNamed(context, routeName.cartScreen);
    } else {
      final providerDetail =
          Provider.of<ProviderDetailsProvider>(context, listen: false);
      providerDetail.selectProviderIndex = 0;
      providerDetail.notifyListeners();
      onBook(context, services!,
          addTap: () => onAdd(id),
          minusTap: () => onRemoveService(context, id)).then((e) {
        searchList[id].selectedRequiredServiceMan =
            searchList[id].requiredServicemen;
        notifyListeners();
      });
    }
  }

  void onTapFeatures(BuildContext context, Services? services, int id) async {
    List<Services> saveList = recentSearchList;
    if (!saveList.any((element) => element.id == services!.id)) {
      saveList.insert(0, services!);
      if (saveList.length > 5) {
        saveList = saveList.sublist(0, 5);
      }
      recentSearchList = saveList;
      await pref!.setString(session.recentSearch,
          jsonEncode(saveList.map((e) => e.toJson()).toList()));
      notifyListeners();
    }
    Provider.of<ServicesDetailsProvider>(context, listen: false)
        .getServiceById(context, services!.id);
    route.pushNamed(context, routeName.servicesDetailsScreen,
        arg: {'serviceId': services.id});
  }

  Future<void> getMaxPrice(BuildContext context) async {
    try {
      final response = await apiServices.getApi(
        "${api.service}?latitude=${position!.latitude}&longitude=${position!.longitude}",
        [],
      );
      if (response.isSuccess!) {
        maxPrice = 100.0;
        for (var data in response.data) {
          Services services = Services.fromJson(data);
          if (services.price != null && services.price! > maxPrice) {
            maxPrice = services.price!;
          }
        }
        upperVal = maxPrice;
        notifyListeners();
      }
    } catch (e) {
      log("Error in getMaxPrice: $e");
      Fluttertoast.showToast(msg: "Failed to load max price");
    }
  }

  void onRemoveService(BuildContext context, int index) async {
    if ((searchList[index].selectedRequiredServiceMan!) == 1) {
      route.pop(context);
      isAlert = false;
    } else {
      if ((searchList[index].requiredServicemen!) ==
          (searchList[index].selectedRequiredServiceMan!)) {
        isAlert = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);
        isAlert = false;
      } else {
        isAlert = false;
        searchList[index].selectedRequiredServiceMan =
            ((searchList[index].selectedRequiredServiceMan!) - 1);
      }
    }
    notifyListeners();
  }

  void onAdd(int index) {
    isAlert = false;
    int count = (searchList[index].selectedRequiredServiceMan!);
    count++;
    searchList[index].selectedRequiredServiceMan = count;
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    recentSearchList = [];
    await pref!.remove(session.recentSearch);
    notifyListeners();
  }

  void onFilter(int index) {
    selectIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    animationController?.dispose();
    searchCtrl.dispose();
    filterSearchCtrl.dispose();
    searchFocus.dispose();
    filterSearchFocus.dispose();
    super.dispose();
  }

  void removeTopServiceAt(int index) {
    topServices().removeAt(index);
    notifyListeners();
  }
}
