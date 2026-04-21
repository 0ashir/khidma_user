import 'package:intl/intl.dart';

import '../../../../config.dart';

class CouponLayout extends StatelessWidget {
  final CouponModel? data;
  final GestureTapCallback? onTap;
  final bool isArg;
  final Color? color;
  const CouponLayout(
      {super.key, this.data, this.onTap, this.isArg = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.s20),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(isDark(context)
                  ? eImageAssets.couponDark
                  : eImageAssets.coupon))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            flex: 4,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  language(context,
                      data?.title ?? ""),
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText)),
              RichText(
                  text: TextSpan(
                      text: language(context, translations!.useCode),
                      style: appCss.dmDenseMedium12
                          .textColor(appColor(context).lightText),
                      children: [
                    TextSpan(
                        style: appCss.dmDenseBold12
                            .textColor(appColor(context).lightText),
                        text: " ${data!.code} "),
                    TextSpan(
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText),
                        text:
                            "${language(context, translations!.toSave)} ${'${data!.amount}${data!.type == "percentage" ? "%" : "${getSymbol(context)}"}\n${language(context, translations!.off)}'} ${language(context, translations!.ofRealPrice)}"),
                  ]))
            ]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(eImageAssets.dashLines, height: Sizes.s50),
            const HSpace(Sizes.s17),
            Text(
                '${data!.amount}${data!.type == "percentage" ? "%" : "${getSymbol(context)}"}\n${language(context, translations!.off).toUpperCase()}',
                style:
                    appCss.dmDenseBold14.textColor(appColor(context).darkText))
          ])
        ]),
        const VSpace(Sizes.s28),
        Row(
            mainAxisAlignment: data!.endDate != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (data!.endDate != null)
                RichText(
                    text: TextSpan(
                        text: language(context, translations!.validTill),
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText),
                        children: [
                      TextSpan(
                          style: appCss.dmDenseMedium12
                              .textColor(appColor(context).darkText),
                          text:
                              " ${data!.endDate != null ? DateFormat("dd-MM-yyyy").format(DateTime.parse(data!.endDate!)) : ''}")
                    ])),
              Row(children: [
                Text(
                    language(context,
                        isArg ? translations!.copyCode : translations!.useCode),
                    style: appCss.dmDenseMedium14
                        .textColor(color ?? appColor(context).primary)),
                const HSpace(Sizes.s5),
                isArg
                    ? Tooltip(
                        message: "Copied",
                        child: SvgPicture.asset(eSvgAssets.copy,
                            height: Sizes.s18,
                            colorFilter: ColorFilter.mode(
                                color ?? appColor(context).primary,
                                BlendMode.srcIn)),
                      )
                    : SvgPicture.asset(eSvgAssets.anchorArrowRight,
                        colorFilter: ColorFilter.mode(
                            appColor(context).primary, BlendMode.srcIn))
              ]).inkWell(onTap: onTap),
            ])
      ]).paddingSymmetric(vertical: Insets.i15, horizontal: Insets.i20),
    ).paddingOnly(bottom: Insets.i20);
    /*return Stack(children: [
      Image.asset(isDark(context) ?eImageAssets.couponDark : eImageAssets.coupon,

          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          ).paddingSymmetric(horizontal: Insets.i20),
      Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(flex: 4,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(language(context, "${language(context, translations!.spend)} ${data!.minSpend} ${language(context, translations!.amount)}"),
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText)),
              RichText(
                  text: TextSpan(
                      text: language(context, translations!.useCode),
                      style: appCss.dmDenseMedium12
                          .textColor(appColor(context).lightText),
                      children: [
                    TextSpan(
                        style: appCss.dmDenseBold12
                            .textColor(appColor(context).lightText),
                        text: " ${data!.code} "),
                    TextSpan(
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText),
                        text: "${language(context, translations!.toSave)} ${'${data!.amount}${data!.type == "percentage" ? "%":"${getSymbol(context)}"}\n${language(context,translations!.off)}'} ${language(context, translations!.ofRealPrice)}"),
  TextSpan(
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText),
                        text: "${language(context, translations!.toSave)} ${'${data!.amount}${data!.type == "percentage" ? "%":"${getSymbol(context)}"}\n${language(context,translations!.off)}'} ${language(context, translations!.ofRealPrice)}"),

                  ]))
            ]),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Image.asset(eImageAssets.dashLines, height: Sizes.s50),
            const HSpace(Sizes.s17),
            Text(
            '${data!.amount}${data!.type == "percentage" ? "%":"${getSymbol(context)}"}\n${language(context, translations!.off).toUpperCase()}',
                style: appCss.dmDenseBold14
                    .textColor(appColor(context).darkText))
          ])
        ]),
        const VSpace(Sizes.s28),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RichText(
              text: TextSpan(
                  text: language(context, translations!.validTill),
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).lightText),
                  children: [
                TextSpan(
                    style: appCss.dmDenseMedium12
                        .textColor(appColor(context).darkText),
                    text: " ${data!.endDate != null  ?  DateFormat("dd-MM-yyyy").format(DateTime.parse(data!.endDate!)) : DateFormat("dd-MM-yyyy").format(DateTime.now())}")
              ])),
          Row(children: [
            Text(language(context, translations!.useCode),
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).primary)),
            const HSpace(Sizes.s5),
            SvgPicture.asset(eSvgAssets.anchorArrowRight,
                colorFilter: ColorFilter.mode(
                    appColor(context).primary, BlendMode.srcIn))
          ]).inkWell(onTap: onTap),
          
        ])
      ]).paddingSymmetric(vertical:Insets.i15,horizontal: Insets.i40)
    ]).width( MediaQuery.of(context).size.width).paddingOnly(bottom: Insets.i20);*/
  }
}
