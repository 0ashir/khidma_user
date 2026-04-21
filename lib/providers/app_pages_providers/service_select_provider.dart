import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../config.dart';
import '../../utils/date_time_picker.dart';

class ServiceSelectProvider with ChangeNotifier {
  bool isStep2 = false, isPackage = false, isBottom = true;
  dynamic servicesCart;
  PrimaryAddress? address;
  int selectProviderIndex = 0;
  UserModel? userModel;
  final FocusNode noteFocus = FocusNode();
  TextEditingController txtNote = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool isPositionedRight = false;
  bool isAnimateOver = false;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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

  deleteJobRequestConfirmation(context, sync, index) {
    animateDesign(sync);
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<SlotBookingProvider>(
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
                                            height: Sizes.s208,
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
                                                            .removeAddOn)))),
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
                      Text(language(context, translations!.removeAddOnsDes),
                              textAlign: TextAlign.center,
                              style: appCss.dmDenseRegular14
                                  .textColor(appColor(context).lightText)
                                  .textHeight(1.6))
                          .paddingSymmetric(horizontal: Sizes.s56),
                      const VSpace(Sizes.s25),
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
                                color: appColor(context).primary,
                                onTap: () {
                                  servicesCart!.selectedAdditionalServices!
                                      .removeAt(index);
                                  notifyListeners();
                                  route.pop(context);
                                },
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).whiteColor),
                                title: translations!.yes ?? appFonts.yes))
                      ])
                    ]).padding(
                        horizontal: Insets.i20,
                        top: Insets.i60,
                        bottom: Insets.i20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(language(context, translations!.removeAddOns),
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
                begin: const Offset(0, 0.5), end: const Offset(0, 1.6))
            .animate(
                CurvedAnimation(parent: controller!, curve: Curves.elasticOut));
        notifyListeners();
      });
    });

    notifyListeners();
  }

  addToCart(context) async {
    debugPrint(":::;Serr :${servicesCart!.selectedServiceMan}");
    servicesCart!.primaryAddress = address;

    // Retrieve SlotBookingProvider to get scheduled data
    final slotBooking =
        Provider.of<SlotBookingProvider>(context, listen: false);

    // Populate schedule booking data if it's a scheduled service
    if ((servicesCart?.type == 'scheduled' ||
            servicesCart?.type == 'schedule') &&
        slotBooking.selectedDateList.isNotEmpty) {
      servicesCart?.isScheduledBooking = 1;
      servicesCart?.scheduleStartDate = slotBooking.rangeStart;
      servicesCart?.scheduleEndDate = slotBooking.rangeEnd;

      // Calculate time string safely
      String timeStr = "";
      if (slotBooking.scrollHourIndex < appArray.hourList.length &&
          slotBooking.scrollMinIndex < appArray.minList.length) {
        timeStr =
            "${appArray.hourList[slotBooking.scrollHourIndex]}:${appArray.minList[slotBooking.scrollMinIndex]} ${appArray.amPmList[slotBooking.amIndex ?? 0]}";
      }
      servicesCart?.scheduleTime = timeStr;

      servicesCart?.bookingFrequency = slotBooking.bookingFrequency;
      servicesCart?.scheduledDatesJson =
          List<DateTime>.from(slotBooking.selectedDateList);
      servicesCart?.scheduledServicesCount =
          slotBooking.selectedDateList.length;
      if (slotBooking.bookingFrequency == 'daily') {
        servicesCart?.selectedWeekdays =
            List<String>.from(slotBooking.newWeekDayList);
      }
    }

    notifyListeners();
    final cartCtrl = Provider.of<CartProvider>(context, listen: false);

    int index = cartCtrl.cartList.indexWhere((element) =>
        element.isPackage == false &&
        element.serviceList != null &&
        element.serviceList!.id == servicesCart!.id);
    log("ADDD :${servicesCart!.primaryAddress}");
    if (index >= 0) {
      cartCtrl.cartList[index].serviceList!.selectedAdditionalServices =
          List.from(servicesCart!.selectedAdditionalServices ?? []);
    } else {
      CartModel cartModel =
          CartModel(isPackage: false, serviceList: servicesCart);
      cartCtrl.cartList.add(cartModel);
    }
    log("CART: ${cartCtrl.cartList}");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(session.cart);
    List<String> personsEncoded =
        cartCtrl.cartList.map((person) => jsonEncode(person.toJson())).toList();
    await preferences.setString(session.cart, json.encode(personsEncoded));

    cartCtrl.notifyListeners();
    cartCtrl.checkout(context);
    isStep2 = false;
    notifyListeners();
    route.pushNamed(context, routeName.cartScreen);
  }

  Future<bool> onBack(BuildContext context) async {
    if (isStep2) {
      isStep2 = false;
      notifyListeners();
      return false; // prevent popping, just go back to step 1
    } else {
      isStep2 = false;

      txtNote.text = "";
      if (servicesCart != null) {
        // servicesCart!.serviceDate = null;
        // servicesCart!.selectDateTimeOption = null;

        if (isPackage) {
          final packageCtrl =
              Provider.of<SelectServicemanProvider>(context, listen: false);
          servicePackageList[selectProviderIndex].serviceDate = null;
          servicePackageList[selectProviderIndex].selectDateTimeOption = null;
        }
      }

      notifyListeners();
      return true; // allow popping the page
    }
  }

  bool isLoading = false;

  Future<void> onNext(BuildContext context) async {
    if (servicesCart!.selectedRequiredServiceMan == null) {
      Fluttertoast.showToast(
          msg: "Please select Any 1 serviceman",
          backgroundColor: appColor(context).red);
      return;
    }
    isLoading = true;
    notifyListeners();

    if ((servicesCart!.selectedRequiredServiceMan!) ==
        (servicesCart!.selectedServiceMan != null
            ? servicesCart!.selectedServiceMan!.length
            : 1)) {
      final sloatBooking =
          Provider.of<SlotBookingProvider>(context, listen: false);
      /*  sloatBooking.  */

      log("message-=-=-=-=-=1212${servicesCart.selectedAdditionalServices /* ?.map((service) => {
            "id": service.id,
            "qty": service.qty,
          }).toList() */
          }");

      await sloatBooking.callBookingApi(
        servicesCart.id,
        servicesCart.requiredServicemen,
        servicesCart.selectedAdditionalServices
            ?.map((service) => {
                  "id": service.id,
                  "qty": service.qty,
                })
            .toList(),
      );

      servicesCart!.selectServiceManType = "as_per_my_choice";
      log("messageopopopopopopopopopopopop${servicesCart!.selectServiceManType}");

      // Sync serviceDate for scheduled bookings if needed
      if ((servicesCart!.type == 'scheduled' ||
              servicesCart!.type == 'schedule') &&
          servicesCart!.serviceDate == null &&
          sloatBooking.rangeStart != null) {
        servicesCart!.serviceDate = sloatBooking.rangeStart;
      }

      if (address != null ||
          servicesCart!.type == 'scheduled' ||
          servicesCart!.type == 'schedule') {
        if (servicesCart!.serviceDate != null ||
            servicesCart!.type == 'scheduled' ||
            servicesCart!.type == 'schedule') {
          if (servicesCart!.selectedServiceMan != null &&
              servicesCart!.selectedServiceMan!.isNotEmpty) {
            log("message-=-=-=");
            if (isPackage) {
              isStep2 = false;
              servicePackageList[selectProviderIndex] = servicesCart!;
              isLoading = false;
              notifyListeners();
              route.pop(context, arg: servicesCart);
              return;
            } else {
              await Provider.of<CommonApiProvider>(context, listen: false)
                  .selfApi(context)
                  .then((value) {
                isStep2 = true;
              });
            }
          } else {
            // If scheduled, proceed even if servicemen not selected?
            // User said "navigate".
            if ((servicesCart!.type == 'scheduled' ||
                servicesCart!.type == 'schedule') && servicesCart!.selectServiceManType == 'app_choose') {
              await Provider.of<CommonApiProvider>(context, listen: false)
                  .selfApi(context)
                  .then((value) {
                isStep2 = true;
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Please select Any 1 serviceman",
                  backgroundColor: appColor(context).red);
            }
          }
        } else {
          Fluttertoast.showToast(
              msg: "Please select Date/Time slot",
              backgroundColor: appColor(context).red);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Please select Location",
            backgroundColor: appColor(context).red);
      }
    } else {
      // Check validation for servicemen count
      if (servicesCart!.type == 'scheduled' ||
          servicesCart!.type == 'schedule') {
        // Bypass strict servicemen count check for scheduled
        await Provider.of<SlotBookingProvider>(context, listen: false)
            .callBookingApi(
          servicesCart.id,
          servicesCart.requiredServicemen,
          servicesCart.selectedAdditionalServices
              ?.map((service) => {
                    "id": service.id,
                    "qty": service.qty,
                  })
              .toList(),
        );

        servicesCart!.selectServiceManType = "as_per_my_choice";

        // Logic repetition for successful navigation
        await Provider.of<CommonApiProvider>(context, listen: false)
            .selfApi(context)
            .then((value) {
          isStep2 = true;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Please select required number of servicemen",
            backgroundColor: appColor(context).red);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  onInit(context) async {
    showLoading(context);

    scrollController.addListener(listen);
    isStep2 = false;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    notifyListeners();
    /*  dynamic data = ModalRoute.of(context)!.settings.arguments;
    servicesCart = data['selectServicesCart'];
    servicesCart!.selectedRequiredServiceMan =
        servicesCart!.requiredServicemen ?? "1";
    isPackage = data['isPackage'] ?? false;
    selectProviderIndex = data['selectProviderIndex'] ?? 0;*/
    dynamic data = ModalRoute.of(context)!.settings.arguments;

    servicesCart = data['selectServicesCart'];
    log("data : $servicesCart");
    servicesCart!.selectedRequiredServiceMan =
        servicesCart!.selectedRequiredServiceMan ?? 1;
    isPackage = data['isPackage'] ?? false;
    selectProviderIndex = data['selectProviderIndex'] ?? 0;
    log("Dsdgfh :$servicesCart");
    notifyListeners();
    final locationCtrl = Provider.of<LocationProvider>(context, listen: false);
    if (locationCtrl.addressList.isNotEmpty) {
      int index = locationCtrl.addressList
          .indexWhere((element) => element.isPrimary == 1);
      if (index > 0) {
        address = locationCtrl.addressList[index];
      } else {
        address = locationCtrl.addressList[0];
      }
    }

    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      servicePackageList[selectProviderIndex].primaryAddress = address;
      packageCtrl.notifyListeners();
    } else {
      servicesCart!.primaryAddress = address;
    }
    log("CHECK : #$isPackage");
    hideLoading(context);

    final slotBooking =
        Provider.of<SlotBookingProvider>(context, listen: false);
    slotBooking.initBookingFrequency();

    userModel =
        UserModel.fromJson(json.decode(preferences.getString(session.user)!));
    notifyListeners();
  }

  onChangeLocation(context, PrimaryAddress primaryAddress) {
    address = primaryAddress;
    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      servicePackageList[selectProviderIndex].primaryAddress = address;
      packageCtrl.notifyListeners();
    } else {
      servicesCart!.primaryAddress = address;
    }
    notifyListeners();
  }

  Future<bool> checkSlotAvailable(context, id, indexKey) async {
    bool isValid = false;
    if (servicesCart!.serviceDate != null) {
      try {
        final utcDate = servicesCart!.serviceDate!.toUtc();
        var data = {
          "provider_id": userModel!.id,
          "dateTime":
              "${DateFormat("dd-MMM-yyy,hh:mm").format(utcDate)} ${DateFormat("aa").format(utcDate).toLowerCase()}"
        };

        log("data : $data");
        await apiServices
            .getApi(api.isValidTimeSlot, data, isData: true, isToken: true)
            .then((value) async {
          if (value.isSuccess!) {
            log("DDAA `:${value.data}");
            if (value.data['isValidTimeSlot'] == true) {
              isValid = true;
              return true;
            }
            notifyListeners();
          } else {
            isValid = false;
            notifyListeners();
            Fluttertoast.showToast(msg: value.message);
            return false;
          }
        });
      } catch (e) {
        isValid = false;
        notifyListeners();
        return false;
      }
    } else {
      isValid = false;
      notifyListeners();
      Fluttertoast.showToast(
          msg: "Please Select Date and Time", backgroundColor: Colors.red);
      return false;
    }
    return isValid;
  }

  onTapDate(context) {
    debugPrint("servicesCart :${servicesCart!.selectServiceManType}");
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context3) {
          return DateTimePicker(
            isService: isPackage,
            service: servicesCart,
            selectProviderIndex: selectProviderIndex,
          );
        }).then((value) {
      if (value != null) {
        log("SSSS:$value");
        if (isPackage) {
          final packageCtrl =
              Provider.of<SelectServicemanProvider>(context, listen: false);
          // log("value::${value['date']}");
          notifyListeners();
          // Assuming value contains date and format; update only relevant fields
          servicesCart!.serviceDate = value.date as DateTime?;
          servicesCart!.selectedDateTimeFormat = value['format'] as String?;
          servicesCart!.selectDateTimeOption = "custom";
          servicePackageList[selectProviderIndex] = servicesCart!;
          notifyListeners();
          packageCtrl.notifyListeners();
        } else {
          notifyListeners();
          servicesCart!.serviceDate = value['date'] as DateTime?;
          servicesCart!.selectedDateTimeFormat = value['format'] as String?;
          servicesCart!.selectDateTimeOption = "custom";
          servicePackageList[selectProviderIndex] = servicesCart!;
          notifyListeners();
        }
      }
    });
  }

 

  String buttonName(context) {
    String name = translations!.next ?? appFonts.next;
    log("isPackage ::$isPackage");
    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      if (servicePackageList.length == 1) {
        name = translations!.submit ?? appFonts.submit;
        return name;
      } else {
        log("IMDD:${selectProviderIndex + 1} //$selectProviderIndex");
        if (selectProviderIndex + 1 < servicePackageList.length) {
          name = translations!.submit ?? appFonts.submit;
        } else {
          name = translations!.next ?? appFonts.next;
        }

        return name;
      }
    } else {
      return translations!.next ?? appFonts.next;
    }
  }
}
