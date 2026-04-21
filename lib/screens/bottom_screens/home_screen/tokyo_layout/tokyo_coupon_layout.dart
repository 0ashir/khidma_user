import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/dashboard_user_model.dart';
import 'package:fixit_user/screens/bottom_screens/home_screen/tokyo_layout/tokyo_custom_coupon_layout.dart';
import 'package:flutter/services.dart';

class TokyoCouponLayout extends StatelessWidget {
  final Coupons? data;
  const TokyoCouponLayout({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
            size: const Size(Sizes.s205, 0),
            painter: TokyoCustomCouponLayout()),
        RotationTransition(
          turns: const AlwaysStoppedAnimation(270 / 360),
          child: Text(
              language(context,
                  "${double.parse(data!.amount!.toString()).round()}${data!.type == "percentage" ? "%" : "${getSymbol(context)}"} ${language(context, translations!.off).toUpperCase()}"),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style:
                  appCss.dmDenseBold15.textColor(appColor(context).darkText)),
        ).padding(vertical: Sizes.s38, bottom: Sizes.s5),
        Row(
          children: [
            Image.asset(
              eImageAssets.linePackage,
              height: 83,
              color: const Color(0XFF7A8591),
            ).padding(left: 48),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data?.title ?? "",
                    style: appCss.dmDenseBold14
                        .textColor(appColor(context).darkText)),
                const VSpace(Sizes.s15),
                Text(language(context, translations?.useCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: appCss.dmDenseRegular12
                        .textColor(appColor(context).lightText)),
                const VSpace(Sizes.s4),
                Text(language(context, data!.code.toString()),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: appCss.dmDenseBold12
                        .textColor(appColor(context).lightText))
              ],
            ).padding(left: 15, top: 10),
          ],
        )
      ],
    )
        .paddingOnly(
            left: rtl(context) ? 0 : Insets.i20,
            right: rtl(context) ? Insets.i20 : 0)
        .inkWell(onTap: () {
      Clipboard.setData(ClipboardData(text: data!.code!));
    });
  }
}
