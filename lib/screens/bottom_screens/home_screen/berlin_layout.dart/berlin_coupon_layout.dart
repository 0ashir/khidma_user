import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/dashboard_user_model.dart';
import 'package:flutter/services.dart';

class BerlinCouponLayout extends StatelessWidget {
  final Coupons? data;

  const BerlinCouponLayout({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(eImageAssets.berlinCoupon),
                    fit: BoxFit.fill)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  eSvgAssets.couponIcon1,
                  height: Sizes.s15,
                  colorFilter: ColorFilter.mode(
                      appColor(context).whiteColor, BlendMode.srcIn),
                )
                    .paddingAll(Insets.i9)
                    .decorated(
                        color: appColor(context).primary,
                        borderRadius: BorderRadius.circular(Insets.i20))
                    .paddingDirectional(horizontal: Sizes.s15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data?.title ?? "",
                        style: appCss.dmDenseBold14
                            .textColor(appColor(context).darkText)),
                    Text(
                        language(
                            context, "${translations!.useCode}#${data!.code}"),
                        overflow: TextOverflow.ellipsis,
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText)),
                  ],
                ),
                Image.asset(
                  eImageAssets.linePackage,
                  color: appColor(context).lightText,
                ).paddingDirectional(horizontal: Sizes.s10),
                Text(
                    language(context,
                        "${double.parse(data!.amount!.toString()).round()}${data!.type == "percentage" ? "%" : "${getSymbol(context)}"} ${language(context, translations!.off).toUpperCase()}"),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: appCss.dmDenseBold15
                        .textColor(appColor(context).primary)),
                const HSpace(Sizes.s15)
              ],
            ).paddingDirectional(vertical: Sizes.s15))
        .paddingOnly(
            left: rtl(context) ? 0 : Insets.i20,
            right: rtl(context) ? Insets.i20 : 0)
        .inkWell(onTap: () {
      Clipboard.setData(ClipboardData(text: data!.code!));
    });
  }
}
