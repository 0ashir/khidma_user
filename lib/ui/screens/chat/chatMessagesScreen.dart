import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/chat/deleteChatCubit.dart';
import 'package:e_demand/cubits/chat/submitReportCubit.dart';
import 'package:e_demand/cubits/chat/unblockUserCubit.dart';
import 'package:e_demand/ui/widgets/ReportReasonBottomSheet.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/confirmActionBottomSheet.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatMessagesScreen({super.key, required this.chatUser});

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();

  static CupertinoPageRoute route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) {
              return ChatMessagesCubit(
                chatRepository: ChatRepository(),
                chatUserCubit: arguments['chatUsersCubit'] as ChatUsersCubit?,
                chatUser: arguments["chatUser"] ?? ChatUser.fromJson({}),
              );
            },
          ),
          BlocProvider(
            create: (context) => GetChatQuestionsCubit(ChatRepository()),
          ),
        ],
        child: ChatMessagesScreen(
          chatUser: arguments["chatUser"] ?? ChatUser.fromJson({}),
        ),
      ),
    );
  }
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final _chatMessageSendTextController = TextEditingController();

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_notificationsScrollListener);

  late final currentUserId =
      context.read<UserDetailsCubit>().getUserDetails().id ?? "";

  void _notificationsScrollListener() {
    if (context.read<ChatMessagesCubit>().hasMore()) {
      // nextPageTrigger will have a value equivalent to 70% of the list size.
      final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

      // _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
      if (_scrollController.position.pixels > nextPageTrigger) {
        if (mounted) {
          context.read<ChatMessagesCubit>().fetchMoreChatMessages();
        }
      }
    }
  }

  @override
  void initState() {
    Routes.currentRoute = chatMessages;

    Future.delayed(Duration.zero, () {
      fetchChatMessages();
    });

    //register user id with which the current user is talking with
    ChatNotificationsUtils.currentChattingUserHashCode =
        widget.chatUser.hashCode;

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notificationsScrollListener);
    _scrollController.dispose();
    _chatMessageSendTextController.dispose();
    ChatRepository().markMessageAsRead(
      bookingId: widget.chatUser.bookingId,
      providerId: widget.chatUser.partnerId,
      toAdmin: widget.chatUser.chatUserType == ChatUserType.adminSupport,
    );
    super.dispose();
  }

  void fetchChatMessages() {
    context.read<ChatMessagesCubit>().fetchChatMessages();
  }

  String? _resolveAvatarUrl(ChatMessage msg) {
    final profile = msg.senderDetails.profile;
    return profile.isNotEmpty ? profile : null;
  }

  String _getChatQuestionType() {
    switch (widget.chatUser.chatUserType) {
      case ChatUserType.adminSupport:
        return 'customer_admin_support';
      case ChatUserType.providerBooking:
        return 'post_booking';
      case ChatUserType.providerEnquiry:
        return 'pre_booking';
    }
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return CustomSizedBox(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                15,
                (index) => _buildOneChatShimmerLoader(boxConstraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOneChatShimmerLoader(BoxConstraints boxConstraints) {
    final bool isStart = Random().nextBool();
    return Align(
      alignment: isStart
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomShimmerLoadingContainer(
          height: 30,
          width: boxConstraints.maxWidth * 0.8,
          borderRadius: 12,
        ),
      ),
    );
  }

  Widget _buildDateLabel({required DateTime date}) {
    final String formattedDate = DateFormat('d MMMM').format(date);
    final String dayLabel;

    if (date.isToday()) {
      dayLabel = "today".translate(context: context);
    } else if (date.isYesterday()) {
      dayLabel = "yesterday".translate(context: context);
    } else {
      dayLabel = '';
    }

    final String labelText = dayLabel.isNotEmpty
        ? '$dayLabel, $formattedDate'
        : formattedDate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomText(
        labelText,
        color: context.colors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _loadingMoreChatsWidget() {
    return CustomContainer(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      borderRadius: 12,
      color: context.colors.surfacePrimary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSizedBox(
            width: 12,
            height: 12,
            child: CustomCircularProgressIndicator(
              color: context.colors.iconBrand,
            ),
          ),
          const CustomSizedBox(width: 10),
          Flexible(
            child: CustomText(
              "loadingMoreChats".translate(context: context),
              maxLines: 1,
              fontSize: 12,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingMoreErrorWidget({required Function() onTapRetry}) {
    return GestureDetector(
      onTap: onTapRetry,
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        borderRadius: UiUtils.borderRadiusOf10,
        color: context.colors.surfacePrimary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 16, color: context.colors.iconBrand),
            const CustomSizedBox(width: 10),
            Flexible(
              child: CustomText(
                "errorLoadingMoreRetry".translate(context: context),
                maxLines: 1,
                fontSize: 12,
                color: context.colors.textError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleClick(int item) async {
    final chatMessagesCubit = context.read<ChatMessagesCubit>();
    switch (item) {
      case 0:
        // Check if user is already blocked
        final currentState = chatMessagesCubit.state;
        if (currentState is ChatMessagesFetchSuccess) {
          if (currentState.isBlockedByUser) {
            // Show unblock confirmation
            UiUtils.showBottomSheet(
              context: context,
              child: BlocProvider<UnblockUserCubit>(
                create: (context) => UnblockUserCubit(ChatRepository()),
                child: BlocConsumer<UnblockUserCubit, UnblockUserState>(
                  listener: (bottomSheetContext, state) {
                    if (state is UnblockUserSuccess) {
                      chatMessagesCubit.updateBlockStatus(
                        isBlockedByUser: false,
                        isBlockedByProvider: currentState.isBlockedByProvider,
                      );
                      UiUtils.showMessage(
                        bottomSheetContext,
                        state.message,
                        ToastificationType.success,
                      );
                      Navigator.pop(bottomSheetContext);
                    }
                    if (state is UnblockUserFailure) {
                      UiUtils.showMessage(
                        bottomSheetContext,
                        state.errorMessage,
                        ToastificationType.error,
                      );
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                  builder: (bottomSheetContext, state) {
                    return ConfirmActionBottomSheet(
                      titleText: 'unblockUserTitle'.translate(
                        context: bottomSheetContext,
                      ),
                      questionText: 'unblockUserQuestion'.translate(
                        context: bottomSheetContext,
                      ),
                      descriptionText: 'unblockUserWarning'.translate(
                        context: bottomSheetContext,
                      ),
                      confirmButtonText: 'unblock'.translate(
                        context: bottomSheetContext,
                      ),
                      closeButtonText: 'close'.translate(
                        context: bottomSheetContext,
                      ),
                      isInProgress: state is UnblockUserInProgress,
                      onTapClose: () {
                        Navigator.pop(bottomSheetContext);
                      },
                      onTapConfirm: () async {
                        if (state is UnblockUserInProgress) {
                          return;
                        }
                        await bottomSheetContext
                            .read<UnblockUserCubit>()
                            .unblockUser(widget.chatUser.partnerId.toString());
                      },
                    );
                  },
                ),
              ),
            );
          } else {
            int reasonCount = 0;
            try {
              final reasons = await ChatRepository().getReportReasons();
              reasonCount = reasons.length;
            } catch (_) {}

            if (!mounted) return;

            if (reasonCount == 0) {
              context.read<SubmitReportCubit>().submitReport(
                providerId: widget.chatUser.partnerId ?? '',
                reasonId: '',
                additionalInfo: '',
              );
              chatMessagesCubit.updateBlockStatus(
                isBlockedByUser: true,
                isBlockedByProvider: currentState.isBlockedByProvider,
              );
              return;
            }

            // Show report reason bottom sheet
            UiUtils.showBottomSheet(
              context: context,
              child: ReportReasonBottomSheet(
                providerId: widget.chatUser.partnerId ?? '',
                isBlocked: currentState.isBlockedByUser,
                onBlockStatusChanged: (isBlocked) {
                  chatMessagesCubit.updateBlockStatus(
                    isBlockedByUser: isBlocked,
                    isBlockedByProvider: currentState.isBlockedByProvider,
                  );
                },
              ),
            );
          }
        }
        break;
      case 1:
        UiUtils.showBottomSheet(
          context: context,
          child: BlocProvider<DeleteChatCubit>(
            create: (context) => DeleteChatCubit(ChatRepository()),
            child: BlocConsumer<DeleteChatCubit, DeleteChatState>(
              listener: (bottomSheetContext, state) {
                if (state is DeleteChatSuccess) {
                  // chatMessagesCubit.clearChatMessages();
                  // Remove user from chat list
                  chatMessagesCubit.chatUserCubit?.removeUserFromList(
                    widget.chatUser,
                  );
                  UiUtils.showMessage(
                    bottomSheetContext,
                    'chatDeletedSuccessfully'.translate(
                      context: bottomSheetContext,
                    ),
                    ToastificationType.success,
                  );
                  Navigator.pop(bottomSheetContext); // Pop the bottom sheet
                  Navigator.pop(context); // Pop back to chat list
                }
                if (state is DeleteChatFailure) {
                  UiUtils.showMessage(
                    bottomSheetContext,
                    state.errorMessage,
                    ToastificationType.error,
                  );
                  Navigator.pop(bottomSheetContext);
                }
              },
              builder: (bottomSheetContext, state) {
                return ConfirmActionBottomSheet(
                  titleText: 'deleteChat'.translate(
                    context: bottomSheetContext,
                  ),
                  questionText: 'deleteChatQuestion'.translate(
                    context: bottomSheetContext,
                  ),
                  descriptionText: 'deleteChatWarning'.translate(
                    context: bottomSheetContext,
                  ),
                  confirmButtonText: 'deleteChat'.translate(
                    context: bottomSheetContext,
                  ),
                  closeButtonText: 'close'.translate(
                    context: bottomSheetContext,
                  ),
                  isInProgress: state is DeleteChatInProgress,
                  onTapClose: () {
                    Navigator.pop(bottomSheetContext);
                  },
                  onTapConfirm: () async {
                    if (state is DeleteChatInProgress) {
                      return;
                    }
                    await bottomSheetContext.read<DeleteChatCubit>().deleteChat(
                      widget.chatUser.partnerId.toString(),
                      widget.chatUser.bookingId.toString(),
                    );
                  },
                );
              },
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final chatMessagesState = context.watch<ChatMessagesCubit>().state;
    final handyman = chatMessagesState is ChatMessagesFetchSuccess
        ? chatMessagesState.handyman
        : null;
    final List<ChatParticipant> bookingServices =
        chatMessagesState is ChatMessagesFetchSuccess
        ? chatMessagesState.bookingServices
        : [];
    final String bookingStartDate =
        chatMessagesState is ChatMessagesFetchSuccess
        ? chatMessagesState.bookingStartDate
        : '';
    final String bookingStartTime =
        chatMessagesState is ChatMessagesFetchSuccess
        ? chatMessagesState.bookingStartTime
        : '';
    final String bookingStatus = chatMessagesState is ChatMessagesFetchSuccess
        ? chatMessagesState.bookingStatus
        : '';
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        //removing currently talking user's id
        ChatNotificationsUtils.currentChattingUserHashCode = null;

        //clearing current route when going back to make the onTap of notification routing properly work
        Routes.currentRoute = '';
      },
      child: AnnotatedSafeArea(
        isAnnotated: true,
        applyBottomInset: false,
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: context.colors.backgroundPrimary,
            automaticallyImplyLeading: false,
            toolbarHeight: size.height * .08,
            elevation: 0,
            titleSpacing: 2,
            backgroundColor: context.colors.backgroundPrimary,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.5),
              child: Container(
                height: 1.5,
                color: context.colors.borderDefault,
              ),
            ),
            leading: UiUtils.getBackArrow(
              backgroundColor: context.colors.backgroundPrimary,
              context,
            ),
            actions: [
              if (widget.chatUser.chatUserType !=
                  ChatUserType.adminSupport) ...[
                PopupMenuButton<int>(
                  color: context.colors.backgroundPrimary,
                  elevation: 4,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (item) => handleClick(item),
                  itemBuilder: (_) {
                    final bool canBlock =
                        widget.chatUser.bookingStatus?.toLowerCase() !=
                            "cancelled" &&
                        widget.chatUser.bookingStatus?.toLowerCase() !=
                            "completed" &&
                        widget.chatUser.bookingStatus?.toLowerCase() !=
                            "booked";
                    final bool canDelete =
                        (context.read<ChatMessagesCubit>().state
                                as ChatMessagesFetchSuccess)
                            .chatMessages
                            .isNotEmpty;
                    return [
                      if (canBlock) ...[
                        PopupMenuItem<int>(
                          value: 0,
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: BlocProvider.value(
                              value: context.read<ChatMessagesCubit>(),
                              child:
                                  BlocBuilder<
                                    ChatMessagesCubit,
                                    ChatMessagesState
                                  >(
                                    builder: (context, state) {
                                      final bool isBlocked =
                                          state is ChatMessagesFetchSuccess &&
                                          state.isBlockedByUser;
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 8,
                                        children: [
                                          CustomContainer(
                                            color: context
                                                .colors
                                                .backgroundSecondary,
                                            shape: BoxShape.circle,
                                            padding: const EdgeInsets.all(8),
                                            child: CustomSvgPicture(
                                              svgImage:
                                                  AppAssets.blockUserScreen,
                                              width: 24,
                                              height: 24,
                                              color: context.colors.iconPrimary,
                                              avoideResponsive: true,
                                            ),
                                          ),
                                          CustomText(
                                            isBlocked
                                                ? 'unblock'.translate(
                                                    context: context,
                                                  )
                                                : 'block&Report'.translate(
                                                    context: context,
                                                  ),
                                            fontSize: 14,
                                            color: context.colors.textPrimary,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            ),
                          ),
                        ),
                      ],
                      if (canBlock && canDelete)
                        PopupMenuItem<int>(
                          enabled: false,
                          height: 1,
                          padding: EdgeInsets.zero,
                          child: Container(
                            height: 1,
                            color: context.colors.borderMuted,
                          ),
                        ),
                      if (canDelete) ...[
                        PopupMenuItem<int>(
                          value: 1,
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                CustomContainer(
                                  color: context.colors.backgroundErrorSubtle,
                                  shape: BoxShape.circle,
                                  padding: const EdgeInsets.all(8),
                                  child: CustomSvgPicture(
                                    svgImage: AppAssets.drDeleteAccount,
                                    width: 20,
                                    height: 20,
                                    color: context.colors.iconError,
                                    avoideResponsive: true,
                                  ),
                                ),
                                CustomText(
                                  'deleteChat'.translate(context: context),
                                  fontSize: 14,
                                  color: context.colors.textError,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ];
                  },
                ),
              ],
            ],
            title: CustomSizedBox(
              width: double.maxFinite,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.chatUser.chatUserType !=
                      ChatUserType.adminSupport) ...[
                    CustomContainer(
                      clipBehavior: Clip.antiAlias,
                      height: 44,
                      width: 44,
                      shape: BoxShape.circle,
                      child:
                          widget.chatUser.avatar.trim().isEmpty ||
                              widget.chatUser.avatar.toLowerCase() == "null"
                          ? const CustomSvgPicture(svgImage: AppAssets.user)
                          : CustomCachedNetworkImage(
                              networkImageUrl: widget.chatUser.avatar,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const CustomSizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          widget.chatUser.userName.translate(context: context),
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                        if (widget.chatUser.chatUserType !=
                            ChatUserType.adminSupport)
                          if (widget.chatUser.chatUserType ==
                              ChatUserType.providerBooking) ...[
                            CustomText(
                              "# ${widget.chatUser.bookingId}",
                              color: context.colors.textBrand,
                              fontSize: 12.0,
                            ),
                          ] else ...[
                            CustomText(
                              "preBookingEnquiries".translate(context: context),
                              color: context.colors.textSecondary,
                              height: 1,
                              fontSize: 12.0,
                            ),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar:
              (widget.chatUser.bookingStatus?.toLowerCase() != "cancelled" &&
                  widget.chatUser.bookingStatus?.toLowerCase() != "completed" &&
                  widget.chatUser.bookingStatus?.toLowerCase() != "booked")
              ? BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                  builder: (context, state) {
                    if (state is ChatMessagesFetchSuccess) {
                      if (state.isBlockedByUser || state.isBlockedByProvider) {
                        return CustomContainer(
                          borderRadius: 12,
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(
                            15,
                            10,
                            15,
                            10 + MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          color: context.colors.backgroundBrand.withValues(
                            alpha: 0.3,
                          ),
                          child: CustomText(
                            state.isBlockedByUser
                                ? "youHaveBlockedThisProvider".translate(
                                    context: context,
                                  )
                                : "youHaveBeenBlockedByProvider".translate(
                                    context: context,
                                  ),
                            color: context.colors.textBrand,
                            fontSize: 12,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final systemSettingCubit = context
                          .read<SystemSettingCubit>();
                      final showAttachmentButton =
                          systemSettingCubit.isChatImageUploadEnabled ||
                          systemSettingCubit.isChatFileUploadEnabled;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.chatMessages.isEmpty)
                            _buildQuickReplyChips(),
                          CustomContainer(
                            padding: EdgeInsetsDirectional.only(
                              bottom: MediaQuery.viewInsetsOf(context).bottom,
                            ),
                            borderRadiusStyle: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            color: context.colors.backgroundPrimary,
                            child: ChatMessageSendingWidget(
                              showAttachmentButton: showAttachmentButton,
                              onMessageSend: () {
                                if (_chatMessageSendTextController.text
                                    .trim()
                                    .isNotEmpty) {
                                  context
                                      .read<ChatMessagesCubit>()
                                      .sendChatMessage(
                                        context: context,
                                        chatMessage: ChatMessage(
                                          messageType:
                                              ChatMessageType.textMessage,
                                          files: [],
                                          message:
                                              _chatMessageSendTextController
                                                  .text
                                                  .trim(),
                                          isLocallyStored: true,
                                          id: DateTime.now()
                                              .microsecondsSinceEpoch
                                              .toString(),
                                          sendOrReceiveDateTime: DateTime.now(),
                                          receiverId:
                                              widget.chatUser.partnerId ?? '0',
                                          senderId: currentUserId,
                                          senderDetails: SenderDetails.fromJson(
                                            {},
                                          ),
                                        ),

                                        chattingWith: widget.chatUser,
                                      );
                                  _chatMessageSendTextController.clear();
                                }
                              },
                              onAttachmentTap: () {
                                final systemSettingCubit = context
                                    .read<SystemSettingCubit>();
                                UiUtils.showBottomSheet(
                                  context: context,
                                  child: AttachmentDialogWidget(
                                    enableImageUpload: systemSettingCubit
                                        .isChatImageUploadEnabled,
                                    enableFileUpload: systemSettingCubit
                                        .isChatFileUploadEnabled,
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onItemSelected:
                                        (selectedFilePaths, isImage) {
                                          Navigator.pop(context);
                                          context
                                              .read<ChatMessagesCubit>()
                                              .sendChatMessage(
                                                context: context,
                                                chatMessage: ChatMessage(
                                                  messageType: isImage
                                                      ? ChatMessageType
                                                            .imageMessage
                                                      : ChatMessageType
                                                            .fileMessage,
                                                  message: '',
                                                  files: selectedFilePaths.map((
                                                    e,
                                                  ) {
                                                    return MessageDocument(
                                                      fileName: e.fileName,
                                                      fileSize: e.fileSize,
                                                      fileType: e.fileType,
                                                      fileUrl: e.fileUrl,
                                                    );
                                                  }).toList(),
                                                  isLocallyStored: true,
                                                  id: DateTime.now()
                                                      .microsecondsSinceEpoch
                                                      .toString(),
                                                  sendOrReceiveDateTime:
                                                      DateTime.now(),
                                                  receiverId:
                                                      widget.chatUser.partnerId,
                                                  senderId: currentUserId,
                                                  senderDetails:
                                                      SenderDetails.fromJson(
                                                        {},
                                                      ),
                                                ),

                                                chattingWith: widget.chatUser,
                                              );
                                        },
                                  ),
                                );
                                return;
                              },
                              textController: _chatMessageSendTextController,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              : CustomContainer(
                  color: context.colors.backgroundPrimary,
                  padding: const EdgeInsets.all(16).copyWith(
                    bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  borderRadiusStyle: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: CustomContainer(
                    color: context.colors.backgroundBrandSubtle,
                    padding: const EdgeInsets.all(8),
                    borderRadius: UiUtils.borderRadiusOf8,
                    child: CustomText(
                      "youCantMessageToProvider".translate(context: context),
                      color: context.colors.textBrand,
                      fontSize: 12,
                      height: 16 / 12,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          body: Column(
            children: [
              if (bookingServices.isNotEmpty)
                _buildBookingCard(
                  services: bookingServices,
                  startDate: bookingStartDate,
                  startTime: bookingStartTime,
                  status: bookingStatus,
                ),
              if (handyman != null) _buildHandymanBanner(handyman),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
                  child: BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                    builder: (context, state) {
                      if (state is ChatMessagesFetchSuccess) {
                        return Stack(
                          children: [
                            state.chatMessages.isEmpty
                                ? widget.chatUser.bookingStatus
                                                  ?.toLowerCase() !=
                                              "cancelled" &&
                                          widget.chatUser.bookingStatus
                                                  ?.toLowerCase() !=
                                              "completed" &&
                                          widget.chatUser.bookingStatus
                                                  ?.toLowerCase() !=
                                              "booked"
                                      ? _emptyChatWidget(
                                          state.isBlockedByUser,
                                          state.isBlockedByProvider,
                                        )
                                      : Center(
                                          child: NoDataFoundWidget(
                                            titleKey: "noChatHistoryFound"
                                                .translate(context: context),
                                            subtitleKey:
                                                "noChatHistoryFoundDescription"
                                                    .translate(
                                                      context: context,
                                                    ),
                                          ),
                                        )
                                : ListView.builder(
                                    controller: _scrollController,
                                    reverse: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: state.chatMessages.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          //if it's 1st item - reverse scroll so last then show date label
                                          //or if an item's date is not the same as next item, show date label
                                          if (index ==
                                                  (state.chatMessages.length -
                                                      1) ||
                                              (!state
                                                  .chatMessages[index]
                                                  .sendOrReceiveDateTime
                                                  .isSameAs(
                                                    state
                                                        .chatMessages[index ==
                                                                (state
                                                                        .chatMessages
                                                                        .length -
                                                                    1)
                                                            ? (state
                                                                      .chatMessages
                                                                      .length -
                                                                  1)
                                                            : index + 1]
                                                        .sendOrReceiveDateTime,
                                                  )))
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.only(
                                                    top: 10,
                                                    bottom: 5,
                                                  ),
                                              child: Center(
                                                child: _buildDateLabel(
                                                  date: state
                                                      .chatMessages[index]
                                                      .sendOrReceiveDateTime,
                                                ),
                                              ),
                                            ),
                                          SingleChatMessageItem(
                                            key: ValueKey(
                                              state.chatMessages[index].id,
                                            ),
                                            senderId: currentUserId,
                                            showTime: true,
                                            chatMessage:
                                                state.chatMessages[index],
                                            isLoading: state.loadingIds
                                                .contains(
                                                  state.chatMessages[index].id,
                                                ),
                                            isError: state.errorIds.contains(
                                              state.chatMessages[index].id,
                                            ),
                                            avatarUrl: _resolveAvatarUrl(
                                              state.chatMessages[index],
                                            ),
                                            onRetry: (ChatMessage chatMessage) {
                                              context
                                                  .read<ChatMessagesCubit>()
                                                  .sendChatMessage(
                                                    context: context,
                                                    chatMessage: chatMessage,

                                                    chattingWith:
                                                        widget.chatUser,
                                                    isRetry: true,
                                                  );
                                            },
                                          ),
                                          if (index ==
                                              0) //padding to latest message
                                            const CustomSizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: 25,
                                ),
                                child: state.moreChatMessageFetchProgress
                                    ? _loadingMoreChatsWidget()
                                    : state.moreChatMessageFetchError
                                    ? _loadingMoreErrorWidget(
                                        onTapRetry: () {
                                          context
                                              .read<ChatMessagesCubit>()
                                              .fetchMoreChatMessages();
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is ChatMessagesFetchFailure) {
                        return Center(
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              fetchChatMessages();
                            },
                          ),
                        );
                      }
                      return _buildShimmerLoader();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required final List<ChatParticipant> services,
    required final String startDate,
    required final String startTime,
    required final String status,
  }) {
    final String firstServiceName = services.first.name;
    final int moreCount = services.length - 1;

    final String formattedDate = startDate.formatDate();
    final String formattedTime = startTime.localeFormatTime();

    final String lowerStatus = status.toLowerCase();
    final Color statusColor = UiUtils.getBookingStatusColor(
      context: context,
      statusVal: lowerStatus,
    );

    return CustomInkWellContainer(
      onTap: () {
        Navigator.pushNamed(
          context,
          bookingDetails,
          arguments: {'bookingId': widget.chatUser.bookingId},
        );
      },
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border(
          bottom: BorderSide(color: context.colors.borderDefault),
          top: BorderSide(color: context.colors.borderDefault),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            offset: Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CustomText(
                          firstServiceName,
                          maxLines: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      if (moreCount > 0)
                        CustomText(
                          ' +$moreCount ${'more'.translate(context: context)}',
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomSvgPicture(
                        svgImage: AppAssets.calendar,
                        width: 16,
                        height: 16,
                        color: context.colors.iconPrimary,
                        avoideResponsive: true,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomText(
                        formattedDate,
                        fontSize: 12,
                        color: context.colors.textPrimary,
                      ),
                      const CustomSizedBox(width: 8),
                      CustomContainer(
                        height: 12,
                        width: 1,
                        color: context.colors.borderStrong,
                      ),
                      const CustomSizedBox(width: 8),

                      CustomSvgPicture(
                        svgImage: AppAssets.clock,
                        width: 16,
                        height: 16,
                        color: context.colors.iconPrimary,
                        avoideResponsive: true,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomText(
                        formattedTime,
                        fontSize: 12,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (status.isNotEmpty) ...[
              const CustomSizedBox(width: 8),
              CustomContainer(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: UiUtils.borderRadiusOf8,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: CustomText(
                  status.capitalize(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
            const CustomSizedBox(width: 8),
            CustomSvgPicture(
              svgImage:
                  Directionality.of(
                    context,
                  ).toString().contains(TextDirection.RTL.value.toLowerCase())
                  ? AppAssets.backArrow
                  : AppAssets.backArrowLtr,
              width: 24,
              height: 24,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandymanBanner(ChatParticipant handyman) {
    final bool hasImage =
        handyman.profileImage.trim().isNotEmpty &&
        handyman.profileImage.toLowerCase() != 'null';
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      boxShadow: [
        BoxShadow(
          color: context.colors.overlayHeaderShadow,
          offset: const Offset(0, 8),
          blurRadius: 16,
        ),
      ],
      child: Row(
        children: [
          CustomContainer(
            height: 32,
            width: 32,
            shape: BoxShape.circle,
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? CustomCachedNetworkImage(
                    networkImageUrl: handyman.profileImage,
                    fit: BoxFit.cover,
                    height: 32,
                    width: 32,
                  )
                : const CustomSvgPicture(svgImage: AppAssets.user),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      handyman.name,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: context.colors.textPrimary,
                    ),
                    const CustomSizedBox(width: 8),
                    CustomContainer(
                      height: 4,
                      width: 4,
                      shape: BoxShape.circle,
                      color: context.colors.backgroundTertiary,
                    ),
                    const CustomSizedBox(width: 8),
                    CustomText(
                      'handyman'.translate(context: context),
                      fontSize: 12,
                      color: context.colors.textBrand,
                    ),
                  ],
                ),
                CustomText(
                  'handymanAddedToChat'.translate(context: context),
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChatWidget(bool isBlockedByUser, bool isBlockedByProvider) {
    if (!isBlockedByUser && !isBlockedByProvider) {
      final chatQuestionsCubit = context.read<GetChatQuestionsCubit>();
      if (chatQuestionsCubit.state is GetChatQuestionsInitial) {
        Future.microtask(() {
          chatQuestionsCubit.fetchChatQuestions(type: _getChatQuestionType());
        });
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuickReplyChips() {
    return BlocBuilder<GetChatQuestionsCubit, GetChatQuestionsState>(
      builder: (context, state) {
        if (state is! GetChatQuestionsSuccess || state.questions.isEmpty) {
          return const SizedBox.shrink();
        }
        return CustomContainer(
          color: context.colors.backgroundPrimary,
          padding: const EdgeInsets.all(16),
          border: Border(
            bottom: BorderSide(color: context.colors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  CustomSvgPicture(
                    svgImage: AppAssets.preBooking,
                    height: 16,
                    width: 16,
                    color: context.colors.iconPrimary,
                    avoideResponsive: true,
                  ),
                  CustomText(
                    (widget.chatUser.chatUserType ==
                                ChatUserType.providerBooking
                            ? 'postBookingQA'
                            : 'preBookingQA')
                        .translate(context: context),
                    fontSize: 12,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: state.questions
                      .map(
                        (final q) =>
                            _buildPredefineMessageWidget(message: q.question),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredefineMessageWidget({required String message}) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      onTap: () {
        context.read<ChatMessagesCubit>().sendChatMessage(
          context: context,
          chatMessage: ChatMessage(
            messageType: ChatMessageType.textMessage,
            files: [],
            message: message,
            isLocallyStored: true,
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            sendOrReceiveDateTime: DateTime.now(),
            receiverId: widget.chatUser.partnerId,
            senderId: currentUserId,
            senderDetails: SenderDetails.fromJson({}),
          ),

          chattingWith: widget.chatUser,
        );
      },
      child: CustomContainer(
        color: context.colors.backgroundSecondary,
        borderRadius: UiUtils.borderRadiusOf8,
        padding: const EdgeInsets.all(8),
        child: CustomText(
          message,
          color: context.colors.textPrimary,
          maxLines: 1,
          fontSize: 12,
        ),
      ),
    );
  }
}
