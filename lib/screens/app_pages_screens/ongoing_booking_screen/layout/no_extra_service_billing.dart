import 'dart:developer';

import '../../../../config.dart';

class NoExtraServiceAddedBill extends StatelessWidget {
  final BookingModel? bookingModel;
  const NoExtraServiceAddedBill({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final price = bookingModel?.service?.price ?? 0.0;
    final requiredServicemen = bookingModel?.service?.requiredServicemen ?? 1;
    final selectedRequiredServiceMan =
        bookingModel?.service?.selectedRequiredServiceMan ?? 1;
    final serviceRate = bookingModel?.service?.serviceRate ?? 0.0;

    final currencyVal = currency(context).currencyVal;
    log("bookingModel!.taxes::${bookingModel!.service!.taxes}");
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
                image: AssetImage(isDark(context)
                    ? eImageAssets.pendingBillBgDark
                    : eImageAssets.pendingBillBg),
                fit: BoxFit.fill)),
        child: Column(children: [
          BillRowCommon(
                  title: "Service Price" /* translations!.perServiceCharge */,
                  price: symbolPosition
                      ? "${getSymbol(context)}${(bookingModel?.service?.price).toStringAsFixed(2)}"
                      : "${(bookingModel?.service?.price).toStringAsFixed(2)}${getSymbol(context)}")
              .marginOnly(bottom: Insets.i20),
          if (bookingModel!.service!.discount != null &&
              bookingModel!.service!.discount != 0)
            BillRowCommon(
                    color: appColor(context).red,
                    title:
                        "${translations!.appliedDiscount} (${bookingModel!.service!.discount}%)",
                    price: formattedDifference)
                .marginOnly(bottom: Insets.i20),
          BillRowCommon(
                  title: symbolPosition
                      ? "${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${getSymbol(context)}${bookingModel?.perServicemanCharge} × ${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)})"
                      : "${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)} ${language(context, translations!.serviceman)} (${bookingModel?.perServicemanCharge}${getSymbol(context)}× ${(bookingModel!.requiredServicemen != null ? bookingModel!.requiredServicemen! : 0) + (bookingModel!.totalExtraServicemen != null ? bookingModel!.totalExtraServicemen! : 0)})",
                  price: symbolPosition
                      ? "${getSymbol(context)}${(bookingModel?.totalExtraServicemenCharge)}"
                      : "${bookingModel?.totalExtraServicemenCharge}${getSymbol(context)}",
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText))
              .marginOnly(bottom: Insets.i20),
          if (bookingModel!.additionalServices != null)
            ...bookingModel!.additionalServices!.map((charge) {
              return BillRowCommon(
                title: "${charge.title} (\$${charge.price} × ${charge.qty})",
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
                  color: appColor(context).online)
              .paddingOnly(bottom: Insets.i20),
          if (bookingModel!.taxes != null && bookingModel!.taxes!.isNotEmpty)
            ...bookingModel!.taxes!.map((tax) {
              double rate = tax.rate ?? 0;

              return BillRowCommon(
                title:
                    "${translations!.tax} (${tax.name} ${rate.toStringAsFixed(0)}%)",
                price: symbolPosition
                    ? "+${getSymbol(context)}${tax.amount}"
                    : "+${tax.amount}${getSymbol(context)}",
                color: appColor(context).online,
              ).paddingOnly(bottom: Insets.i10);
            }),
          if (bookingModel!.taxes != null && bookingModel!.taxes!.isNotEmpty)
            const VSpace(Sizes.s20),
          const VSpace(Sizes.s15),
          BillRowCommon(
              title: translations!.totalAmount,
              price: symbolPosition
                  ? "${getSymbol(context)}${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}"
                  : "${(currency(context).currencyVal * bookingModel!.total!).toStringAsFixed(2)}${getSymbol(context)}",
              styleTitle:
                  appCss.dmDenseMedium14.textColor(appColor(context).darkText),
              style: appCss.dmDenseBold16.textColor(appColor(context).primary))
        ]).paddingSymmetric(vertical: Insets.i30));
  }
}
