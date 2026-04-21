import '../../../../config.dart';
import 'dart:math' as math;

class BalanceLayout extends StatelessWidget {
  final Animation<Offset>? offsetAnimation;
  final String? totalBalance;
  final bool isTap, isGuest;

  const BalanceLayout(
      {super.key,
      this.offsetAnimation,
      this.totalBalance,
      this.isTap = true,
      this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(eImageAssets.balanceContainer,
          height: Sizes.s65,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(language(context, translations!.totalAvailable),
              style: appCss.dmDenseSemiBold12
                  .textColor(appColor(context).whiteColor)),
          const VSpace(Sizes.s3),
          //if (value.offsetAnimation != null)
          Row(children: [
            Text(
                symbolPosition
                    ? "${getSymbol(context)} ${userModel?.wallet?.balance ?? 0.0}"
                    : "${userModel?.wallet?.balance ?? 0.0} ${getSymbol(context)}",
                style: appCss.dmDenseBold18
                    .textColor(appColor(context).whiteColor)),
            const HSpace(Sizes.s8),
            SlideTransition(
                position: offsetAnimation!,
                child: SvgPicture.asset(eSvgAssets.anchorArrowRight))
          ])
        ]).paddingSymmetric(horizontal: Insets.i12),
        rtl(context)
            ? Image.asset(eGifAssets.wallet, height: Sizes.s60)
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.asset(eGifAssets.wallet, height: Sizes.s60))
      ])
    ]).inkWell(onTap: () async {
      if (isTap) {
        if (isGuest) {
          route.pushAndRemoveUntil(context);
        } else {
          route.pushNamed(context, routeName.walletBalance)!.then((e) async {
            final commonApi =
                Provider.of<CommonApiProvider>(context, listen: false);
            await commonApi.selfApi(context);
          });
        }
      }
    });
  }
}
