import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/screens/app_pages_screens/ongoing_booking_screen/layout/extra_service_add_billing.dart';
import 'package:fixit_user/screens/app_pages_screens/ongoing_booking_screen/layout/no_extra_service_billing.dart';
import 'package:fixit_user/screens/app_pages_screens/pending_booking_screen/layouts/payment_status_summary.dart';
import 'package:flutter/rendering.dart';

import '../../../config.dart';
import '../../bottom_screens/booking_screen/booking_shimmer/booking_detail_shimmer.dart';

class OngoingBookingScreen extends StatefulWidget {
  const OngoingBookingScreen({super.key});

  @override
  State<OngoingBookingScreen> createState() => _OngoingBookingScreenState();
}

class _OngoingBookingScreenState extends State<OngoingBookingScreen>
    with TickerProviderStateMixin {
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      log("fdftsf :$state");
      final book = Provider.of<OngoingBookingProvider>(context, listen: false);
      book.getBookingDetailBy(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OngoingBookingProvider>(builder: (context1, value, child) {
      log("value.booking?.grandTotalWithExtras::${value.booking?.grandTotalWithExtras}////${value.booking?.total}");
      return StatefulWrapper(
          onInit: () => Future.delayed(
              const Duration(milliseconds: 150), () => value.onReady(context)),
          child: PopScope(
              canPop: true,
              onPopInvoked: (didPop) {
                value.onBack(context, false);
                if (didPop) return;
              },
              child: Scaffold(
                  appBar: AppBarCommon(
                      title: translations!.ongoingBooking,
                      onTap: () => value.onBack(context, true)),
                  body: value.isLoading || value.booking == null
                      ? const BookingDetailShimmer()
                      : Stack(alignment: Alignment.bottomCenter, children: [
                          RefreshIndicator(
                            onRefresh: () async {
                              value.onRefresh(context);
                            },
                            child: SingleChildScrollView(
                                controller: value.scrollController,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StatusDetailLayout(
                                          data: value.booking,
                                          onTapStatus: () => showBookingStatus(
                                              context, value.booking)),
                                      if (value.booking!.extraCharges != null &&
                                          value.booking!.extraCharges!
                                              .isNotEmpty)
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                      language(
                                                          context,
                                                          translations!
                                                              .addedServiceDetails),
                                                      style: appCss
                                                          .dmDenseSemiBold14
                                                          .textColor(
                                                              appColor(context)
                                                                  .darkText))
                                                  .padding(
                                                      top: Insets.i20,
                                                      bottom: Insets.i10),
                                              AddServiceLayout(
                                                  extraCharge: value
                                                      .booking!.extraCharges),
                                            ]),
                                      Text(
                                              language(context,
                                                  translations!.billSummary),
                                              style: appCss.dmDenseSemiBold14
                                                  .textColor(appColor(context)
                                                      .darkText))
                                          .paddingOnly(
                                              top: Insets.i25,
                                              bottom: Insets.i10),
                                      value.booking!.extraCharges != null &&
                                              value.booking!.extraCharges!
                                                  .isNotEmpty
                                          ? ExtraServiceAddBilling(
                                              booking: value.booking)
                                          : NoExtraServiceAddedBill(
                                              bookingModel: value.booking),
                                      if (value.booking!.advancePaymentEnable!)
                                        PaymentSummaryWidget(
                                          booking: value.booking!,
                                        ),
                                      if (value.booking!.service !=
                                              null /* &&
                                              value.booking!.service!
                                                  .reviews!.isNotEmpty */
                                          )
                                        if (value.booking!.service != null &&
                                            value.booking?.service?.reviews ==
                                                [])
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        language(
                                                            context,
                                                            translations!
                                                                .review),
                                                        overflow:
                                                            TextOverflow.clip,
                                                        style: appCss
                                                            .dmDenseSemiBold14
                                                            .textColor(appColor(
                                                                    context)
                                                                .darkText))),
                                                Text(
                                                        language(
                                                            context,
                                                            translations!
                                                                .viewAll),
                                                        style: appCss
                                                            .dmDenseRegular14
                                                            .textColor(appColor(
                                                                    context)
                                                                .primary))
                                                    .inkWell(
                                                        onTap: () =>
                                                            route.pushNamed(
                                                                context,
                                                                routeName
                                                                    .servicesReviewScreen,
                                                                arg: value
                                                                    .booking!
                                                                    .service))
                                              ]).paddingOnly(
                                              top: Insets.i20,
                                              bottom: Insets.i12),
                                      if (value.booking!.service != null &&
                                          value.booking?.service?.reviews == [])
                                        ...value.booking!.service!.reviews!
                                            .asMap()
                                            .entries
                                            .map((e) => ServiceReviewLayout(
                                                data: e.value,
                                                index: e.key,
                                                list: appArray.reviewList)),
                                      const VSpace(Sizes.s100)
                                    ]).paddingOnly(
                                    left: Insets.i20, right: Insets.i20)),
                          ),
                          AnimatedBuilder(
                              animation: value.scrollController,
                              builder: (BuildContext context, Widget? child) {
                                return AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    height: value.scrollController.position
                                                .userScrollDirection ==
                                            ScrollDirection.reverse
                                        ? 0
                                        : 70,
                                    color: appColor(context).whiteBg,
                                    padding: const EdgeInsets.only(
                                        left: Insets.i20,
                                        right: Insets.i20,
                                        bottom: Insets.i20),
                                    child: value.booking!.bookingStatus?.slug ==
                                            /* appFonts.ontheway */ appFonts
                                                .onthewayStatus
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 50,
                                            decoration: ShapeDecoration(
                                                color:
                                                    appColor(context).primary,
                                                shape: SmoothRectangleBorder(
                                                    borderRadius:
                                                        SmoothBorderRadius(
                                                            cornerRadius:
                                                                AppRadius.r8,
                                                            cornerSmoothing:
                                                                1))),
                                            child:
                                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                              value.isUpdateStatus
                                                  ? const CircularProgressIndicator(
                                                          color: Colors.white)
                                                      .center()
                                                      .padding(
                                                          vertical: Sizes.s5)
                                                  : Text(
                                                      translations!
                                                          .startService!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: appCss
                                                          .dmDenseSemiBold16
                                                          .textColor(
                                                              appColor(context)
                                                                  .whiteColor))
                                            ])).inkWell(onTap: () => value.onStart(context))
                                        /*  ButtonCommon(
                                                    title: translations!
                                                        .startService,
                                                    onTap: () => value
                                                        .onStart(context)) */
                                        : value.isPayButton
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 50,
                                                decoration: ShapeDecoration(
                                                    color: appColor(context)
                                                        .greenColor,
                                                    shape: SmoothRectangleBorder(
                                                        borderRadius:
                                                            SmoothBorderRadius(
                                                                cornerRadius:
                                                                    AppRadius
                                                                        .r8,
                                                                cornerSmoothing:
                                                                    1))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    value.isBooking
                                                        ? const CircularProgressIndicator(
                                                                color: Colors
                                                                    .white)
                                                            .center()
                                                            .padding(
                                                                vertical:
                                                                    Sizes.s5)
                                                        : Text(
                                                            // Check if advance payment is enabled and remaining payment is pending
                                                            (value.booking?.advancePaymentEnable ==
                                                                        true &&
                                                                    (value.booking
                                                                            ?.remainingPaymentStatus
                                                                            ?.toLowerCase() !=
                                                                        'completed'))
                                                                ? (symbolPosition
                                                                    ? "${language(context, translations!.pay)} ${getSymbol(context)}${value.booking?.remainingPaymentAmount?.toStringAsFixed(2)}"
                                                                    : "${language(context, translations!.pay)} ${value.booking?.remainingPaymentAmount?.toStringAsFixed(2)}${getSymbol(context)}")
                                                                : (value.booking
                                                                            ?.paymentStatus !=
                                                                        "COMPLETED"
                                                                    ? (symbolPosition
                                                                        ? value.booking?.grandTotalWithExtras !=
                                                                                0
                                                                            ? "${language(context, translations!.pay)} ${getSymbol(context)}${value.booking?.grandTotalWithExtras?.toStringAsFixed(2)}"
                                                                            : "${language(context, translations!.pay)} ${getSymbol(context)}${value.booking?.total?.toStringAsFixed(2)}"
                                                                        : value.booking?.grandTotalWithExtras !=
                                                                                0
                                                                            ? "${language(context, translations!.pay)} ${value.booking?.grandTotalWithExtras?.toStringAsFixed(2)}${getSymbol(context)}"
                                                                            : "${language(context, translations!.pay)} ${value.booking?.total?.toStringAsFixed(2)}${getSymbol(context)}")
                                                                    : (symbolPosition
                                                                        ? "${language(context, translations!.pay)} ${getSymbol(context)}${value.booking?.extraChargesTotal?.grandTotal == 0 ? value.booking?.total : value.booking?.extraChargesTotal?.grandTotal?.toStringAsFixed(2)}"
                                                                        : "${language(context, translations!.pay)} ${value.booking?.extraChargesTotal?.grandTotal == 0 ? value.booking?.total : value.booking?.extraChargesTotal?.grandTotal?.toStringAsFixed(2)}${getSymbol(context)}")),
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: appCss
                                                                .dmDenseSemiBold16
                                                                .textColor(appColor(
                                                                        context)
                                                                    .whiteColor),
                                                          )
                                                  ],
                                                ),
                                              ).inkWell(onTap: () => value.paySuccess(context))
                                            /* ButtonCommon(
                                                    title: "${language(context, translations!.pay)} ${getSymbol(context)}${(currency(context).currencyVal * totalServicesChargesAndTotalBooking(value.booking!)).toStringAsFixed(2)}",
                                                    onTap: () => value.paySuccess(
                                                          context,
                                                        ),
                                                    style: appCss.dmDenseSemiBold16.textColor(appColor(context).whiteColor),
                                                    color: appColor(context).greenColor,
                                                    c) */
                                            : value.booking?.service != null && value.booking!.service!.type == "remotely"
                                                ? Expanded(child: ButtonCommon(title: translations!.completed!, onTap: () => value.completeConfirmation(context, this)))
                                                : Row(children: [
                                                    Expanded(
                                                        child: ButtonCommon(
                                                            title: value.booking!.bookingStatus?.slug == appFonts.onHold
                                                                ? translations!
                                                                    .restart!
                                                                : translations!
                                                                    .pause!,
                                                            color: value
                                                                        .booking!
                                                                        .bookingStatus!
                                                                        .name!
                                                                        .toLowerCase() ==
                                                                    appFonts
                                                                        .onHold
                                                                ? const Color(
                                                                    0xFF27AF4D)
                                                                : const Color(
                                                                    0xFFFF4B4B),
                                                            onTap: () => value
                                                                        .booking!
                                                                        .bookingStatus!
                                                                        .slug ==
                                                                    appFonts
                                                                        .onHold
                                                                ? value.onPauseConfirmation(
                                                                    context,
                                                                    isHold: false)
                                                                : value.onPauseConfirmation(context))),
                                                    const HSpace(Sizes.s15),
                                                    Expanded(
                                                        child: ButtonCommon(
                                                            title: translations!
                                                                .completed!,
                                                            onTap: () => value
                                                                .completeConfirmation(
                                                                    context,
                                                                    this)))
                                                  ]));
                              })
                        ]))));
    });
  }
}
