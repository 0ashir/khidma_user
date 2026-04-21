import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/config.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/add_job_request/layouts/accept_provider_confirmation.dart';

import '../../../helper/notification.dart';

class JobRequestDetailsProvider with ChangeNotifier {
  int selectedIndex = 0, selected = -1;
  bool isBottom = true;
  int? serviceId;
  ScrollController scrollController = ScrollController();
  double widget1Opacity = 0.0;
  JobRequestModel? service;
  bool isPositionedRight = false;
  bool isAnimateOver = false;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  onImageChange(index) {
    selectedIndex = index;
    notifyListeners();
  }

  onReady(context) async {
    scrollController.addListener(listen);

    notifyListeners();
    dynamic data = ModalRoute.of(context)!.settings.arguments;
    log("service :${data['serviceId']}");
    if (data['serviceId'] != null) {
      getServiceById(context, data['serviceId']);
    } else {
      service = data['services'];
      notifyListeners();
      getServiceById(context, service!.id);
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      widget1Opacity = 1;
      notifyListeners();
    });
    notifyListeners();
  }

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getServiceById(context, service!.id);

    hideLoading(context);
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  onExpansionChange(newState, index) {
    log("dghfdkg:$newState");
    if (newState) {
      const Duration(seconds: 20000);
      selected = index;
      notifyListeners();
    } else {
      selected = -1;
      notifyListeners();
    }
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

  onBack(context, isBack) {
    // service = null;
    selectedIndex = 0;

    serviceId = 0;
    widget1Opacity = 0.0;
    notifyListeners();
    log("djhfkf :$service");
    if (isBack) {
      route.pop(context);
    }
  }

  bool isLoader = false;
  getServiceById(context, serviceId) async {
    isLoader = true;
    try {
      log("serviceId::$serviceId");

      await apiServices
          .getApi("${api.serviceRequest}/$serviceId", [],
              isToken: true, isData: true)
          .then((value) {
        log("VV l :${value.isSuccess} || ${value.data['data']}");
        if (value.isSuccess!) {
          isLoader = false;
          service = JobRequestModel.fromJson(value.data['data']);

          log("service!.status :${service!.bids}");
          notifyListeners();
        } else {
          isLoader = false;

          notifyListeners();
          Fluttertoast.showToast(
              backgroundColor: Colors.red, msg: value.message);
        }
      });
    } catch (e) {
      isLoader = false;
      log("ERRROEEE JOB getServiceById : $e");
      notifyListeners();
    }
  }

  acceptProvider(context, ProviderModel provider, bid) {
    // log("message::::$bid");
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return AcceptProviderConfirmation(
              provider: provider,
              accept: () {
                acceptRejectBid(context, bid);
                log("message::::$bid");
              });
        });
  }

//update status
  acceptRejectBid(context, bid, {isCancel = false}) async {
    try {
      showLoading(context);
      notifyListeners();
      dynamic data;
      if (!isCancel) {
        route.pop(context);
      }
      log("value:${service!.id}");
      data = {"status": isCancel ? "rejected" : "accepted"};
      await apiServices
          .putApi("${api.bid}/$bid", data, isToken: true, isData: true)
          .then((value) {
        log("value :${value.isSuccess}");
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {

          createBookingNotification(NotificationType.updateBidEvent);


          debugPrint("BID DATA : ${value.data['service']}");
          getServiceById(context, service!.id);
          notifyListeners();
        }
      });
      hideLoading(context);
      notifyListeners();
    } catch (e) {
      log("SSS :${e.toString()}");
      hideLoading(context);
      notifyListeners();
    }
  }

  bookService(context) {
    log("service!.service::${service!.service!.title}");
    onBook(context, service!.service!,
            addTap: () => onAdd(context, service!.service!.id!),
            minusTap: () => onRemoveService(context, service!.service!.id))!
        .then((e) {
      service!.service!.selectedRequiredServiceMan =
          service!.service!.requiredServicemen;
      notifyListeners();
    });
  }

  onAdd(context, index) {
    isAlert = false;
    notifyListeners();
    int count = (service!.service!.selectedRequiredServiceMan!);
    count++;
    service!.service!.selectedRequiredServiceMan = count;

    notifyListeners();
  }

  onRemoveService(context, index, {isSearch = false}) async {
    if ((service!.service!.requiredServicemen!) ==
        (service!.service!.selectedRequiredServiceMan!)) {
      isAlert = true;
      notifyListeners();
      await Future.delayed(DurationClass.s3);
      isAlert = false;
      notifyListeners();
    } else {
      isAlert = false;
      notifyListeners();
      service!.service!.selectedRequiredServiceMan =
          ((service!.service!.selectedRequiredServiceMan!) - 1);
    }

    notifyListeners();
  }

  rejectJobRequestConfirmation(context, /* sync, */ id) {
    /* animateDesign(sync); */
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<JobRequestListProvider>(
                builder: (context3, value, child) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: Insets.i20),
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(SmoothRadius(
                          cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
                  backgroundColor: appColor(context).whiteBg,
                  content: Column(
                      /* alignment: Alignment.topRight, */ mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Title
                              Expanded(
                                child: Text(
                                    language(
                                        context,
                                        translations!
                                            .rejectJobRequestConfirmation),
                                    textAlign: TextAlign.start,
                                    style: appCss.dmDenseRegular14
                                        .textColor(appColor(context).lightText)
                                        .textHeight(1.6)),
                              ),
                              Icon(CupertinoIcons.multiply,
                                      size: Sizes.s20,
                                      color: appColor(context).darkText)
                                  .inkWell(onTap: () => route.pop(context))
                            ]).padding(
                            horizontal: Insets.i20,
                            top: Insets.i20,
                            bottom: Insets.i15),
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
                                    acceptRejectBid(context, id,
                                        isCancel: true);
                                    route.pop(context);
                                  },
                                  style: appCss.dmDenseSemiBold16
                                      .textColor(appColor(context).whiteColor),
                                  title: translations!.yes ?? appFonts.yes))
                        ]).padding(horizontal: Insets.i20, bottom: Insets.i20)
                      ])).padding(vertical: Insets.i22);
            });
          });
        }).then((value) {
      isPositionedRight = false;
      isAnimateOver = false;
      notifyListeners();
    });
  }

  /* animateDesign(TickerProvider sync) {
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
  } */
}
