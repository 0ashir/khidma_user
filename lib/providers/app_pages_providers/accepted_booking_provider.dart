import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/status_booking_model.dart';

class AcceptedBookingProvider with ChangeNotifier {
  List<StatusBookingModel> acceptedStatusList = [];
  BookingModel? booking;
  final FocusNode searchFocus = FocusNode();
  TextEditingController reasonCtrl = TextEditingController();
  bool isLoading = false;

  onReady(BuildContext context) async {
    dynamic arg = ModalRoute.of(context)!.settings.arguments;
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      if (arg['bookingId'] != null) {
        log("arg['bookingId']::${arg['bookingId']}");
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

  /*onReady(context) {
    dynamic arg = ModalRoute.of(context)!.settings.arguments;

    if (arg['bookingId'] != null) {
      getBookingDetailBy(context, id: arg['bookingId']);
    } else {
      booking = arg['booking'];
      notifyListeners();
      getBookingDetailBy(context);
    }
  }*/

  onBack(context, isBack) {
    booking = null;
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }
  // bool isJoin = false;


  openZoom(context,{meetingLink, int? bookingId}) async {
    log("meetingLink $meetingLink");
    final Uri zoomUri = Uri.parse(meetingLink);

    if (await canLaunchUrl(zoomUri)) {
      await launchUrl(
        zoomUri,
        mode: LaunchMode.externalApplication,
      );
      notifyListeners();
      updateStatus(context);
      getBookingDetailBy(context,id: bookingId);
      route.pop(context);
      // route.pop(context);
    } else {
      // isJoin =false;
      throw 'Could not launch $meetingLink';
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
                      child: Image.asset(eImageAssets.restartBg,
                          width: Sizes.s150)),
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
                if (booking!.service!.type == "remotely") {
                  // chatAndUpdateStatus(context);
                } else {
                  updateStatus(context);
                }
              });
        });
  }


  onCancelBooking(context) {
    showDialog(
        context: context,
        builder: (context1) => AlertDialog(
            contentPadding: EdgeInsets.zero,
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
                        controller: reasonCtrl,
                        focusNode: searchFocus,
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
                        /*onTap: ()=>updateStatus(context,isCancel: true),*/
                        color: reasonCtrl.text.isNotEmpty
                            ? appColor(context).primary
                            : appColor(context).primary.withOpacity(0.10),
                        borderColor: reasonCtrl.text.isNotEmpty
                            ? appColor(context).primary
                            : appColor(context).primary.withOpacity(0.10),
                        fontColor: reasonCtrl.text.isNotEmpty
                            ? appColor(context).whiteColor
                            : appColor(context).primary,
                        onTap: () {
                          if (reasonCtrl.text.isNotEmpty) {
                            updateStatus(context, isCancel: true);
                          } else {
                            Fluttertoast.showToast(msg: "Please Enter reason");
                          }
                        },
                        title: translations!.submit ?? appFonts.submit)
                  ]).padding(
                  horizontal: Insets.i20, top: Insets.i60, bottom: Insets.i20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // Title
                Text(language(context, translations!.reasonOfCancelBooking),
                    style: appCss.dmDenseExtraBold16
                        .textColor(appColor(context).darkText)),
                Icon(CupertinoIcons.multiply,
                        size: Sizes.s20, color: appColor(context).darkText)
                    .inkWell(onTap: () => route.pop(context))
              ]).paddingAll(Insets.i20)
            ])));
  }

  //booking detail by id
  getBookingDetailBy(context, {id}) async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.booking}/${id ?? booking!.id}", [],
              isToken: true, isData: true)
          .then((value) {
        log("BOOKING DATA : ${value.data['data']}");

        if (value.isSuccess!) {
          isLoading = false;
          booking = BookingModel.fromJson(value.data['data']);
          notifyListeners();
        } else {
          Fluttertoast.showToast(msg: value.message);
        }
      });
      log("STATYS L $booking");
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getBookingDetailBy(context);
    hideLoading(context);
    notifyListeners();
  }

  completeSuccess(context) {
    showCupertinoDialog(
      context: context,
      builder: (context1) {
        return AlertDialogCommon(
          title: translations!.successfullyDelete,
          height: Sizes.s140,
          image: eGifAssets.successGif,
          subtext: language(context, translations!.cancelBookingSuccessfully),
          bText1: language(context, translations!.okay),
          b1OnTap: () {
            route.pop(context);
            route.pop(context);
            route.pushNamed(context, routeName.cancelledServiceScreen,
                arg: {"bookingId": booking!.id!}).then((e) {
              log("CHEC");
              route.pushNamedAndRemoveUntil(context, routeName.dashboard);
              final dash =
                  Provider.of<DashboardProvider>(context, listen: false);
              dash.selectIndex = 1;
              dash.notifyListeners();
            });
          },
        );
      },
    );
  }

  //update status
  updateStatus(context, {isCancel = false}) async {
    try {
      showLoading(context);
      notifyListeners();
      dynamic data;
      if (isCancel) {
        route.pop(context);
        data = {
          "reason": reasonCtrl.text,
          "booking_status": translations!.cancel
        };
      } else {
        data = {"booking_status": appFonts.onGoing};
      }
      await apiServices
          .putApi("${api.booking}/${booking!.id}", data,
              isToken: true, isData: true)
          .then((value) {
        hideLoading(context);
        notifyListeners();
        reasonCtrl.text = "";
        if (value.isSuccess!) {
          debugPrint("BOOKING DATA : ${value.data}");
          booking = BookingModel.fromJson(value.data);
          if (isCancel) {
            completeSuccess(context);
          }
          notifyListeners();
        }
      });
      hideLoading(context);
      notifyListeners();
    } catch (e) {
      hideLoading(context);
      notifyListeners();
    }
  }

  checkForCancelButtonShow() {
    bool isShow = false;

    DateTime now = DateTime.now();
    DateTime bookDate = DateTime.parse(booking!.dateTime!);
    Duration duration = now.difference(bookDate);
    isShow = duration.inHours <
        int.parse(appSettingModel!.general!.cancellationRestrictionHours!);
    return isShow;
  }
}
