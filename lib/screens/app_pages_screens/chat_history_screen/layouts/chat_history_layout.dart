import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class ChatHistoryLayout extends StatelessWidget {
  final dynamic data;
  final List? list;
  final int? index;
  final GestureTapCallback? onTap;

  const ChatHistoryLayout(
      {super.key, this.data, this.list, this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    log("data::$data//${MessageType.offer.name}");
    final bool isMe = data['senderId'].toString() == userModel?.id.toString();

    final String imageUrl =
        isMe ? (data['receiverImage'] ?? '') : (data['senderImage'] ?? '');
    return Column(children: [
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                  height: Sizes.s45,
                  width: Sizes.s45,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage(eImageAssets.noImageFound3)
                                  as ImageProvider,
                          fit: BoxFit.cover))),
              const HSpace(Sizes.s10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  (data as Map<String, dynamic>).containsKey('isOffer')
                      ? data['senderId'].toString() == userModel?.id.toString()
                          ? (data["receiverName"] ?? "")
                          : (data['senderName'] ?? "")
                      : "#${data['bookingNumber'] ?? ''}",
                  style: appCss.dmDenseMedium14
                      .textColor(appColor(context).darkText),
                ),
                const VSpace(Sizes.s2),
                Text(
                        (data as Map<String, dynamic>).containsKey('isOffer')
                            ? data['messageType'] == MessageType.offer.name
                                ? data['senderId'].toString() ==
                                        userModel!.id.toString()
                                    ? "You send the offer"
                                    : "You received the offer"
                                : data['lastMessage'] ?? 'Offer sent'
                            : data['messageType'] == MessageType.offer
                                ? data['senderId'] == userModel!.id
                                    ? "You send the offer"
                                    : data["lastMessage"]['title'] ??
                                        'Offer sent'
                                : data['messageType'] == "image"
                                    ? data['senderId'] == userModel!.id
                                        ? "\u{1F4F8} You send the image"
                                        : "\u{1F4F8} ${data['senderName']} send you the image"
                                    : data['messageType'] == "video"
                                        ? data['senderId'] == userModel!.id
                                            ? "\u{1F4F8} You send the Video"
                                            : "\u{1F4F8} ${data['senderName']} send you the Video"
                                        : data["lastMessage"] is String
                                            ? data["lastMessage"]
                                            : "New message",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).lightText))
                    .width(Sizes.s150)
              ])
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                  DateFormat('dd MMM yy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(data["updateStamp"].toString()))),
                  style: appCss.dmDenseRegular12
                      .textColor(appColor(context).lightText)),
              const VSpace(Sizes.s3),
              // if ((data as Map<String, dynamic>).containsKey('isOffer'))
              //   SvgPicture.asset(eSvgAssets.offer)
            ])
          ]).inkWell(onTap: onTap),
      if (index != list!.length - 1)
        const DividerCommon().paddingSymmetric(vertical: Insets.i15)
    ]);
  }
}
