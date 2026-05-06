// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:fixit_user/providers/app_pages_providers/offer_chat_provider.dart';

import '../../../../config.dart';

class FeaturedServicesLayout extends StatelessWidget {
  final data;
  final GestureTapCallback? onTap, addTap;
  final bool? isProvider, inCart, isShowAdd;

  const FeaturedServicesLayout(
      {super.key,
      this.data,
      this.onTap,
      this.isProvider = true,
      this.addTap,
      this.isShowAdd = true,
      this.inCart = false});

  @override
  Widget build(BuildContext context) {
    log("message 123456 ${data?.status}");
    return Consumer3<CategoriesDetailsProvider, ChatProvider,
        OfferChatProvider>(builder: (context, catCtrl, chatCtrl, value, child) {
      return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                // if (data?.user != null)
                //   Row(
                //     children: [
                //       Container(
                //         height: Sizes.s30,
                //         width: Sizes.s30,
                //         decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             image: DecorationImage(
                //                 image: (data?.user?.media?.isNotEmpty ?? false)
                //                     ? NetworkImage(data!.user!.media!.first.originalUrl.toString())
                //                     :  AssetImage(eImageAssets.noImageFound3) as ImageProvider,)),
                //       ),
                //       const HSpace(Sizes.s8),
                //       Text(data?.user?.name ?? "" ,
                //           style: appCss.dmDenseMedium12
                //               .textColor(appColor(context).darkText)),
                //       const HSpace(Sizes.s5),
                //       SvgPicture.asset(eSvgAssets.star),
                //       const HSpace(Sizes.s2),
                //       Text(data?.user?.reviewRatings.toString() ?? "",
                //           style: appCss.dmDenseMedium13
                //               .textColor(appColor(context).darkText)),
                //       const Spacer(),
                //       CommonArrow(
                //           arrow: eSvgAssets.chat,
                //           svgColor: appColor(context).primary,
                //           color:
                //               appColor(context).primary.withValues(alpha: 0.15),
                //           onTap: () {
                //             log("data!.user!.media::${data!.user!.media}//${data!.user!.name}//${data!.user!.id}");
                //             route.pushNamed(
                //                 context, routeName.providerChatScreen,
                //                 arg: {
                //                   "image": data!.user!.media != null &&
                //                           data!.user!.media!.isNotEmpty
                //                       ? data!.user!.media![0].originalUrl!
                //                       : "",
                //                   "name": data!.user!.name,
                //                   "role": "user",
                //                   "userId": data!.user!.id,
                //                   "token": data!.user!.fcmToken,
                //                   "phone": data!.user!.phone,
                //                   "code": data!.user!.code,
                //                 });
                //           })
                //     ],
                //   ).padding(horizontal: Sizes.s15, vertical: Sizes.s12),
                Stack(alignment: Alignment.topRight, children: [
                  data!.media != null && data!.media!.isNotEmpty
                      ? CommonImageLayout(
                          tlRadius: 0,
                          tRRadius: 0,
                          blRadius: 0,
                          bRRadius: 0,
                          isAllBorderRadius: false,
                          image: data?.media?.first.originalUrl,
                          boxFit: BoxFit.cover,
                          height: Sizes.s230,
                          assetImage: eImageAssets.noImageFound2)
                      : CommonCachedImage(
                          tlRadius: 0,
                          tRRadius: 0,
                          blRadius: 0,
                          bRRadius: 0,
                          isAllBorderRadius: false,
                          height: Sizes.s230,
                          image: eImageAssets.noImageFound2),
                  if (data?.status == 0)
                    Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            height: Sizes.s230,
                            child: Text(
                                    translations!.unavailableService.toString(),
                                    style: appCss.dmDenseSemiBold15
                                        .textColor(appColor(context).whiteBg))
                                .padding(
                                    horizontal: Sizes.s5, vertical: Sizes.s2)
                                .decorated(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r20),
                                    color: appColor(context)
                                        .darkText
                                        .withOpacity(0.8)))
                        .decorated(
                            color:
                                appColor(context).whiteColor.withOpacity(0.5)),
                  Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        if (data!.isFeatured != 0)
                          SizedBox(
                                  child: Text(appFonts.trending,
                                          style: appCss.dmDenseMedium12
                                              .textColor(
                                                  appColor(context).whiteColor))
                                      .padding(
                                          left: Sizes.s10,
                                          right: Insets.i20,
                                          top: Insets.i3,
                                          bottom: Insets.i3))
                              .decorated(
                                  image: DecorationImage(
                                      image: AssetImage(eImageAssets.ad),
                                      fit: BoxFit.fill))
                      ]).paddingSymmetric(vertical: Insets.i10),
                  if (data!.discount != "" && data!.discount != 0)
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          if (data!.discount != null && data!.discount > 0)
                            SizedBox(
                                    child: Text(
                                            "${data!.discount}% ${language(context, translations!.off)}",
                                            style: appCss.dmDenseMedium12
                                                .textColor(appColor(context)
                                                    .whiteColor))
                                        .padding(
                                            horizontal: Insets.i9,
                                            top: Insets.i3,
                                            bottom: Insets.i3))
                                .decorated(
                                    color: appColor(context).red,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r30))
                        ]).paddingSymmetric(
                        horizontal: Insets.i20, vertical: Insets.i10)
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text(capitalizeFirstLetter(data!.title!),
                          style: appCss.dmDenseSemiBold15
                              .textColor(appColor(context).darkText)),
                    ),
                    if (data!.discount != null && data!.discount > 0)
                      Text(
                          symbolPosition
                              ? "${getSymbol(context)}${(currency(context).currencyVal * (data!.price ?? 0)).toStringAsFixed(2)}"
                              : "${(currency(context).currencyVal * (data!.price ?? 0)).toStringAsFixed(2)}${getSymbol(context)}",
                          style: appCss.dmDenseRegular14
                              .textColor(appColor(context).lightText)
                              .lineThrough),
                    const HSpace(Sizes.s8),
                    Text(
                        symbolPosition
                            ? "${getSymbol(context)}${((currency(context).currencyVal * (data!.serviceRate ?? data!.price ?? 0)).toStringAsFixed(2))}"
                            : "${((currency(context).currencyVal * (data!.serviceRate ?? data!.price ?? 0)).toStringAsFixed(2))}${getSymbol(context)}",
                        style: appCss.dmDenseBold16
                            .textColor(appColor(context).darkText))
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const VSpace(Sizes.s8),
                              IntrinsicHeight(
                                  child: Row(children: [
                                SvgPicture.asset(eSvgAssets.clock),
                                const HSpace(Sizes.s5),
                                Text("${data?.duration ?? ''} ",
                                    style: appCss.dmDenseSemiBold12
                                        .textColor(appColor(context).online)),
                                VerticalDivider(
                                        indent: 1,
                                        endIndent: 1,
                                        width: 1,
                                        color: appColor(context).online)
                                    .paddingSymmetric(horizontal: Insets.i5),
                                SvgPicture.asset(eSvgAssets.servicemenIcon,
                                    height: Sizes.s16,
                                    colorFilter: ColorFilter.mode(
                                        appColor(context).online,
                                        BlendMode.srcIn)),
                                const HSpace(Sizes.s5),
                                Expanded(
                                    child: Text(
                                        "${data!.requiredServicemen} ${capitalizeFirstLetter(language(context, translations!.serviceman))}",
                                        style: appCss.dmDenseSemiBold12
                                            .textColor(
                                                appColor(context).online))),
                                if (data?.status == 1)
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CommonArrow(
                                            arrow: eSvgAssets.chat,
                                            svgColor: appColor(context).primary,
                                            color: appColor(context)
                                                .primary
                                                .withValues(alpha: 0.15),
                                            onTap: () async {
                                              log("message-=-=-=-=-=${data?.user?.name}");
                                              final chatHistoryProvider =
                                                  Provider.of<
                                                          ChatHistoryProvider>(
                                                      context,
                                                      listen: false);
                                              final currentUserId =
                                                  chatHistoryProvider
                                                      .userModel?.id
                                                      .toString();
                                              final otherUserId =
                                                  data!.user!.id.toString();

                                              String? existingChatId;

                                              for (var doc
                                                  in chatHistoryProvider
                                                      .chatHistory) {
                                                final d = doc.data()
                                                    as Map<String, dynamic>;
                                                final senderId =
                                                    d['senderId'].toString();
                                                final receiverId =
                                                    d['receiverId'].toString();

                                                final isMatch = (senderId ==
                                                            currentUserId &&
                                                        receiverId ==
                                                            otherUserId) ||
                                                    (receiverId ==
                                                            currentUserId &&
                                                        senderId ==
                                                            otherUserId);

                                                if (isMatch &&
                                                    d['isOffer'] == true) {
                                                  existingChatId = d['chatId'];
                                                  break;
                                                }
                                              }

                                              final chatId = existingChatId ??
                                                  ChatProvider.buildChatId(
                                                    senderId: currentUserId
                                                        .toString(),
                                                    receiverId: otherUserId,
                                                    bookingId:
                                                        null, // or bookingId if you have it
                                                  );
                                              route.pushNamed(context,
                                                  routeName.providerChatScreen,
                                                  arg: {
                                                    "image": data!.user!
                                                                    .media !=
                                                                null &&
                                                            data!.user!.media!
                                                                .isNotEmpty
                                                        ? data!.user!.media![0]
                                                                .originalUrl ??
                                                            ""
                                                        : "",
                                                    "name": data!.user!.name,
                                                    "role": "user",
                                                    "userId": data!.user!.id,
                                                    "token":
                                                        data!.user!.fcmToken,
                                                    "phone": data!.user!.phone,
                                                    "code": data!.user!.code,
                                                    "chatId":
                                                        existingChatId ?? chatId

                                                    // fallback to 0 if no match
                                                  });
                                            }),
                                        const HSpace(Sizes.s10),
                                        if (data?.status == 1)
                                          catCtrl.loadingServiceId == data?.id
                                              ? Container(
                                                  width: Sizes.s60,
                                                  height: Sizes.s38,
                                                  decoration: ShapeDecoration(
                                                    color: appColor(context)
                                                        .primary,
                                                    shape:
                                                        SmoothRectangleBorder(
                                                      borderRadius:
                                                          SmoothBorderRadius(
                                                        cornerRadius:
                                                            AppRadius.r8,
                                                        cornerSmoothing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      // Static size for CircularProgressIndicator
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: appColor(context)
                                                            .whiteColor,
                                                        strokeWidth:
                                                            2.5, // Thinner stroke for smaller size
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : /*(inCart!)
                                              ? AddedButtonCommon(onTap: addTap)
                                              : */
                                              isShowAdd == true
                                                  ? AddButtonCommon(
                                                      onTap: addTap)
                                                  : Container(
                                                      decoration: ShapeDecoration(
                                                          color: appColor(
                                                                  context)
                                                              .primary,
                                                          shape: SmoothRectangleBorder(
                                                              borderRadius: SmoothBorderRadius(
                                                                  cornerRadius:
                                                                      AppRadius
                                                                          .r8,
                                                                  cornerSmoothing:
                                                                      1))),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.add, color: appColor(context).whiteColor, size: Sizes.s16),
                                                          const SizedBox(width: 4),
                                                          Text("Add", style: appCss.dmDenseSemiBold12.textColor(appColor(context).whiteColor)),
                                                        ],
                                                      ).padding(horizontal: Insets.i10, vertical: Insets.i10),
                                                      ).inkWell(onTap: addTap)
                                      ])
                              ]))
                            ])),
                      ]),
                ]).padding(horizontal: Insets.i14, vertical: Insets.i13)
              ]))
          .decorated(
              color: data?.status == 1
                  ? appColor(context).whiteBg
                  : appColor(context).lightText.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                    blurRadius: 3,
                    spreadRadius: 2,
                    color: appColor(context).darkText.withOpacity(0.06))
              ],
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(color: appColor(context).stroke))
          .inkWell(onTap: onTap)
          .paddingOnly(bottom: Insets.i15);
    });
  }
}
