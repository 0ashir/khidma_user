// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/screens/app_pages_screens/completed_service_screen/layouts/completed_bill_paid.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../config.dart';
import '../../bottom_screens/booking_screen/booking_shimmer/booking_detail_shimmer.dart';

class CompletedServiceScreen extends StatelessWidget {
  const CompletedServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletedServiceProvider>(
        builder: (context1, value, child) {
      log("value.booking!.paymentStatus::${value.booking}");
      return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          value.booking = null;
          value.isDownloading = false;
          value.progress = "";
          value.notifyListeners();
          if (didPop) return;
        },
        child: StatefulWrapper(
            onInit: () => Future.delayed(const Duration(milliseconds: 150),
                () => value.onReady(context)),
            child: Scaffold(
                appBar: AppBarCommon(
                  title: translations!.completedBooking,
                  onTap: () {
                    value.booking = null;
                    value.isDownloading = false;
                    value.progress = "";
                    value.notifyListeners();
                    route.pop(context);
                  },
                ),
                body: value.isLoading || value.booking == null
                    ? const BookingDetailShimmer()
                    : SizedBox.expand(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              children: [
                                RefreshIndicator(
                                  onRefresh: () async {
                                    value.getBookingDetailBy(context);
                                  },
                                  child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              kToolbarHeight -
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top,

                                          //https://fixit.com/booking/invoice/262254
                                        ),
                                        child: IntrinsicHeight(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      StatusDetailLayout(
                                                        data: value.booking,
                                                        rateTap: (id) => route
                                                            .pushNamed(
                                                                context,
                                                                routeName
                                                                    .rateApp,
                                                                arg: {
                                                              "isServiceRate":
                                                                  true,
                                                              "servicemanId": id
                                                            }).then((e) => value
                                                                .getBookingDetailBy(
                                                                    context)),
                                                        onTapStatus: () =>
                                                            showBookingStatus(
                                                                context,
                                                                value.booking),
                                                        isLayout: true,
                                                      ),
                                                      Text(
                                                              language(
                                                                  context,
                                                                  translations!
                                                                      .billSummary),
                                                              style: appCss
                                                                  .dmDenseSemiBold14
                                                                  .textColor(appColor(
                                                                          context)
                                                                      .darkText))
                                                          .paddingOnly(
                                                              top: Insets.i25,
                                                              bottom:
                                                                  Insets.i10),
                                                      if (value.booking!
                                                              .paymentStatus !=
                                                          null)
                                                        value.booking!
                                                                    .paymentStatus!
                                                                    .toLowerCase() !=
                                                                translations!
                                                                    .completed
                                                            ? value.booking!.extraCharges !=
                                                                        null &&
                                                                    value
                                                                        .booking!
                                                                        .extraCharges!
                                                                        .isNotEmpty
                                                                ? CompletedBookingBillPaidLayout(
                                                                    bookingModel:
                                                                        value
                                                                            .booking)
                                                                : CompletedBookingBillLayoutIfNotPaid(
                                                                    bookingModel:
                                                                        value
                                                                            .booking)
                                                            : CompletedBookingBillPaidLayout(
                                                                bookingModel:
                                                                    value
                                                                        .booking),
                                                      if (value.booking!
                                                                  .extraCharges !=
                                                              null &&
                                                          value
                                                              .booking!
                                                              .extraCharges!
                                                              .isNotEmpty)
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                      language(
                                                                          context,
                                                                          translations!
                                                                              .addedServiceDetails),
                                                                      style: appCss
                                                                          .dmDenseSemiBold14
                                                                          .textColor(appColor(context)
                                                                              .darkText))
                                                                  .padding(
                                                                      top: Insets
                                                                          .i20,
                                                                      bottom: Insets
                                                                          .i10),
                                                              AddServiceLayout(
                                                                  extraCharge: value
                                                                      .booking!
                                                                      .extraCharges),
                                                            ]),
                                                      Text(
                                                              language(
                                                                  context,
                                                                  translations!
                                                                      .paymentSummary),
                                                              style: appCss
                                                                  .dmDenseSemiBold14
                                                                  .textColor(appColor(
                                                                          context)
                                                                      .darkText))
                                                          .padding(
                                                              top: Insets.i25,
                                                              bottom:
                                                                  Insets.i10),
                                                      CompletedBookingPaymentSummaryLayout(
                                                          bookingModel:
                                                              value.booking),
                                                      if (value.booking!
                                                                  .service !=
                                                              null &&
                                                          value
                                                                  .booking!
                                                                  .service!
                                                                  .reviews !=
                                                              null &&
                                                          value
                                                              .booking!
                                                              .service!
                                                              .reviews!
                                                              .isNotEmpty)
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
                                                                          TextOverflow
                                                                              .clip,
                                                                      style: appCss
                                                                          .dmDenseSemiBold14
                                                                          .textColor(
                                                                              appColor(context).darkText))),
                                                              // Text(
                                                              //         language(
                                                              //             context,
                                                              //             translations!
                                                              //                 .viewAll),
                                                              //         style: appCss
                                                              //             .dmDenseRegular14
                                                              //             .textColor(appColor(
                                                              //                     context)
                                                              //                 .primary))
                                                              //     .inkWell(
                                                              //         onTap: () =>
                                                              //             route.pushNamed(
                                                              //                 context,
                                                              //                 routeName
                                                              //                     .servicesReviewScreen,
                                                              //                 arg: value
                                                              //                     .booking!
                                                              //                     .service))
                                                            ]).paddingOnly(
                                                            top: Insets.i20,
                                                            bottom: Insets.i12),
                                                      if (value
                                                              .booking!
                                                              .service!
                                                              .reviews !=
                                                          null)
                                                        ...value.booking!
                                                            .service!.reviews!
                                                            .asMap()
                                                            .entries
                                                            .map((e) =>
                                                                ServiceReviewLayout(
                                                                    data:
                                                                        e.value,
                                                                    index:
                                                                        e.key,
                                                                    list: appArray
                                                                        .reviewList)),
                                                    ]).padding(
                                                    horizontal: Insets.i20),
                                                const VSpace(Sizes.s40),
                                              ]),
                                        ),
                                      )).paddingOnly(bottom: Insets.i40),
                                ),
                                value.booking!.paymentMethod == "cash"
                                    ? value.booking!.paymentStatus! ==
                                            translations!.completed!
                                                .toUpperCase()
                                        ? Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              color: appColor(context).whiteBg,
                                              child: value.booking!.bookingStatus!.slug !=
                                                          appFonts.completed
                                                              .toLowerCase() &&
                                                      value.booking!.paymentStatus !=
                                                          appFonts.completed
                                                              .toUpperCase()
                                                  ? const CompletedStatusLayout()
                                                  : BottomSheetButtonCommon(
                                                      textOne:
                                                          translations!.invoice,
                                                      iconOne: SvgPicture.asset(
                                                          eSvgAssets.download,
                                                          colorFilter: ColorFilter.mode(
                                                              appColor(context)
                                                                  .primary,
                                                              BlendMode.srcIn)),
                                                      iconTwo: SvgPicture.asset(
                                                          eSvgAssets.rate,
                                                          colorFilter: ColorFilter.mode(appColor(context).whiteBg, BlendMode.srcIn)),
                                                      textTwo: translations!.rateUs,
                                                      isRateComplete: isServiceRate(value.booking!.service!.reviews!),
                                                      applyTap: () /* {
                                                        log("message=-=-=-=-=-=-${value.booking!.service?.id ?? ""}");
                                                      } */
                                                          {
                                                        value
                                                            .requestPermissionAndDownload(
                                                                context);
                                                        route.pushNamed(context,
                                                            routeName.rateApp,
                                                            arg: {
                                                              "isServiceRate":
                                                                  true,
                                                              "serviceId": value
                                                                  .booking!
                                                                  .service
                                                                  ?.id
                                                            }).then((e) => value
                                                            .getBookingDetailBy(
                                                                context));
                                                      },
                                                      clearTap: () => value.requestPermissionAndDownload(context)),
                                            ).paddingDirectional(
                                                top: Sizes.s10),
                                          )
                                        : Align(
                                            alignment: Alignment.bottomCenter,
                                            child: ButtonCommon(
                                                    title: symbolPosition
                                                        ? "${language(context, translations!.pay)} ${getSymbol(context)}${(currency(context).currencyVal * totalServicesChargesAndTotalBooking(value.booking!)).toStringAsFixed(2)}"
                                                        : "${language(context, translations!.pay)} ${(currency(context).currencyVal * totalServicesChargesAndTotalBooking(value.booking!)).toStringAsFixed(2)}${getSymbol(context)}",
                                                    margin: 20,
                                                    onTap: () => value
                                                        .paySuccess(context),
                                                    style: appCss
                                                        .dmDenseSemiBold16
                                                        .textColor(
                                                            appColor(context)
                                                                .whiteColor),
                                                    color: appColor(context)
                                                        .greenColor,
                                                    borderColor:
                                                        appColor(context)
                                                            .greenColor)
                                                .paddingOnly(
                                                    bottom: Insets.i20),
                                          )
                                    : value.booking!.extraCharges != null &&
                                            value.booking!.extraCharges!
                                                .isNotEmpty &&
                                            value.booking!.extraCharges!
                                                .where((element) =>
                                                    element.paymentStatus !=
                                                    translations!.completed)
                                                .isEmpty
                                        ? Align(
                                            alignment: Alignment.bottomCenter,
                                            child: ButtonCommon(
                                                    title: symbolPosition
                                                        ? "${language(context, translations!.pay)} ${getSymbol(context)}${(currency(context).currencyVal * totalServicesChargesAndTotalBooking(value.booking!)).toStringAsFixed(2)}"
                                                        : "${language(context, translations!.pay)} ${(currency(context).currencyVal * totalServicesChargesAndTotalBooking(value.booking!)).toStringAsFixed(2)}${getSymbol(context)}",
                                                    margin: 20,
                                                    onTap: () => value
                                                        .paySuccess(context),
                                                    style: appCss
                                                        .dmDenseSemiBold16
                                                        .textColor(
                                                            appColor(context)
                                                                .whiteColor),
                                                    color: appColor(context)
                                                        .greenColor,
                                                    borderColor:
                                                        appColor(context)
                                                            .greenColor)
                                                .paddingOnly(
                                                    bottom: Insets.i20),
                                          )
                                        : Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              color: appColor(context).whiteBg,
                                              child: value
                                                              .booking!
                                                              .bookingStatus!
                                                              .slug !=
                                                          appFonts.completed
                                                              .toLowerCase() &&
                                                      value.booking!.paymentStatus!
                                                              .toLowerCase() !=
                                                          appFonts.completed
                                                              .toLowerCase()
                                                  ? const CompletedStatusLayout()
                                                  : BottomSheetButtonCommon(
                                                      textOne:
                                                          translations!.invoice,
                                                      textTwo:
                                                          translations!.rateUs,
                                                      iconOne: SvgPicture.asset(
                                                          eSvgAssets.download,
                                                          colorFilter: ColorFilter.mode(
                                                              appColor(context)
                                                                  .primary,
                                                              BlendMode.srcIn)),
                                                      iconTwo: SvgPicture.asset(eSvgAssets.rate, colorFilter: ColorFilter.mode(appColor(context).whiteBg, BlendMode.srcIn)),
                                                      // isRateComplete: isServiceRate(value.booking!.service!.reviews!=[]?value.booking!.service!.reviews:null),
                                                      applyTap: () {
                                                        log("message=-==-=-=-=-=-=${value.booking!.service?.id}");
                                                        route.pushNamed(context,
                                                            routeName.rateApp,
                                                            arg: {
                                                              "isServiceRate":
                                                                  true,
                                                              "serviceId": value
                                                                  .booking!
                                                                  .service
                                                                  ?.id
                                                            }).then((e) => value
                                                            .getBookingDetailBy(
                                                                context));
                                                      } /* => route.pushNamed(context, routeName.rateApp, arg: {"isServiceRate": true, "serviceId": value.booking!.serviceId}) */ /* .then((e) => value.getBookingDetailBy(context)) */,
                                                      clearTap: () => value.requestPermissionAndDownload(context)),
                                            ),
                                          )
                              ],
                            ),
                            if (value.isDownloading)
                              Container(
                                padding: const EdgeInsets.all(Sizes.s12),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r8),
                                    color: appColor(context)
                                        .darkText
                                        .withOpacity(0.2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: appColor(context).stroke,
                                          blurRadius: AppRadius.r16,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 0)
                                    ]),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                language(context,
                                                    translations!.downloadBill),
                                                style: appCss.dmDenseMedium16
                                                    .textColor(appColor(context)
                                                        .primary)),
                                          ]),
                                      const HSpace(Sizes.s20),
                                      CircularPercentIndicator(
                                          radius: 27.0,
                                          lineWidth: Sizes.s6,
                                          animation: true,
                                          percent: (value.perc / 100),
                                          center: Text(
                                              '${value.valDownload.toStringAsFixed(0)}%',
                                              style: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .darkText)),
                                          backgroundColor:
                                              appColor(context).primary,
                                          circularStrokeCap:
                                              CircularStrokeCap.round,
                                          progressColor:
                                              appColor(context).primary)
                                    ]),
                              ),
                          ],
                        ),
                      ))),
      );
    });
  }
}
