import '../../../../config.dart';

class ProviderDetailsLayout extends StatelessWidget {
  final String? pName, rating, experience, service, image;
  final GestureTapCallback? onTap;

  const ProviderDetailsLayout(
      {super.key,
      this.rating,
      this.service,
      this.pName,
      this.experience,
      this.onTap,
      this.image});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesDetailsProvider>(
        builder: (context, serviceCtrl, child) {
      return SizedBox(
              child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(language(context, translations!.chat),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          CommonArrow(
              isThirteen: true,
              arrow: eSvgAssets.chat,
              svgColor: appColor(context).primary,
              color: appColor(context).primary.withValues(alpha: 0.15),
              onTap: () {
                serviceCtrl.onChatTap(context);
              })
          /*  Row(children: [
              Text(language(context, translations!.view),
                  style:
                      appCss.dmDenseMedium12.textColor(appColor(context).primary)),
              const HSpace(Sizes.s4),
              SvgPicture.asset(eSvgAssets.anchorArrowRight,
                  colorFilter:
                      ColorFilter.mode(appColor(context).primary, BlendMode.srcIn))
            ])*/
        ]).paddingSymmetric(horizontal: Insets.i15),
        Divider(height: 1, color: appColor(context).stroke)
            .padding(top: Insets.i10, bottom: Insets.i15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            image != null
                ? CachedNetworkImage(
                    imageUrl: image!,
                    imageBuilder: (context, imageProvider) => Container(
                        height: Sizes.s40,
                        width: Sizes.s40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover, image: imageProvider))),
                    placeholder: (context, url) => Container(
                        height: Sizes.s40,
                        width: Sizes.s40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage(eImageAssets.noImageFound3)))),
                    errorWidget: (context, url, error) => Container(
                        height: Sizes.s40,
                        width: Sizes.s40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage(eImageAssets.noImageFound3)))),
                  )
                : Container(
                    height: Sizes.s40,
                    width: Sizes.s40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(eImageAssets.noImageFound3)))),
            const HSpace(Sizes.s12),
            Text(pName ?? 'Name',
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).darkText))
          ]),
          if (rating != null && rating != "0.0")
            Row(children: [
              SvgPicture.asset(eSvgAssets.star,
                  height: Sizes.s16,
                  colorFilter: ColorFilter.mode(
                      appColor(context).rateColor, BlendMode.srcIn)),
              /* RatingLayout(
                    initialRating: rating != null ? double.parse(rating!) : 0.0,
                    color: appColor(context).rateColor), */
              const HSpace(Sizes.s4),
              Text(rating!,
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).darkText))
            ])
        ]).paddingSymmetric(horizontal: Insets.i15),
        const VSpace(Sizes.s15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(language(context, translations!.totalExperience),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          Text(experience!,
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).darkText))
              .width(Sizes.s100)
        ]).paddingSymmetric(horizontal: Insets.i15),
        const DottedLines()
            .paddingSymmetric(vertical: Insets.i10, horizontal: Insets.i15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
              language(
                  context,
                  translations?.servicesDelivered
                          ?.replaceAll('=>', ':')
                          .trim() ??
                      ''),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          RichText(
              text: TextSpan(
                  text: service.toString(),
                  style: appCss.dmDenseSemiBold14
                      .textColor(appColor(context).primary),
                  children: [
                TextSpan(
                    text: " ${language(context, translations!.service)}",
                    style: appCss.dmDenseSemiBold12
                        .textColor(appColor(context).primary))
              ]))
        ]).paddingSymmetric(horizontal: Insets.i15)
      ]))
          .paddingSymmetric(vertical: Insets.i15)
          .boxShapeExtension(color: appColor(context).fieldCardBg)
          .inkWell(onTap: onTap);
    });
  }
}
