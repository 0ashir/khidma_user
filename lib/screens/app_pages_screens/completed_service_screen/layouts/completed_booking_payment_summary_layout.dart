import '../../../../config.dart';

class CompletedBookingPaymentSummaryLayout extends StatelessWidget {
  final BookingModel? bookingModel;

  const CompletedBookingPaymentSummaryLayout({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(isDark(context)
                    ? eImageAssets.billSummaryDark
                    : eImageAssets.paymentSummary),
                fit: BoxFit.fill)),
        child: Column(children: [
          BillRowCommon(
              title: translations!.methodType,
              price: bookingModel!.paymentMethod == "cash"
                  ? translations!.cash
                  : bookingModel!.paymentMethod),
          const VSpace(Sizes.s20),
          BillRowCommon(
              title: translations!.status,
              price:
                  bookingModel!.bookingStatus!.slug == translations!.completed
                      ? bookingModel!.paymentStatus == "COMPLETED"
                          ? language(context, translations!.paid)
                          : language(context, translations!.notPaid)
                      : bookingModel!.paymentStatus == "COMPLETED"
                          ? language(context, translations!.paid)
                          : language(context, translations!.notPaid),
              style:
                  appCss.dmDenseMedium14.textColor(appColor(context).online)),
        ]).paddingSymmetric(
          vertical: Insets.i20,
        ));
  }
}
