import '../../../../../config.dart';

class AcceptProviderConfirmation extends StatelessWidget {
  final ProviderModel? provider;
  final GestureTapCallback? accept;
  const AcceptProviderConfirmation({
    super.key,
    this.provider,
    this.accept,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialogCommon(
      title: appFonts.assignToName(context, provider!.name),
      subtext: translations!.areYouSureServicemen,
      isBooked: true,
      isTwoButton: true,
      firstBText: translations!.cancel,
      firstBTap: () => route.pop(context),
      secondBText: translations!.yes,
      secondBTap: accept,
      widget: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Stack(alignment: Alignment.topRight, children: [
                Image.asset(eImageAssets.assignServicemen,
                    height: Sizes.s148, width: Sizes.s130),
                SizedBox(
                        height: Sizes.s34,
                        width: Sizes.s34,
                        child: Image.asset(eGifAssets.tick,
                            height: Sizes.s34, width: Sizes.s34))
                    .paddingOnly(top: Insets.i30)
              ]))
          .paddingOnly(top: Insets.i15)
          .decorated(
              color: appColor(context).fieldCardBg,
              borderRadius: BorderRadius.circular(AppRadius.r10)),
      height: Sizes.s145,
    );
  }
}
