import '../../../../config.dart';

class CompletedBookingBillLayoutIfNotPaid extends StatelessWidget {
  final BookingModel? bookingModel;
  const CompletedBookingBillLayoutIfNotPaid({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final price = bookingModel?.service?.price ?? 0.0;
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
        : "-${difference.toStringAsFixed(2)}${getSymbol(context)}";

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(eImageAssets.completeBg),
                colorFilter: ColorFilter.mode(
                    appColor(context).fieldCardBg, BlendMode.srcIn),
                fit: BoxFit.fill)),
        child: Column(children: [
          BillRowCommon(
                  title: "Service Price" /* translations!.perServiceCharge */,
                  price: symbolPosition
                      ? "${getSymbol(context)}${(currency(context).currencyVal * (bookingModel?.service?.price ?? 0.0)).toStringAsFixed(2)}"
                      : "${(currency(context).currencyVal * (bookingModel?.service?.price ?? 0.0)).toStringAsFixed(2)}${getSymbol(context)}")
              .marginOnly(bottom: Insets.i20),
          if (bookingModel!.service?.discount != null &&
              bookingModel!.service?.discount != 0)
            BillRowCommon(
                    color: appColor(context).red,
                    title:
                        "${translations!.appliedDiscount} (${bookingModel!.service!.discount}%)",
                    price: formattedDifference)
                .marginOnly(bottom: Insets.i20),
          BillRowCommon(
                  title: symbolPosition
                      ? "${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${getSymbol(context)}${bookingModel?.perServicemanCharge}× ${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)})"
                      : "${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${bookingModel?.perServicemanCharge}${getSymbol(context)} × ${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)})",
                  price: symbolPosition
                      ? "${getSymbol(context)}${bookingModel?.totalExtraServicemenCharge?.toStringAsFixed(2)}"
                      : "${bookingModel?.totalExtraServicemenCharge?.toStringAsFixed(2)}${getSymbol(context)}",
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText))
              .paddingOnly(bottom: Insets.i20),
          BillRowCommon(
                  title: translations!.platformFees,
                  price: symbolPosition
                      ? "+${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.platformFees!).toStringAsFixed(2)}"
                      : "+${(currency(context).currencyVal * bookingModel!.platformFees!).toStringAsFixed(2)}${getSymbol(context)}",
                  color: appColor(context).online)
              .padding(bottom: Insets.i20),
          if (bookingModel!.taxes != null && bookingModel!.taxes!.isNotEmpty)
            ...bookingModel!.taxes!.map((tax) {
              double rate = tax.rate ?? 0;

              return BillRowCommon(
                title:
                    "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                price: symbolPosition
                    ? "+${getSymbol(context)}${(currency(context).currencyVal * tax.amount).toStringAsFixed(2)}"
                    : "+${(currency(context).currencyVal * tax.amount).toStringAsFixed(2)}${getSymbol(context)}",
                color: appColor(context).online,
              ).paddingOnly(bottom: Insets.i20);
            }),
          // BillRowCommon(
          //     title: translations!.tax,
          //     price:
          //         "+${getSymbol(context)}${(currency(context).currencyVal * (bookingModel!.tax??0.0)).toStringAsFixed(2)}",
          //     color: appColor(context).online),
          //

          if (bookingModel!.additionalServices != null)
            ...bookingModel!.additionalServices!.map((charge) {
              return BillRowCommon(
                title: "${charge.title} (\$${charge.price} × ${charge.qty})",
                color: appColor(context).green,
                price: symbolPosition
                    ? "+${getSymbol(context)}${charge.totalPrice!.toStringAsFixed(2)}"
                    : "+${charge.totalPrice!.toStringAsFixed(2)}${getSymbol(context)}",
              ).padding(bottom: Insets.i10);
            }),
          DottedLines(
            color: appColor(context).stroke,
          ).paddingOnly(bottom: 25).paddingSymmetric(horizontal: 5),
          BillRowCommon(
              title: bookingModel!.extraCharges != null &&
                      bookingModel!.extraCharges!.isNotEmpty
                  ? translations!.totalAmount
                  : translations!.payableAmount,
              price: symbolPosition
                  ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}"
                  : "${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}${getSymbol(context)}",
              styleTitle: bookingModel!.extraCharges != null &&
                      bookingModel!.extraCharges!.isNotEmpty
                  ? appCss.dmDenseMedium14.textColor(appColor(context).darkText)
                  : appCss.dmDenseMedium14.textColor(appColor(context).primary),
              style: bookingModel!.extraCharges != null &&
                      bookingModel!.extraCharges!.isNotEmpty
                  ? appCss.dmDenseBold16.textColor(appColor(context).darkText)
                  : appCss.dmDenseBold16.textColor(appColor(context).primary)),
          const VSpace(Sizes.s15),
          /*  BillRowCommon(
                  title: language(context, translations!.extraServiceCharge),
                  price: "+\$5.80",
                  styleTitle: appCss.dmDenseMedium14
                      .textColor(appColor(context).lightText),
                  style: appCss.dmDenseMedium14
                      .textColor(appColor(context).greenColor))
              .paddingOnly(bottom: Insets.i20), */
          /* if (bookingModel!.extraCharges != null &&
              bookingModel!.extraCharges!.isNotEmpty)
            ...bookingModel!.extraCharges!.map((charge) {
              return BillRowCommon(
                title: language(context, translations!.extraServiceCharge),
                color: appColor(context).green,
                price: symbolPosition
                    ? "+ ${getSymbol(context)}${(currency(context).currencyVal * charge.total).toStringAsFixed(2)}"
                    : "+ ${(currency(context).currencyVal * charge.total).toStringAsFixed(2)}",
              ).padding(bottom: Insets.i10);
            }), */
          if (bookingModel!.extraCharges != null &&
              bookingModel!.extraCharges!.isNotEmpty)
            Divider(
                    color: appColor(context).stroke,
                    thickness: 1,
                    height: 1,
                    indent: 6,
                    endIndent: 6)
                .paddingOnly(bottom: 18),
          if (bookingModel!.extraCharges != null &&
              bookingModel!.extraCharges!.isNotEmpty)
            BillRowCommon(
                    title: translations!.payableAmount,
                    price: symbolPosition
                        ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}"
                        : "${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}${getSymbol(context)}",
                    styleTitle: appCss.dmDenseMedium14
                        .textColor(appColor(context).primary),
                    style: appCss.dmDenseBold16
                        .textColor(appColor(context).primary))
                .paddingOnly(bottom: 10),
        ]).paddingSymmetric(
          vertical: Insets.i20,
        ));
  }
}
