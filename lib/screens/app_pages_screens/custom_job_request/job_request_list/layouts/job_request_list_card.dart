import 'package:intl/intl.dart';
import '../../../../../config.dart';

class JobRequestListCard extends StatelessWidget {
  final JobRequestModel? data;
  final GestureTapCallback? deleteTap;
  const JobRequestListCard({super.key, this.data, this.deleteTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(children: [
                data!.media!.isNotEmpty
                    ? CommonImageLayout(
                            height: Sizes.s52,
                            width: Sizes.s52,
                            radius: 8,
                            image: data!.media![0].originalUrl!,
                            assetImage: eImageAssets.noImageFound3)
                        .boxShapeExtension()
                    : CommonCachedImage(
                            image: eImageAssets.noImageFound3,
                            assetImage: eImageAssets.noImageFound3,
                            height: Sizes.s52,
                            width: Sizes.s52)
                        .boxShapeExtension(),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capitalizeFirstLetter(data!.title),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        const VSpace(Sizes.s8),
                        Text(
                            (data!.status != "accepted")
                                ? symbolPosition
                                    ? "${getSymbol(context)}${currency(context).currencyVal * data!.initialPrice!}"
                                    : "${currency(context).currencyVal * data!.initialPrice!}${getSymbol(context)}"
                                : symbolPosition
                                    ? "${getSymbol(context)}${currency(context).currencyVal * data!.finalPrice!}"
                                    : "${currency(context).currencyVal * data!.finalPrice!}${getSymbol(context)}",
                            overflow: TextOverflow.ellipsis,
                            style: appCss.dmDenseSemiBold12
                                .textColor(appColor(context).darkText)),
                      ]).paddingOnly(left: Insets.i10),
                )
              ]),
            ),
            Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.s12, vertical: Sizes.s4),
                decoration: ShapeDecoration(
                    color: colorCondition(data!.status, context),
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 11, cornerSmoothing: 2))),
                child: Text(capitalizeFirstLetter(data!.status),
                    style: appCss.dmDenseMedium10
                        .textColor(appColor(context).whiteColor)))
          ]),
      const VSpace(Sizes.s12),
      const DottedLines(),
      const VSpace(Sizes.s18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateFormat("MMM d, yyyy")
                  .format(DateTime.parse(data!.bookingDate.toString())),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          CommonArrow(
              arrow: eSvgAssets.delete,
              isThirteen: true,
              onTap: deleteTap,
              svgColor: appColor(context).red,
              color: appColor(context).red.withOpacity(0.1))
        ],
      )
    ])
        .paddingAll(12)
        .boxBorderExtension(context, isShadow: true)
        .marginOnly(bottom: Sizes.s20)
        .inkWell(
            onTap: () => route.pushNamed(context, routeName.jobRequestDetail,
                arg: {"serviceId": data!.id}));
  }
}
