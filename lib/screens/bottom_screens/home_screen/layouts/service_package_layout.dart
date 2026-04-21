import '../../../../config.dart';

class ServicePackageList extends StatelessWidget {
  final ServicePackageModel? data;
  final GestureTapCallback? onTap;
  final bool? isViewAll;
  final Animation<double>? rotationAnimation;

  const ServicePackageList(
      {super.key,
      this.data,
      this.onTap,
      this.isViewAll = false,
      this.rotationAnimation});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, HomeScreenProvider>(
        builder: (context, lang, value, child) {
      return Stack(children: [
        Stack(children: [
          Container(
              padding: EdgeInsets.only(
                  top: Insets.i15,
                  left: lang.locale?.languageCode == "ar" ? 0 : Insets.i15,
                  right: lang.locale?.languageCode == "ar" ? Insets.i15 : 0),
              decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 10, cornerSmoothing: 1)),
                  color: data!.hexaCode != null
                      ? fromHex(data!.hexaCode!)
                      : appColor(context).primary.withOpacity(0.8)),
              height: isViewAll == true
                  ? MediaQuery.of(context).size.height
                  : Sizes.s145,
              width: isViewAll == true
                  ? MediaQuery.of(context).size.width
                  : Sizes.s165,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              height: isViewAll == true ? Sizes.s43 : Sizes.s32,
                              width: isViewAll == true ? Sizes.s43 : Sizes.s32,
                              decoration: ShapeDecoration(
                                  color: appColor(context).whiteColor,
                                  shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                          cornerRadius: 8,
                                          cornerSmoothing: 1))),
                              padding: const EdgeInsets.all(5),
                              child: data!.media != null &&
                                      data!.media!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: data!.media![0].originalUrl!,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              eImageAssets.noImageFound1),
                                      placeholder: (context, url) =>
                                          Image.asset(
                                              eImageAssets.noImageFound1),
                                      /*  imageBuilder: (context, imageProvider) =>
                                          Image(
                                        image: imageProvider,
                                        color: data!.hexaCode != null
                                            ? fromHex(data!.hexaCode!)
                                            : appColor(context)
                                                .primary
                                                .withOpacity(0.8),
                                      ), */
                                    )
                                  : Image.asset(eImageAssets.noImageFound1)),
                          const VSpace(Sizes.s8),
                          Expanded(
                            child: Text(data!.title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: isViewAll == true
                                        ? appCss.dmDenseMedium14.textColor(
                                            appColor(context).whiteColor)
                                        : appCss.dmDenseMedium12.textColor(
                                            appColor(context).whiteColor))
                                .paddingOnly(right: Sizes.s12),
                          ),
                          const VSpace(Sizes.s2),
                          Text(
                              symbolPosition
                                  ? "${getSymbol(context)}${(currency(context).currencyVal * data!.price!).toStringAsFixed(2)}"
                                  : "${(currency(context).currencyVal * data!.price!).toStringAsFixed(2)}${getSymbol(context)}",
                              style: isViewAll == true
                                  ? appCss.dmDenseBold18
                                      .textColor(appColor(context).whiteColor)
                                  : appCss.dmDenseBold14
                                      .textColor(appColor(context).whiteColor)),
                        ],
                      ),
                    ),
                    // VSpace(isViewAll == true ? Sizes.s26 : Sizes.s15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language(context, translations!.seeMore),
                              style: appCss.dmDenseMedium14
                                  .textColor(appColor(context).whiteColor)),
                          Expanded(
                            child: SvgPicture.asset(eSvgAssets.anchorArrowRight,
                                    colorFilter: ColorFilter.mode(
                                        appColor(context).whiteColor,
                                        BlendMode.srcIn))
                                .marginSymmetric(horizontal: 15),
                          )
                        ]).marginOnly(bottom: Sizes.s20)
                  ])),
        ])
      ]).inkWell(onTap: onTap).paddingOnly(right: Insets.i15);
    });
  }
}
