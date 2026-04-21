import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/screens/app_pages_screens/pending_booking_screen/layouts/payment_status_summary.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../config.dart';
import '../../bottom_screens/booking_screen/booking_shimmer/booking_detail_shimmer.dart';

class AcceptedBookingScreen extends StatelessWidget {
  const AcceptedBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AcceptedBookingProvider, PendingBookingProvider>(
        builder: (context, val, val2, child) {
      final price = val.booking?.service?.price ?? 0.0;
      final requiredServicemen = val.booking?.service?.requiredServicemen ?? 1;
      final selectedRequiredServiceMan =
          val.booking?.service?.selectedRequiredServiceMan ?? 1;
      final serviceRate = val.booking?.service?.serviceRate ?? 0.0;

      final currencyVal = currency(context).currencyVal;

      double totalPrice = (currencyVal *
          ((price / requiredServicemen) * selectedRequiredServiceMan));
      double baseRate =
          (currencyVal * (serviceRate * selectedRequiredServiceMan));
      double difference = totalPrice - baseRate;

      String formattedDifference = symbolPosition
          ? "-${getSymbol(context)}${difference.toStringAsFixed(2)}"
          : "-${difference.toStringAsFixed(2)}${getSymbol(context)}";
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            val.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
              onInit: () => Future.delayed(const Duration(milliseconds: 150),
                  () => val.onReady(context)),
              child: val.isLoading || val.booking == null
                  ? const BookingDetailShimmer().padding(top: Sizes.s40)
                  : Scaffold(
                      appBar: AppBarCommon(
                          title: val.booking?.bookingStatus?.slug == "assigned"
                              ? translations?.assignBooking ??
                                  appFonts.assignedBooking
                              : translations?.acceptedBookings,
                          onTap: () => val.onBack(context, true)),
                      body: SizedBox.expand(
                          child: Stack(children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            val.onRefresh(context);
                          },
                          child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                StatusDetailLayout(
                                    data: val.booking,
                                    onTapStatus: () => showBookingStatus(
                                        context, val.booking)),
                                Text(
                                        language(
                                            context, translations!.billSummary),
                                        style: appCss.dmDenseSemiBold14
                                            .textColor(
                                                appColor(context).darkText))
                                    .paddingOnly(
                                        top: Insets.i25, bottom: Insets.i10),
                                Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(isDark(context)
                                              ? eImageAssets.pendingBillBgDark
                                              : eImageAssets.pendingBillBg),
                                          fit: BoxFit.fill)),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            BillRowCommon(
                                              title: translations!.service,
                                              price: symbolPosition
                                                  ? "${getSymbol(context)}${(val.booking?.service?.price)}"
                                                  : "${((val.booking?.service?.price)).toStringAsFixed(2)}${getSymbol(context)}",
                                            ).marginOnly(bottom: Insets.i20),
                                            if (val.booking!.service
                                                        ?.discount !=
                                                    null &&
                                                val.booking?.service
                                                        ?.discount !=
                                                    0)
                                              BillRowCommon(
                                                      color:
                                                          appColor(context).red,
                                                      title:
                                                          "${translations!.appliedDiscount} (${val.booking!.service!.discount}%)",
                                                      price:
                                                          formattedDifference)
                                                  .marginOnly(
                                                      bottom: Insets.i20),
                                            BillRowCommon(
                                                    title:
                                                        "${(val.booking!.requiredServicemen != null ? val.booking!.requiredServicemen! : 0) + (val.booking!.totalExtraServicemen != null ? val.booking!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${getSymbol(context)}${((val.booking?.perServicemanCharge))} × ${(val.booking!.requiredServicemen != null ? val.booking!.requiredServicemen! : 0) + (val.booking!.totalExtraServicemen != null ? val.booking!.totalExtraServicemen! : 0)})",
                                                    price: symbolPosition
                                                        ? "${getSymbol(context)}${(val.booking?.totalExtraServicemenCharge)}"
                                                        : "${(val.booking?.totalExtraServicemenCharge)}${getSymbol(context)}",
                                                    style: appCss.dmDenseBold14
                                                        .textColor(
                                                            appColor(context)
                                                                .darkText))
                                                .marginOnly(bottom: Insets.i20),
                                            /* BillRowCommon(
                                                      title:
                                                          "${((val.booking!.requiredServicemen ?? 1) + (val.booking!.totalExtraServicemen != null ? (val.booking!.totalExtraServicemen ?? 1) : 0))} ${language(context, translations!.serviceman)}",
                                                      price:
                                                          "${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.service?.price / (val.booking!.requiredServicemen ?? 1) + (val.booking!.totalExtraServicemen ?? 0))).toStringAsFixed(2)}",
                                                      style: appCss.dmDenseBold14
                                                          .textColor(
                                                              appColor(context)
                                                                  .darkText))
                                                  .paddingSymmetric(
                                                      vertical: Insets.i20), */

                                            if (val.booking!
                                                    .additionalServices !=
                                                null)
                                              ...val
                                                  .booking!.additionalServices!
                                                  .map((charge) {
                                                return BillRowCommon(
                                                  title:
                                                      "${charge.title} (\$${charge.price} × ${charge.qty})",
                                                  color:
                                                      appColor(context).green,
                                                  price: symbolPosition
                                                      ? "+${getSymbol(context)}${charge.totalPrice!.toStringAsFixed(2)}"
                                                      : "+${charge.totalPrice!.toStringAsFixed(2)}${getSymbol(context)}",
                                                ).padding(bottom: Insets.i20);
                                              }),
                                            /*  if (val.booking!.taxes != null)
                                                BillRowCommon(
                                                        title:
                                                            translations!.tax,
                                                        price:
                                                            "+${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.tax ?? 0.0)).toStringAsFixed(2)}",
                                                        color: appColor(context)
                                                            .online)
                                                    .paddingOnly(
                                                        bottom: Insets.i20), */
                                            BillRowCommon(
                                                    title: translations!
                                                        .platformFees,
                                                    price: symbolPosition
                                                        ? "+${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}"
                                                        : "+${(currency(context).currencyVal * (val.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                    color: appColor(context)
                                                        .online)
                                                .padding(bottom: Insets.i20),
                                            if (val.booking!.taxes != null &&
                                                val.booking!.taxes!.isNotEmpty)
                                              ...val.booking!.taxes!.map((tax) {
                                                double rate = tax.rate ?? 0;

                                                return BillRowCommon(
                                                  title:
                                                      "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                                                  price:
                                                      "+${getSymbol(context)}${tax.amount}",
                                                  color:
                                                      appColor(context).online,
                                                ).paddingOnly(
                                                    bottom: Insets.i10);
                                              }),
                                            if (val.booking!.taxes != null &&
                                                val.booking!.taxes!.isNotEmpty)
                                              const VSpace(Sizes.s20),
                                          ],
                                        ),
                                        const VSpace(Sizes.s15),
                                        /* Divider(
                                                color: appColor(context).stroke, thickness: 1, height: 1,indent: 6,endIndent: 6).paddingOnly(bottom:23),*/
                                        BillRowCommon(
                                                title:
                                                    translations!.totalAmount,
                                                price: symbolPosition
                                                    ? "${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.total ?? 0.0)).toStringAsFixed(2)}"
                                                    : "${(currency(context).currencyVal * (val.booking!.total ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                styleTitle: appCss
                                                    .dmDenseMedium14
                                                    .textColor(appColor(context)
                                                        .darkText),
                                                style: appCss.dmDenseBold16
                                                    .textColor(appColor(context)
                                                        .primary))
                                            .paddingOnly(top: Insets.i10)
                                      ]).paddingSymmetric(vertical: Insets.i20),
                                ),
                                if (val.booking!.advancePaymentEnable!)
                                  PaymentSummaryWidget(
                                    booking: val.booking!,
                                  ),
                                // if (val.booking?.service!.reviews != null &&
                                //     val.booking!.service!.reviews!.isNotEmpty)
                                //   Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: [
                                //         Expanded(
                                //             child: Text(
                                //                 language(context,
                                //                     translations!.review),
                                //                 overflow: TextOverflow.clip,
                                //                 style: appCss
                                //                     .dmDenseSemiBold14
                                //                     .textColor(
                                //                         appColor(context)
                                //                             .darkText))),
                                //         Text(
                                //                 language(context,
                                //                     translations!.viewAll),
                                //                 style: appCss.dmDenseRegular14
                                //                     .textColor(
                                //                         appColor(context)
                                //                             .primary))
                                //             .inkWell(
                                //                 onTap: () => route.pushNamed(
                                //                     context,
                                //                     routeName
                                //                         .servicesReviewScreen,
                                //                     arg:
                                //                         val.booking!.service))
                                //       ]).paddingOnly(
                                //       top: Insets.i20, bottom: Insets.i12),
                                // if (val.booking?.service!.reviews != null)
                                //   ...val.booking!.service!.reviews!
                                //       .asMap()
                                //       .entries
                                //       .map((e) => ServiceReviewLayout(
                                //           data: e.value,
                                //           index: e.key,
                                //           list: appArray.reviewList)),
                                (val.booking?.bookingStatus?.slug ==
                                            appFonts.accepted ||
                                        val.booking?.bookingStatus?.slug ==
                                            appFonts.pending)
                                    ? val.checkForCancelButtonShow()
                                        ? ButtonCommon(
                                            title: translations!.cancelBooking!,
                                            onTap: () => val.onCancelBooking(
                                                context)).paddingOnly(
                                            top: Insets.i35, bottom: Insets.i30)
                                        : const VSpace(Sizes.s80)
                                    : const VSpace(Sizes.s80)
                              ]).paddingSymmetric(horizontal: Insets.i20)),
                        ),
                        // if(val.booking?.bookingStatus?.slug == "assign")
                        if (val.booking?.bookingStatus?.slug == "assigned" &&
                            (val.booking?.service?.type == "remotely" ||
                                val.booking?.service?.type == "provider_site"))
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(children: [
                                if (val.booking!.service!.type ==
                                    "provider_site")
                                  Expanded(
                                    child: ButtonCommon(
                                            title: translations!.location!,
                                            color: appColor(context).whiteBg,
                                            borderColor: appColor(context).primary,
                                            fontColor: appColor(context).primary,
                                            onTap: () async {
                                              print(
                                                  "objectpppp-=-==- ${val.booking?.service?.destinationLocation?.lat}");
                                              final availableMaps =
                                                  await MapLauncher
                                                      .installedMaps;

                                              await availableMaps.first
                                                  .showMarker(
                                                coords: Coords(
                                                  double.tryParse(val
                                                              .booking
                                                              ?.service
                                                              ?.destinationLocation
                                                              ?.lat ??
                                                          '') ??
                                                      0.0,
                                                  double.tryParse(val
                                                              .booking
                                                              ?.service
                                                              ?.destinationLocation
                                                              ?.lng ??
                                                          '') ??
                                                      0.0,
                                                ),
                                                title: "Ocean Beach",
                                              );
                                            })
                                        .paddingOnly(
                                            left: Sizes.s20,
                                            right: Sizes.s20,
                                            bottom: Insets.i20)
                                        .backgroundColor(
                                            appColor(context).whiteBg),
                                  ),
                                val.booking!.service!.type == "remotely"
                                    ? val.booking?.zoomMeeting == null
                                        ? Container()
                                        : Expanded(
                                            child: ButtonCommon(
                                                    title:
                                                        /* val.isJoin == true
                                                              ? translations!
                                                                  .completed!
                                                              :*/
                                                        "Join Meeting",
                                                    onTap: () {
                                                      val.openZoom(context,
                                                          bookingId:
                                                              val.booking?.id,
                                                          meetingLink: val
                                                              .booking
                                                              ?.zoomMeeting
                                                              ?.joinUrl);
                                                      /* if (val.isJoin ==
                                                            true) {

                                                          // final abcd = Provider.of<OngoingBookingProvider>(context,listen: false);
                                                          // abcd.completeConfirmation(context, this);
                                                        } else {
                                                          val.openZoom(
                                                              meetingLink: val
                                                                  .booking
                                                                  ?.zoomMeeting
                                                                  ?.joinUrl);
                                                        }*/
                                                    })
                                                .paddingOnly(
                                                    left: Sizes.s20,
                                                    right: Sizes.s20,
                                                    bottom: Insets.i20)
                                                .backgroundColor(
                                                    appColor(context).whiteBg),
                                          )
                                    : Expanded(
                                        child:
                                            ButtonCommon(
                                                    title: translations!
                                                        .startService!,
                                                    onTap: () =>
                                                        val.onStart(context))
                                                .paddingOnly(
                                                    left: Sizes.s20,
                                                    right: Sizes.s20,
                                                    bottom: Insets.i20)
                                                .backgroundColor(
                                                    appColor(context).whiteBg))
                              ]))
                      ])))));
    });
  }
}
