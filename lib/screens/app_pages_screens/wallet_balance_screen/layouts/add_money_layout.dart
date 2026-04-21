import 'package:fixit_user/providers/app_pages_providers/wallet_bonus_provider.dart';
import '../../../../config.dart';

class AddMoneyLayout extends StatelessWidget {
  final BuildContext? buildContext;

  const AddMoneyLayout({super.key, this.buildContext});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletProvider, WalletBonusProvider>(
        builder: (context1, value, value2, child) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            decoration: ShapeDecoration(
                shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(
                            cornerRadius: AppRadius.r20, cornerSmoothing: 1),
                        topRight: SmoothRadius(
                            cornerRadius: AppRadius.r20,
                            cornerSmoothing: 0.4))),
                color: appColor(context).whiteBg),
            child: SingleChildScrollView(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(language(context, translations!.addMoney),
                    style: appCss.dmDenseMedium18
                        .textColor(appColor(context).darkText)),
                SvgPicture.asset(eSvgAssets.close)
                    .inkWell(onTap: () => route.pop(context))
              ]).paddingAll(Insets.i20),
              const VSpace(Sizes.s10),
              if (value2.walletBonusList.isNotEmpty) ...[
                SizedBox(
                  height: Sizes.s90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.i20),
                    scrollDirection: Axis.horizontal,
                    itemCount: value2.walletBonusList.length,
                    separatorBuilder: (_, __) => const HSpace(Sizes.s10),
                    itemBuilder: (context, index) {
                      final bonus = value2.walletBonusList[index];

                      return InkWell(
                        onTap: () {
                          /// Optional: auto fill amount
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          padding: const EdgeInsets.all(Insets.i12),
                          decoration: BoxDecoration(
                            color: appColor(context)
                                .primary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                            border: Border.all(
                              color: appColor(context).primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bonus.name.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: appCss.dmDenseSemiBold14
                                    .textColor(appColor(context).primary),
                              ),
                              const VSpace(Sizes.s4),
                              Text(
                                bonus.description.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: appCss.dmDenseRegular12
                                    .textColor(appColor(context).lightText),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VSpace(Sizes.s20),
              ],
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(language(context, translations!.amount),
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText)),
                const VSpace(Sizes.s8),
                TextFieldCommon(
                    controller: value.moneyCtrl,
                    focusNode: value.moneyFocus,
                    keyboardType: TextInputType.number,
                    hintText: translations!.enterAmount!,
                    prefixIcon: eSvgAssets.amount),
                const VSpace(Sizes.s20),
                Text(language(context, translations!.addForm),
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText)),
                const VSpace(Sizes.s8),
                PaymentDropDownLayout(
                    icon: eSvgAssets.wallet,
                    val: value.wallet,
                    isIcon: true,
                    list: value.paymentList,
                    onChanged: (val) => value.onTapGateway(val)),
              ])
                  .paddingSymmetric(
                      vertical: Insets.i20, horizontal: Insets.i15)
                  .boxShapeExtension(color: appColor(context).fieldCardBg)
                  .paddingSymmetric(horizontal: Insets.i20),
              const VSpace(Sizes.s30),
              Row(children: [
                Expanded(
                    child: ButtonCommon(
                        title: translations!.cancel!,
                        color: appColor(context).whiteBg,
                        borderColor: appColor(context).primary,
                        onTap: () => route.pop(context),
                        style: appCss.dmDenseSemiBold16
                            .textColor(appColor(context).primary))),
                const HSpace(Sizes.s15),
                Expanded(
                    child: ButtonCommon(
                        title: translations!.addMoney!,
                        onTap: () => value.addToWallet(context, buildContext)))
              ]).paddingSymmetric(horizontal: Insets.i20)
            ]))),
      );
    });
  }
}
