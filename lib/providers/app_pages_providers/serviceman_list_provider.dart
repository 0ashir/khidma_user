import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../screens/app_pages_screens/serviceman_list_screen/layouts/service_filter_layout.dart';

class ServicemanListProvider with ChangeNotifier {
  List<ProviderModel> servicemanList = [];
  List<ProviderModel> searchServicemanList = [];
  int selectedIndex = 0;
  int ratingIndex = 0;
  String providerId = "0";
  List selectCategory = [];
  int yearValue = 1;
  List selectedRates = [];
  final FocusNode searchFocus = FocusNode();
  TextEditingController controller = TextEditingController();
  AnimationController? animationController;
  String? requiredServiceman;
  bool isLoading = true;

  onReady(context, TickerProvider sync) async {
    selectCategory = [];
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    // log("data : $data");
    providerId = data['providerId'].toString();
    requiredServiceman = data['requiredServiceman']?.toString();
    List<ProviderModel> serviceList = data['selectedServiceMan'] ?? [];
    for (var d in serviceList) {
      if (selectCategory.contains(d.id)) {
        selectCategory.remove(d.id); // unselect
      } else {
        selectCategory.add(d.id); // select
      }
    }
    animationController = AnimationController(
        vsync: sync, duration: const Duration(milliseconds: 1200));
    _runAnimation();
    notifyListeners();

    getServicemenByProviderId(context, providerId);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController!.dispose();
    super.dispose();
  }

  void _runAnimation() async {
    for (int i = 0; i < 300; i++) {
      await animationController!.forward();
      await animationController!.reverse();
    }
  }

  String totalCountFilter() {
    int count = 0;
    if (selectedRates.isNotEmpty) {
      count++;
    }
    if (selectCategory.isNotEmpty) {
      count++;
    }

    return count.toString();
  }

  onTapYear(context, val) {
    yearValue = val;
    notifyListeners();
    getServicemenByProviderId(context, providerId);
  }

  void onCategorySelected(
      BuildContext context, servicemanId, indexKey, name) async {
    final countRequired = int.parse(requiredServiceman ?? "1");

    final selectProvider =
        Provider.of<ServiceSelectProvider>(context, listen: false);

    if (countRequired == 1) {
      bool isValid = await selectProvider.checkSlotAvailable(
          context, servicemanId, indexKey);
      if (isValid) {
        selectedIndex = indexKey;
      } else {
        Fluttertoast.showToast(
            msg: "$name is Not Available", backgroundColor: Colors.red);
      }
    } else {
      if (selectCategory.contains(servicemanId)) {
        selectCategory.remove(servicemanId); // Unselect
      } else {
        if (selectCategory.length >= countRequired) {
          Fluttertoast.showToast(
              msg: "Only $requiredServiceman required person",
              backgroundColor: Colors.red);
        } else {
          bool isValid = await selectProvider.checkSlotAvailable(
              context, servicemanId, indexKey);
          if (isValid) {
            selectCategory.add(servicemanId); // Select
          } else {
            Fluttertoast.showToast(
                msg: "$name is Not Available", backgroundColor: Colors.red);
          }
        }
      }
    }

    notifyListeners(); // This ensures the UI is refreshed
  }

  // void onCategorySelected(context, index, indexKey, name) async {
  //   if (int.parse(requiredServiceman ?? "1") == 1) {
  //     final selectProvider =
  //         Provider.of<ServiceSelectProvider>(context, listen: false);
  //     bool isValid =
  //         await selectProvider.checkSlotAvailable(context, index, indexKey);
  //     if (isValid) {
  //       selectedIndex = indexKey;
  //       notifyListeners();
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: "$name is Not Available", backgroundColor: Colors.red);
  //     }
  //   } else {
  //     if (selectCategory.contains(index)) {
  //       selectCategory.remove(index); // unselect
  //     } else {
  //       final selectProvider =
  //           Provider.of<ServiceSelectProvider>(context, listen: false);
  //       bool isValid =
  //           await selectProvider.checkSlotAvailable(context, index, indexKey);
  //       if (selectCategory.length == int.parse(requiredServiceman ?? "1")) {
  //         //   snackBarMessengers(context,message: "Only $requiredServiceman required person");
  //         Fluttertoast.showToast(
  //             msg: "Only $requiredServiceman required person");
  //       } else {
  //         log(" isValid :$isValid");
  //         if (isValid) {
  //           selectCategory.add(index); // select
  //         } else {
  //           Fluttertoast.showToast(msg: "$name is Not Available");
  //         }
  //       }
  //     }
  //   }
  //
  //   notifyListeners();
  // }

  onTapRating(id) {
    if (!selectedRates.contains(id)) {
      selectedRates.add(id);
    } else {
      selectedRates.remove(id);
    }
    notifyListeners();
    log("selectedRates ;%$selectedRates");
  }

  onTapFilter(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const ServiceFilterLayout();
      },
    );
  }

  bool isLoadingForProvider = false;

  // getServicemenByProviderId(context, id, {val}) async {
  //   isLoadingForProvider = true;
  //   try {
  //     if (val == null) {
  //       FocusScope.of(context).requestFocus(FocusNode());
  //     }
  //
  //     String apiUrl = "";
  //     if (selectedRates.isNotEmpty) {
  //       String rate = "";
  //       rate = selectedRates.join(', ');
  //
  //       log("rate: $rate");
  //       apiUrl =
  //           "${api.serviceman}?provider_id=$id&experience=${yearValue == 1 ? "low" : "high"}&rating=$rate";
  //     } else {
  //       apiUrl =
  //           "${api.serviceman}?provider_id=$id&experience=${yearValue == 1 ? "low" : "high"}&search=${controller.text}";
  //     }
  //     if (controller.text.isNotEmpty) {
  //       "${api.serviceman}?provider_id=$id&search=${controller.text}";
  //     }
  //
  //     log("UUURRRLLL::$apiUrl");
  //     notifyListeners();
  //     await apiServices.getApi(
  //       apiUrl,
  //       [],
  //     ).then((value) {
  //       if (value.isSuccess!) {
  //         isLoadingForProvider = false;
  //         List data = value.data;
  //         // log("data : $data");
  //
  //         servicemanList = [];
  //         for (var list in data) {
  //           if (!servicemanList.contains(ProviderModel.fromJson(list))) {
  //             servicemanList.add(ProviderModel.fromJson(list));
  //           }
  //           notifyListeners();
  //         }
  //       }
  //       isLoading = false;
  //       notifyListeners();
  //       log("serviceManList : ${servicemanList.length}");
  //     });
  //   } catch (e) {
  //     isLoadingForProvider = false;
  //     log("ERRROEEE getServicemenByProviderId : $e");
  //     notifyListeners();
  //   }
  // }
  getServicemenByProviderId(BuildContext context, id, {val}) async {
    isLoadingForProvider = true;
    try {
      if (val == null) {
        FocusScope.of(context).requestFocus(FocusNode());
      }

      String apiUrl = "${api.serviceman}?provider_id=$id";

      // 👇 Priority: If user is typing a search query
      if (controller.text.isNotEmpty) {
        apiUrl = "${api.serviceman}?provider_id=$id&search=${controller.text}";
      } else if (selectedRates.isNotEmpty) {
        final rate = selectedRates.join(',');
        apiUrl =
            "${api.serviceman}?provider_id=$id&experience=${yearValue == 1 ? "low" : "high"}&rating=$rate";
      } else {
        apiUrl =
            "${api.serviceman}?provider_id=$id&experience=${yearValue == 1 ? "low" : "high"}";
      }

      log("UUURRRLLL::$apiUrl");

      notifyListeners();

      final response = await apiServices.getApi(apiUrl, []);

      isLoading = false;
      isLoadingForProvider = false;
      servicemanList.clear();

      if (response.isSuccess!) {
        for (var list in response.data) {
          final model = ProviderModel.fromJson(list);
          if (!servicemanList.contains(model)) {
            servicemanList.add(model);
            log("servicemanList::$servicemanList");
          }
        }
      }

      log("serviceManList : ${servicemanList.length}");
      notifyListeners();
    } catch (e) {
      isLoadingForProvider = false;
      log("ERRROEEE getServicemenByProviderId : $e");
      notifyListeners();
    }
  }

  clearTap(context) {
    selectedRates = [];
    yearValue = 1;
    notifyListeners();
    animationController!.dispose();
    route.pop(context);
    getServicemenByProviderId(
      context,
      providerId,
    );
  }

  applyTap(context) {
    route.pop(context);
    getServicemenByProviderId(context, providerId);
  }

  onSaveTap(context) {
    List<ProviderModel> selectedProvider = [];
    log("selectCategory:$selectCategory");
    if (selectCategory.isNotEmpty) {
      servicemanList.asMap().entries.forEach((element) {
        if (selectCategory.contains(element.value.id)) {
          if (!selectedProvider.contains(element.value)) {
            selectedProvider.add(element.value);
          }
        }
      });
    } else {
      if (!selectedProvider.contains(servicemanList[selectedIndex])) {
        selectedProvider.add(servicemanList[selectedIndex]);
      }
    }

    log("selectedProvider : ${selectedProvider.length}");
    notifyListeners();
    route.pop(context, arg: selectedProvider);
  }
}
