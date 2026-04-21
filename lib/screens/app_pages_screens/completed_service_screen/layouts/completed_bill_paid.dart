// ignore_for_file: unused_local_variable

import '../../../../config.dart';

class CompletedBookingBillPaidLayout extends StatelessWidget {
  final BookingModel? bookingModel;

  const CompletedBookingBillPaidLayout({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    /*  final price = bookingModel?.service?.price ?? 0.0;
    final requiredServicemen = bookingModel?.service?.requiredServicemen ?? 1;
    final selectedRequiredServiceMan =
        bookingModel?.service?.selectedRequiredServiceMan ?? 1;
    final serviceRate = bookingModel?.service?.serviceRate ?? 0.0;

    final currencyVal = currency(context).currencyVal;

    double totalPrice = (currencyVal *
        ((price / requiredServicemen) * selectedRequiredServiceMan));
    double baseRate =
        (currencyVal * (serviceRate * selectedRequiredServiceMan));
    double difference = totalPrice - baseRate;
    String formattedDifference = symbolPosition
        ? "-${getSymbol(context)}${difference.toStringAsFixed(2)}"
        : "-${difference.toStringAsFixed(2)}${getSymbol(context)}"; */
    double extraChargeTotal = 0.0;
    /*  if (bookingModel!.extraCharges != null &&
        bookingModel!.extraCharges!.isNotEmpty) {
      extraChargeTotal = bookingModel!.extraCharges!
          .map((e) => e.total)
          .fold(0.0, (prev, amount) => prev + amount);
    } */

    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(isDark(context)
                        ? eImageAssets.completedBillBg
                        : eImageAssets.ongoingBg)
                    /*  ? eImageAssets.pendingBillBgDark
                        : eImageAssets.pendingBillBg) */
                    ,
                    fit: BoxFit.fill)),
            child: Column(children: [
              BillRowCommon(
                      title:
                          "Service Price" /* translations!.perServiceCharge */,
                      price: symbolPosition
                          ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel?.service?.price).toStringAsFixed(2)}"
                          : "${(currency(context).currencyVal * bookingModel?.service?.price).toStringAsFixed(2)}${getSymbol(context)}")
                  .marginOnly(bottom: Insets.i20),
              if (bookingModel!.service?.discount != null &&
                  bookingModel?.service?.discount != 0)
                BillRowCommon(
                        color: appColor(context).red,
                        title:
                            "${translations!.appliedDiscount} (${bookingModel!.service!.discount}%)",
                        price: symbolPosition
                            ? "${getSymbol(context)}${bookingModel?.service?.discountAmount}"
                            : "${bookingModel?.service?.discountAmount}${getSymbol(context)}")
                    .marginOnly(bottom: Insets.i20),
              BillRowCommon(
                      title:
                          "${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${((bookingModel?.perServicemanCharge))} × ${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)})",
                      price: symbolPosition
                          ? "${getSymbol(context)}${bookingModel?.totalExtraServicemenCharge!.toStringAsFixed(2)}"
                          : "${bookingModel?.totalExtraServicemenCharge!.toStringAsFixed(2)}${getSymbol(context)}",
                      style: appCss.dmDenseBold14
                          .textColor(appColor(context).darkText))
                  .padding(bottom: Insets.i20),
              /* BillRowCommon(
                title:
                    "${((bookingModel!.requiredServicemen ?? 1) + (bookingModel!.totalExtraServicemen != null ? (bookingModel!.totalExtraServicemen ?? 1) : 0))} ${language(context, translations!.serviceman)}",
                price: symbolPosition
                    ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel?.service?.price / ((bookingModel!.requiredServicemen ?? 1) + (bookingModel!.totalExtraServicemen != null ? (bookingModel!.totalExtraServicemen ?? 1) : 0))).toStringAsFixed(2)}"
                    : "${(currency(context).currencyVal * bookingModel?.service?.price / ((bookingModel!.requiredServicemen ?? 1) + (bookingModel!.totalExtraServicemen != null ? (bookingModel!.totalExtraServicemen ?? 1) : 0))).toStringAsFixed(2)}${getSymbol(context)}",
              ).paddingSymmetric(vertical: Insets.i10), */

              /* if (bookingModel!.extraCharges != null &&
                  bookingModel!.extraCharges!.isNotEmpty)
                ...bookingModel!.extraCharges!.map((charge) {
                  return BillRowCommon(
                    title: language(context, translations!.extraServiceCharge),
                    price:
                        "${getSymbol(context)}${(currency(context).currencyVal * charge.total)}",
                  );
                }), */
              /*  if (bookingModel!.extraCharges != null &&
                  bookingModel!.extraCharges!.isNotEmpty)
                const VSpace(Sizes.s20), */

              /* if (bookingModel!.service?.discount != null) const VSpace(Sizes.s20), */
              /* if (bookingModel!.service?.discount != null)
                BillRowCommon(
                        color: appColor(context).red,
                        title:
                            "${translations!.appliedDiscount} (${bookingModel!.service!.discount}%)",
                        price: formattedDifference)
                    .marginOnly(bottom: Insets.i10), */

              if (bookingModel!.additionalServices != null)
                ...bookingModel!.additionalServices!.map((charge) {
                  return BillRowCommon(
                    title: charge.title,
                    color: appColor(context).green,
                    price: symbolPosition
                        ? "+${getSymbol(context)}${charge.totalPrice!.toStringAsFixed(2)}"
                        : "+${charge.totalPrice!.toStringAsFixed(2)}${getSymbol(context)}",
                  ).padding(bottom: Insets.i20);
                }),

              BillRowCommon(
                title: translations!.platformFees,
                price: symbolPosition
                    ? "+${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.platformFees!).toStringAsFixed(2)}"
                    : "+${(currency(context).currencyVal * bookingModel!.platformFees!).toStringAsFixed(2)}${getSymbol(context)}",
              ).paddingSymmetric(horizontal: Insets.i5).paddingOnly(
                  bottom: bookingModel!.extraCharges != null &&
                          bookingModel!.extraCharges!.isNotEmpty
                      ? Insets.i20
                      : Insets.i10),
              if (bookingModel!.taxes != null &&
                  bookingModel!.taxes!.isNotEmpty)
                ...bookingModel!.taxes!.map((tax) {
                  double rate = tax.rate ?? 0;

                  return BillRowCommon(
                    title:
                        "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(2)}%)",
                    price: symbolPosition
                        ? "+${getSymbol(context)}${tax.amount.toStringAsFixed(2)}"
                        : "+${tax.amount.toStringAsFixed(2)}${getSymbol(context)}",
                    color: appColor(context).online,
                  ).paddingOnly(bottom: Insets.i20);
                }),
              /*   if (bookingModel!.service!.taxes != null &&
                  bookingModel!.service!.taxes!.isNotEmpty)
                ...bookingModel!.service!.taxes!.map((tax) {
                  double rate = tax.rate ?? 0;

                  return BillRowCommon(
                    title:
                        "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                    price: symbolPosition
                        ? "+${getSymbol(context)}${(currency(context).currencyVal * rate).toStringAsFixed(0)}"
                        : "+${(currency(context).currencyVal * rate).toStringAsFixed(0)}",
                    color: appColor(context).online,
                  ).paddingOnly(bottom: Insets.i20);
                }), */
              // BillRowCommon(
              //         title: translations!.tax,
              //         price:
              //             "+${getSymbol(context)}${(currency(context).currencyVal * (bookingModel!.tax??0.0)).toStringAsFixed(2)}",
              //         color: appColor(context).online)
              //     .paddingOnly(bottom: Insets.i20),
              // DottedLines(color: appColor(context).stroke)
              //     .paddingOnly(
              //         bottom: bookingModel!.extraCharges != null &&
              //                 bookingModel!.extraCharges!.isNotEmpty
              //             ? 23
              //             : Insets.i20)
              //     .paddingSymmetric(horizontal: Insets.i5),
              if (bookingModel!.extraCharges != null &&
                  bookingModel!.extraCharges!.isNotEmpty)
                ...bookingModel!.extraCharges!.map((charge) {
                  return BillRowCommon(
                    title: language(context, translations!.extraServiceCharge),
                    color: appColor(context).green,
                    price: symbolPosition
                        ? "+ ${getSymbol(context)}${(charge.total?.toStringAsFixed(2))}"
                        : "+ ${(charge.total?.toStringAsFixed(2))}${getSymbol(context)}",
                  ).padding(bottom: Insets.i20);
                }),

              // if (bookingModel!.extraCharges != null &&
              //     bookingModel!.extraCharges!.isNotEmpty)
              //   BillRowCommon(
              //     title: language(context, translations!.platformFees),
              //     color: appColor(context).green,
              //     price: symbolPosition
              //         ? "+ ${getSymbol(context)}${(bookingModel?.extraChargesTotal?.platformFees?.toStringAsFixed(2))}"
              //         : "+ ${(bookingModel?.extraChargesTotal?.platformFees?.toStringAsFixed(2))}${getSymbol(context)}",
              //   ).padding(bottom: Insets.i20),

              if (bookingModel!.extraCharges != null &&
                  bookingModel!.extraCharges!.isNotEmpty)
                BillRowCommon(
                  title: language(context, translations!.tax),
                  color: appColor(context).green,
                  price: symbolPosition
                      ? "+ ${getSymbol(context)}${(bookingModel?.extraChargesTotal?.taxAmount?.toStringAsFixed(2))}"
                      : "+ ${(bookingModel?.extraChargesTotal?.taxAmount?.toStringAsFixed(2))}${getSymbol(context)}",
                ).padding(bottom: Insets.i20),

              if (bookingModel!.extraCharges != null &&
                  bookingModel!.extraCharges!.isNotEmpty)
                const VSpace(Sizes.s10),

              Divider(color: appColor(context).stroke)
                  .paddingSymmetric(horizontal: Insets.i8),
              (bookingModel!.extraCharges != null &&
                      bookingModel!.extraCharges!.isNotEmpty)
                  ? BillRowCommon(
                          title: translations!.amount /* payableAmount */,
                          price: symbolPosition
                              ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.grandTotalWithExtras!).toStringAsFixed(2)}"
                              : "${(currency(context).currencyVal * bookingModel!.grandTotalWithExtras!).toStringAsFixed(2)}${getSymbol(context)}",
                          styleTitle: appCss.dmDenseMedium14
                              .textColor(appColor(context).primary),
                          style: appCss.dmDenseBold16
                              .textColor(appColor(context).primary))
                      .paddingOnly(
                          bottom: bookingModel!.extraCharges != null &&
                                  bookingModel!.extraCharges!.isNotEmpty
                              ? Insets.i10
                              : Insets.i3)
                  : BillRowCommon(
                          title: translations!.amount /* payableAmount */,
                          price: symbolPosition
                              ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}"
                              : "${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}${getSymbol(context)}",
                          styleTitle:
                              appCss.dmDenseMedium14.textColor(appColor(context).primary),
                          style: appCss.dmDenseBold16.textColor(appColor(context).primary))
                      .paddingOnly(bottom: bookingModel!.extraCharges != null && bookingModel!.extraCharges!.isNotEmpty ? Insets.i10 : Insets.i3),

              // if (bookingModel!.extraCharges != null &&
              //     bookingModel!.extraCharges!.isNotEmpty)
              //   ...bookingModel!.extraCharges!.map((charge) {
              //     return BillRowCommon(
              //       title: language(context, translations!.extraServiceCharge),
              //       color: appColor(context).green,
              //       price: symbolPosition
              //           ? "+ ${getSymbol(context)}${(currency(context).currencyVal * charge.total)}"
              //           : "+ ${(currency(context).currencyVal * charge.total)}${getSymbol(context)}",
              //     ).padding(bottom: Insets.i10);
              //   }),
              // if (bookingModel!.extraCharges != null &&
              //     bookingModel!.extraCharges!.isNotEmpty)
              //   const VSpace(Sizes.s10),
              // if (bookingModel!.extraCharges != null &&
              //     bookingModel!.extraCharges!.isNotEmpty)
              //   Divider(color: appColor(context).stroke)
              //       .paddingSymmetric(horizontal: Insets.i8),
              // if (bookingModel!.extraCharges != null &&
              //     bookingModel!.extraCharges!.isNotEmpty)
              //   BillRowCommon(
              //       title: translations!.payableAmount,
              //       price: symbolPosition
              //           ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.total! + extraChargeTotal).toStringAsFixed(2)}"
              //           : "${(currency(context).currencyVal * bookingModel!.total! + extraChargeTotal).toStringAsFixed(2)}${getSymbol(context)}",
              //       styleTitle: appCss.dmDenseMedium14
              //           .textColor(appColor(context).primary),
              //       style: appCss.dmDenseBold16
              //           .textColor(appColor(context).primary))
            ]).paddingSymmetric(
              vertical: Insets.i20,
            )),
      ],
    );
  }
}
