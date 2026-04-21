import 'dart:developer';

import '../../../../config.dart';
import '../../../../providers/app_pages_providers/offer_chat_provider.dart';

class ChatAppBarLayout extends StatelessWidget {
  final Function(int)? onSelected;
  final bool isOffer;

  const ChatAppBarLayout({super.key, this.onSelected, this.isOffer = false});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, OfferChatProvider>(
        builder: (context1, value, offerChat, child) {
      log("offerChat.name::${value.bookingId}//$isOffer");
      return Container(
              height: Sizes.s108,
              decoration: ShapeDecoration(
                  color: appColor(context).fieldCardBg,
                  shape: SmoothRectangleBorder(
                      side: BorderSide(color: appColor(context).stroke),
                      borderRadius: const SmoothBorderRadius.vertical(
                          bottom: SmoothRadius(
                              cornerRadius: AppRadius.r20,
                              cornerSmoothing: 1)))),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      // Arrow
                      CommonArrow(
                          arrow: eSvgAssets.arrowLeft,
                          color: appColor(context).whiteBg,
                          onTap: () => isOffer
                              ? offerChat.onBack(context, true)
                              : value.onBack(context, true)),
                      const HSpace(Sizes.s15),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                                isOffer
                                    ? offerChat.name ?? ""
                                    : "#${value.bookingNumber ?? ""}",
                                style: appCss.dmDenseMedium14
                                    .textColor(appColor(context).darkText)),
                            // const VSpace(Sizes.s2),
                            // Status
                            // Text(language(context, appFonts.online),
                            //     style: appCss.dmDenseMedium12
                            //         .textColor(appColor(context).online))
                          ])
                    ]),

                    // isOffer
                    //     ? SizedBox()
                    //     : SizedBox(
                    //         height: Sizes.s40,
                    //         width: Sizes.s40,
                    //         child: PopupMenuButton(
                    //           color: appColor(context).whiteBg,
                    //           constraints: const BoxConstraints(
                    //               minWidth: Sizes.s87, maxWidth: Sizes.s87),
                    //           position: PopupMenuPosition.under,
                    //           shape: const RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.all(
                    //                   Radius.circular(AppRadius.r8))),
                    //           onSelected: (value) => onSelected!(value),
                    //           padding: const EdgeInsets.all(0),
                    //           iconSize: Sizes.s20,
                    //           offset: const Offset(5, 20),
                    //           icon: SvgPicture.asset(eSvgAssets.more,
                    //               height: Sizes.s20,
                    //               colorFilter: ColorFilter.mode(
                    //                   appColor(context).darkText,
                    //                   BlendMode.srcIn)),
                    //           itemBuilder: (context) => [
                    //             buildPopupMenuItem(
                    //                 list: appArray.optionList
                    //                     .asMap()
                    //                     .entries
                    //                     .map((e) => PopupItemRowCommon(
                    //                           onTap: () => onSelected!(e.key),
                    //                           data: e.value,
                    //                           index: e.key,
                    //                           list: appArray.optionList,
                    //                         ))
                    //                     .toList())
                    //           ],
                    //         ).decorated(
                    //             color: appColor(context).whiteBg,
                    //             shape: BoxShape.circle),
                    //       )
                  ]).paddingOnly(
                  right: Insets.i20, left: Insets.i20, top: Insets.i35))
          .decorated();
    });
  }
}
