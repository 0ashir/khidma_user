import '../../../common_tap.dart';
import '../../../config.dart';
import '../../bottom_screens/booking_screen/booking_shimmer/booking_detail_shimmer.dart';

class CancelledBookingScreen extends StatelessWidget {
  const CancelledBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CancelledBookingProvider>(builder: (context1, val, child) {
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

      return StatefulWrapper(
        onInit: () => Future.delayed(
            const Duration(milliseconds: 150), () => val.onReady(context)),
        child: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            val.onBack(context, false);
            if (didPop) return;
          },
          child: Scaffold(
              appBar: AppBarCommon(
                title: translations!.cancelledBooking,
                onTap: () {
                  val.onBack(context, true);
                },
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  val.getBookingDetailBy(context);
                },
                child: val.isLoading || val.booking == null
                    ? const BookingDetailShimmer()
                    : SingleChildScrollView(
                        child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              StatusDetailLayout(
                                  data: val.booking,
                                  onTapStatus: () =>
                                      showBookingStatus(context, val.booking)),
                              Text(language(context, translations!.billSummary),
                                      style: appCss.dmDenseSemiBold14.textColor(
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
                                              title: translations!
                                                  .perServiceCharge,
                                              price: symbolPosition
                                                  ? "${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.perServicemanCharge ?? 0.0)).toStringAsFixed(2)}"
                                                  : "${(currency(context).currencyVal * (val.booking!.perServicemanCharge ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}"),
                                          BillRowCommon(
                                                  title:
                                                      "${((val.booking!.requiredServicemen ?? 1) + (val.booking!.totalExtraServicemen != null ? (val.booking!.totalExtraServicemen ?? 1) : 0))} ${language(context, translations!.serviceman)}",
                                                  price: symbolPosition
                                                      ? "${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.subtotal ?? 0.0)).toStringAsFixed(2)}"
                                                      : "${(currency(context).currencyVal * (val.booking!.subtotal ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                  style: appCss.dmDenseBold14
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText))
                                              .paddingSymmetric(
                                                  vertical: Insets.i20),

                                          if (val.booking!.service?.discount !=
                                                  null &&
                                              val.booking!.service?.discount !=
                                                  0)
                                            BillRowCommon(
                                                    color:
                                                        appColor(context).green,
                                                    title:
                                                        "${translations!.appliedDiscount} (${val.booking!.service!.discount}%)",
                                                    price: formattedDifference)
                                                .marginOnly(bottom: Insets.i20),
                                          // BillRowCommon(
                                          //         title: translations!.tax,
                                          //         price:
                                          //             "+${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.tax ?? 0.0)).toStringAsFixed(2)}",
                                          //         color:
                                          //             appColor(context).online)
                                          //     .paddingOnly(bottom: Insets.i20),
                                          BillRowCommon(
                                              title: translations!.platformFees,
                                              price: symbolPosition
                                                  ? "+${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}"
                                                  : "+${(currency(context).currencyVal * (val.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                              color: appColor(context).online)
                                        ],
                                      ),
                                      const VSpace(Sizes.s30),
                                      /* Divider(
                                color: appColor(context).stroke, thickness: 1, height: 1,indent: 6,endIndent: 6).paddingOnly(bottom:23),*/
                                      BillRowCommon(
                                              title: translations!.totalAmount,
                                              price: symbolPosition
                                                  ? "${getSymbol(context)}${(currency(context).currencyVal * (val.booking!.total ?? 0.0)).toStringAsFixed(2)}"
                                                  : "${(currency(context).currencyVal * (val.booking!.total ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                              styleTitle: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .darkText),
                                              style: appCss.dmDenseBold16
                                                  .textColor(appColor(context)
                                                      .primary))
                                          .paddingOnly(top: Insets.i10),
                                    ]).paddingSymmetric(vertical: Insets.i20),
                              ),
                              if (val.booking?.bookingReasons?.isNotEmpty ??
                                  false)
                                Text(language(context, translations!.reason),
                                        style: appCss.dmDenseSemiBold14
                                            .textColor(
                                                appColor(context).darkText))
                                    .paddingOnly(
                                        top: Insets.i10, bottom: Insets.i10),
                              // const VSpace(Sizes.s20),
                              if (val.booking?.bookingReasons?.isNotEmpty ??
                                  false)
                                Container(
                                  padding: const EdgeInsets.all(Insets.i20),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: ShapeDecoration(
                                    color:
                                        appColor(context).red.withOpacity(0.1),
                                    shadows: [
                                      BoxShadow(
                                        color: appColor(context).whiteBg,
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                      )
                                    ],
                                    shape: SmoothRectangleBorder(
                                      side: BorderSide(
                                          color: appColor(context).fieldCardBg),
                                      borderRadius: SmoothBorderRadius(
                                        cornerRadius: AppRadius.r12,
                                        cornerSmoothing: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    val.booking!.bookingReasons!.first.reason
                                            ?.toString() ??
                                        "",
                                    style: TextStyle(
                                      fontSize: Sizes.s15,
                                      color: appColor(context).red,
                                    ),
                                  ),
                                ),
                            ])
                            .padding(horizontal: Insets.i20, bottom: Sizes.s30),
                      ),
              )),
        ),
      );
    });
  }
}
