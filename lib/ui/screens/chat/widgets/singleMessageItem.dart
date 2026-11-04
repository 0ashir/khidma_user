import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SingleChatMessageItem extends StatefulWidget {
  final ChatMessage chatMessage;
  final bool isLoading;
  final bool isError;
  final String senderId;
  final Function(ChatMessage chatMessage) onRetry;
  final bool showTime;
  final String? avatarUrl;

  const SingleChatMessageItem({
    super.key,
    required this.chatMessage,
    required this.isLoading,
    required this.isError,
    required this.onRetry,
    required this.senderId,
    this.showTime = true,
    this.avatarUrl,
  });

  @override
  State<SingleChatMessageItem> createState() => _SingleChatMessageItemState();
}

class _SingleChatMessageItemState extends State<SingleChatMessageItem> {
  final double _messageItemBorderRadius = 8;

  final ValueNotifier _linkAddNotifier = ValueNotifier('');

  @override
  void dispose() {
    _linkAddNotifier.dispose();
    super.dispose();
  }

  Widget _buildTextMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required ChatMessage textMessage,
  }) {
    return Row(
      mainAxisAlignment: textMessage.senderId == widget.senderId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomContainer(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.8,
              minWidth: constraints.maxWidth * 0.15,
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(8),
            color: textMessage.senderId == widget.senderId
                ? context.colors.backgroundBrandSubtle
                : context.colors.backgroundPrimary,
            borderRadius: _messageItemBorderRadius,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: textMessage.senderId == widget.senderId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  //This is preview builder for image
                  ValueListenableBuilder(
                    valueListenable: _linkAddNotifier,
                    builder: (context, dynamic value, c) {
                      if (value == null || value == '') {
                        return const SizedBox.shrink();
                      }

                      return FutureBuilder(
                        future: AnyLinkPreview.getMetadata(link: value),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return const SizedBox.shrink();
                            }
                            return LinkPreview(snapshot: snapshot, link: value);
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                  SelectableText.rich(
                    TextSpan(
                      style: TextStyle(color: context.colors.textPrimary),
                      children: replaceLink(text: textMessage.message).map((
                        data,
                      ) {
                        //This will add link to msg
                        if (isLink(data)) {
                          //This will notify preview object that it has link
                          _linkAddNotifier.value = data;

                          return TextSpan(
                            text: data,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (await canLaunchUrl(Uri.parse(data))) {
                                  await launchUrl(Uri.parse(data));
                                }
                              },
                            style: const TextStyle(color: Color(0xff0000FF)),
                          );
                        }
                        return TextSpan(
                          text: data,
                          style: TextStyle(color: context.colors.textPrimary),
                        );
                      }).toList(),
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                  if (widget.showTime)
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomText(
                        UiUtils.formatTimeWithDateTime(
                          textMessage.sendOrReceiveDateTime,
                        ),
                        fontSize: 12,
                        color: context.colors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required ChatMessage imageMessage,
  }) {
    Widget singleImageItem({
      required ChatMessage imageMessage,
      required int index,
    }) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            imagesFullScreenView,
            arguments: {
              "isFile": imageMessage.isLocallyStored,
              "images": imageMessage.files.map((e) => e.fileUrl).toList(),
              "initialPage": index == 0 ? null : index,
              "userName": imageMessage.senderId == widget.senderId
                  ? "you".translate(context: context)
                  : imageMessage.senderDetails.name,
              "messageDateTime": imageMessage.sendOrReceiveDateTime,
            },
          );
        },
        child: CustomContainer(
          borderRadius: 8,
          color: context.colors.surfacePrimary,
          clipBehavior: Clip.antiAlias,
          child: imageMessage.isLocallyStored
              ? imageMessage.files[index].fileUrl.endsWith(".svg")
                    ? SvgPicture.file(
                        File(imageMessage.files[index].fileUrl),
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(imageMessage.files[index].fileUrl),
                        fit: BoxFit.contain,
                      )
              : CustomCachedNetworkImage(
                  networkImageUrl: imageMessage.files[index].fileUrl,
                  fit: BoxFit.contain,
                ),
        ),
      );
    }

    return imageMessage.files.isEmpty
        ? const SizedBox.shrink()
        : CustomContainer(
            // Width/height are already fractions of the available width;
            // rw()/rh() scaling on tablets would push the bubble past it.
            avoideResponsive: true,
            width: imageMessage.files.length > 2
                ? constraints.maxWidth * 0.8
                : imageMessage.files.length == 1
                ? constraints.maxWidth * 0.6
                : constraints.maxWidth * 0.8,
            height: imageMessage.files.length > 2
                ? constraints.maxWidth * 0.8
                : imageMessage.files.length == 1
                ? constraints.maxWidth * 0.6
                : constraints.maxWidth * 0.4,
            color: imageMessage.senderId == widget.senderId
                ? context.colors.backgroundBrand
                : context.colors.surfacePrimary,
            borderRadiusStyle: BorderRadiusDirectional.all(
              Radius.circular(_messageItemBorderRadius),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: (imageMessage.senderId == widget.senderId)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: singleImageItem(
                          imageMessage: imageMessage,
                          index: 0,
                        ),
                      ),
                      if (imageMessage.files.length > 1 &&
                          imageMessage.files.length != 3) ...[
                        const CustomSizedBox(width: 5),
                        Expanded(
                          child: singleImageItem(
                            imageMessage: imageMessage,
                            index: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (imageMessage.files.length >= 3) ...[
                  const CustomSizedBox(height: 5),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: singleImageItem(
                            imageMessage: imageMessage,
                            index: imageMessage.files.length == 3 ? 1 : 2,
                          ),
                        ),
                        const CustomSizedBox(width: 5),
                        Expanded(
                          child: singleImageItem(
                            imageMessage: imageMessage,
                            index: imageMessage.files.length == 3 ? 2 : 3,
                          ),
                        ),
                        if (imageMessage.files.length > 4) ...[
                          const CustomSizedBox(width: 5),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                singleImageItem(
                                  imageMessage: imageMessage,
                                  index: 4,
                                ),
                                if (imageMessage.files.length > 5)
                                  GestureDetector(
                                    //this is because above ontap won't work as this on is on top in stack
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        imagesFullScreenView,
                                        arguments: {
                                          "isFile":
                                              imageMessage.isLocallyStored,
                                          "initialPage": 4,
                                          "userName":
                                              imageMessage.senderId ==
                                                  widget.senderId
                                              ? "you".translate(
                                                  context: context,
                                                )
                                              : widget
                                                    .chatMessage
                                                    .senderDetails
                                                    .name,
                                          "images": imageMessage.files
                                              .map((e) => e.fileUrl)
                                              .toList(),
                                          "messageDateTime": imageMessage
                                              .sendOrReceiveDateTime,
                                        },
                                      );
                                    },
                                    child: CustomContainer(
                                      alignment: Alignment.center,
                                      color: Colors.black38,
                                      borderRadius: 8,
                                      child: CustomText(
                                        "+${imageMessage.files.length - 5}",
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.textInverseLight,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (imageMessage.message.trim().isNotEmpty) ...[
                  const CustomSizedBox(height: 5),
                  CustomText(
                    "${imageMessage.message} ",
                    textAlign: TextAlign.start,
                    fontSize: 12,
                    color: imageMessage.senderId == widget.senderId
                        ? context.colors.textInverseLight
                        : context.colors.textPrimary,
                  ),
                ],
                const CustomSizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CustomText(
                    UiUtils.formatTimeWithDateTime(
                      imageMessage.sendOrReceiveDateTime,
                    ),
                    fontSize: 12,
                    color: imageMessage.senderId == widget.senderId
                        ? context.colors.textInverseLight
                        : context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildFileMessageWidget({
    required BuildContext context,
    required BoxConstraints constraints,
    required ChatMessage fileMessage,
  }) {
    final List<bool> isDownloading = [];
    for (int i = 0; i < fileMessage.files.length; i++) {
      isDownloading.add(false);
    }
    return CustomSizedBox(
      width: constraints.maxWidth * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(fileMessage.files.length, (index) {
          final file = fileMessage.files[index];
          return StatefulBuilder(
            builder: (context, reBuilder) {
              return GestureDetector(
                onTap: () async {
                  if (isDownloading[index]) {
                    return;
                  }
                  reBuilder(() {
                    isDownloading[index] = true;
                  });
                  try {
                    if (fileMessage.isLocallyStored) {
                      OpenFile.open(file.fileUrl);
                    } else {
                      await UiUtils.downloadOrShareFile(
                        url: file.fileUrl,
                        isDownload: true,
                        customFileName: file.fileName,
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      UiUtils.showMessage(
                        context,
                        'somethingWentWrong'.translate(context: context),
                        ToastificationType.error,
                      );
                    }
                  }
                  reBuilder(() {
                    isDownloading[index] = false;
                  });
                },
                child: CustomContainer(
                  color: fileMessage.senderId == widget.senderId
                      ? context.colors.backgroundBrand
                      : context.colors.surfacePrimary,
                  borderRadiusStyle: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(_messageItemBorderRadius),
                    topStart: Radius.circular(_messageItemBorderRadius),
                    topEnd: fileMessage.senderId == widget.senderId
                        ? Radius.zero
                        : Radius.circular(_messageItemBorderRadius),
                    bottomStart: fileMessage.senderId == widget.senderId
                        ? Radius.circular(_messageItemBorderRadius)
                        : Radius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        (fileMessage.senderId == widget.senderId)
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CustomSizedBox(width: 5),
                          if (!fileMessage.isLocallyStored)
                            CustomContainer(
                              height: 50,
                              width: 50,
                              shape: BoxShape.circle,
                              color: context.colors.surfacePrimary,
                              padding: EdgeInsets.all(
                                isDownloading[index] ? 15 : 12,
                              ),
                              child: isDownloading[index]
                                  ? const CustomCircularProgressIndicator()
                                  : CustomSvgPicture(
                                      svgImage: AppAssets.download,
                                      boxFit: BoxFit.contain,
                                      color: context.colors.iconBrand,
                                    ),
                            ),
                          const CustomSizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  file.fileName,
                                  maxLines: 2,
                                  fontSize: 14,
                                  textAlign: TextAlign.start,
                                  color: fileMessage.senderId == widget.senderId
                                      ? context.colors.textInverseLight
                                      : context.colors.textPrimary,
                                ),
                                const CustomSizedBox(height: 2),
                                CustomText(
                                  "${file.getFileSizeString} | ${file.fileType.capitalize()}",
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  fontSize: 12,
                                  color: fileMessage.senderId == widget.senderId
                                      ? context.colors.textInverseLight
                                      : context.colors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (fileMessage.message.trim().isNotEmpty &&
                          index == fileMessage.files.length - 1) ...[
                        const CustomSizedBox(height: 5),
                        CustomText(
                          "${fileMessage.message} ",
                          textAlign: TextAlign.start,
                          fontSize: 12,
                          color: fileMessage.senderId == widget.senderId
                              ? context.colors.textInverseLight
                              : context.colors.textPrimary,
                        ),
                      ],
                      if (index == fileMessage.files.length - 1) ...[
                        const CustomSizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CustomText(
                            UiUtils.formatTimeWithDateTime(
                              fileMessage.sendOrReceiveDateTime,
                            ),
                            fontSize: 12,
                            color: fileMessage.senderId == widget.senderId
                                ? context.colors.textInverseLight
                                : context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildAvatar() {
    final String? url = widget.avatarUrl;
    final bool hasUrl =
        url != null && url.trim().isNotEmpty && url.toLowerCase() != 'null';
    return CustomContainer(
      height: 24,
      width: 24,
      shape: BoxShape.circle,
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? CustomCachedNetworkImage(networkImageUrl: url, fit: BoxFit.cover)
          : const CustomSvgPicture(svgImage: AppAssets.user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isMyMessage =
                  widget.chatMessage.senderId == widget.senderId;

              final Widget bubble =
                  widget.chatMessage.messageType == ChatMessageType.textMessage
                  ? _buildTextMessageWidget(
                      context: context,
                      constraints: constraints,
                      textMessage: widget.chatMessage,
                    )
                  : widget.chatMessage.messageType ==
                        ChatMessageType.imageMessage
                  ? _buildImageMessageWidget(
                      context: context,
                      constraints: constraints,
                      imageMessage: widget.chatMessage,
                    )
                  : widget.chatMessage.messageType ==
                        ChatMessageType.fileMessage
                  ? _buildFileMessageWidget(
                      context: context,
                      constraints: constraints,
                      fileMessage: widget.chatMessage,
                    )
                  : const SizedBox.shrink();

              final Widget avatar = widget.avatarUrl != null
                  ? _buildAvatar()
                  : const SizedBox(width: 28);

              return Align(
                alignment: isMyMessage
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMyMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: isMyMessage
                      ? [bubble, const CustomSizedBox(width: 6), avatar]
                      : [avatar, const CustomSizedBox(width: 6), bubble],
                ),
              );
            },
          ),
          Align(
            alignment: widget.chatMessage.senderId == widget.senderId
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: widget.isLoading
                ? CustomText(
                    "sending".translate(context: context),
                    maxLines: 1,
                    fontSize: 10,
                    color: context.colors.textTertiary,
                  )
                : widget.isError
                ? GestureDetector(
                    onTap: () {
                      widget.onRetry(widget.chatMessage);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 10,
                          color: context.colors.backgroundError,
                        ),
                        const CustomSizedBox(width: 2),
                        Flexible(
                          child: CustomText(
                            "errorSendingMessageTryAgain".translate(
                              context: context,
                            ),
                            maxLines: 1,
                            fontSize: 10,
                            color: context.colors.textError,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
