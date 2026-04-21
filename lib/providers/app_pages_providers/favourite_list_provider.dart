import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';

import '../../common_tap.dart';
import '../../config.dart';

class FavouriteListProvider with ChangeNotifier {
  List<FavouriteModel> favoriteList = [];
  List providerFavList = [];
  List serviceFavList = [];
  TextEditingController providerCtrl = TextEditingController();
  TextEditingController serviceCtrl = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  final FocusNode serviceSearchFocus = FocusNode();
  int selectedIndex = 0;

  onChangeList(index) {
    selectedIndex = index;
    if (selectedIndex == 1) {
      var apiUrlName =
          "${api.favoriteList}?type=service&search=${serviceCtrl.text}";
    }
    notifyListeners();
  }

  // Future<void> providerDataList() async {
  //   providerFavList.clear();
  //   bool hasMore = true;
  //
  //   while (hasMore) {
  //     try {
  //       final response = await apiServices
  //           .getApi("${api.favoriteList}?type=provider", [], isToken: true);
  //
  //       final data = response.data;
  //
  //       if (data is List) {
  //         providerFavList
  //             .addAll(data.map((e) => FavouriteModel.fromJson(e)).toList());
  //         hasMore = false;
  //       } else {
  //         log("Unexpected provider response structure: $data");
  //         hasMore = false;
  //       }
  //     } catch (e) {
  //       log("Error loading provider favorites: $e");
  //       hasMore = false;
  //     }
  //   }
  // }
  //
  // Future<void> serviceDataList() async {
  //   serviceFavList.clear();
  //   bool hasMore = true;
  //
  //   while (hasMore) {
  //     try {
  //       final response = await apiServices
  //           .getApi("${api.favoriteList}?type=service", [], isToken: true);
  //
  //       final data = response.data;
  //
  //       if (data is List) {
  //         serviceFavList
  //             .addAll(data.map((e) => FavouriteModel.fromJson(e)).toList());
  //         hasMore = false;
  //       } else {
  //         log("Unexpected service response structure: $data");
  //         hasMore = false;
  //       }
  //     } catch (e) {
  //       log("Error loading service favorites: $e");
  //       hasMore = false;
  //     }
  //   }
  // }

  //favorite list
  getFavourite(context) async {
    notifyListeners();

    String apiUrlName = "";
    if (providerCtrl.text.isNotEmpty || serviceCtrl.text.isNotEmpty) {
      if (selectedIndex == 0) {
        apiUrlName =
            "${api.favoriteList}?type=provider&search=${providerCtrl.text}";
      } else {
        apiUrlName =
            "${api.favoriteList}?type=service&search=${serviceCtrl.text}";
      }
    } else {
      apiUrlName = api.favoriteList;
    }
    try {
      await apiServices.getApi(apiUrlName, [], isToken: true).then((value) {
        if (value.isSuccess!) {
          List favList = value.data;
          log("favList::$favList");
          favoriteList = [];
          serviceFavList = [];
          providerFavList = [];
          notifyListeners();
          for (var data in favList.reversed.toList()) {
            FavouriteModel favouriteModel = FavouriteModel.fromJson(data);
            if (!favoriteList.contains(favouriteModel)) {
              favoriteList.add(favouriteModel);

              if (favouriteModel.service?.id != null) {
                log("SER : ${favouriteModel.service?.id}");
                if (!serviceFavList.contains(favouriteModel)) {
                  serviceFavList.add(favouriteModel);
                } else {
                  onRemoveService(context, id: favouriteModel.service?.id);
                  serviceFavList.remove(favouriteModel);
                  getFavourite(context);
                  notifyListeners();
                }
                notifyListeners();
              } else {
                if (!providerFavList.contains(favouriteModel)) {
                  providerFavList.add(favouriteModel);
                } else {
                  providerFavList.remove(favouriteModel);
                  getFavourite(context);
                  notifyListeners();
                }
                notifyListeners();
              }
            }
            notifyListeners();
          }
        } else {
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: Colors.red);
        }
      });
      log("favoriteList : ${favoriteList.length}");
    } catch (e) {
      notifyListeners();
    }
  }

  addFav(type, context, id) async {
    String apiURL = "";

    if (type == "service") {
      log("providerrrrrrrr");

      apiURL = "${api.favoriteList}?type=$type&serviceId=$id";
    } else {
      apiURL = "${api.favoriteList}?type=$type&providerId=$id";
    }
    await apiServices.postApi(apiURL, {}, isToken: true).then((value) {
      if (value.isSuccess!) {
        getFavourite(context);
        final commonApi =
            Provider.of<CommonApiProvider>(context, listen: false);
        commonApi.getDashboardHome2(context);
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: value.message, backgroundColor: Colors.red);
        log("message is -----------> ${value.message}");
      }
      // hideLoading(context);
      notifyListeners();
    });
  }

  // add to favourite api
  addToFav(context, id, type) async {
    var body = {};
    showLoading(context);
    log("body : $body");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isGuest = preferences.getBool(session.isContinueAsGuest) ?? false;
    if (isGuest) {
      route.pushAndRemoveUntil(context);
    } else {
      try {
        String apiURL = "";
        if (type == "service") {
          apiURL = "${api.favoriteList}?serviceId=$id&type=$type";
        } else {
          apiURL = "${api.favoriteList}?providerId=$id&type=$type";
        }

        showLoading(context);
        notifyListeners();
        await apiServices.postApi(apiURL, {}, isToken: true).then((value) {
          if (value.isSuccess!) {
            getFavourite(context);
            notifyListeners();
          } else {
            Fluttertoast.showToast(msg: value.message);
          }
          hideLoading(context);
          notifyListeners();
        });
      } catch (e) {
        hideLoading(context);
        notifyListeners();
        log("CATCH addToFav: $e");
      }
    }
    hideLoading(context);
    notifyListeners();
  }

  onBack(context, isBack) {
    selectedIndex = 0;
    providerCtrl.text = "";
    serviceCtrl.text = "";
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }

  //remove from favourite api
  // deleteToFav(context, id, type) async {
  //   int index = 0;
  //   showLoading(context);
  //   try {
  //     showLoading(context);
  //     notifyListeners();
  //     if (type == "service") {
  //       serviceFavList.removeWhere(
  //           (element) => element.service?.id.toString() == id.toString());
  //       notifyListeners();
  //       index = favoriteList.indexWhere(
  //           (element) => element.service?.id.toString() == id.toString());
  //     } else {
  //       providerFavList.removeWhere(
  //           (element) => element.providerId.toString() == id.toString());
  //       notifyListeners();
  //       index = favoriteList.reversed.toList().indexWhere(
  //           (element) => element.providerId.toString() == id.toString());
  //     }
  //
  //     notifyListeners();
  //     int favId = favoriteList[index].id!;
  //     log("favId : $favId");
  //     if (type == "service") {
  //       favoriteList.removeWhere(
  //           (element) => element.service?.id.toString() == id.toString());
  //     } else {
  //       favoriteList.removeWhere(
  //           (element) => element.providerId.toString() == id.toString());
  //     }
  //     log("DDD :${"${api.favoriteList}/$favId"}");
  //     await apiServices
  //         .deleteApi("${api.favoriteList}/$favId", {}, isToken: true)
  //         .then((value) {
  //       hideLoading(context);
  //       notifyListeners();
  //       if (value.isSuccess!) {
  //         log("CCCC:::${value.data}");
  //
  //         getFavourite(context);
  //       } else {
  //         snackBarMessengers(context, message: value.message);
  //       }
  //     });
  //   } catch (e) {
  //     getFavourite(context);
  //     hideLoading(context);
  //     notifyListeners();
  //     log("CATCH deleteToFav: $e");
  //   }
  //   hideLoading(context);
  //   notifyListeners();
  // }

  deleteFav(context, {isFavId, id}) async {
    log("CCCC::isFavId:$isFavId");
    notifyListeners();
    await apiServices
        .deleteApi("${api.favoriteList}/$isFavId", {}, isToken: true)
        .then((value) {
      hideLoading(context);
      notifyListeners();
      if (value.isSuccess!) {
        log("CCCC:::${value.data}");
        final commonApi =
            Provider.of<CommonApiProvider>(context, listen: false);
        commonApi.getDashboardHome2(context);
        Fluttertoast.showToast(msg: value.message);
        // final providerDetail =
        // Provider.of<ProviderDetailsProvider>(context, listen: false);
        // providerDetail.getProviderById(context, id);

        // getFavourite(context);
      } else {
        Fluttertoast.showToast(msg: value.message);
      }
    });
  }

  onFeatured(context, services, id) async {
    final providerDetail =
        Provider.of<ProviderDetailsProvider>(context, listen: false);
    providerDetail.selectProviderIndex = 0;
    providerDetail.notifyListeners();
    onBook(context, services!,
            addTap: () => onAdd(id: id),
            minusTap: () => onRemoveService(context, id: id))!
        .then((e) {
      serviceFavList[id].service!.selectedRequiredServiceMan =
          serviceFavList[id].service!.requiredServicemen;
      notifyListeners();
    });
  }

  void onRemoveService(BuildContext context, {required int id}) async {
    // 🔹 Instantly remove the provider from providerFavList
    providerFavList.removeWhere((element) => element.provider?.id == id);

    // 🔹 Instantly remove the service from serviceFavList
    serviceFavList.removeWhere((element) => element.service?.id == id);

    // 🔹 Notify UI about the change
    notifyListeners();

    // 🔹 Continue with your existing serviceman logic
    final serviceItem = serviceFavList[id]?.service;

    if (serviceItem == null) return;

    if (serviceItem.selectedRequiredServiceMan == 1) {
      route.pop(context);
      isAlert = false;
      notifyListeners();
    } else {
      if (serviceItem.requiredServicemen ==
          serviceItem.selectedRequiredServiceMan) {
        isAlert = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);
        isAlert = false;
        notifyListeners();
      } else {
        isAlert = false;
        notifyListeners();
        serviceItem.selectedRequiredServiceMan =
            (serviceItem.selectedRequiredServiceMan! - 1);
      }
    }

    // Final UI update
    notifyListeners();
  }

  onAdd({id}) {
    isAlert = false;
    notifyListeners();
    int count = (serviceFavList[id].service!.selectedRequiredServiceMan!);
    count++;
    serviceFavList[id].service!.selectedRequiredServiceMan = count;
    notifyListeners();
  }
}
