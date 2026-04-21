import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fixit_user/config.dart';

class ServicesPackageDetailsProvider with ChangeNotifier {
  int selectedIndex = 0;
  int? serviceId;
  bool isBottom = true;
  ScrollController scrollController = ScrollController();
  double widget1Opacity = 0.0;
  bool isServicesPackageLoader = false;
  ServicePackageModel? service;

  onImageChange(int index) {
    selectedIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  onReady(BuildContext context) async {
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    log("Arguments received: $data");
    isServicesPackageLoader = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      if (data != null && data['packageId'] != null) {
        serviceId = data['packageId'] as int;
        log("Using packageId: $serviceId");
        await getServicePackageById(context, serviceId!);
      } else {
        final prefs = await SharedPreferences.getInstance();
        serviceId = prefs.getInt('lastServiceId');
        if (serviceId != null) {
          log("Using cached serviceId: $serviceId");
          await getServicePackageById(context, serviceId!);
        } else {
          final String? serviceJson = prefs.getString('lastService');
          if (serviceJson != null) {
            service = ServicePackageModel.fromJson(jsonDecode(serviceJson));
            serviceId = service!.id;
            isServicesPackageLoader = false;
            log("Using cached service: id=${service!.id}, title=${service!.title}");
            WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
          } else {
            log("No valid serviceId or services provided");
            Fluttertoast.showToast(msg: "No package data available");
            isServicesPackageLoader = false;
            WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
          }
        }
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        widget1Opacity = 1;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      });
    } catch (e, s) {
      log("Error in onReady: $e\nStack: $s");
      Fluttertoast.showToast(msg: "Failed to load package details");
      isServicesPackageLoader = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void show() {
    if (!isBottom) {
      isBottom = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> getServicePackageById(BuildContext context, int serviceId) async {
    isServicesPackageLoader = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      log("Fetching service package for serviceId: $serviceId");
      final response = await Dio().get(
        "${api.servicePackagesDetails}/$serviceId",
        // Uncomment if authentication is required
        // options: Options(headers: {'Authorization': 'Bearer your_token'}),
      );
      log("API Status Code: ${response.statusCode}");
      log("API Response: ${jsonEncode(response.data)}");

      if (response.statusCode == 200) {
        Map<String, dynamic>? jsonData;
        if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
          // Extract 'data' field
          if (jsonData!['success'] == true && jsonData['data'] is Map<String, dynamic>) {
            jsonData = jsonData['data'];
            log("Extracted data field: ${jsonEncode(jsonData)}");
          } else {
            log("Error: Response missing 'success' or 'data' field");
            jsonData = {};
          }
        } else {
          log("Error: API response is not a valid JSON object");
          jsonData = {};
        }

        if (jsonData == null || jsonData.isEmpty) {
          log("Error: Empty or invalid API response");
          Fluttertoast.showToast(msg: "No package data found");
          isServicesPackageLoader = false;
          hideLoading(context);
          WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
          return;
        }

        service = ServicePackageModel.fromJson(jsonData);
        log("Parsed ServicePackage: id=${service!.id}, title=${service!.title}, price=${service!.price}, media=${service!.media?.map((m) => m.originalUrl).toList()}, user=${service!.user?.name}, services=${service!.services?.map((s) => s.title).toList()}");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastServiceId', serviceId);
        await prefs.setString('lastService', jsonEncode(service!.toJson()));

        isServicesPackageLoader = false;
        hideLoading(context);
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      } else {
        log("API Failed: ${response.statusCode} - ${response.statusMessage}");
        Fluttertoast.showToast(msg: "Failed to load package details");
        isServicesPackageLoader = false;
        hideLoading(context);
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    } catch (e, s) {
      log("Error in getServicePackageById: $e\nStack: $s");
      Fluttertoast.showToast(msg: "Error loading package details");
      isServicesPackageLoader = false;
      hideLoading(context);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  onRefresh(BuildContext context) async {
    if (serviceId != null) {
      isServicesPackageLoader = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      await getServicePackageById(context, serviceId!);
      isServicesPackageLoader = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      log("Cannot refresh: serviceId is null");
      Fluttertoast.showToast(msg: "No package data to refresh");
    }
  }

  onBack(BuildContext context, bool isBack) {
    service = null;
    serviceId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    if (isBack) {
      route.pop(context);
    }
  }
}

/*
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fixit_user/config.dart';

class ServicesPackageDetailsProvider with ChangeNotifier {
  int selectedIndex = 0;
  int? serviceId;
  bool isBottom = true;
  ScrollController scrollController = ScrollController();
  double widget1Opacity = 0.0;

  ServicePackageModel? serviceList;

  onImageChange(index) {
    selectedIndex = index;
    notifyListeners();
  }

  onReady(context) async {
    // scrollController.addListener(listen);
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    log("service :$data");
    if (data['packageId'] != null) {
      serviceId = data['packageId'];
      notifyListeners();
    } else {
      serviceList = data['services'];
      serviceId = serviceList!.id;
      notifyListeners();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      widget1Opacity = 1;
      notifyListeners();
    });
    getServicePackageById(context, serviceId);
    notifyListeners();
  }

  @override
  void dispose() {
    // scrollController.dispose();
    super.dispose();
  }

*/
/*   void listen() {
    if (scrollController.position.pixels >= 100) {
      hide();
      log("scrollController.position.pixels${scrollController.position.pixels}");
      notifyListeners();
    } else {
      show();
      log("scrollController.position.pixels${scrollController.position.pixels}");
      notifyListeners();
    }

    notifyListeners();
  }
 *//*

  void show() {
    if (!isBottom) {
      isBottom = true;
      notifyListeners();
    }
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      notifyListeners();
    }
  }

*/
/*   getServicePackageById(context, serviceId) async {
    log(" serviceId::${serviceId}");

    try {
      await apiServices
          .getApi("${api.servicePackagesDetails}/$serviceId", []).then((value) {
        if (value.isSuccess!) {
          log("value.isSuccess service Packages :::${value.data}");
          notifyListeners();
          service = ServicePackageModel.fromJson(value.data);
          log("DDDD 1:${service}");
          hideLoading(context);
          notifyListeners();
        }
      });
    } catch (e, s) {
      log("ERRROEEE getServicePackageById : $e=====>$s");
      hideLoading(context);
      notifyListeners();
    }
  } *//*

  bool isServicesPackageLoader = false;
  Future<void> getServicePackageById(context, serviceId) async {
    isServicesPackageLoader = true;
    notifyListeners();

    try {
      final response =
          await Dio().get("${api.servicePackagesDetails}/$serviceId");

      if (response.statusCode == 200) {
        isServicesPackageLoader = false;
        log("value.isSuccess service Packages :::${response.data}");
        serviceList = ServicePackageModel.fromJson(response.data);

        hideLoading(context);
        notifyListeners();
      }
    } catch (e, s) {
      isServicesPackageLoader = false;
      log("ERRROEEE getServicePackageById : $e=====>$s");
      hideLoading(context);
      notifyListeners();
      print("Error fetching blog: $e");
    }

    notifyListeners();
  }

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getServicePackageById(context, serviceId);
    hideLoading(context);
    notifyListeners();
  }

  onBack(context, isBack) async {
    if (isBack) {
      route.pop(context);
    }
    serviceList = null;
    serviceId = null;
    notifyListeners();
  }
}
*/
