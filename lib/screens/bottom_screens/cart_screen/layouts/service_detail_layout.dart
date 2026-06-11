import '../../../../config.dart';

class ServiceDetailLayout extends StatelessWidget {
  final SingleServices? data;
  final PackageServices? packageService;
  final int? totalServiceman;
  const ServiceDetailLayout(
      {super.key, this.data, this.packageService, this.totalServiceman});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 2.8,
        width: MediaQuery.of(context).size.width,
        decoration: ShapeDecoration(
            shape: const SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(
                        cornerRadius: AppRadius.r20, cornerSmoothing: 1),
                    topRight: SmoothRadius(
                        cornerRadius: AppRadius.r20, cornerSmoothing: 0.4))),
            color: appColor(context).whiteBg),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(language(context, translations!.acServiceCharge),
                style: appCss.dmDenseMedium18
                    .textColor(appColor(context).darkText)),
            SvgPicture.asset(eSvgAssets.close)
                .inkWell(onTap: () => route.pop(context)),
          ]).paddingAll(Insets.i20),
          Builder(builder: (context) {
            final perCharge = data != null
                ? (data!.perServiceCharge ?? data!.perServicemanCharge ?? 0)
                : (packageService!.perServicemanCharge ?? 0);
            final quantity = data?.total?.quantity ?? 1;
            final totalCharge = data != null
                ? (data!.total?.totalServiceCharge ?? perCharge * quantity)
                : (packageService!.total?.subtotal ?? 0);

            return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(eImageAssets.detailsBg),
                        fit: BoxFit.fill)),
                child: Column(children: [
                  Column(children: [
                    BillRowCommon(
                        title: translations!.perServiceCharge,
                        price: symbolPosition
                            ? "${getSymbol(context)}${(currency(context).currencyVal * perCharge).toStringAsFixed(2)}"
                            : "${(currency(context).currencyVal * perCharge).toStringAsFixed(2)}${getSymbol(context)}"),
                    const VSpace(Sizes.s20),
                    BillRowCommon(
                        title: data != null
                            ? "$quantity × ${language(context, translations!.perServiceCharge ?? '')}"
                            : "\$${packageService!.total!.totalServicemen!} servicemen (${getSymbol(context)}${"${(currency(context).currencyVal * perCharge).toStringAsFixed(2)} × ${packageService!.total!.totalServicemen!}"})",
                        price: symbolPosition
                            ? "${getSymbol(context)}${(currency(context).currencyVal * totalCharge).toStringAsFixed(2)}"
                            : "${(currency(context).currencyVal * totalCharge).toStringAsFixed(2)}${getSymbol(context)}")
                  ]).paddingSymmetric(
                    vertical: Insets.i20,
                  ),
                  const VSpace(Sizes.s6),
                  Divider(
                      color: appColor(context).stroke,
                      thickness: 1,
                      height: 1,
                      endIndent: 6,
                      indent: 6),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language(context, translations!.totalAmount),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        Text(
                            symbolPosition
                                ? "${getSymbol(context)}${(currency(context).currencyVal * totalCharge).toStringAsFixed(2)}"
                                : "${(currency(context).currencyVal * totalCharge).toStringAsFixed(2)}${getSymbol(context)}",
                            style: appCss.dmDenseBold16
                                .textColor(appColor(context).primary))
                      ]).paddingSymmetric(
                      vertical: Insets.i20, horizontal: Insets.i15)
                ])).paddingSymmetric(horizontal: Insets.i15);
          })
        ]));
  }
}
