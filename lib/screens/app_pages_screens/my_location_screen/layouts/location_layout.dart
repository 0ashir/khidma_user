import '../../../../config.dart';

class LocationLayout extends StatelessWidget {
  final PrimaryAddress? data;
  final GestureTapCallback? editOnTap, deleteOnTap;
  final bool isPrimaryAnTapLayout, selectedIndex;

  const LocationLayout(
      {super.key,
      this.data,
      this.deleteOnTap,
      this.editOnTap,
      this.isPrimaryAnTapLayout = true,
      this.selectedIndex = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          data!.isPrimary == 1 || selectedIndex
              ? SvgPicture.asset(
                  eSvgAssets.tickCircle,
                  height: Sizes.s40,
                ).paddingAll(Insets.i5).decorated(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2, color: appColor(context).fieldCardBg))
              : SvgPicture.asset(
                      data!.type == "home"
                          ? eSvgAssets.homeFill
                          : eSvgAssets.beg,
                      colorFilter: ColorFilter.mode(
                          appColor(context).lightText, BlendMode.srcIn))
                  .paddingAll(Insets.i9)
                  .decorated(
                      color: appColor(context).stroke,
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 4, color: appColor(context).fieldCardBg)),
          const HSpace(Sizes.s10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data!.alternativeName ?? "",
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).darkText)),
            Text(
                data!.alternativePhone != null
                    ? "+${data!.code} ${data!.alternativePhone.toString()}"
                    : "",
                style: appCss.dmDenseMedium12
                    .textColor(appColor(context).lightText))
          ])
        ]),
        data?.type == null
            ? const SizedBox.shrink()
            : Text("${data?.type?.capitalizeFirst()}",
                    style: appCss.dmDenseMedium12
                        .textColor(appColor(context).primary))
                .paddingSymmetric(horizontal: Insets.i10, vertical: Insets.i5)
                .decorated(
                    borderRadius: BorderRadius.circular(AppRadius.r13),
                    color: appColor(context).primary.withOpacity(0.1))
      ]).paddingAll(Insets.i12),
      Divider(height: 1, color: appColor(context).stroke),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const VSpace(Sizes.s12),
        Text(language(context, translations!.address?.replaceAll('=>', ' :')),
            style:
                appCss.dmDenseMedium12.textColor(appColor(context).lightText)),
        const VSpace(Sizes.s5),
        Text(
            "${data?.address!}${"${data?.area != null ? "," : ""}${data?.area ?? ""}"},${" ${data?.city}"},${data?.state?.name == null ? "" : " ${data?.state?.name},"}${data?.country?.name == null ? "" : " ${data?.country?.name},"}${" ${data!.postalCode}"}",
            style:
                appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
        DottedLines(
                color: isPrimaryAnTapLayout
                    ? appColor(context).stroke
                    : appColor(context).whiteColor)
            .paddingSymmetric(vertical: isPrimaryAnTapLayout ? Insets.i10 : 0),
        if (isPrimaryAnTapLayout)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                "\u2022 ${data!.isPrimary == 1 ? translations!.setAsPrimary : translations!.notSetAsPrimary}",
                style: appCss.dmDenseMedium12.textColor(data!.isPrimary == 1
                    ? appColor(context).green
                    : appColor(context).lightText)),
            Row(children: [
              CommonArrow(
                  onTap: editOnTap,
                  arrow: eSvgAssets.edit,
                  svgColor: appColor(context).darkText),
              const HSpace(Sizes.s12),
              CommonArrow(
                  onTap: deleteOnTap,
                  arrow: eSvgAssets.delete,
                  svgColor: appColor(context).red,
                  color: appColor(context).red.withOpacity(0.1))
            ])
          ])
      ]).paddingSymmetric(horizontal: Insets.i15)
    ])
        .paddingOnly(bottom: Insets.i15)
        .decorated(
            color: appColor(context).whiteBg,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            boxShadow: [
              BoxShadow(
                  color: appColor(context).darkText.withOpacity(0.06),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 2)),
            ],
            border: Border.all(color: appColor(context).stroke))
        .paddingOnly(bottom: Insets.i15, left: 20, right: 20);
  }
}
