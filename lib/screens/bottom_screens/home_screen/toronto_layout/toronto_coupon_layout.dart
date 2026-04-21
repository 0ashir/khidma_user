import 'package:fixit_user/models/dashboard_user_model.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/dubai_layout/dubai_custom_coupon_layout.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/toronto_layout/toronto_coupon_coustom_layout.dart';
import 'package:flutter/services.dart';

import '../../../../config.dart';

class TorontoCouponLayout extends StatelessWidget {
  final Coupons? data;
  final bool isDubai;

  const TorontoCouponLayout({super.key, this.data, this.isDubai = false});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CustomPaint(
          painter: isDubai == true
              ? DubaiCustomCouponLayout()
              : TorontoCouponCoustomLayout()),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const VSpace(Sizes.s15),
        SvgPicture.asset(
          eSvgAssets.couponIcon1,
          height: Sizes.s15,
          colorFilter:
              ColorFilter.mode(appColor(context).whiteColor, BlendMode.srcIn),
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
        isDubai == true
            ? const VSpace(Sizes.s5)
            : Image.asset(eImageAssets.hDashLine)
                .paddingDirectional(vertical: Sizes.s6),
        Text(language(context, translations!.useCode),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
                appCss.dmDenseRegular12.textColor(appColor(context).lightText)),
        const VSpace(Sizes.s5),
        FittedBox(
            child: Text("#${language(context, data!.code)}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: appCss.dmDenseBold12
                        .textColor(appColor(context).primary))
                .padding(horizontal: Sizes.s5))
      ]).paddingDirectional(horizontal: Sizes.s4)
    ])
        .paddingOnly(
            left: rtl(context) ? 0 : Insets.i20,
            right: rtl(context) ? Insets.i20 : 0)
        .inkWell(onTap: () {
      Clipboard.setData(ClipboardData(text: data!.code!));
    });
  }
}
