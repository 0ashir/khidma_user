import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/chatUnreadCountBadge.dart';
import 'package:flutter/material.dart';

class ChatUserItemWidget extends StatelessWidget {
  final ChatUser chatUser;
  final bool showCount;
  final ChatUsersCubit chatUsersCubit;

  const ChatUserItemWidget({
    super.key,
    required this.chatUser,
    this.showCount = true,
    required this.chatUsersCubit,
  });

  String _messagePreview(BuildContext context) {
    final realtimeMessage = chatUser.lastMessage?.message.trim() ?? '';
    if (realtimeMessage.isNotEmpty) {
      return realtimeMessage;
    }
    final listMessage = chatUser.lastMessageText?.trim() ?? '';
    if (listMessage.isNotEmpty) {
      return listMessage;
    }
    if (chatUser.chatUserType == ChatUserType.providerEnquiry) {
      return "preBookingEnquiries".translate(context: context);
    }
    return chatUser.translatedOrderStatus ?? '';
  }

  DateTime? get _lastMessageDate {
    final realtimeDate = chatUser.lastMessage?.sendOrReceiveDateTime;
    if (realtimeDate != null) {
      return realtimeDate;
    }
    if (chatUser.lastChatDate == null) {
      return null;
    }
    return DateTime.tryParse(chatUser.lastChatDate!);
  }

  ({Color background, Color text}) _statusColors(BuildContext context) {
    switch (chatUser.bookingStatus) {
      case "completed":
      case "booked":
        return (
          background: context.colors.backgroundSuccessSubtle,
          text: context.colors.textSuccess,
        );
      case "confirmed":
        return (
          background: context.colors.backgroundBrandSubtle,
          text: context.colors.textBrand,
        );
      case "started":
        return (
          background: context.colors.backgroundInfoSubtle,
          text: context.colors.textInfo,
        );
      case "pending":
      case "rescheduled":
        return (
          background: context.colors.backgroundWarningSubtle,
          text: context.colors.textWarning,
        );
      case "cancelled":
      case "cancel":
        return (
          background: context.colors.backgroundErrorSubtle,
          text: context.colors.textError,
        );
      default:
        return (
          background: context.colors.backgroundSecondary,
          text: context.colors.textSecondary,
        );
    }
  }

  Widget _profileImageBuilder(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
      child:
          chatUser.avatar.trim().isEmpty ||
              chatUser.avatar.toLowerCase() == "null"
          ? const CustomSvgPicture(
              svgImage: AppAssets.user,
              width: 40,
              height: 40,
            )
          : CustomCachedNetworkImage(
              networkImageUrl: chatUser.avatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildBookingHeader(BuildContext context) {
    final statusColors = _statusColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomText(
                '#${chatUser.bookingId ?? ''}',
                color: context.colors.textPrimary,
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
            if ((chatUser.translatedOrderStatus ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomText(
                  chatUser.translatedOrderStatus!,
                  color: statusColors.text,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 16 / 12,
                ),
              ),
          ],
        ),
        const CustomSizedBox(height: 12),
        SizedBox(
          height: 1,
          width: double.infinity,
          child: DashedRect(
            color: context.colors.borderMuted,
            strokeWidth: 1,
            gap: 4,
          ),
        ),
        const CustomSizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastMessageDate = _lastMessageDate;
    final hasUnread = chatUser.hasUnreadMessages;
    final isBooking = chatUser.chatUserType == ChatUserType.providerBooking;

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
        onTap: () {
          Navigator.pushNamed(
            context,
            chatMessages,
            arguments: {"chatUser": chatUser, "chatUsersCubit": chatUsersCubit},
          ).then((_) => chatUsersCubit.silentRefresh());
        },
        child: CustomContainer(
          padding: const EdgeInsets.all(12),
          borderRadius: UiUtils.borderRadiusOf12,
          color: context.colors.surfacePrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBooking) _buildBookingHeader(context),
              Row(
                crossAxisAlignment: hasUnread
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  _profileImageBuilder(context),
                  const CustomSizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: CustomText(
                                chatUser.userName,
                                maxLines: 1,
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.0,
                              ),
                            ),
                            const CustomSizedBox(width: 4),
                            if (chatUser.isProviderVerified)
                              CustomSvgPicture(
                                svgImage: AppAssets.verified,
                                width: 16,
                                height: 16,
                                avoideResponsive: true,
                                color: context.colors.iconBrand,
                              ),
                          ],
                        ),
                        const CustomSizedBox(height: 4),
                        CustomText(
                          _messagePreview(context),
                          maxLines: 1,
                          color: context.colors.textSecondary,
                          fontSize: 12.0,
                        ),
                      ],
                    ),
                  ),
                  const CustomSizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lastMessageDate != null)
                        CustomText(
                          UiUtils.formatTimeWithDateTime(lastMessageDate),
                          color: hasUnread
                              ? context.colors.textBrand
                              : context.colors.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                          fontSize: 12.0,
                        ),
                      if (hasUnread) ...[
                        const CustomSizedBox(height: 4),
                        ChatUnreadCountBadge(
                          count: chatUser.unreadNotificationsCount,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
