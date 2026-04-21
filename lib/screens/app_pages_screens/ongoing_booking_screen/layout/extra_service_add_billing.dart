import 'dart:developer';

import '../../../../config.dart';

class ExtraServiceAddBilling extends StatelessWidget {
  final BookingModel? booking;

  const ExtraServiceAddBilling({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    log("booking?.platformFees${booking?.platformFees}");
    /* final price = booking?.service?.price ?? 0.0;
    final requiredServicemen = booking?.service?.requiredServicemen ?? 1;
    final selectedRequiredServiceMan =
        booking?.service?.selectedRequiredServiceMan ?? 1;
    final serviceRate = booking?.service?.serviceRate ?? 0.0;

    final currencyVal = currency(context).currencyVal;

    double totalPrice = (currencyVal *
        ((price / requiredServicemen) * selectedRequiredServiceMan));
    double baseRate =
        (currencyVal * (serviceRate * selectedRequiredServiceMan));
    double difference = totalPrice - baseRate;

    String formattedDifference = symbolPosition
        ? "-${getSymbol(context)}${difference.toStringAsFixed(2)}"
        : "-${difference.toStringAsFixed(2)}${getSymbol(context)}"; */

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(isDark(context)
                    ? eImageAssets.completedBillBg
                    : eImageAssets.ongoingBg),
                fit: BoxFit.fill)),
        child: Column(children: [
          BillRowCommon(
                  title: "Service Price" /* translations!.perServiceCharge */,
                  price: symbolPosition
                      ? "${getSymbol(context)}${booking?.service?.price!.toStringAsFixed(2)}"
                      : "${booking?.service?.price!.toStringAsFixed(2)}${getSymbol(context)}")
              .padding(bottom: Insets.i20),
          if (booking!.service?.discount != null &&
              booking!.service?.discount != 0)
            BillRowCommon(
                    color: appColor(context).red,
                    title:
                        "${translations!.appliedDiscount} (${booking!.service!.discount}%)",
                    price: booking!.service!.discountAmount)
                .marginOnly(bottom: Insets.i20),
          BillRowCommon(
                  title:
                      "${(booking!.requiredServicemen != null ? booking!.requiredServicemen! : 0) + (booking!.totalExtraServicemen != null ? booking!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${getSymbol(context)}${((booking?.perServicemanCharge))} × ${(booking!.requiredServicemen != null ? booking!.requiredServicemen! : 0) + (booking!.totalExtraServicemen != null ? booking!.totalExtraServicemen! : 0)})",
                  price: symbolPosition
                      ? "${getSymbol(context)}${booking?.totalExtraServicemenCharge!.toStringAsFixed(2)}"
                      : "${booking?.totalExtraServicemenCharge!.toStringAsFixed(2)}${getSymbol(context)}",
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText))
              .padding(bottom: Insets.i20),
          /* if (booking!.service!.taxes != null &&
              booking!.service!.taxes!.isNotEmpty)
            ...booking!.service!.taxes!.map((tax) {
              double rate = tax.rate ?? 0;

              return BillRowCommon(
                title:
                    "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                price:
                    "+${getSymbol(context)}${(currency(context).currencyVal * rate).toStringAsFixed(0)}",
                color: appColor(context).online,
              ).paddingOnly(bottom: Insets.i20);
            }), */
          /*  if (booking!.service?.discount != null)
            BillRowCommon(
                    color: appColor(context).red,
                    title:
                        "${translations!.appliedDiscount} (${booking!.service!.discount}%)",
                    price: formattedDifference)
                .marginOnly(bottom: Insets.i20), */
          if (booking!.additionalServices != null)
            ...booking!.additionalServices!.map((charge) {
              return BillRowCommon(
                title: charge.title,
                color: appColor(context).green,
                price: symbolPosition
                    ? "+${getSymbol(context)}${charge.totalPrice!.toStringAsFixed(2)}"
                    : "+${charge.totalPrice!.toStringAsFixed(2)}${getSymbol(context)}",
              ).padding(bottom: Insets.i20);
            }),
          /*     if (isPaymentComplete(booking!))
            if (booking!.extraCharges !=
                    null &&
                booking!.extraCharges!.isNotEmpty)
              ...booking!.extraCharges!.asMap().entries.map((e) => BillRowCommon(
                      title:
                          "Extra service charge(${e.value.perServiceAmount} × ${e.value.noServiceDone})",
                      price: symbolPosition
                          ? "+${getSymbol(context)}${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}"
                          : "+${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}${getSymbol(context)}",
                      style: appCss.dmDenseBold14
                          .textColor(appColor(context).green))
                  .paddingOnly(bottom: Insets.i20)), */
          // BillRowCommon(
          //         title: translations!.platformFees,
          //         price: symbolPosition
          //             ? "+${getSymbol(context)}${booking?.platformFees!.toStringAsFixed(2)}"
          //             : "+${booking?.platformFees!.toStringAsFixed(2)}${getSymbol(context)}",
          //         color: appColor(context).online)
          //     .paddingOnly(
          //         bottom:
          //             isPaymentComplete(booking!) ? Insets.i20 : Insets.i34),
          if (booking!.taxes != null && booking!.taxes!.isNotEmpty)
            ...booking!.taxes!.map((tax) {
              double rate = tax.rate ?? 0;

              return BillRowCommon(
                title:
                    "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                price: symbolPosition
                    ? "+${getSymbol(context)}${tax.amount.toStringAsFixed(2)}"
                    : "+${tax.amount.toStringAsFixed(2)}${getSymbol(context)}",
                color: appColor(context).online,
              ).paddingOnly(bottom: Insets.i20);
            }),
          if (isPaymentComplete(booking!))
            if (booking!.extraCharges !=
                    null &&
                booking!.extraCharges!.isNotEmpty)
              ...booking!.extraCharges!.asMap().entries.map((e) => BillRowCommon(
                      title:
                          "Extra service charge(${e.value.perServiceAmount} × ${e.value.noServiceDone})",
                      price: symbolPosition
                          ? "+${getSymbol(context)}${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}"
                          : "+${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}${getSymbol(context)}",
                      style: appCss.dmDenseBold14
                          .textColor(appColor(context).green))
                  .paddingOnly(bottom: Insets.i20)),
          const DottedLines().paddingSymmetric(horizontal: Insets.i5),
          if (!isPaymentComplete(booking!))
            BillRowCommon(
                    title: translations!.totalAmount,
                    price: symbolPosition
                        ? "${getSymbol(context)}${(currency(context).currencyVal * booking!.total!).toStringAsFixed(2)}"
                        : "${(currency(context).currencyVal * booking!.total!).toStringAsFixed(2)}${getSymbol(context)}",
                    styleTitle: appCss.dmDenseSemiBold14
                        .textColor(appColor(context).darkText),
                    style: appCss.dmDenseBold16
                        .textColor(appColor(context).darkText))
                .paddingSymmetric(vertical: Insets.i20),
          if (!isPaymentComplete(booking!))
            if (booking!.extraCharges !=
                    null &&
                booking!.extraCharges!.isNotEmpty)
              ...booking!.extraCharges!.asMap().entries.map((e) => BillRowCommon(
                      title:
                          "Extra service charge(${e.value.perServiceAmount} × ${e.value.noServiceDone})",
                      price: symbolPosition
                          ? "+${getSymbol(context)}${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}"
                          : "+${((e.value.noServiceDone ?? 1) * (currency(context).currencyVal * e.value.perServiceAmount!)).toStringAsFixed(2)}${getSymbol(context)}",
                      style: appCss.dmDenseBold14
                          .textColor(appColor(context).green))
                  .paddingOnly(bottom: Insets.i20)),
          BillRowCommon(
                  title: translations!.platformFees,
                  price: symbolPosition
                      ? "+${getSymbol(context)}${(booking?.platformFees?.toStringAsFixed(2))}"
                      : "+${(booking?.platformFees?.toStringAsFixed(2))}${getSymbol(context)}",
                  style:
                      appCss.dmDenseBold14.textColor(appColor(context).green))
              .paddingOnly(bottom: Insets.i20),
          if (booking!.extraCharges != null &&
              booking!.extraCharges!.isNotEmpty)
            BillRowCommon(
                    title: translations!.tax,
                    price: symbolPosition
                        ? "+${getSymbol(context)}${(booking?.extraChargesTotal?.taxAmount?.toStringAsFixed(2))}"
                        : "+${(booking?.extraChargesTotal?.taxAmount?.toStringAsFixed(2))}${getSymbol(context)}",
                    style:
                        appCss.dmDenseBold14.textColor(appColor(context).green))
                .paddingOnly(bottom: Insets.i20),

          /*  if (booking!.additionalServices != null)
            ...booking!.additionalServices!.map((charge) {
              return BillRowCommon(
                title: charge.title,
                color: appColor(context).green,
                price: symbolPosition
                    ? "+${getSymbol(context)}${charge.price!.toStringAsFixed(2)}"
                    : "+${charge.price!.toStringAsFixed(2)}${getSymbol(context)}",
              ).padding(bottom: Insets.i20);
            }), */
          /*  if (booking!.paymentMethod == "on_hand")
            BillRowCommon(
                title: translations!.advancePaid,
                price:
                    "-${getSymbol(context)}${(currency(context).currencyVal * booking!.total!).toStringAsFixed(2)}",
                style: appCss.dmDenseMedium14.textColor(appColor(context).red)), */
          if (!isPaymentComplete(booking!))
            Divider(color: appColor(context).stroke)
                .paddingSymmetric(horizontal: Insets.i8),
          const VSpace(Sizes.s20),
          BillRowCommon(
              title: booking!.paymentStatus == "COMPLETED"
                  ? translations!.amount
                  : translations!.payableAmount,
              price: booking!.paymentStatus == "COMPLETED"
                  ? "${getSymbol(context)}${booking?.grandTotalWithExtras?.toStringAsFixed(2)}"
                  : "${getSymbol(context)}${booking?.grandTotalWithExtras?.toStringAsFixed(2)}",
              styleTitle:
                  appCss.dmDenseMedium15.textColor(appColor(context).primary),
              style: appCss.dmDenseBold16.textColor(appColor(context).primary)),
          if (booking!.paymentStatus == "COMPLETED") const VSpace(Sizes.s20),
          if (booking!.paymentStatus == "COMPLETED")
            BillRowCommon(
                title: translations!.advancePaid,
                price: symbolPosition
                    ? "-${getSymbol(context)}${(currency(context).currencyVal * booking!.total!).toStringAsFixed(2)}"
                    : "-${(currency(context).currencyVal * booking!.total!).toStringAsFixed(2)}${getSymbol(context)}",
                style: appCss.dmDenseMedium14.textColor(appColor(context).red)),
          if (booking!.paymentStatus == "COMPLETED") const VSpace(Sizes.s20),
          if (booking!.paymentStatus == "COMPLETED")
            BillRowCommon(
                title: translations!.payableAmount,
                price: symbolPosition
                    ? "${getSymbol(context)}${(booking?.extraChargesTotal?.grandTotal?.toStringAsFixed(2))}"
                    : "${(booking?.extraChargesTotal?.grandTotal?.toStringAsFixed(2))}${getSymbol(context)}",
                styleTitle:
                    appCss.dmDenseMedium15.textColor(appColor(context).primary),
                style:
                    appCss.dmDenseBold16.textColor(appColor(context).primary)),
        ]).paddingSymmetric(vertical: Insets.i30));
  }
}
