import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../helper/notification.dart';
import '../../models/status_booking_model.dart';
import '../../screens/app_pages_screens/app_details_screen/layouts/page_detail.dart';

class OngoingBookingProvider with ChangeNotifier {
  BookingModel? booking;
  TextEditingController onHoldCtrl = TextEditingController();
  final FocusNode reasonFocus = FocusNode();
  List<StatusBookingModel> bookingList = [];
  ScrollController scrollController = ScrollController();

  bool animate1 = false,
      animate2 = false,
      animate3 = false,
      isPayButton = false,
      isBottom = true;

  onBack(context, isBack) {
    isPayButton = false;
    // booking = null;
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }

  onStart(context) {
    showDialog(
        context: context,
        builder: (context1) {
          return AlertDialogCommon(
              title: translations!.startService,
              image: eGifAssets.restart,
              subtext: translations!.areYouSureBeing,
              bText1: translations!.startService,
              height: Sizes.s145,
              isBooked: true,
              widget: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        eImageAssets.restartBg,
                        width: Sizes.s150,
                      )),
                  Image.asset(
                    eGifAssets.restart,
                    height: Sizes.s137,
                  ),
                ],
              ).height(Sizes.s150).paddingOnly(bottom: Insets.i20).decorated(
                  color: appColor(context).fieldCardBg,
                  borderRadius: BorderRadius.circular(AppRadius.r10)),
              b1OnTap: () {
                route.pop(context);
             /*   if (booking!.service!.type == "remotely") {
                  chatAndUpdateStatus(context);
                } else {*/
                  updateStatus(context, appFonts.onGoing);
                  getBookingDetailBy(context);
                // }
              });
        });
  }

  chatAndUpdateStatus(context) {
    // updateStatus(context);
    route.pushNamed(context, routeName.chatScreen, arg: {
      "image": booking!.servicemen![0].media != null &&
              booking!.servicemen![0].media!.isNotEmpty
          ? booking!.servicemen![0].media![0].originalUrl!
          : "",
      "name": booking!.servicemen![0].name,
      "role": "serviceman",
      "userId": booking!.servicemen![0].id,
      "token": booking!.servicemen![0].fcmToken,
      "phone": booking!.servicemen![0].phone,
      "code": booking!.servicemen![0].code,
      "bookingId": booking!.id
    }).then((e) {
      route.pop(context);
      route.pop(context);
    });
  }

  onPauseConfirmation(context, {isHold = true}) {
    showDialog(
        context: context,
        builder: (context1) {
          return AlertDialogCommon(
              title: isHold
                  ? translations!.holdService
                  : translations!.restartService,
              image: isHold ? eImageAssets.hold : eImageAssets.complete1,
              subtext: isHold
                  ? translations!.areYouSureHold
                  : translations!.areYouSureRestart,
              isBooked: true,
              bText1: isHold
                  ? translations!.pauseService
                  : translations!.restartService,
              height: Sizes.s145,
              widget: isHold
                  ? Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(eImageAssets.holdCloud,
                                              width: Sizes.s60),
                                          Image.asset(eGifAssets.hold,
                                              height: Sizes.s125,
                                              width: Sizes.s125),
                                        ])),
                                Align(
                                    alignment: Alignment.topRight,
                                    child: Image.asset(eImageAssets.hold,
                                            height: Sizes.s34,
                                            width: Sizes.s62,
                                            fit: BoxFit.fill)
                                        .paddingOnly(top: 20))
                              ]).width(Sizes.s223)
                            ],
                          ))
                      .paddingSymmetric(vertical: Insets.i20)
                      .decorated(
                          color: appColor(context).fieldCardBg,
                          borderRadius: BorderRadius.circular(AppRadius.r10))
                  : Stack(alignment: Alignment.bottomCenter, children: [
                      Image.asset(eGifAssets.restart, height: Sizes.s130)
                          .paddingOnly(top: Insets.i10),
                      ClipRRect(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 12, cornerSmoothing: 1),
                          child: Image.asset(eImageAssets.restartCloud))
                    ]).decorated(
                      color: appColor(context).fieldCardBg,
                      borderRadius: BorderRadius.circular(AppRadius.r10)),
              b1OnTap: () {
                route.pop(context);
                if (isHold) {
                  onPauseBooking(context);
                } else {
                  updateStatus(context, appFonts.startAgain);
                  getBookingDetailBy(context, id: "${booking!.id}");
                }
              });
        });
  }

  bool isLoading = false;

  onReady(BuildContext context) async {
    scrollController.addListener(listen);
    notifyListeners();
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      if (arg['bookingId'] != null) {
        // Case 1: Fetch data from API using bookingId
        await getBookingDetailBy(context, id: arg['bookingId']);
      } else if (arg["booking"] != null) {
        // Case 2: Use passed BookingModel without API call
        booking = arg["booking"] as BookingModel;
        log("Using passed booking: id=${booking!.id}, serviceTitle=${booking!.service?.title}, media=${booking!.service?.media?.map((m) => m.originalUrl).toList()}");
        isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      } else {
        log("No bookingId or booking provided in arguments");
        Fluttertoast.showToast(msg: "Invalid booking data");
        isLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    } catch (e) {
      log("Error in onReady: $e");
      Fluttertoast.showToast(msg: "Error loading booking details");
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  /* onReady(context) {
    scrollController.addListener(listen);
    notifyListeners();
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    if (arg['bookingId'] != null) {
      getBookingDetailBy(context, id: arg['bookingId']);
    } else {
      booking = arg['booking'];
      notifyListeners();
      getBookingDetailBy(context);
    }
  }*/

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void listen() {
    if (scrollController.position.pixels >= 200) {
      hide();
      notifyListeners();
    } else {
      show();
      notifyListeners();
    }
  }

  void show() {
    if (!isBottom) {
      isBottom = true;
      notifyListeners();
    }
    notifyListeners();
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      notifyListeners();
    }
    notifyListeners();
  }

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getBookingDetailBy(context);
    // hideLoading(context);
    notifyListeners();
  }

  //booking detail by id
  getBookingDetailBy(context, {id}) async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.booking}/${id ?? booking!.id}", [],
              isToken: true, isData: true)
          .then((value) {
        // hideLoading(context);
        if (value.isSuccess!) {
          createBookingNotification(NotificationType.updateBookingStatusEvent);
          isLoading = false;
          debugPrint("BOOKING DATA : ${value.data['data']}");
          booking = BookingModel.fromJson(value.data["data"]);
          notifyListeners();
        } else {
          isLoading = false;
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: Colors.red);
        }
      });
      log("STATYS L $booking");
    } catch (e) {
      hideLoading(context);
      notifyListeners();
    }
  }

  doneButtonTap(context, status, {isCancel = false, sync}) {
    route.pop(context);
    log("isPaymentComplete(booking!):${isPaymentComplete(booking!)}");
    if (isPaymentComplete(booking!)) {
      isPayButton = true;
    } else {
      isPayButton = false;
      onRefresh(context);
    }

    if (isPayButton == false) {
      updateStatus(context, translations!.completed);
      // Provider.of<DashboardProvider>(context, listen: false)
      //     .getBookingHistory(context);
      // getBookingDetailBy(context);
      onRefresh(context);
    }
    notifyListeners();
  }

/*  paySuccess(context) {
    route.pushNamed(context, routeName.paymentScreen,
        arg: {'bookingId': booking!.id}).then((e) async {
      log("PAYME :$e");
      if (e != null) {
        if (e['isVerify'] == true) {
          await getVerifyPayment(e['data'], context);
        }
      }
    });
  }*/

  //booking payment

  bool isBooking = false;

  bookingPayment(context, isCash) async {
    isBooking = true;
    showLoading(context);
    notifyListeners();
    log("bookingId :${booking!.extraCharges}");
    try {
      var body = {
        "booking_id": booking!.id,
        "payment_method": booking!.paymentMethod,
        "currency_code": currency(context).currency!.code,
        "type": booking!.extraCharges == null || booking!.extraCharges!.isEmpty
            ? "booking"
            : "extra_charge"
      };

      log("checkoutBody: $body");
      await apiServices
          .postApi(api.extraPaymentCharge, body, isData: true, isToken: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();

        if (value.isSuccess!) {
          isBooking = false;
          if (isCash) {
            route.pop(context);
            log("=============>>>>>>>>>>${translations!.completed}");
            updateStatus(context, translations!.completed);
            Provider.of<DashboardProvider>(context, listen: false)
                .getBookingHistory(context);
          } else {
            isBooking = false;
            route
                .pushNamed(context, routeName.checkoutWebView, arg: value.data)
                .then((e) async {
              log("SSS :$e");
              if (e != null) {
                log("value.data[sss :${value.data}");
                if (e['isVerify'] == true) {
                  log("value.data[sdsafdsfs :${value.data}");
                  log("value.data[ :${value.data}");
                  await getVerifyPayment(value.data['item_id'], context);
                } else {
                  log("value.data[sss :${value.data}");
                  Fluttertoast.showToast(
                      msg: "Payment Failed",
                      backgroundColor: appColor(context).red);
                }
              } else {
                log("value.data[sss :${value.data}");
                Fluttertoast.showToast(
                    msg: "Payment Failed",
                    backgroundColor: appColor(context).red);
              }
            });
          }
          notifyListeners();
        } else {
          isBooking = false;
          Fluttertoast.showToast(msg: value.message);
        }
      });
    } catch (e) {
      isBooking = false;
      hideLoading(context);
      Fluttertoast.showToast(msg: e.toString());
      notifyListeners();
    }
  }

//verify payment
  getVerifyPayment(data, context) async {
    try {
      await apiServices
          .getApi(
              "${api.verifyPayment}?item_id=$data&type=${booking!.extraCharges == null || booking!.extraCharges!.isEmpty ? "booking" : "extra_charge"}",
              [],
              isToken: true,
              isData: true)
          .then((value) {
        if (value.isSuccess!) {
          if (value.data["payment_status"].toString().toLowerCase() ==
              "pending") {
            log("EEEE xfgxdvgxdvsdd :${value.message}");
            Fluttertoast.showToast(
                msg: translations!.yourPaymentIsDeclined ??
                    appFonts.yourPaymentIsDeclined,
                backgroundColor: Colors.red);
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content:
            //       Text(language(context, translations!.yourPaymentIsDeclined)),
            //   backgroundColor: appColor(context).red,
            // ));
          } else {
            log("EEEE xfgsdd :${value.message}");
            Fluttertoast.showToast(
                msg: translations!.successfullyComplete ??
                    appFonts.successfullyComplete,
                backgroundColor: appColor(context).primary);
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content:
            //       Text(language(context, translations!.successfullyComplete)),
            //   backgroundColor: appColor(context).primary,
            // ));
            updateStatus(context, translations!.completed);
            Provider.of<DashboardProvider>(context, listen: false)
                .getBookingHistory(context);
            getBookingDetailBy(context);
          }
        } else {
          log("EEEE xfg :${value.message}");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: Colors.red);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(language(context, value.message)),
          //   backgroundColor: appColor(context).red,
          // ));
        }
      });
    } catch (e) {
      log("xfgjkhdfg :$e");
      notifyListeners();
    }
  }

  //update status
  bool isUpdateStatus = false;

  updateStatus(context, status, {isCancel = false, sync}) async {
    isUpdateStatus = true;
    log("NOCHANGE");
    try {
      showLoading(context);

      notifyListeners();
      dynamic data;
      if (isCancel) {
        route.pop(context);
        data = {"reason": onHoldCtrl.text, "booking_status": status};
      } else {
        data = {"booking_status": status};
      }
      log("DATA For Completed :$data");
      log("ON L${api.booking}/${booking!.id}");
      await apiServices
          .putApi("${api.booking}/${booking!.id}", data,
              isToken: true, isData: true)
          .then((value) {
        // hideLoading(context);
        notifyListeners();
        onHoldCtrl.text = "";
        if (value.isSuccess!) {
          createBookingNotification(NotificationType.updateBookingStatusEvent);
          isUpdateStatus = false;
          debugPrint("STATYS YYYY:  ${booking!.id}");
          booking = BookingModel.fromJson(value.data);
          getBookingDetailBy(context, id: booking!.id);
          Provider.of<DashboardProvider>(context, listen: false)
              .getBookingHistory(context);
          notifyListeners();
          if (status == "completed") {
            completeSuccess(
              context,
            );
          }
        } else {
          isUpdateStatus = false;
          log("SSS :${value.data} // ${value.message}");
          notifyListeners();
        }
      });
      // hideLoading(context);
      notifyListeners();
    } catch (e, s) {
      isUpdateStatus = false;
      log("SSS :$e===>$s");
      // hideLoading(context);
      notifyListeners();
    }
  }

  paySuccess(context) {
    if (booking!.paymentMethod == "cash") {
      bookingPayment(context, true);
    } else if (booking!.paymentMethod == "wallet") {
      bookingPayment(context, true);
    } else {
      bookingPayment(context, false);
    }
  }

  onPauseBooking(context) {
    final appDetails = Provider.of<AppDetailsProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (context1) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(horizontal: Insets.i20),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.r14))),
            backgroundColor: appColor(context).whiteBg,
            content: Stack(alignment: Alignment.topRight, children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language(context, translations!.reason),
                        style: appCss.dmDenseMedium14
                            .textColor(appColor(context).darkText)),
                    const VSpace(Sizes.s8),
                    TextFieldCommon(
                        controller: onHoldCtrl,
                        focusNode: reasonFocus,
                        isNumber: true,
                        hintText: translations!.writeHere ?? appFonts.writeHere,
                        maxLines: 4,
                        minLines: 4,
                        fillColor: appColor(context).fieldCardBg),
                    // Sub text
                    const VSpace(Sizes.s15),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language(context, "\u2022"),
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).lightText)),
                          const HSpace(Sizes.s10),
                          Expanded(
                              child: RichText(
                                  text: TextSpan(
                                      style: appCss.dmDenseMedium14.textColor(
                                          appColor(context).lightText),
                                      text: language(
                                          context, translations!.pleaseReadThe),
                                      children: [
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        appDetails.pageList
                                            .asMap()
                                            .entries
                                            .map((e) {
                                          e.value.title ==
                                                  language(
                                                      context,
                                                      translations!
                                                          .cancellationPolicy)
                                              ? route.push(
                                                  context,
                                                  PageDetail(
                                                    page: e.value,
                                                  ))
                                              : null;
                                        });
                                      },
                                    style: TextStyle(
                                        color: appColor(context).darkText,
                                        fontFamily:
                                            GoogleFonts.dmSans().fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline),
                                    text: language(context,
                                        translations!.cancellationPolicy)),
                                TextSpan(
                                    style: appCss.dmDenseMedium14
                                        .textColor(appColor(context).lightText),
                                    text: language(context,
                                        translations!.beforeCancelling))
                              ])))
                        ]),
                    const VSpace(Sizes.s20),
                    ButtonCommon(
                      onTap: () {
                        if (onHoldCtrl.text.isNotEmpty) {
                          log("OOOO :${appFonts.onHold}");
                          updateStatus(context, appFonts.onHold,
                              isCancel: true);
                          getBookingDetailBy(context, id: "${booking!.id}");
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please Enter reason",
                              backgroundColor: Colors.red);
                        }
                      },
                      title: translations!.submit ?? appFonts.submit,
                    )
                  ]).padding(
                  horizontal: Insets.i20, top: Insets.i60, bottom: Insets.i20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // Title
                Text(language(context, translations!.reasonOfHold),
                    style: appCss.dmDenseExtraBold16
                        .textColor(appColor(context).darkText)),
                Icon(CupertinoIcons.multiply,
                        size: Sizes.s20, color: appColor(context).darkText)
                    .inkWell(onTap: () => route.pop(context))
              ]).paddingAll(Insets.i20)
            ])));
  }

  completeSuccess(context) {
    showCupertinoDialog(
      context: context,
      builder: (context1) {
        return AlertDialogCommon(
          title: translations!.successfullyComplete,
          height: Sizes.s140,
          image: eGifAssets.successGif,
          subtext: language(context, translations!.areYouSureComplete),
          bText1: language(context, translations!.viewBillDetails),
          b1OnTap: () {
            route.pushNamed(context, routeName.completedServiceScreen,
                arg: {"bookingId": booking!.id}).then((e) {
              route.pushNamedAndRemoveUntil(context, routeName.dashboard);
              final dash =
                  Provider.of<DashboardProvider>(context, listen: false);
              dash.selectIndex = 1;
              dash.getBookingHistory(context);
              dash.notifyListeners();
            });
          },
        );
      },
    );
  }

  //complete done confirmation
  completeConfirmation(context, sync) {
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<OngoingBookingProvider>(
                builder: (context3, value, child) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: Insets.i20),
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppRadius.r14))),
                  backgroundColor: appColor(context).whiteBg,
                  content: Stack(alignment: Alignment.topRight, children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Gif
                      Stack(alignment: Alignment.topCenter, children: [
                        Stack(alignment: Alignment.topCenter, children: [
                          SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(children: [
                                    Stack(children: [
                                      Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                              eImageAssets.completeBookingGirl,
                                              height: Sizes.s150)),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Image.asset(
                                            eGifAssets.completeBooking,
                                            height: Sizes.s55,
                                          ).paddingOnly(top: Insets.i10))
                                    ]).width(Sizes.s160)
                                  ]))
                              .paddingSymmetric(vertical: Insets.i5)
                              .decorated(
                                  color: appColor(context).fieldCardBg,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10))
                        ])
                      ]),
                      // Sub text
                      const VSpace(Sizes.s15),
                      Text(language(context, translations!.areYouSureComplete),
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
                          color: appColor(context).primary,
                          fontColor: appColor(context).whiteColor,
                          onTap: () =>
                              doneButtonTap(context, "completed", sync: this),
                          title: translations!.yes ?? appFonts.yes,
                        ))
                      ])
                    ]).padding(
                        horizontal: Insets.i20,
                        top: Insets.i60,
                        bottom: Insets.i20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(language(context, translations!.completeService),
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
      notifyListeners();
    }).then((value) {
      log("SSSS555");
      animate1 = false;
      animate2 = false;
      animate3 = false;
      notifyListeners();
    });
  }
}
