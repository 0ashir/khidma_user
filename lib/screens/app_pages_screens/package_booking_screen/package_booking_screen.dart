import '../../../config.dart';
import 'layouts/package_detail_top_layout.dart';

class PackageBookingScreen extends StatelessWidget {
  const PackageBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageBookingProvider>(builder: (context, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(
            const Duration(milliseconds: 100), () => value.onReady(context)),
        child: Scaffold(
          appBar: AppBarCommon(title: translations!.packageDetails),
          body: SingleChildScrollView(
              child: Column(children: [
            ...value.packageBookingLists
                .asMap()
                .entries
                .map((e) => PackageDetailTopLayout(data: e.value)),
            Text(language(context, translations!.billSummary),
                    style: appCss.dmDenseSemiBold14
                        .textColor(appColor(context).darkText))
                .padding(top: Insets.i25, bottom: Insets.i10)
                .alignment(Alignment.centerLeft),
            Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(eImageAssets.paymentSummary),
                        colorFilter: ColorFilter.mode(
                            appColor(context).fieldCardBg, BlendMode.srcIn),
                        fit: BoxFit.fill)),
                child: Column(children: [
                  BillRowCommon(title: translations!.amount, price: "\$12.00"),
                  // const VSpace(Sizes.s20),
                  // BillRowCommon(
                  //     title: translations!.tax,
                  //     price: "+\$1.20",
                  //     style: appCss.dmDenseMedium14
                  //         .textColor(appColor(context).online)),
                  const DividerCommon().paddingSymmetric(vertical: Insets.i20),
                  BillRowCommon(
                      title: translations!.totalAmount,
                      price: "\$10.40",
                      styleTitle: appCss.dmDenseMedium14
                          .textColor(appColor(context).darkText),
                      style: appCss.dmDenseMedium14
                          .textColor(appColor(context).online)),
                ]).paddingSymmetric(
                    vertical: Insets.i20, horizontal: Insets.i15)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Text(language(context, translations!.review),
                      overflow: TextOverflow.clip,
                      style: appCss.dmDenseSemiBold14
                          .textColor(appColor(context).darkText))),
              Text(language(context, translations!.viewAll),
                      style: appCss.dmDenseRegular14
                          .textColor(appColor(context).primary))
                  .inkWell(
                      onTap: () => route.pushNamed(
                          context, routeName.servicesReviewScreen))
            ]).paddingOnly(top: Insets.i20, bottom: Insets.i12),
            /*    ...appArray.reviewList
                      .asMap()
                      .entries
                      .map((e) => ServiceReviewLayout(
                      data: e.value,
                      index: e.key,
                      list: appArray.reviewList))
                      .toList()*/
          ]).paddingSymmetric(horizontal: Insets.i20)),
        ),
      );
    });
  }
}
