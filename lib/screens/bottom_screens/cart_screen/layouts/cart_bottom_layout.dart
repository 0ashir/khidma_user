import '../../../../config.dart';

class CartBottomLayout extends StatelessWidget {
  final String? amount;
  final GestureTapCallback? onTap;
  final bool hasOfflineProviders;
  const CartBottomLayout(
      {super.key,
      this.amount,
      this.onTap,
      this.hasOfflineProviders = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            height: Sizes.s120,
            width: MediaQuery.of(context).size.width,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(language(context, translations!.totalAmount),
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).lightText)),
                Text(amount!,
                    style: appCss.dmDenseBold20
                        .textColor(appColor(context).primary))
              ]),
              const VSpace(Sizes.s12),
              Opacity(
                opacity: hasOfflineProviders ? 0.5 : 1.0,
                child: ButtonCommon(
                    title: translations!.proceedCheckout!,
                    icon: SvgPicture.asset(eSvgAssets.doubleRight),
                    onTap: hasOfflineProviders ? null : onTap),
              )
            ]).paddingSymmetric(horizontal: Insets.i20))
        .decorated(
            color: isDark(context)
                ? appColor(context).whiteBg
                : appColor(context).cartBottomBg);
  }
}
