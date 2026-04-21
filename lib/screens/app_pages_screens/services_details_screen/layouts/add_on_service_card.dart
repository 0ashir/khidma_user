// import 'dart:developer';

// import '../../../../config.dart';
// import '../../../../models/service_details_model.dart';

// class AddOnServiceCard extends StatelessWidget {
//   final additionalServices;
//   final bool isContain, isDelete, isIconShow;
//   final int? index, additionalServicesLength;
//   final GestureTapCallback? deleteTap, onTap;
//   const AddOnServiceCard(
//       {super.key,
//       this.additionalServices,
//       this.isDelete = false,
//       this.isContain = false,
//       this.index,
//       this.additionalServicesLength,
//       this.deleteTap,
//       this.onTap,
//       this.isIconShow = true});

//   @override
//   Widget build(BuildContext context) {
//     // final media = additionalServices is Map<String, dynamic>
//     //     ? additionalServices['media'] ?? []
//     //     : additionalServices.media ?? [];

//     final title = additionalServices is Map<String, dynamic>
//         ? additionalServices['title']
//         : additionalServices.title;

//     final price = additionalServices is Map<String, dynamic>
//         ? additionalServices['price']
//         : additionalServices.price;

//     final rawMedia = additionalServices is Map<String, dynamic>
//         ? additionalServices['media']
//         : additionalServices.media;

// // Always ensure media is a list
//     final media = rawMedia is List ? rawMedia : [];

//     final imageUrl = media.isNotEmpty
//         ? (media[0] is String
//             ? media[0]
//             : media[0] is Map
//                 ? media[0]['original_id'] ?? ''
//                 : media[0] is AdditionalServiceMedia
//                     ? (media[0] as AdditionalServiceMedia).originalId ?? ''
//                     : '')
//         : '';

//     log("imageUrl::${imageUrl.runtimeType}");
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             imageUrl!.isNotEmpty
//                 ? CommonImageLayout(
//                     radius: 8,
//                     width: Sizes.s50,
//                     height: Sizes.s50,
//                     image: imageUrl.toString() ?? '',
//                     assetImage: eImageAssets.noImageFound2,
//                   )
//                 : Container(
//                     height: Sizes.s52,
//                     width: Sizes.s52,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         image: DecorationImage(
//                             image: AssetImage(eImageAssets.noImageFound1),
//                             fit: BoxFit.contain))),
//             const HSpace(Sizes.s10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                         maxLines: 2,
//                         style: appCss.dmDenseMedium14
//                             .textColor(appColor(context).darkText))
//                     .width(Sizes.s180),
//                 const VSpace(Sizes.s8),
//                 Text(
//                     symbolPosition
//                         ? "${getSymbol(context)}${currency(context).currencyVal * price}"
//                         : "${currency(context).currencyVal * price}${getSymbol(context)}",
//                     style: appCss.dmDenseMedium14
//                         .textColor(appColor(context).darkText)),
//               ],
//             )
//           ],
//         ),
//         if (isIconShow)
//           isDelete
//               ? CommonArrow(
//                   arrow: eSvgAssets.delete,
//                   svgColor: appColor(context).red,
//                   onTap: deleteTap,
//                   color: appColor(context).red.withOpacity(0.1))
//               : isContain
//                   ? SvgPicture.asset(
//                       eSvgAssets.tickCircle,
//                       height: Sizes.s20,
//                     ).inkWell(onTap: onTap)
//                   : SvgPicture.asset(eSvgAssets.add,
//                           colorFilter: ColorFilter.mode(
//                               appColor(context).primary, BlendMode.srcIn))
//                       .paddingAll(1)
//                       .decorated(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: appColor(context).primary))
//                       .inkWell(onTap: onTap)
//       ],
//     )
//         .inkWell(onTap: onTap)
//         .paddingSymmetric(horizontal: Insets.i15, vertical: Sizes.s12)
//         .boxBorderExtension(context,
//             bColor: isContain
//                 ? appColor(context).primary.withOpacity(.10)
//                 : appColor(context).stroke,
//             color: isContain
//                 ? appColor(context).primary.withOpacity(.10)
//                 : appColor(context).whiteBg)
//         .paddingOnly(
//             bottom: index != additionalServicesLength ? Insets.i15 : 0);
//   }
// }

import 'dart:developer';

import '../../../../config.dart';
import '../../../../models/service_details_model.dart';

class AddOnServiceCard extends StatefulWidget {
  final dynamic additionalServices;
  final bool isContain, isDelete, isIconShow;
  final int? index, additionalServicesLength;
  final String? count;
  final GestureTapCallback? deleteTap, onTap, incrementTap, decrementTap;

  const AddOnServiceCard({
    super.key,
    this.additionalServices,
    this.isDelete = false,
    this.isContain = false,
    this.index,
    this.count,
    this.additionalServicesLength,
    this.deleteTap,
    this.onTap,
    this.incrementTap,
    this.decrementTap,
    this.isIconShow = true,
  });

  @override
  State<AddOnServiceCard> createState() => _AddOnServiceCardState();
}

class _AddOnServiceCardState extends State<AddOnServiceCard> {
/*   int count = 1; */ // 👈 default quantity

  @override
  Widget build(BuildContext context) {
    final title = widget.additionalServices is Map<String, dynamic>
        ? widget.additionalServices['title']
        : widget.additionalServices.title;

    final price = widget.additionalServices is Map<String, dynamic>
        ? widget.additionalServices['price']
        : widget.additionalServices.price;

    final rawMedia = widget.additionalServices is Map<String, dynamic>
        ? widget.additionalServices['media']
        : widget.additionalServices.media;
    final qty = widget.additionalServices is Map<String, dynamic>
        ? widget.additionalServices['qty']
        : widget.additionalServices.qty;

    final media = rawMedia is List ? rawMedia : [];

    final imageUrl = media.isNotEmpty
        ? (media[0] is String
            ? media[0]
            : media[0] is Map
                ? media[0]['original_id'] ?? ''
                : media[0] is AdditionalServiceMedia
                    ? (media[0] as AdditionalServiceMedia).originalId ?? ''
                    : '')
        : '';

    log("imageUrl::${imageUrl.runtimeType}");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ---------- Left Side (Image + Text) ----------
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            imageUrl.isNotEmpty
                ? CommonImageLayout(
                    radius: 8,
                    width: Sizes.s50,
                    height: Sizes.s50,
                    image: imageUrl.toString(),
                    assetImage: eImageAssets.noImageFound2,
                  )
                : Container(
                    height: Sizes.s52,
                    width: Sizes.s52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: AssetImage(eImageAssets.noImageFound1),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
            const HSpace(Sizes.s10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Sizes.s130,
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: appCss.dmDenseMedium14
                        .textColor(appColor(context).darkText),
                  ),
                ) /* .width(Sizes.s180) */,
                const VSpace(Sizes.s8),
                Text(
                  symbolPosition
                      ? "${getSymbol(context)}${currency(context).currencyVal * price}"
                      : "${currency(context).currencyVal * price}${getSymbol(context)}",
                  style: appCss.dmDenseMedium14
                      .textColor(appColor(context).darkText),
                ),
              ],
            )
          ],
        ).padding(left: Sizes.s3),

        // ---------- Right Side (Increment / Decrement or Icons) ----------
        if (widget.isIconShow)
          widget.isDelete
              ? Row(
                  children: [
                    Text(
                      "Qty : ${qty ?? 0 /* widget.count */}",
                      style: appCss.dmDenseMedium14
                          .textColor(appColor(context).darkText),
                    ),
                    const HSpace(Sizes.s5),
                    CommonArrow(
                      arrow: eSvgAssets.delete,
                      svgColor: appColor(context).red,
                      onTap: widget.deleteTap,
                      color: appColor(context).red.withOpacity(0.1),
                    ),
                  ],
                ).padding(right: Sizes.s5)
              : widget.isContain
                  ? Expanded(
                      child: Row(
                        children: [
                          // Decrement Button
                          IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: 18,
                                color: appColor(context).darkText,
                              ),
                              onPressed: widget
                                  .decrementTap /* () {
                              setState(() {
                                if (count > 1) count--;
                              });
                            }, */
                              ),
                          Text(
                            "${qty ?? 0 /* widget.count */}",
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText),
                          ),
                          // Increment Button
                          IconButton(
                              icon: Icon(Icons.add,
                                  size: 18, color: appColor(context).darkText),
                              onPressed: widget
                                  .incrementTap /* () {
                              setState(() {
                                count++;
                              });
                            }, */
                              ),
                          CommonArrow(
                            arrow: eSvgAssets.delete,
                            svgColor: appColor(context).red,
                            onTap: widget.onTap,
                            color: appColor(context).red.withOpacity(0.1),
                          ),
                          /* SizedBox(
                            width: Sizes.s10,
                          ), */
                        ],
                      ),
                    )
                  : SvgPicture.asset(
                      eSvgAssets.add,
                      colorFilter: ColorFilter.mode(
                        appColor(context).primary,
                        BlendMode.srcIn,
                      ),
                    )
                      .paddingAll(1)
                      .decorated(
                        shape: BoxShape.circle,
                        border: Border.all(color: appColor(context).primary),
                      )
                      .padding(right: Sizes.s10)
                      .inkWell(onTap: widget.onTap),
      ],
    )
        .inkWell(onTap: widget.onTap)
        .paddingSymmetric(/* horizontal: Insets.i15, */ vertical: Sizes.s12)
        .boxBorderExtension(
          context,
          bColor: widget.isContain
              ? appColor(context).primary.withOpacity(.10)
              : appColor(context).stroke,
          color: widget.isContain
              ? appColor(context).primary.withOpacity(.10)
              : appColor(context).whiteBg,
        )
        .paddingOnly(
            bottom: widget.index != widget.additionalServicesLength
                ? Insets.i15
                : 0);
  }
}
