import 'dart:developer';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/current_zone_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../screens/app_pages_screens/current_location_screen/layouts/google.dart';
import 'dart:ui' as ui;

class LocationProvider with ChangeNotifier {
  AnimationController? animationController;
  bool isPositionedRight = false;
  bool isAnimateOver = false, isBottom = true;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;
  PrimaryAddress? address;
  double? newLog, newLat;
  int primaryAddress = 0;
  CameraPosition? cameraPosition;
  Set<Marker> markers = {};
  Position? position1;
  GoogleMapController? mapController;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  List<PrimaryAddress> addressList = [];
  Placemark? place;
  bool isEdit = false, isButtonShow = false;
  int count = 0;
  int? selectedIndex;

  dynamic argumentData;
  List<CountryStateModel> countryStateList = [];
  List<StateModel> stateList = [];
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void disposeController() {
    mapController = null;
    notifyListeners();
  }

  searchLocation(context) {
    route.push(context, const SearchLocation()).then((e) async {
      if (e != null) {
        log("GET :$e");
        position = e;
        notifyListeners();
        getAddressFromLatLng(context);
      }
    });
  }

  void listen() {
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

  void updatePosition(CameraPosition positions) {
    log("POS :$position");
    position = LatLng(positions.target.latitude, positions.target.longitude);
    // / getAddressFromLatLng();
  }

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

  onController(controller) {
    mapController = controller;
    notifyListeners();
  }

  onAnimate(TickerProvider sync) async {
    animationController = AnimationController(
        vsync: sync, duration: const Duration(milliseconds: 1200));
    _runAnimation();
    notifyListeners();
  }

  void _runAnimation() async {
    for (int i = 0; i < 300; i++) {
      await animationController!.forward();
      await animationController!.reverse();
    }
  }

  selectAddress(ind) {
    selectedIndex = ind;
    notifyListeners();
  }

  // created method for getting user current location
  Future getUserCurrentLocation(context, {isRoute = false}) async {
    Geolocator.requestPermission().then((value) async {
      position1 = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));

      position = LatLng(position1!.latitude, position1!.longitude);
      notifyListeners();
      getAddressFromLatLng(context);
      if (isRoute) {
        route.pushNamed(context, routeName.currentLocation);
      }
      log("POS :$position");
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      log("ERROR $error");
    });
  }

  fetchCurrent(context) async {
    newLat = null;
    newLog = null;
    notifyListeners();
    getUserCurrentLocation(context);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getAddressFromLatLng(context) async {
    await placemarkFromCoordinates(
            newLat ?? position!.latitude, newLog ?? position!.longitude)
        .then((List<Placemark> placeMarks) async {
      //  log("placeMarks :$placeMarks");
      place = placeMarks[0];
      markers = {};
      final Uint8List markerIcon =
          await getBytesFromAsset(eImageAssets.pin, 50);
      currentAddress = '${place!.name}';
      street = '${place!.street}';
      // log("currentAddresscurrentAddress:$currentAddress");

      if (place!.name == place!.street) {
        street = '${place!.name}, ${place!.subLocality}, ${place!.postalCode}';
      } else {
        street =
            '${place!.name}, ${place!.street}, ${place!.subLocality}, ${place!.postalCode}';
      }
      markers.add(Marker(
        draggable: true,
        onDrag: (value) {
          mapController!.animateCamera(
              CameraUpdate.newLatLng(LatLng(value.latitude, value.longitude)));
          notifyListeners();
        },
        onDragEnd: (value) {
          newLat = value.latitude;
          newLog = value.longitude;
          position = LatLng(value.latitude, value.longitude);
          if (newLat != null && newLog != null) {
            getAddressFromLatLng(context);
          }
          notifyListeners();
        },
        markerId: MarkerId(
            LatLng(newLat ?? position!.latitude, newLog ?? position!.longitude)
                .toString()),
        position:
            LatLng(newLat ?? position!.latitude, newLog ?? position!.longitude),
        infoWindow: InfoWindow(title: place!.name, snippet: place!.subLocality),
        icon: BitmapDescriptor.bytes(markerIcon),
      ));
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(
            LatLng(position!.latitude, position!.longitude)));
      }
      notifyListeners();
      log("NEW : ${position!.latitude}/ ${position!.longitude}");
    }).catchError((e) {
      debugPrint("ee : $e");
    });
  }

  bool isAddLoading = false;

  Future getLocationList(context) async {
    log("PPPP:$position");
    isAddLoading = true;
    notifyListeners();
    try {
      await apiServices.getApi(api.address, [], isToken: true).then((value) {
        if (value.isSuccess!) {
          List address = value.data['data'];
          addressList = [];
          isAddLoading = false;
          for (var data in address.reversed.toList()) {
            if (!addressList.contains(PrimaryAddress.fromJson(data))) {
              addressList.add(PrimaryAddress.fromJson(data));
            }
            notifyListeners();
          }
          notifyListeners();
        } else {
          isAddLoading = false;
          log("message ==== ${value.message}");
          // Fluttertoast.showToast(
          //     msg: value.message, backgroundColor: appColor(context).red);
        }
      });
      getDefaultAddress(context);
    } catch (e) {
      notifyListeners();
    }
  }

  onBackMap(context) {
    getDefaultAddress(context);
  }

  getDefaultAddress(context) async {
    int index = addressList.indexWhere((element) => element.isPrimary == 1);
    log("index :$index");
    if (index >= 0) {
      primaryAddress = index;
      setPrimaryAddress = index;
      userPrimaryAddress = addressList[primaryAddress];
    } else {
      await getUserCurrentLocation(context);

      // getZoneId();
      primaryAddress = 0;
      setPrimaryAddress = null;
      userPrimaryAddress = null;
      currentAddress = null;
    }

    notifyListeners();
    log("userPrimaryAddress : $userPrimaryAddress");

    if (index >= 0) {
      if (addressList[primaryAddress].latitude != null) {
        position = LatLng(double.parse(addressList[primaryAddress].latitude!),
            double.parse(addressList[primaryAddress].longitude!));
        notifyListeners();
      }
      //getAddressFromLatLng(context);
    } else {}
  }

//zone id

  Future<void> getZoneId(context,
      {String? lat, String? lan, bool isLocation = false}) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle case where location services are disabled
        log("Location services are disabled");
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
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
      }

      // Get position only if we have permission
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      log("position getZoneId:$position");
      log("zone by point =====> ${isLocation == true ? "${api.zoneByPoint}?lat=${lat ?? position.latitude}&lng=${lan ?? position.longitude}" : "${api.zoneByPoint}?lat=${position.latitude}&lng=${position.longitude}"}");
      await apiServices.getApi(
          isLocation == true
              ? "${api.zoneByPoint}?lat=${lat ?? position.latitude}&lng=${lan ?? position.longitude}"
              : "${api.zoneByPoint}?lat=${position.latitude}&lng=${position.longitude}",
          []).then((value) async {
        log("CALUE zone api response:${value.data}");
        if (value.isSuccess!) {
          List o = value.data;
          String idsString = o.map((obj) => obj['id'].toString()).join(',');
          currentZoneModel.clear(); // Clear previous data
          for (var data in value.data) {
            currentZoneModel.add(Datum1.fromJson(data));
          }
          zoneIds = idsString;
          log("string :$idsString");
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString(session.zoneIds, idsString);
          pref.setString(session.zoneIds, idsString);
          final loc = Provider.of<SplashProvider>(context, listen: false);
          loc.loadDashboardApis(context);
          //log("message=-=-=-=-=-=-=-===-=====-=-- IsZone UPDATE DONE ${value.data}");
        }
        notifyListeners();
      });
    } catch (e, s) {
      // log("EEEE getZoneId :: $e====> $s");
      // Consider providing a default zone ID or other fallback here
      notifyListeners();
    }
  }

//   Future<void> getZoneId(
//       {String? lat, String? lan, bool isLocation = false}) async {
//     Position position = await Geolocator.getCurrentPosition(
//         locationSettings:
//             const LocationSettings(accuracy: LocationAccuracy.high));
//     log("position getZoneId:$position");
//     try {
//       await apiServices.getApi(
//           isLocation == true
//               ? "${api.zoneByPoint}?lat=${lat /* position.latitude */}&lng=${lan /* position.longitude */}"
//               : "${api.zoneByPoint}?lat=${position.latitude}&lng=${position.longitude}",
//           []).then((value) async {
//         log("CALUE :${value.data}");
//         if (value.isSuccess!) {
//           List o = value.data;
//           String idsString = o.map((obj) => obj['id'].toString()).join(',');
//           for (var data in value.data) {
//             currentZoneModel.add(Datum1.fromJson(data));
//             notifyListeners();
//           }
//           zoneIds = idsString;
//           log("string :$idsString");
//           SharedPreferences pref = await SharedPreferences.getInstance();
//           pref.setString(session.zoneIds, idsString);
//           log("message=-=-=-=-=-=-=-===-=====-=-- IsZone UPDATE DONE ${value.data}");
//           notifyListeners();
//         }
//         notifyListeners();
//       });
//     } catch (e, s) {
//       log("EEEE getZoneId :: $e====> $s");
//       notifyListeners();
//     }
//   }

  setDefault(context) {
    primaryAddress = selectedIndex!;
    log("primaryAddress :$primaryAddress");
    log("primaryAddress :${addressList[primaryAddress].address}");
    userPrimaryAddress = addressList[primaryAddress];
    street = addressList[primaryAddress].address;
    currentAddress = addressList[primaryAddress].address;
    //log("street :$street");
    setPrimaryAddress = selectedIndex;
    getLocationList(context);
    notifyListeners();
    setAddressPrimary(context, userPrimaryAddress!.id);
    if (addressList[primaryAddress].latitude != null) {
      position = LatLng(double.parse(addressList[primaryAddress].latitude!),
          double.parse(addressList[primaryAddress].longitude!));
    }
    notifyListeners();
    //getAddressFromLatLng();
    route.pop(context);
    getZoneId(context);
  }

  //set primary address
  setAddressPrimary(context, id) async {
    try {
      await apiServices
          .putApi("${api.setAddressPrimary}/$id", [], isToken: true)
          .then((value) {
        log("setAddressPrimary : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {}
      });
    } catch (e) {
      log("CATCH setAddressPrimary: $e");
    }
  }

  // country state list
  Future<void> getCountryState() async {
    countryStateList = [];

    try {
      await apiServices.getApi(api.country, []).then((value) {
        if (value.isSuccess!) {
          List co = value.data;
          // log("COUNRY :${co.length}");
          for (var data in value.data) {
            if (!countryStateList.contains(CountryStateModel.fromJson(data))) {
              countryStateList.add(CountryStateModel.fromJson(data));
            }
            notifyListeners();
          }

          stateList = countryStateList[0].state!;
          // log("stateList:${stateList}");
          notifyListeners();
        }
      });
    } catch (e) {
      log("ERRROEEE getCountryState $e");
      notifyListeners();
    }
  }

  //delete Address
  deleteAddress(context, id, {isBack = false}) async {
    showLoading(context);
    route.pop(context);
    log("ADDRESS ID : ${api.address}/$id");
    try {
      await apiServices
          .deleteApi("${api.address}/$id", {}, isToken: true)
          .then((value) {
        hideLoading(context);
        log("VVVV : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {
          completeSuccess(context, isBack);
          getLocationList(context);
        } else {
          log("message====${value.message}");
          // Fluttertoast.showToast(
          //     msg: value.message, backgroundColor: appColor(context).red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("CATCH deleteAddress: $e");
    }
  }

  deleteAccountConfirmation(context, sync, id, {isBack = false}) {
    animateDesign(sync);
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<LocationProvider>(
                builder: (context3, value, child) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: Insets.i20),
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(SmoothRadius(
                          cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
                  backgroundColor: appColor(context).whiteBg,
                  content: Stack(alignment: Alignment.topRight, children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Gif
                      Stack(alignment: Alignment.topCenter, children: [
                        Stack(alignment: Alignment.topCenter, children: [
                          SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        SizedBox(
                                            height: Sizes.s180,
                                            width: Sizes.s150,
                                            child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                curve: isPositionedRight
                                                    ? Curves.bounceIn
                                                    : Curves.bounceOut,
                                                alignment: isPositionedRight
                                                    ? Alignment.center
                                                    : Alignment.topCenter,
                                                child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    height: 40,
                                                    child: Image.asset(
                                                        eImageAssets
                                                            .locationColor)))),
                                        Image.asset(eImageAssets.dustbin,
                                                height: Sizes.s88,
                                                width: Sizes.s88)
                                            .paddingOnly(bottom: Insets.i24)
                                      ]))
                              .decorated(
                                  color: appColor(context).fieldCardBg,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10)),
                        ]),
                        if (offsetAnimation != null)
                          SlideTransition(
                              position: offsetAnimation!,
                              child: (offsetAnimation != null &&
                                      isAnimateOver == true)
                                  ? Image.asset(eImageAssets.dustbinCover,
                                      height: 38)
                                  : const SizedBox())
                      ]),
                      // Sub text
                      const VSpace(Sizes.s15),
                      Text(
                          language(context,
                              translations!.deleteLocationSuccessfully),
                          textAlign: TextAlign.center,
                          style: appCss.dmDenseRegular14
                              .textColor(appColor(context).lightText)
                              .textHeight(1.2)),
                      const VSpace(Sizes.s20),
                      Row(children: [
                        Expanded(
                            child: ButtonCommon(
                                onTap: () => route.pop(context),
                                title: translations!.no ?? appFonts.no,
                                borderColor: appColor(context).primary,
                                color: appColor(context).whiteBg,
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).primary))),
                        const HSpace(Sizes.s15),
                        Expanded(
                            child: ButtonCommon(
                                title: translations!.yes ?? appFonts.yes,
                                color: appColor(context).primary,
                                onTap: () => deleteAddress(context, id),
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).whiteColor)))
                      ])
                    ]).padding(
                        horizontal: Insets.i20,
                        top: Insets.i60,
                        bottom: Insets.i20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(language(context, translations!.deleteLocation),
                              style: appCss.dmDenseExtraBold18
                                  .textColor(appColor(context).darkText)),
                          Icon(CupertinoIcons.multiply,
                                  size: Sizes.s20,
                                  color: appColor(context).darkText)
                              .inkWell(onTap: () => route.pop(context))
                        ]).paddingAll(Insets.i20)
                  ]));
            });
          });
        }).then((value) {
      isPositionedRight = false;
      isAnimateOver = false;
      notifyListeners();
    });
  }

  animateDesign(TickerProvider sync) {
    Future.delayed(DurationClass.s1).then((value) {
      isPositionedRight = true;
      notifyListeners();
    }).then((value) {
      Future.delayed(DurationClass.ms150).then((value) {
        isAnimateOver = true;
        notifyListeners();
      }).then((value) {
        controller = AnimationController(
            vsync: sync, duration: const Duration(seconds: 2))
          ..forward();
        offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.5), end: const Offset(0, 0.88))
            .animate(
                CurvedAnimation(parent: controller!, curve: Curves.elasticOut));
        notifyListeners();
      });
    });

    notifyListeners();
  }

  onLocationInit(context) async {
    argumentData = null;
    log("CALL :: $count");

    PermissionStatus status = await Permission.locationWhenInUse.status;
    log("Location Permission Status: ${status.isGranted}");

    if (status.isPermanentlyDenied) {
      log("Permission Permanently Denied - Opening App Settings...");
      await openAppSettings();
      return;
    }

    if (status.isDenied) {
      log("Permission Denied - Requesting Again...");
      PermissionStatus requestStatus =
          await Permission.locationWhenInUse.request();

      if (requestStatus.isDenied || requestStatus.isPermanentlyDenied) {
        log("Permission still denied after request.");
        return;
      }
    }

    notifyListeners();

    scrollController.addListener(listen);
    position = null;
    count++;
    notifyListeners();

    argumentData = ModalRoute.of(context)!.settings.arguments;
    currentAddress = "";

    if (argumentData != null) {
      var arg = argumentData['data'];
      isEdit = true;
      address = arg;

      log("LAT : ${address!.latitude}// ${address!.longitude}");

      position = LatLng(
        double.parse(address!.latitude!),
        double.parse(address!.longitude!),
      );

      log("ARGH :$position");
      notifyListeners();

      getAddressFromLatLng(context);
    } else {
      log("ISSSS");
      getUserCurrentLocation(context);
      isEdit = false;
    }

    notifyListeners();
  }

  onReady(context) {
    dynamic arg = ModalRoute.of(context)!.settings.arguments ?? false;
    isButtonShow = arg;
    notifyListeners();
  }

  onBack() {
    // selectedIndex = null;
    notifyListeners();
  }

  completeSuccess(context, isBack) {
    showCupertinoDialog(
        context: context,
        builder: (context1) {
          return AlertDialogCommon(
              title: translations!.successfullyDelete,
              height: Sizes.s140,
              image: eGifAssets.successGif,
              subtext:
                  language(context, translations!.locationDeletedSuccessfully),
              bText1: language(context, translations!.okay),
              b1OnTap: () {
                if (isBack) {
                  route.pop(context);
                  route.pop(context);
                } else {
                  route.pop(context);
                }
              });
        });
  }
}
