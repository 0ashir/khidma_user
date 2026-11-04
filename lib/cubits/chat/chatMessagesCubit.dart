import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';

abstract class ChatMessagesState {}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesFetchInProgress extends ChatMessagesState {}

class ChatMessagesFetchFailure extends ChatMessagesState {
  final String errorMessage;

  ChatMessagesFetchFailure({required this.errorMessage});
}

class ChatMessagesFetchSuccess extends ChatMessagesState {
  final List<ChatMessage> chatMessages;
  final int totalOffset;
  final bool moreChatMessageFetchError;
  final bool moreChatMessageFetchProgress;
  final List<String> loadingIds;
  final List<String> errorIds;
  final bool isBlockedByUser;
  final bool isBlockedByProvider;
  final ChatParticipant? handyman;
  final List<ChatParticipant> bookingServices;
  final String bookingStartDate;
  final String bookingStartTime;
  final String bookingStatus;

  ChatMessagesFetchSuccess({
    required this.chatMessages,
    required this.totalOffset,
    required this.moreChatMessageFetchError,
    required this.moreChatMessageFetchProgress,
    required this.loadingIds,
    required this.errorIds,
    required this.isBlockedByUser,
    required this.isBlockedByProvider,
    this.handyman,
    this.bookingServices = const [],
    this.bookingStartDate = '',
    this.bookingStartTime = '',
    this.bookingStatus = '',
  });

  ChatMessagesFetchSuccess copyWith({
    List<ChatMessage>? newChatMessages,
    int? newTotalOffset,
    bool? newFetchMoreTransactionsInProgress,
    bool? newFetchMoreTransactionsError,
    List<String>? loadingIds,
    List<String>? errorIds,
    bool? newIsBlockedByUser,
    bool? newIsBlockedByProvider,
  }) {
    return ChatMessagesFetchSuccess(
      chatMessages: newChatMessages ?? chatMessages,
      totalOffset: newTotalOffset ?? totalOffset,
      moreChatMessageFetchProgress:
          newFetchMoreTransactionsInProgress ?? moreChatMessageFetchProgress,
      moreChatMessageFetchError:
          newFetchMoreTransactionsError ?? moreChatMessageFetchError,
      loadingIds: loadingIds ?? this.loadingIds,
      errorIds: errorIds ?? this.errorIds,
      isBlockedByUser: newIsBlockedByUser ?? isBlockedByUser,
      isBlockedByProvider: newIsBlockedByProvider ?? isBlockedByProvider,
      handyman: handyman,
      bookingServices: bookingServices,
      bookingStartDate: bookingStartDate,
      bookingStartTime: bookingStartTime,
      bookingStatus: bookingStatus,
    );
  }
}

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository chatRepository;
  ChatUsersCubit? chatUserCubit; //to remove the count for this user
  final ChatUser chatUser;

  ChatMessagesCubit({
    required this.chatRepository,
    this.chatUserCubit,
    required this.chatUser,
  }) : super(ChatMessagesInitial());

  StreamSubscription<ChatNotificationData>? _streamSubscription;

  Future<void> registerNotificationListener() async {
    // Cancel existing subscription before creating a new one
    if (_streamSubscription != null) {
      await _streamSubscription!.cancel();
      _streamSubscription = null;
    }

    _streamSubscription = ChatNotificationsUtils
        .notificationStreamController
        .stream
        .listen((event) {
          if (state is ChatMessagesFetchSuccess) {
            final stateAs = state as ChatMessagesFetchSuccess;

            // Check if this message is for the current chat user
            // Use hash code comparison first, then fallback to direct field comparison
            final int? currentHashCode =
                ChatNotificationsUtils.currentChattingUserHashCode;
            final int eventUserHashCode = event.fromUser.hashCode;

            final bool isForCurrentUser =
                currentHashCode != null && currentHashCode == eventUserHashCode;

            if (isForCurrentUser) {
              // Check if message already exists to avoid duplicates
              // Use both ID and timestamp to check for duplicates (in case ID is empty or same)
              final String messageId = event.receivedMessage.id;
              final DateTime messageDateTime =
                  event.receivedMessage.sendOrReceiveDateTime;

              final bool messageExists = stateAs.chatMessages.any((element) {
                // Check by ID if ID is not empty and not "0"
                if (messageId.isNotEmpty &&
                    messageId != "0" &&
                    element.id == messageId) {
                  return true;
                }
                // Also check by timestamp and sender ID to avoid duplicates with same timestamp
                if (element.sendOrReceiveDateTime == messageDateTime &&
                    element.senderId == event.receivedMessage.senderId &&
                    element.message == event.receivedMessage.message) {
                  return true;
                }
                return false;
              });

              if (!messageExists) {
                // Create a new list to avoid mutating the existing one
                final List<ChatMessage> tempList = List.from(
                  stateAs.chatMessages,
                );
                tempList.insert(0, event.receivedMessage);
                emit(stateAs.copyWith(newChatMessages: tempList));
              }
            }
          }
        });
  }

  bool isLoading() {
    if (state is ChatMessagesFetchInProgress) {
      return true;
    }
    return false;
  }

  Future<void> fetchChatMessages() async {
    emit(ChatMessagesFetchInProgress());
    try {
      final Map<String, dynamic> data = await chatRepository.fetchChatMessages(
        offset: 0,
        bookingId: chatUser.bookingId,
        providerId: chatUser.partnerId,
        toAdmin: chatUser.chatUserType == ChatUserType.adminSupport,
      );

      //registration of notification listener if the chat messages were fetched successfully
      registerNotificationListener();

      return emit(
        ChatMessagesFetchSuccess(
          chatMessages: data['chatMessages'],
          totalOffset: data['totalItems'],
          moreChatMessageFetchError: false,
          moreChatMessageFetchProgress: false,
          loadingIds: [],
          errorIds: [],
          isBlockedByUser: data['isBlockedByUser'],
          isBlockedByProvider: data['isBlockedByProvider'],
          handyman: data['handyman'],
          bookingServices: data['bookingServices'] ?? [],
          bookingStartDate: data['bookingStartDate'] ?? '',
          bookingStartTime: data['bookingStartTime'] ?? '',
          bookingStatus: data['bookingStatus'] ?? '',
        ),
      );
    } catch (e) {
      emit(ChatMessagesFetchFailure(errorMessage: e.toString()));
    }
  }

  Future<void> fetchMoreChatMessages() async {
    if (state is ChatMessagesFetchSuccess) {
      final stateAs = state as ChatMessagesFetchSuccess;
      if (stateAs.moreChatMessageFetchProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMoreTransactionsInProgress: true));

        final Map moreTransactionResult = await chatRepository
            .fetchChatMessages(
              offset: stateAs.chatMessages
                  .where((element) => !element.isLocallyStored)
                  .length,
              bookingId: chatUser.bookingId,
              providerId: chatUser.partnerId,
              toAdmin: chatUser.chatUserType == ChatUserType.adminSupport,
            );

        final List<ChatMessage> transactions = stateAs.chatMessages;

        transactions.addAll(moreTransactionResult['chatMessages']);

        emit(
          ChatMessagesFetchSuccess(
            chatMessages: transactions,
            totalOffset: moreTransactionResult['totalItems'],
            moreChatMessageFetchError: false,
            moreChatMessageFetchProgress: false,
            loadingIds: stateAs.loadingIds,
            errorIds: stateAs.errorIds,
            isBlockedByUser: stateAs.isBlockedByUser,
            isBlockedByProvider: stateAs.isBlockedByProvider,
            handyman: stateAs.handyman,
            bookingServices: stateAs.bookingServices,
            bookingStartDate: stateAs.bookingStartDate,
            bookingStartTime: stateAs.bookingStartTime,
            bookingStatus: stateAs.bookingStatus,
          ),
        );
      } catch (e) {
        emit(
          (state as ChatMessagesFetchSuccess).copyWith(
            newFetchMoreTransactionsInProgress: false,
            newFetchMoreTransactionsError: true,
          ),
        );
      }
    }
  }

  Future<void> sendChatMessage({
    required BuildContext context,
    required ChatUser chattingWith,
    required ChatMessage chatMessage,
    bool isRetry = false,
  }) async {
    if (state is ChatMessagesFetchSuccess) {
      final thisState = state as ChatMessagesFetchSuccess;
      List<ChatMessage> allMessages = thisState.chatMessages;
      List<String> loadingIds = thisState.loadingIds;
      List<String> errorIds = thisState.errorIds;

      if (!isRetry) {
        allMessages.insert(0, chatMessage);
      }
      if (!loadingIds.contains(chatMessage.id)) {
        loadingIds.add(chatMessage.id);
      }
      errorIds.remove(chatMessage.id);
      emit(
        thisState.copyWith(
          newChatMessages: allMessages,
          loadingIds: loadingIds,
          errorIds: errorIds,
        ),
      );
      ChatMessage? newMessageNetwork;
      try {
        newMessageNetwork = await chatRepository.sendChatMessage(
          message: chatMessage.messageType == ChatMessageType.textMessage
              ? chatMessage.message
              : '',
          toAdmin: chattingWith.chatUserType == ChatUserType.adminSupport,
          receiverId: chattingWith.partnerId,
          bookingId: chattingWith.bookingId,
          filePaths: chatMessage.messageType != ChatMessageType.textMessage
              ? chatMessage.files.map((e) => e.fileUrl).toList()
              : [],
        );
      } catch (error) {
        ClarityService.logAction(ClarityActions.chatMessageSent, {
          'booking_id': chattingWith.bookingId,
          'receiver_id': chattingWith.partnerId ?? '0',
          'message_type': chatMessage.messageType.name,
          'result': 'error',
          'error_message': error.toString(),
        });
        if (state is ChatMessagesFetchSuccess) {
          errorIds = (state as ChatMessagesFetchSuccess).errorIds;
          if (!errorIds.contains(chatMessage.id)) {
            errorIds.add(chatMessage.id);
          }
        }
      }
      if (state is ChatMessagesFetchSuccess) {
        loadingIds = (state as ChatMessagesFetchSuccess).loadingIds;
        loadingIds.remove(chatMessage.id);
        allMessages = (state as ChatMessagesFetchSuccess).chatMessages;

        //store new message data instead of local one
        final int indexToBeChanged = allMessages.indexWhere(
          (e) => e.id == chatMessage.id,
        );
        if (newMessageNetwork != null) {
          allMessages.removeAt(indexToBeChanged);
          allMessages.insert(indexToBeChanged, newMessageNetwork);
          ClarityService.logAction(ClarityActions.chatMessageSent, {
            'booking_id': chattingWith.bookingId,
            'receiver_id': chattingWith.partnerId ?? '0',
            'message_type': chatMessage.messageType.name,
            'has_attachment':
                chatMessage.messageType != ChatMessageType.textMessage,
          });
        }
        emit(
          thisState.copyWith(
            newChatMessages: allMessages,
            loadingIds: loadingIds,
            errorIds: errorIds,
          ),
        );

        if (chattingWith.chatUserType != ChatUserType.adminSupport) {
          //if a message is sent successfully, make the user first in user-list as well
          chatUserCubit?.makeUserFirstOrAddFirst(
            chattingWith.copyWith(lastMessage: newMessageNetwork),
            isFromSendingMessage: true,
          );
        }
      }
    }
  }

  bool hasMore() {
    if (state is ChatMessagesFetchSuccess) {
      return (state as ChatMessagesFetchSuccess).chatMessages
              .where((element) => !element.isLocallyStored)
              .length <
          (state as ChatMessagesFetchSuccess).totalOffset;
    }
    return false;
  }

  void disposeNotificationListener() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
  }

  void updateBlockStatus({
    required bool isBlockedByUser,
    required bool isBlockedByProvider,
  }) {
    if (state is ChatMessagesFetchSuccess) {
      final stateAs = state as ChatMessagesFetchSuccess;
      emit(
        stateAs.copyWith(
          newIsBlockedByUser: isBlockedByUser,
          newIsBlockedByProvider: isBlockedByProvider,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    //making all messages read
    chatUserCubit?.makeUserUnreadCountZero(chatUser: chatUser);
    disposeNotificationListener();
    super.close();
  }
}
