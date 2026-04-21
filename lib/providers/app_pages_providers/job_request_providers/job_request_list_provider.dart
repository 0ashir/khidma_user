import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';


class JobRequestListProvider extends ChangeNotifier {
  List<JobRequestModel> jobRequestList = [];
  bool isPositionedRight = false;
  bool isAnimateOver = false;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  onInit(context) async {
    try {
      showLoading(context);
      /*jobRequestList = appArray.jobRequestList
         .map((e) => JobRequestModel.fromJson(e))
         .toList();*/
      notifyListeners();
      hideLoading(context);
      notifyListeners();
      log("JOBB :${jobRequestList.length}");
    } catch (e) {
      log("EEEE JobRequest: $e");
    }
  }

  //delete Job Request
  deleteJobRequest(context, id, {isBack = false}) async {
    try {
      showLoading(context);
      route.pop(context);
      log("id;$id");
      await apiServices
          .deleteApi("${api.serviceRequest}/$id", {}, isToken: true)
          .then((value) {
        hideLoading(context);
        log("VVVV : ${value.isSuccess}");
        notifyListeners();
        if (value.isSuccess!) {
          log("VVVV : 123");
          final dash = Provider.of<DashboardProvider>(context, listen: false);
          /* snackBarMessengers(context,
              color: appColor(context).primary, message: value.message); */
          dash.getJobRequest();
        } else {
          log("VVVV : 456");
          Fluttertoast.showToast(
              msg: value.message, backgroundColor: Colors.red);
        }
      });
    } catch (e) {
      hideLoading(context);
      notifyListeners();
      log("EEEE deleteJobRequest: $e");
    }
  }

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    dash.getJobRequest();
    hideLoading(context);
    notifyListeners();
  }

  deleteJobRequestConfirmation(context, sync, id) {
    animateDesign(sync);
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
                                                            .jobRequest)))),
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
                                  translations!.deleteJobRequestConfirmation),
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
                                onTap: () => deleteJobRequest(context, id),
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
                              language(context, translations!.deleteJobRequest),
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

  
}
