import '../../../../config.dart';

class ReviewLayout extends StatelessWidget {
  final Reviews? data;
  final GestureTapCallback? editTap, deleteTap;
  final bool? isEditDelete;

  const ReviewLayout({super.key, this.data, this.deleteTap, this.editTap, this.isEditDelete = true});


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          //Image.asset(data["image"],height: Sizes.s38,width: Sizes.s38).decorated(shape: BoxShape.circle),
          data!.serviceman!.id == null
              ? data!.provider!.media.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data!.provider!.media[0].originalUrl!,
                      placeholder: (context, url) => Container(
                          height: Sizes.s38,
                          width: Sizes.s38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage(eImageAssets.noImageFound3)))),
                      imageBuilder: (context, imageProvider) => Container(
                          height: Sizes.s38,
                          width: Sizes.s38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover, image: imageProvider))),
                      errorWidget: (context, url, error) => Container(
                          height: Sizes.s38,
                          width: Sizes.s38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage(eImageAssets.noImageFound1)))))
                  : Container(
                      height: Sizes.s38,
                      width: Sizes.s38,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(eImageAssets.noImageFound3))))
              : data!.serviceman!.media.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data!.serviceman!.media[0].originalUrl!,
                      placeholder: (context, url) => Container(
                          height: Sizes.s38,
                          width: Sizes.s38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage(eImageAssets.noImageFound1)))),
                      imageBuilder: (context, imageProvider) => Container(
                          height: Sizes.s38,
                          width: Sizes.s38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover, image: imageProvider))),
                      errorWidget: (context, url, error) =>
                          Container(height: Sizes.s38, width: Sizes.s38, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(eImageAssets.noImageFound3)))))
                  : Container(height: Sizes.s38, width: Sizes.s38, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(eImageAssets.noImageFound1)))),
          const HSpace(Sizes.s10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                    data!.serviceman!.id == null
                        ? data!.provider!.name ?? ''
                        : data!.serviceman!.name ?? '',
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText)),
                VerticalDivider(
                    color: appColor(context).darkText,
                    thickness: 1.5,
                    endIndent: 4,
                    indent: 5),
                Row(children: [
                  SvgPicture.asset(eSvgAssets.star),
                  Text(data!.rating.toString(),
                      style: appCss.dmDenseMedium13
                          .textColor(appColor(context).darkText))
                ])
              ]),
            ),
            if (data!.service != null)
              Text(data!.service!.title ?? '',
                      maxLines: 2,
                      style: appCss.dmDenseMedium12
                          .textColor(appColor(context).lightText))
                  .width(Sizes.s120)
          ]),
        ]),
        Container(
            padding: const EdgeInsets.all(Insets.i5),
            decoration: ShapeDecoration(
                color: data!.serviceman!.id == null
                    ? appColor(context).primary.withValues(alpha: 0.10)
                    : appColor(context).greenColor.withValues(alpha: 0.10),
                shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 6, cornerSmoothing: 1))),
            child: Text(
              data!.serviceman!.id == null
                  ? language(context, translations!.service)
                  : language(context, translations!.serviceman)
                      .capitalizeFirst(),
              style: appCss.dmDenseMedium11.textColor(
                  data!.serviceman!.id == null
                      ? appColor(context).primary
                      : appColor(context).greenColor),
            ))
      ]),
      const VSpace(Sizes.s15),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data!.description ?? '',
            style:
                appCss.dmDenseMedium12.textColor(appColor(context).darkText)),
        Divider(height: 1, color: appColor(context).stroke)
            .paddingSymmetric(vertical: Insets.i15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(getTime(DateTime.parse(data!.createdAt.toString())),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          isEditDelete == true ?   Row(children: [
            CommonArrow(
                onTap: editTap, isThirteen: true, arrow: eSvgAssets.edit),
            const HSpace(Sizes.s12),
            CommonArrow(
                onTap: deleteTap,
                isThirteen: true,
                arrow: eSvgAssets.delete,
                svgColor: appColor(context).red,
                color: appColor(context).red.withValues(alpha: 0.1))
          ]): Container()
        ])
      ])
    ])
        .paddingAll(Insets.i15)
        .boxBorderExtension(context, radius: AppRadius.r12)
        .paddingOnly(bottom: Insets.i20);
  }
}
