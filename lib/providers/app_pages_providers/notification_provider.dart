import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';

class NotificationProvider with ChangeNotifier {
  bool isNotification = false;
  AnimationController? animationController;
  List<NotificationModel> notificationList = [];

  bool isNotificationLoading = false;

  bool isPositionedRight = false;
  bool isAnimateOver = false;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  onRefresh(context) {
    getNotificationList(context);
  }

  onAnimate(TickerProvider sync, context) {
    getNotificationList(context);
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

  getNotificationList(context) async {
    isNotificationLoading = true;
    notifyListeners();
    try {
      await apiServices
          .getApi(api.notifications, [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          isNotificationLoading = false;
          List address = value.data;
          notificationList = [];
          for (var data in address.toList()) {
            if (!notificationList.contains(NotificationModel.fromJson(data))) {
              notificationList.add(NotificationModel.fromJson(data));
            }

            notifyListeners();
          }
        }
      });
    } catch (e) {
      isNotificationLoading = false;
      log("EEE :getNotification :$e");
      notifyListeners();
    }
  }

  readOnly(context, id) async {
    showLoading(context);
    notifyListeners();
    try {
      await apiServices
          .postApi("${api.notifications}/$id/mark-as-read", [], isToken: true)
          .then((value) {
        hideLoading(context);
        if (value.isSuccess!) {
          getNotificationList(context);
          // Fluttertoast.showToast(
          //   msg: value.message,
          //   backgroundColor: appColor(context).primary,
          // );
          notifyListeners();
        } else {
          Fluttertoast.showToast(
            msg: value.message,
            backgroundColor: appColor(context).red,
          );
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: appColor(context).red,
      );
      log("messL::::$e");
      hideLoading(context);
      notifyListeners();
    }
  }

  readAll(context) async {
    showLoading(context);
    notifyListeners();
    try {
      await apiServices.putApi(api.markAsRead, [], isToken: true).then((value) {
        hideLoading(context);
        if (value.isSuccess!) {
          getNotificationList(context);
          notifyListeners();
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
    }
  }

  //delete
  deleteNotification(context) async {
    route.pop(context);
    try {
      await apiServices
          .getApi(api.deleteNotification, [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          completeSuccess(context);
          getNotificationList(context);
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }

  completeSuccess(context) {
    showCupertinoDialog(
      context: context,
      builder: (context1) {
        return AlertDialogCommon(
          title: translations!.successfullyDelete,
          height: Sizes.s140,
          image: eGifAssets.successGif,
          subtext:
              language(context, translations!.notificationDeletedSuccessfully),
          bText1: language(context, translations!.okay),
          b1OnTap: () {
            route.pop(context);
          },
        );
      },
    );
  }

  deleteNotificationConfirmation(
    context,
    sync,
  ) {
    animateDesign(sync);
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<NotificationProvider>(
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
                                                            .bellTrash)))),
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
                              translations!.deleteNotificationSuccessfully),
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
                                onTap: () => deleteNotification(context),
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
                          Text(
                              language(
                                  context, translations!.deleteNotification),
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

  totalCount() {
    int count = 0;
    for (var data in notificationList) {
      if (data.readAt == null) {
        count++;
      }
    }
    return count;
  }

  onBack() {
    animationController!.dispose();
    notifyListeners();
  }

  onTap(NotificationModel model, BuildContext context, index) async {
    readOnly(context, notificationList[index].id);
    getNotificationList(context);
    if (model.data!.type == "provider") {
      Provider.of<ProviderDetailsProvider>(context, listen: false)
          .getProviderById(context, model.data!.providerId);

      route.pushNamed(context, routeName.providerDetailsScreen,
          arg: {'providerId': model.data!.providerId});
    }
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    final bookingg = Provider.of<BookingProvider>(context, listen: false);

    // Fetch booking history (you can optimize by caching later)
    await dash.getBookingHistory(context);

    // Find booking by ID
    final booking = bookingg.bookingList.firstWhere(
      (e) => e.id == model.data!.bookingId,
    );

    log("Notification Type: ${model.data!.type}");
    if (model.data!.type == "booking") {
      switch (booking.bookingStatus!.slug) {
        case "pending":
          route.pushNamed(context, routeName.pendingBookingScreen,
              arg: {"bookingId": booking.id});
          break;
        case "accepted":
        case "assigned":
          route.pushNamed(context, routeName.acceptedBookingScreen,
              arg: {"bookingId": booking.id});
          break;
        case "ongoing":
        case "on_hold":
        case "ontheway":
        case "start_again":
          route.pushNamed(context, routeName.ongoingBookingScreen,
              arg: {"bookingId": booking.id});
          break;
        case "completed":
          route.pushNamed(context, routeName.completedServiceScreen,
              arg: {"bookingId": booking.id});
          break;
        case "cancelled":
          route.pushNamed(context, routeName.cancelledServiceScreen,
              arg: {"bookingId": booking.id});
          break;
        // case "extra charge":
        //   route.pushNamed(context, routeName.completedServiceScreen,
        //       arg: {"bookingId": booking.id});
        //   break;
        default:
          Fluttertoast.showToast(msg: "Unknown booking status");
      }
    } else {
      Fluttertoast.showToast(msg: "Booking not found");
    }
  }

  // onTap(NotificationModel model, context) {
  //   Provider.of<ProviderDetailsProvider>(context, listen: false)
  //       .getProviderById(context, model.data!.bookingId);
  //   log("TY{PE : ${model.data!.type}//${model.data!.message}");
  //   if (model.data!.type == "provider") {
  //     Provider.of<ProviderDetailsProvider>(context, listen: false)
  //         .getProviderById(context, model.data!.providerId);
  //
  //     route.pushNamed(context, routeName.providerDetailsScreen,
  //         arg: {'providerId': model.data!.providerId});
  //   } else if (model.data!.type == "booking") {
  //     log("DNH :${model.data!.toJson()}");
  //     if (model.data!.message!.toLowerCase().contains(appFonts.pending)) {
  //       route.pushNamed(context, routeName.pendingBookingScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!
  //         .toLowerCase()
  //         .contains(appFonts.accepted)) {
  //       route.pushNamed(context, routeName.acceptedBookingScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!.toLowerCase().contains(appFonts.onHold)) {
  //       route.pushNamed(context, routeName.ongoingBookingScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!
  //             .toLowerCase()
  //             .contains(appFonts.ongoing) ||
  //         model.data!.message!.toLowerCase().contains(appFonts.ontheway) ||
  //         model.data!.message!.toLowerCase().contains(appFonts.startAgain) ||
  //         model.data!.message!.toLowerCase().contains(appFonts.onHold)) {
  //       route.pushNamed(context, routeName.ongoingBookingScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!
  //         .toLowerCase()
  //         .contains(translations!.completed)) {
  //       route.pushNamed(context, routeName.completedServiceScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!
  //         .toLowerCase()
  //         .contains(appFonts.assigned)) {
  //       route.pushNamed(context, routeName.acceptedBookingScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     } else if (model.data!.message!
  //         .toLowerCase()
  //         .contains(translations!.cancel)) {
  //       route.pushNamed(
  //           navigatorKey.currentContext, routeName.cancelledServiceScreen,
  //           arg: {"bookingId": model.data!.bookingId});
  //     }
  //   }
  // }
}
