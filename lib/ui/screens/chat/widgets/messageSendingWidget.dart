import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ChatMessageSendingWidget extends StatelessWidget {
  final Function() onMessageSend;
  final Function() onAttachmentTap;
  final TextEditingController textController;
  final bool showAttachmentButton;

  const ChatMessageSendingWidget({
    super.key,
    required this.onMessageSend,
    required this.textController,
    required this.onAttachmentTap,
    this.showAttachmentButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          Expanded(
            child: CustomContainer(
              borderRadius: UiUtils.borderRadiusOf8,
              color: context.colors.backgroundSecondary,
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      maxLines: 5,
                      minLines: 1,
                      maxLength: max(
                        context
                                .read<SystemSettingCubit>()
                                .chatSettings
                                ?.maxCharactersInATextMessage ??
                            500,
                        1,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "chatSendHint".translate(context: context),
                        counterText: '',
                        hintStyle: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        onMessageSend();
                      },
                      cursorColor: context.colors.textPrimary,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (showAttachmentButton)
                    CustomInkWellContainer(
                      onTap: onAttachmentTap,
                      child: Icon(
                        Icons.add,
                        size: 24,
                        color: context.colors.iconPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          CustomInkWellContainer(
            onTap: onMessageSend,
            child: CustomContainer(
              borderRadius: 48,
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundBrand,
              child: CustomSvgPicture(
                svgImage: AppAssets.sendMessage,
                boxFit: BoxFit.contain,
                width: 32,
                height: 32,
                color: context.colors.iconInverseLight,
                avoideResponsive: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
