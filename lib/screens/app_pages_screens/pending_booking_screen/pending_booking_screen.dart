import 'package:fixit_user/screens/app_pages_screens/pending_booking_screen/layouts/payment_status_summary.dart';
import 'package:fixit_user/screens/bottom_screens/booking_screen/booking_shimmer/booking_detail_shimmer.dart';
import '../../../common_tap.dart';
import '../../../config.dart';

class PendingBookingScreen extends StatelessWidget {
  const PendingBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PendingBookingProvider>(builder: (context1, value, child) {
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            value.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
              onInit: () => value.onReady(context),
              child: Scaffold(
                  appBar: AppBarCommon(
                    title: translations!.pendingBooking,
                    onTap: () => value.onBack(context, true),
                  ),
                  body: SafeArea(
                      child: value.isLoading || value.booking == null
                          ? const BookingDetailShimmer()
                          : ListView(children: [
                              RefreshIndicator(
                                  onRefresh: () => value.onRefresh(context),
                                  child: SingleChildScrollView(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        StatusDetailLayout(
                                          data: value.booking!,
                                          onTapStatus: () => showBookingStatus(
                                              context, value.booking),
                                        ),
                                        Text(
                                          language(context,
                                              translations!.billSummary),
                                          style: appCss.dmDenseSemiBold14
                                              .textColor(
                                                  appColor(context).darkText),
                                        ).paddingOnly(
                                            top: Insets.i15,
                                            bottom: Insets.i10),
                                        Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(isDark(
                                                            context)
                                                        ? eImageAssets
                                                            .pendingBillBgDark
                                                        : eImageAssets
                                                            .pendingBillBg),
                                                    fit: BoxFit.fill)),
                                            child: Column(children: [
                                              BillRowCommon(
                                                      title:
                                                          "${translations?.service}",
                                                      price: symbolPosition
                                                          ? "${getSymbol(context)}${value.booking?.service?.price!.toStringAsFixed(2)}"
                                                          : "${value.booking?.service?.price!.toStringAsFixed(2)}${getSymbol(context)}",
                                                      style: appCss
                                                          .dmDenseBold14
                                                          .textColor(
                                                              appColor(context)
                                                                  .darkText))
                                                  .padding(bottom: Insets.i10),
                                              if (value.booking!.service
                                                          ?.discount !=
                                                      null &&
                                                  value.booking!.service
                                                          ?.discount !=
                                                      0)
                                                BillRowCommon(
                                                        color: appColor(context)
                                                            .red,
                                                        title:
                                                            "${translations!.appliedDiscount} (${value.booking!.service!.discount}%)",
                                                        price: symbolPosition
                                                            ? "-${getSymbol(context)}${value.booking?.service?.discountAmount}"
                                                            : "-${value.booking?.service?.discountAmount}${getSymbol(context)}")
                                                    .marginOnly(
                                                        bottom: Insets.i10),
                                              if (value.booking!
                                                          .couponTotalDiscount !=
                                                      null &&
                                                  value.booking!
                                                          .couponTotalDiscount !=
                                                      0.0)
                                                BillRowCommon(
                                                        color: appColor(context)
                                                            .red,
                                                        title:
                                                            "${translations!.couponDiscount} ",
                                                        price: symbolPosition
                                                            ? "-${getSymbol(context)}${value.booking!.couponTotalDiscount.toString()}"
                                                            : "-${value.booking!.couponTotalDiscount.toString()}${getSymbol(context)}")
                                                    .marginOnly(
                                                        bottom: Insets.i10),
                                              BillRowCommon(
                                                      title: symbolPosition
                                                          ? "${(value.booking!.requiredServicemen != null ? value.booking!.requiredServicemen! : 0) + (value.booking!.totalExtraServicemen != null ? value.booking!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${getSymbol(context)}${value.booking?.perServicemanCharge} × ${(value.booking!.requiredServicemen != null ? value.booking!.requiredServicemen! : 0) + (value.booking!.totalExtraServicemen != null ? value.booking!.totalExtraServicemen! : 0)})"
                                                          : "${(value.booking!.requiredServicemen != null ? value.booking!.requiredServicemen! : 0) + (value.booking!.totalExtraServicemen != null ? value.booking!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${value.booking?.perServicemanCharge}${getSymbol(context)} × ${(value.booking!.requiredServicemen != null ? value.booking!.requiredServicemen! : 0) + (value.booking!.totalExtraServicemen != null ? value.booking!.totalExtraServicemen! : 0)})",
                                                      price: symbolPosition
                                                          ? "${getSymbol(context)}${value.booking?.totalExtraServicemenCharge!.toStringAsFixed(2)}"
                                                          : "${value.booking?.totalExtraServicemenCharge!.toStringAsFixed(2)}${getSymbol(context)}",
                                                      style: appCss
                                                          .dmDenseBold14
                                                          .textColor(
                                                              appColor(context)
                                                                  .darkText))
                                                  .padding(bottom: Insets.i10),
                                              if (value.booking!
                                                      .additionalServices !=
                                                  null)
                                                ...value.booking!
                                                    .additionalServices!
                                                    .map((charge) {
                                                  return BillRowCommon(
                                                          title:
                                                              "${charge.title} (\$${charge.price} × ${charge.qty})",
                                                          color:
                                                              appColor(context)
                                                                  .green,
                                                          price: symbolPosition
                                                              ? "+${getSymbol(context)}${charge.totalPrice!.toStringAsFixed(2)}"
                                                              : "+${charge.totalPrice!.toStringAsFixed(2)}${getSymbol(context)}")
                                                      .padding(
                                                          bottom: Insets.i10);
                                                }),
                                              BillRowCommon(
                                                title:
                                                    translations!.platformFees,
                                                price: symbolPosition
                                                    ? "+${getSymbol(context)}${(currency(context).currencyVal * (value.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}"
                                                    : "+${(currency(context).currencyVal * (value.booking!.platformFees ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                color: appColor(context).online,
                                              ).padding(bottom: Insets.i10),
                                              if (value.booking!.taxes !=
                                                      null &&
                                                  value.booking!.taxes!
                                                      .isNotEmpty)
                                                ...value.booking!.taxes!
                                                    .map((tax) {
                                                  double rate = tax.rate ?? 0;

                                                  return BillRowCommon(
                                                          title:
                                                              "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                                                          price: symbolPosition
                                                              ? "+${getSymbol(context)}${tax.amount}"
                                                              : "+${tax.amount}${getSymbol(context)}",
                                                          color:
                                                              appColor(context)
                                                                  .online)
                                                      .paddingOnly(
                                                          bottom: Insets.i10);
                                                }),
                                              if (value.booking!.taxes !=
                                                      null &&
                                                  value.booking!.taxes!
                                                      .isNotEmpty)
                                                const VSpace(Sizes.s20),
                                              BillRowCommon(
                                                  title:
                                                      translations!.totalAmount,
                                                  price: symbolPosition
                                                      ? "${getSymbol(context)}${(currency(context).currencyVal * (value.booking!.total ?? 0.0)).toStringAsFixed(2)}"
                                                      : "${(currency(context).currencyVal * (value.booking!.total ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}",
                                                  styleTitle: appCss
                                                      .dmDenseMedium14
                                                      .textColor(
                                                          appColor(context)
                                                              .darkText),
                                                  style: appCss.dmDenseBold16
                                                      .textColor(
                                                          appColor(context)
                                                              .primary))
                                            ]).paddingSymmetric(
                                                vertical: Insets.i20)),
                                        if (value
                                            .booking!.advancePaymentEnable!)
                                          PaymentSummaryWidget(
                                            booking: value.booking!,
                                          ),
                                        if (value.booking!.bookingStatus !=
                                                null &&
                                            value.booking!.bookingStatus!
                                                    .slug !=
                                                translations!.cancel)
                                          if (value.booking!.dateTime != null &&
                                              value.checkForCancelButtonShow())
                                            ButtonCommon(
                                                    title: translations!
                                                        .cancelBooking!,
                                                    onTap: value.isCancel
                                                        ? () {}
                                                        : () => value
                                                            .onCancelBooking(
                                                                context))
                                                .paddingOnly(
                                                    top: Insets.i35,
                                                    bottom: Insets.i30),
                                        if (value.booking!.dateTime != null &&
                                            !value.checkForCancelButtonShow())
                                          SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            language(context,
                                                                "${translations!.status}:"),
                                                            style: appCss
                                                                .dmDenseMedium14
                                                                .textColor(appColor(
                                                                        context)
                                                                    .red)),
                                                        const HSpace(Sizes.s10),
                                                        Expanded(
                                                            child: Text(
                                                                language(
                                                                    context,
                                                                    "You can’t cancel this booking short time before it starts."),
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                                style: appCss
                                                                    .dmDenseRegular14
                                                                    .textColor(
                                                                        appColor(context)
                                                                            .red)))
                                                      ]).paddingAll(Insets.i15))
                                              .boxShapeExtension(
                                                  color: appColor(context)
                                                      .red
                                                      .withOpacity(0.1))
                                              .paddingDirectional(
                                                  vertical: Sizes.s20)
                                      ]).paddingOnly(
                                          left: Insets.i20, right: Insets.i20)))
                            ])))));
    });
  }
}
