import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:fixit_user/widgets/alert_message_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config.dart';
import '../../helper/notification.dart';
import '../../models/app_setting_model.dart';
import '../../screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';

class PaymentProvider with ChangeNotifier {
  int? selectIndex, bookingId = 0;
  UserModel? userModel;
  String? method;
  BookingModel? booking;
  SharedPreferences? preferences;
  dynamic checkoutBody;
  double wallet = 0.0;
  CheckoutModel? checkoutModel;
  List<Services> services = [];
  List<ServicePackageModel> servicePackage = [];
  String? itemId;
  List<PaymentMethods> paymentList = [];
  bool isWallet = false,
      isBottom = true,
      isRePayment = false,
      isServiceOnline = false,
      isPackageOnline = false;
  ScrollController scrollController = ScrollController();

  getUserDetail(context) async {
    scrollController.addListener(listen);
    final common = Provider.of<CommonApiProvider>(context, listen: false);
    await common.getPaymentMethodList(context);
    paymentList = [];

    for (var d in paymentMethods) {
      if (d.slug == "cash") {
        log("appSettingModel!.activation!.cash :${appSettingModel!.activation!.cash}");

        if (appSettingModel!.activation!.cash == "1") {
          paymentList.add(d);
        }
      } else {
        paymentList.add(d);
      }
    }
    notifyListeners();
    preferences = await SharedPreferences.getInstance();
    //Map user = json.decode(preferences!.getString(session.user)!);
    userModel =
        UserModel.fromJson(json.decode(preferences!.getString(session.user)!));
    wallet = userModel!.wallet != null ? userModel!.wallet!.balance : 0.0;

    dynamic data = ModalRoute.of(context)!.settings.arguments;

    bookingId = data['bookingId'] ?? 0;

    if (bookingId == 0) {
      checkoutBody = data["checkoutBody"];
      checkoutModel = data["checkoutModel"];
      final cart = Provider.of<CartProvider>(context, listen: false);

      for (var a in cart.cartList) {
        if (!a.isPackage!) {
          log("a.serviceList!.type:${a.serviceList!.type}");
          if (a.serviceList?.type!.contains("remotely")) {
            isServiceOnline = true;
            notifyListeners();
          }
        } else {
          List<Services> ser = a.servicePackageList!.services!;
          isPackageOnline =
              ser.where((element) => element.type == "remotely").isNotEmpty;
        }
      }
      if (isServiceOnline ||
          isPackageOnline ||
          (checkoutModel != null && checkoutModel!.isAdvancePayment == true)) {
        paymentList.removeWhere(
          (element) => element.slug == "cash",
        );
        notifyListeners();
      }
    } else {
      getBookingDetailBy(context);
    }

    if (paymentList.isNotEmpty) {
      method = paymentList[0].slug;
    } else {
      final common = Provider.of<CommonApiProvider>(context, listen: false);
      await common.getPaymentMethodList(context);
      await Future.delayed(Durations.short3);
      paymentList =
          paymentMethods.where((element) => element.status == true).toList();
      method = paymentList.isNotEmpty ? paymentList[0].slug : null;
    }
    notifyListeners();
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

  onSelectPaymentMethod(index, data) {
    selectIndex = index;
    isWallet = false;
    method = data;
    log("selectIndex :$method");
    notifyListeners();
  }

  bool isLoading = false;

  void onContinue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context1) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context2, setState) {
            return AlertDialogCommon(
              isBooked: true,
              title: translations!.successfullyBooked,
              widget: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Image.asset(eImageAssets.booked, height: Sizes.s145),
                    SizedBox(
                      height: Sizes.s34,
                      width: Sizes.s34,
                      child: Image.asset(
                        eGifAssets.tick,
                        height: Sizes.s34,
                        width: Sizes.s34,
                      ),
                    ).paddingOnly(left: Insets.i13, top: Insets.i25),
                  ],
                ),
              ).paddingSymmetric(vertical: Insets.i20).decorated(
                    color: appColor(context).fieldCardBg,
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                  ),
              subtext: translations!.yourBookingHasBeen,
              bText1: translations!.goToBookingList,
              height: Sizes.s145,
              isLoading: isLoading,
              b1OnTap: () async {
                setState(() => isLoading = true);

                method = paymentMethods[0].slug;

                final dash =
                    Provider.of<DashboardProvider>(context, listen: false);
                final common =
                    Provider.of<CommonApiProvider>(context, listen: false);
                final wallet =
                    Provider.of<WalletProvider>(context, listen: false);
                final cartCtrl =
                    Provider.of<CartProvider>(context, listen: false);
                final serviceCtrl = Provider.of<ServicesDetailsProvider>(
                    context,
                    listen: false);

                await common.selfApi(context);
                await wallet.getWalletList(context);
                await dash.getBookingHistory(context);

                dash.selectIndex = 1;
                dash.notifyListeners();
// Clear selected additional services
                serviceCtrl.clearAdditionalServices();
                cartCtrl.checkoutModel = null;
                cartCtrl.isPayment = true;
                cartCtrl.cartList = [];
                isWallet = false;
                selectIndex = 0;
                method = null;

                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.remove(session.cart);

                notifyListeners();
                cartCtrl.notifyListeners();

                setState(() => isLoading = false);

                // Navigate only after UI updates
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const Dashboard();
                }));

                // route.pushNamedAndRemoveUntil(context, routeName.dashboard);
              },
            );
          },
        );
      },
    );
  }

  // onContinue(context) {
  //   showDialog(
  //       context: context,
  //       builder: (context1) {
  //         return StatefulBuilder(
  //           builder: (context, setState)  {
  //             return AlertDialogCommon(
  //                 isBooked: true,
  //                 title: translations!.successfullyBooked,
  //                 widget: Container(
  //                         alignment: Alignment.center,
  //                         width: MediaQuery.of(context).size.width,
  //                         child: Stack(children: [
  //                           Image.asset(eImageAssets.booked, height: Sizes.s145),
  //                           SizedBox(
  //                                   height: Sizes.s34,
  //                                   width: Sizes.s34,
  //                                   child: Image.asset(eGifAssets.tick,
  //                                       height: Sizes.s34, width: Sizes.s34))
  //                               .paddingOnly(left: Insets.i13, top: Insets.i25)
  //                         ]))
  //                     .paddingSymmetric(vertical: Insets.i20)
  //                     .decorated(
  //                         color: appColor(context).fieldCardBg,
  //                         borderRadius: BorderRadius.circular(AppRadius.r10)),
  //                 subtext: translations!.yourBookingHasBeen,
  //                 bText1: translations!.goToBookingList,
  //                 height: Sizes.s145,
  //                 isLoading:isLoading ,
  //                 b1OnTap: () async {
  //                   setState(() => isLoading = true);
  //                   method = paymentMethods[0].slug;
  //                   route.pushNamedAndRemoveUntil(context, routeName.dashboard);
  //                   final dash =
  //                       Provider.of<DashboardProvider>(context, listen: false);
  //
  //                   final common =
  //                       Provider.of<CommonApiProvider>(context, listen: false);
  //                   common.selfApi(context);
  //                   final wallet =
  //                       Provider.of<WalletProvider>(context, listen: false);
  //                   wallet.getWalletList(context);
  //                   dash.selectIndex = 1;
  //                   isLoading =false;
  //                   dash.notifyListeners();
  //                   dash.getBookingHistory(context);
  //                   final cartCtrl =
  //                       Provider.of<CartProvider>(context, listen: false);
  //                   cartCtrl.checkoutModel = null;
  //                   // cartCtrl.checkoutModel!.services = null;
  //                   cartCtrl.isPayment = true;
  //                   cartCtrl.cartList = [];
  //                   isWallet = false;
  //                   selectIndex = 0;
  //                   method = null;
  //                   notifyListeners();
  //
  //                   cartCtrl.notifyListeners();
  //                   SharedPreferences preferences =
  //                       await SharedPreferences.getInstance();
  //                   preferences.remove(session.cart);
  //                   cartCtrl.notifyListeners();
  //                   setState(() => isLoading = false);
  //                 });
  //           }
  //         );
  //       });
  // }

  onTapWallet(context) async {
    isWallet = !isWallet;
    notifyListeners();
    if (isWallet) {
      selectIndex = null;
    }
    notifyListeners();
  }

  //booking detail by id
  getBookingDetailBy(context) async {
    try {
      await apiServices
          .getApi("${api.booking}/$bookingId", [], isToken: true, isData: true)
          .then((value) {
        debugPrint("BOOKING DATA : ${value.data}");

        if (value.isSuccess!) {
          booking = BookingModel.fromJson(value.data);
          notifyListeners();
        }
      });
      log("STATYS L $booking");
    } catch (e) {
      notifyListeners();
    }
  }

  //booking payment
  bookingPayment(context) async {
    try {
      showLoading(context);
      notifyListeners();
      log("bookingId :${booking!.extraCharges}");
      var body = {
        "booking_id": bookingId,
        "payment_method": method,
        "currency_code": currency(context).currency!.code,
        "type": booking!.extraCharges == 0 || booking!.extraCharges!.isEmpty
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
                await getVerifyPayment(value.data['item_id'], context);
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
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
      });
    } catch (e) {
      hideLoading(context);
      Fluttertoast.showToast(msg: e.toString());
      notifyListeners();
    }
  }

  //re-payment
  rePayment(context, itemId, {pay}) async {
    try {
      showLoading(context);
      notifyListeners();
      var body = {
        "item_id": itemId,
        "payment_method": pay ?? method,
        "type": "booking",
        "currency_code": currency(context).currency!.code,
      };

      log("checkoutBody:11 ${currency(context).currency!.code}");
      await apiServices
          .postApi(api.repayment, body, isData: true, isToken: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
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
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
      });
    } catch (e) {
      hideLoading(context);

      notifyListeners();
    }
  }

  addToCartOrBooking(context) {
    log("bookingId :$bookingId");
    log("bookingIdaa :$method");
    if (isWallet) {
      log(" inside iswallet condiotion");
      isPayment = true;
      proceedToBook(context);
    } else {
      if (selectIndex != null) {
        isPayment = true;
        if (isRePayment) {
          print("object isRePayment");
          rePayment(context, itemId);
        } else {
          if (bookingId == 0) {
            // createBookingNotification(NotificationType.createBookingEvent);
            print("object proceedToBook");
            proceedToBook(context);
          } else {
            if (method == "cash") {
              // createBookingNotification(NotificationType.createBookingEvent);
              log("message -=-=-=-= CASH");
              updateStatus(context, "completed");
            } else if (method == "wallet") {
              updateStatus(context, "completed");
            } else {
              log("isRePayment:$isRePayment");
              if (isRePayment) {
                rePayment(context, itemId);
              } else {
                log("Booking Payment");
                bookingPayment(context);
              }
            }
          }
        }
      } else {
        Fluttertoast.showToast(msg: "Select Payment Method");
      }
    }
  }

  //update status
  bool isPayment = false;

  updateStatus(context, status, {isCancel = false, sync, id}) async {
    log("NOCHANGE hkgfklhklfgjhl;fl;");
    isPayment = true;
    notifyListeners();
    log("NOCHANGE");
    try {
      showLoading(context);
      notifyListeners();
      dynamic data;
      if (isCancel) {
        route.pop(context);

        data = {
          "booking_status": "cancel",
          "reason": "Payment Failed",
        };
      } else {
        data = {"booking_status": status};
      }

      log("ON L$data");
      await apiServices
          .putApi("${api.booking}/${isCancel ? id : booking!.id}", data,
              isToken: true, isData: true)
          .then((value) async {
        log("value.isSuccess!:${value.isSuccess!}");
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          isPayment = false;

          notifyListeners();
          if (status == "completed") {
            isWallet = false;
            selectIndex = 0;
            method = null;
            completeSuccess(context);
          } else {
            log("itemIditemId :$itemId");
            notifyListeners();
            await getVerifyPayment(context, itemId);
            route.pushNamedAndRemoveUntil(context, routeName.dashboard);
            final dash = Provider.of<DashboardProvider>(context, listen: false);
            dash.selectIndex = 1;
            dash.notifyListeners();
            dash.getBookingHistory(context);
            final cartCtrl = Provider.of<CartProvider>(context, listen: false);
            cartCtrl.checkoutModel = null;
            cartCtrl.isPayment = true;
            cartCtrl.cartList = [];
            isWallet = false;
            selectIndex = 0;
            method = null;
            cartCtrl.notifyListeners();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.remove(session.cart);
            cartCtrl.notifyListeners();
          }
        } else {
          isPayment = false;
          notifyListeners();
          log("MMEES : ${value.message}");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: appColor(context).red);
        }
      });
      isPayment = false;
      hideLoading(context);
      notifyListeners();
    } catch (e, s) {
      log("EEEE :$e,=--=-=-=-=-=-=-=-=-= $s");
      isPayment = false;
      notifyListeners();
      hideLoading(context);
      Fluttertoast.showToast(
          msg: e.toString(), backgroundColor: appColor(context).red);
      notifyListeners();
    }
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
                route.pop(context);

                route.pushNamed(context, routeName.completedServiceScreen,
                    arg: {"bookingId": booking!.id});
              });
        });
  }

  String convertTo24Hour(String time) {
    try {
      time = time.toUpperCase().trim();

      // Already 24-hour → return as-is
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
        return time;
      }

      // Handles: 2:30 PM, 02:30 PM, 02:30 pm
      final inputFormat = DateFormat("h:mm a");
      final outputFormat = DateFormat("HH:mm");

      return outputFormat.format(inputFormat.parse(time));
    } catch (e) {
      log("Time parse failed: $time");
      return time;
    }
  }

  proceedToBook(context) async {
    try {
      isPayment = true;
      showLoading(context);
      notifyListeners();
      //var body = checkoutBody;
      Map<String, dynamic> body = Map<String, dynamic>.from(checkoutBody);

      /// ✅ HANDLE SCHEDULE TIME (MOST IMPORTANT FIX)
      if (body["services"] != null && body["services"].isNotEmpty) {
        for (var service in body["services"]) {
          if (service["schedule_time"] != null) {
            service["schedule_time"] =
                convertTo24Hour(service["schedule_time"]);
          }
        }
      }
      body["payment_method"] = isWallet ? "wallet" : method;
      body["currency_code"] = currency(context).currency?.code;
      checkoutBody = body;
      notifyListeners();
      log("checkoutBody: $checkoutBody");
      await apiServices
          .postApi(api.booking, body, isData: true, isToken: true)
          .then((value) async {
        isPayment = false;
        hideLoading(context);
        notifyListeners();
        log("VA :${value.data}");
        if (value.isSuccess!) {
          if (body["payment_method"] == "cash") {
            onContinue(context);
            createBookingNotification(NotificationType.createBookingEvent);
          } else if (body["payment_method"] == "wallet") {
            onContinue(context);
            createBookingNotification(NotificationType.createBookingEvent);
            final wallet = Provider.of<WalletProvider>(context, listen: false);
            wallet.getWalletList(context);
          } else {
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
                  showLayout(context, value.data['item_id']);
                }
              } else {
                showLayout(context, value.data['item_id']);
              }
            });
          }
          notifyListeners();
        } else {
          log("SUCCCC ::;:${value.data} //${value.message}");
          flutterAlertMessage(context,
              msg: value.message, bgColor: appColor(context).red);
        }
      });
    } catch (e, s) {
      log("SHHHH:$e");
      log("message=-=-=-=-=-=-=-#$s");
      flutterAlertMessage(context,
          msg: e.toString(), bgColor: appColor(context).red);
      hideLoading(context);
      notifyListeners();
    }
  }

  showLayout(context, id) async {
    showDialog(
      context: context,
      builder: (context1) {
        return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: Insets.i20),
            shape: const SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.all(SmoothRadius(
                    cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
            content:
                Consumer<LanguageProvider>(builder: (context, value, child) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language(context, translations!.selectOne),
                          style: appCss.dmDenseBold18
                              .textColor(appColor(context).darkText)),
                      const Icon(CupertinoIcons.multiply)
                          .inkWell(onTap: () => route.pop(context))
                    ]),
                Image.asset(eImageAssets.bulletDotted)
                    .paddingSymmetric(vertical: Insets.i8),
                Text(
                    language(context,
                        translations!.areYouSureYouWantToCancelBooking),
                    textAlign: TextAlign.center,
                    style:
                        appCss.dmDenseBold18.textColor(appColor(context).red)),
                Image.asset(eImageAssets.bulletDotted)
                    .paddingSymmetric(vertical: Insets.i12),
                Text(language(context, translations!.optionForOrder),
                    textAlign: TextAlign.center,
                    style: appCss.dmDenseLight14
                        .textColor(appColor(context).darkText)),
                const VSpace(Sizes.s25),
                ...appArray.selectRepaymentOrCancel
                    .asMap()
                    .entries
                    .map((e) => e.value['title'] == translations!.cashOnDelivery
                        ? appSettingModel!.activation!.cash == "1"
                            ? SelectOrderCancelOrRepayment(
                                data: e.value,
                                index: e.key,
                                list: appArray.selectRepaymentOrCancel,
                                onTap: () {
                                  if (e.value['title'] ==
                                      translations!.cancelBooking) {
                                    log("jiygijkhnjknkn");
                                    itemId = id.toString();
                                    notifyListeners();

                                    updateStatus(context, "cancel",
                                        isCancel: true, id: id);
                                  } else if (e.value['title'] ==
                                      translations!.cashOnDelivery) {
                                    log("jiygijkhnjknkn");
                                    route.pop(context);
                                    rePayment(context, id, pay: "cash");
                                    isRePayment = true;
                                    notifyListeners();
                                    // getImage(context, ImageSource.camera);
                                  } else {
                                    log("jiygijkhnjknkn");
                                    route.pop(context);
                                    isRePayment = true;
                                    bookingId = int.parse(id.toString());
                                    itemId = id.toString();
                                    notifyListeners();
                                  }
                                })
                            : Container()
                        : SelectOrderCancelOrRepayment(
                            data: e.value,
                            index: e.key,
                            list: appArray.selectRepaymentOrCancel,
                            onTap: () {
                              if (e.value['title'] ==
                                  translations!.cancelBooking) {
                                itemId = id.toString();
                                notifyListeners();
                                log("jiygijkhnjknkn cancel");
                                updateStatus(context, "cancel",
                                    isCancel: true, id: id);
                              } else if (e.value['title'] ==
                                  translations!.cashOnDelivery) {
                                log("jiygijkhnjknkn cash");
                                route.pop(context);
                                rePayment(context, id, pay: "cash");
                                isRePayment = true;
                                notifyListeners();
                              } else {
                                log("jiygijkhnjknkn cash");
                                route.pop(context);
                                isRePayment = true;
                                itemId = id.toString();
                                notifyListeners();
                              }
                            }))
              ]);
            }));
      },
    );
  }

//verify payment
  getVerifyPayment(data, context) async {
    log("OIIII ssss $data");
    log("OIIII ssss $itemId");
    try {
      String id = itemId ?? data.toString();
      log("VERIIFY L$id");
      await apiServices
          .getApi("${api.verifyPayment}?item_id=$id&type=booking", null,
              isToken: true)
          .then((value) {
        log("CALUE :${value.data}");
        log("CALUE 1:${value.message}");
        method = paymentMethods[0].slug;
        if (value.isSuccess!) {
          if (bookingId == 0) {
            onContinue(context);
          } else {
            log("OIIII");
            if (itemId == null) {
              updateStatus(context, "completed");
            }
          }
        }
      });
    } catch (e) {
      log("djhsgfkdg getVerifyPayment:$e");
      notifyListeners();
    }
  }
}
