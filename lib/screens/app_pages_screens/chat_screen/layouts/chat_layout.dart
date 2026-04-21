import 'package:fixit_user/providers/app_pages_providers/offer_chat_provider.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';
import '../../../../models/message_model.dart';

class ChatLayout extends StatelessWidget {
  final MessageModel? document;
  final AlignmentGeometry? alignment;
  final bool? isSentByMe;
  final bool isEmailOrPhone;
  final GestureTapCallback? accept, reject, pay;

  const ChatLayout(
      {super.key,
      this.document,
      this.alignment,
      this.isSentByMe,
      this.isEmailOrPhone = false,
      this.accept,
      this.pay,
      this.reject});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OfferChatProvider>(context);
    return Consumer<OfferChatProvider>(builder: (context, value, child) {
      return Row(
        mainAxisAlignment: isSentByMe == true
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (document!.type == MessageType.text.name)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: Insets.i15, vertical: Insets.i15),
              decoration: BoxDecoration(
                  color: isSentByMe == true
                      ? appColor(context).primary
                      : appColor(context).fieldCardBg,
                  borderRadius: rtl(context)
                      ? BorderRadius.only(
                          topRight: const Radius.circular(Insets.i20),
                          topLeft: const Radius.circular(Insets.i20),
                          bottomRight: Radius.circular(
                              isSentByMe == true ? Insets.i20 : 0),
                          bottomLeft: Radius.circular(
                              isSentByMe == true ? 0 : Insets.i20))
                      : BorderRadius.only(
                          topRight: const Radius.circular(Insets.i20),
                          topLeft: const Radius.circular(Insets.i20),
                          bottomRight: Radius.circular(
                              isSentByMe == true ? 0 : Insets.i20),
                          bottomLeft: Radius.circular(
                              isSentByMe == true ? Insets.i20 : 0))),
              child: Column(
                  crossAxisAlignment: isSentByMe == true
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        isEmailOrPhone
                            ? "The content of this message is confidential"
                            : document!.content.toString(),
                        style: appCss.dmDenseMedium14.textColor(
                            isSentByMe == true
                                ? appColor(context).whiteColor
                                : appColor(context).darkText)),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      if (document!.isSeen == true)
                        SvgPicture.asset(eSvgAssets.doubleTick)
                            .paddingOnly(right: Insets.i5),
                      Text(
                          DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document!.timestamp!))),
                          softWrap: true
                          ,
                          style: appCss.dmDenseRegular13.textColor(
                              isSentByMe == true
                                  ? appColor(context).whiteColor
                                  : appColor(context).lightText))
                    ])
                  ]))
          .paddingDirectional(
              horizontal: Insets.i20, vertical: Sizes.s5),
          if (document!.type == MessageType.image.name)
            Material(
                    elevation: 1,
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 15, cornerSmoothing: 1),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                          width: Sizes.s160,
                          decoration: ShapeDecoration(
                            color: appColor(context).primary,
                            shadows: [
                              BoxShadow(
                                  color: appColor(context)
                                      .darkText
                                      .withOpacity(0.06),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2))
                            ],
                            shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 10, cornerSmoothing: 1)),
                          )),
                      imageUrl: document!.content!,
                      width: Sizes.s160,
                      fit: BoxFit.fill,
                    ))
                .padding(
                    horizontal: Insets.i20,
                    top: Insets.i10,
                    vertical: Insets.i10),
          if (document!.type == MessageType.offer.name)
            Stack(
              children: [
                Container(
                        width: 255,
                        padding: const EdgeInsets.all(Sizes.s12),
                        decoration: BoxDecoration(
                            color: document!.content['ended_at'] ==
                                        DateFormat('dd-MM-yyy')
                                            .format(DateTime.now()) ||
                                    document!.content['status'] == "rejected"
                                ? appColor(context).lightText.withOpacity(0.2)
                                : appColor(context).primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(Sizes.s20),
                                topRight: Radius.circular(Sizes.s20),
                                bottomRight: Radius.circular(Sizes.s20),
                                bottomLeft: Radius.circular(Sizes.s20))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(document!.content!["title"],
                                  style: appCss.dmDenseSemiBold15.textColor(
                                      document!.content['ended_at'] ==
                                                  DateFormat('dd-MM-yyy')
                                                      .format(DateTime.now()) ||
                                              document!.content['status'] ==
                                                  "rejected"
                                          ? appColor(context).lightText
                                          : appColor(context).whiteColor)),
                              const VSpace(Sizes.s6),
                              if (value.isExpand)
                                Text(
                                  document!.content!["description"],
                                  style: appCss.dmDenseMedium12.textColor(
                                      document!.content['ended_at'] ==
                                                  DateFormat('dd-MM-yyy')
                                                      .format(DateTime.now()) ||
                                              document!.content['status'] ==
                                                  "rejected"
                                          ? appColor(context).lightText
                                          : appColor(context)
                                              .whiteColor
                                              .withOpacity(0.5)),
                                ),
                              const VSpace(Sizes.s8),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    eSvgAssets.dollar,
                                    colorFilter: ColorFilter.mode(
                                        document!.content['ended_at'] ==
                                                    DateFormat('dd-MM-yyy')
                                                        .format(
                                                            DateTime.now()) ||
                                                document!.content['status'] ==
                                                    "rejected"
                                            ? appColor(context).lightText
                                            : appColor(context).whiteColor,
                                        BlendMode.srcIn),
                                  ),
                                  const HSpace(Sizes.s10),
                                  Text(
                                    "${language(context, translations!.amount)}: ",
                                    style: appCss.dmDenseMedium12.textColor(
                                        document!.content['ended_at'] ==
                                                    DateFormat('dd-MM-yyy')
                                                        .format(
                                                            DateTime.now()) ||
                                                document!.content['status'] ==
                                                    "rejected"
                                            ? appColor(context).lightText
                                            : appColor(context)
                                                .whiteColor
                                                .withOpacity(0.5)),
                                  ),
                                  Text(
                                    symbolPosition
                                        ? " ${getSymbol(context)}${document!.content!["price"]}"
                                        : " ${document!.content!["price"]}${getSymbol(context)}",
                                    style: appCss.dmDenseMedium12.textColor(
                                        document!.content['ended_at'] ==
                                                    DateFormat('dd-MM-yyy')
                                                        .format(
                                                            DateTime.now()) ||
                                                document!.content['status'] ==
                                                    "rejected"
                                            ? appColor(context).lightText
                                            : appColor(context)
                                                .whiteColor
                                                .withOpacity(0.5)),
                                  ),
                                ],
                              ),
                              if (value.isExpand)
                                Row(children: [
                                  SvgPicture.asset(
                                    eSvgAssets.timer,
                                    colorFilter: ColorFilter.mode(
                                        document!.content['ended_at'] ==
                                                    DateFormat('dd-MM-yyy')
                                                        .format(
                                                            DateTime.now()) ||
                                                document!.content['status'] ==
                                                    "rejected"
                                            ? appColor(context).lightText
                                            : appColor(context).whiteColor,
                                        BlendMode.srcIn),
                                  ),
                                  const HSpace(Sizes.s10),
                                  Text(
                                      "${language(context, "Service time")}: ${document!.content!["duration"]}",
                                      style: appCss.dmDenseMedium12.textColor(
                                          document!.content['ended_at'] ==
                                                      DateFormat(
                                                              'dd-MM-yyy')
                                                          .format(
                                                              DateTime.now()) ||
                                                  document!.content['status'] ==
                                                      "rejected"
                                              ? appColor(context).lightText
                                              : appColor(context)
                                                  .whiteColor
                                                  .withOpacity(0.5)))
                                ]).paddingDirectional(vertical: Sizes.s5),
                              if (value.isExpand)
                                Row(children: [
                                  SvgPicture.asset(
                                    eSvgAssets.accountTag,
                                    colorFilter: ColorFilter.mode(
                                        document!.content['ended_at'] ==
                                                    DateFormat('dd-MM-yyy')
                                                        .format(
                                                            DateTime.now()) ||
                                                document!.content['status'] ==
                                                    "rejected"
                                            ? appColor(context).lightText
                                            : appColor(context).whiteColor,
                                        BlendMode.srcIn),
                                  ),
                                  const HSpace(Sizes.s10),
                                  Text(
                                      "${language(context, appFonts.serviceStaffRequired)}: ${document!.content!["required_servicemen"]}",
                                      style: appCss.dmDenseMedium12.textColor(
                                          document!.content['ended_at'] ==
                                                      DateFormat(
                                                              'dd-MM-yyy')
                                                          .format(
                                                              DateTime.now()) ||
                                                  document!.content['status'] ==
                                                      "rejected"
                                              ? appColor(context).lightText
                                              : appColor(context)
                                                  .whiteColor
                                                  .withOpacity(0.5)))
                                ]),
                              if (value.isExpand)
                                DividerCommon(
                                  color: document!.content['ended_at'] ==
                                              DateFormat('dd-MM-yyy')
                                                  .format(DateTime.now()) ||
                                          document!.content['status'] ==
                                              "rejected"
                                      ? appColor(context).lightText
                                      : appColor(context).whiteColor,
                                ).paddingDirectional(vertical: Sizes.s14),
                              if (value.isExpand)
                                (document!.content['ended_at'] ==
                                            DateFormat('dd-MM-yyy')
                                                .format(DateTime.now()) ||
                                        document!.content['status'] ==
                                            "rejected")
                                    ? Text(
                                            language(
                                                context,
                                                document!.content['status'] == "rejected"
                                                    ? "appFonts.rejected"
                                                    : "appFonts.offerExpired"),
                                            style: appCss.dmDenseMedium12.textColor(
                                                appColor(context).lightText))
                                        .center()
                                    : document!.receiverId.toString() ==
                                            userModel!.id.toString()
                                        ? document!.content['status'] ==
                                                "pending"
                                            ? IntrinsicWidth(
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                    Expanded(
                                                        child: ButtonCommon(
                                                            title: language(
                                                                context,
                                                                translations!
                                                                    .reject),
                                                            onTap: reject,
                                                            borderColor: appColor(
                                                                    context)
                                                                .whiteColor)),
                                                    const HSpace(Sizes.s10),
                                                    Expanded(
                                                        child: ButtonCommon(
                                                            title: language(
                                                                context,
                                                                translations!
                                                                    .accepted),
                                                            onTap: accept,
                                                            color: appColor(
                                                                    context)
                                                                .whiteColor,
                                                            fontColor: appColor(
                                                                    context)
                                                                .primary))
                                                  ]))
                                            : document!.content['status'] == "rejected"
                                                ? Container()
                                                : Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: 50,
                                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                                    decoration: ShapeDecoration(color: appColor(context).whiteColor, shape: SmoothRectangleBorder(side: BorderSide(color: appColor(context).trans), borderRadius: SmoothBorderRadius(cornerRadius: AppRadius.r8, cornerSmoothing: 1))),
                                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                      provider.isLoaderforBooking
                                                          ? const CircularProgressIndicator()
                                                          : Text(
                                                              language(
                                                                  context,
                                                                  translations!
                                                                      .bookNow),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: appCss
                                                                  .dmDenseSemiBold16
                                                                  .textColor(appColor(
                                                                          context)
                                                                      .primary))
                                                    ])).inkWell(onTap: pay) /* ButtonCommon(
                                                    title: translations!.bookNow,
                                                    onTap: pay,
                                                    fontColor: appColor(context).primary,
                                                    color: appColor(context).whiteColor) */
                                        : Container()
                            ]).paddingOnly(bottom: Sizes.s10))
                    .paddingOnly(
                        right: Sizes.s80, left: Sizes.s20, bottom: Sizes.s15),
                Positioned(
                  left: Sizes.s130,
                  bottom: 2,
                  child: CommonArrow(
                      svgColor: appColor(context).primary,
                      arrow: value.isExpand == true
                          ? eSvgAssets.upDoubleArrow
                          : eSvgAssets.downDoubleArrow,
                      isThirteen: true,
                      onTap: () => value.onExpand(value.isExpand),
                      color: const Color(0xFFEEF0FF)),
                )
              ],
            ),
          // if (document!.type == MessageType.video.name)
          //   ChatVideo(snapshot: document!.content!)
        ],
      );
    });
  }
}
