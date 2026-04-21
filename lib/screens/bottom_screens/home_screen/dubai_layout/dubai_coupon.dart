import 'package:flutter/services.dart';

import '../../../../config.dart';
import '../../../../models/dashboard_user_model.dart';

class DubaiCoupon extends StatelessWidget {
  final Coupons? data;

  const DubaiCoupon({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(eImageAssets.dubaiCoupon),
                    fit: BoxFit.fill)),
            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  const VSpace(Sizes.s15),
                  SvgPicture.asset(
                    eSvgAssets.couponIcon1,
                    height: Sizes.s15,
                    colorFilter: ColorFilter.mode(
                        appColor(context).whiteColor, BlendMode.srcIn),
                  ).paddingAll(Insets.i9).decorated(
                      color: appColor(context).primary,
                      borderRadius: BorderRadius.circular(Insets.i9)),
                  const VSpace(Sizes.s3),
                  SizedBox(
                      width: Sizes.s110,
                      child: Text(data?.title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: appCss.dmDenseMedium13
                              .textColor(appColor(context).darkText))),
                  FittedBox(
                      child: Text("#${language(context, data!.code)}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: appCss.dmDenseBold14
                                  .textColor(appColor(context).lightText))
                          .padding(horizontal: Sizes.s5)),
                  Image.asset(eImageAssets.hDashLine)
                      .paddingDirectional(vertical: Sizes.s5),
                  const VSpace(Sizes.s5),
                  /*  Text(
                      language(context,
                          "${double.parse(data!.amount!.toString()).round()}${data!.type == "percentage" ? "%" : "${getSymbol(context)}"} ${language(context, translations!.off).toUpperCase()}"),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: appCss.dmDenseBold15
                          .textColor(appColor(context).primary)) */
                ])
                .paddingDirectional(horizontal: Sizes.s10, vertical: Sizes.s6))
        .paddingOnly(
            left: rtl(context) ? 0 : Insets.i10,
            right: rtl(context) ? Insets.i10 : 0)
        .inkWell(onTap: () {
      Clipboard.setData(ClipboardData(text: data!.code!));
    });
  }
}
