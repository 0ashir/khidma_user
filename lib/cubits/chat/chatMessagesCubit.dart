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

  ChatMessagesFetchSuccess({
    required this.chatMessages,
    required this.totalOffset,
    required this.moreChatMessageFetchError,
    required this.moreChatMessageFetchProgress,
    required this.loadingIds,
    required this.errorIds,
    required this.isBlockedByUser,
    required this.isBlockedByProvider,
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
    );
  }
}

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepository _chatRepository;
  String?
      chatUserId; //to store when chatting starts and to be used to mark as read at the end
  ChatUsersCubit? chatUserCubit; //to remove the count for this user

  ChatMessagesCubit(
    this._chatRepository,
  ) : super(ChatMessagesInitial());

  StreamSubscription<ChatNotificationData>? _streamSubscription;

  Future<void> registerNotificationListener() async {
    _streamSubscription = ChatNotificationsUtils
        .notificationStreamController.stream
        .listen((event) {
      if (state is ChatMessagesFetchSuccess) {
        final stateAs = state as ChatMessagesFetchSuccess;
        if (ChatNotificationsUtils.currentChattingUserHashCode ==
                event.fromUser.hashCode &&
            event.fromUser.senderType != "0") {
          if (!stateAs.chatMessages
              .any((element) => element.id == event.receivedMessage.id)) {
            final tempList = stateAs.chatMessages;
            tempList.insert(0, event.receivedMessage);
            emit(stateAs.copyWith(newChatMessages: tempList));
          }
        } else if (event.fromUser.senderType == "0" &&
            ChatNotificationsUtils.currentChattingUserHashCode ==
                event.fromUser.senderType.hashCode) {
          if (!stateAs.chatMessages
              .any((element) => element.id == event.receivedMessage.id)) {
            final tempList = stateAs.chatMessages;
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

  Future<void> fetchChatMessages({
    required String bookingId,
    required String providerId,
    required String type,
    required ChatUsersCubit chatUsersCubitArgument,
  }) async {
    emit(ChatMessagesFetchInProgress());
    try {
      final Map<String, dynamic> data = await _chatRepository.fetchChatMessages(
          offset: 0, bookingId: bookingId, type: type, providerId: providerId);

      //registration of notification listener if the chat messages were fetched successfully
      registerNotificationListener();
      //storing and calling unread when first time messages are fetched
      chatUserId = chatUserId;
      chatUserCubit = chatUsersCubitArgument;
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
        ),
      );
    } catch (e) {
      emit(
        ChatMessagesFetchFailure(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchMoreChatMessages({
    required String bookingId,
    required String type,
  }) async {
    if (state is ChatMessagesFetchSuccess) {
      final stateAs = state as ChatMessagesFetchSuccess;
      if (stateAs.moreChatMessageFetchProgress) {
        return;
      }
      try {
        emit(stateAs.copyWith(newFetchMoreTransactionsInProgress: true));

        final Map moreTransactionResult =
            await _chatRepository.fetchChatMessages(
          offset: stateAs.chatMessages
              .where((element) => !element.isLocallyStored)
              .length,
          type: type,
          bookingId: bookingId,
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
    required ChatUsersCubit chatUserCubit,
    required ChatUser chattingWith,
    required ChatMessage chatMessage,
    required String receiverId,
    String? bookingId,
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
      emit(thisState.copyWith(
        newChatMessages: allMessages,
        loadingIds: loadingIds,
        errorIds: errorIds,
      ));
      ChatMessage? newMessageNetwork;
      try {
        newMessageNetwork = await _chatRepository.sendChatMessage(
          message: chatMessage.messageType == ChatMessageType.textMessage
              ? chatMessage.message
              : '',
          sendMessageTo: chattingWith.receiverType,
          receiverId: receiverId,
          bookingId: bookingId,
          filePaths: chatMessage.messageType != ChatMessageType.textMessage
              ? chatMessage.files.map((e) => e.fileUrl).toList()
              : [],
        );
      } catch (_) {
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
        final int indexToBeChanged =
            allMessages.indexWhere((e) => e.id == chatMessage.id);
        if (newMessageNetwork != null) {
          allMessages.removeAt(indexToBeChanged);
          allMessages.insert(indexToBeChanged, newMessageNetwork);
        }
        emit(thisState.copyWith(
          newChatMessages: allMessages,
          loadingIds: loadingIds,
          errorIds: errorIds,
        ));

        //if a message is sent successfully, make the user first in user-list as well
        chatUserCubit.makeUserFirstOrAddFirst(
            chattingWith.copyWith(lastMessage: newMessageNetwork));
      }
    }
  }

  bool hasMore() {
    if (state is ChatMessagesFetchSuccess) {
      return (state as ChatMessagesFetchSuccess)
              .chatMessages
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

  void updateBlockStatus(
      {required bool isBlockedByUser, required bool isBlockedByProvider}) {
    if (state is ChatMessagesFetchSuccess) {
      final stateAs = state as ChatMessagesFetchSuccess;
      emit(stateAs.copyWith(
        newIsBlockedByUser: isBlockedByUser,
        newIsBlockedByProvider: isBlockedByProvider,
      ));
    }
  }

  @override
  Future<void> close() async {
    disposeNotificationListener();
    super.close();
  }
}
