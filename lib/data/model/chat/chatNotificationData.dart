import 'package:e_demand/app/generalImports.dart';

/*
this is a general data model to get data of chat message or user when a notification arrives
this model is not connected to any API response
it's internally used, currently used to stream it's instances when a chat notification arrives
also useful to get data of notifications that came while in background
*/
class ChatNotificationData {
  ChatMessage receivedMessage;
  ChatUser fromUser;
  ChatNotificationData(this.receivedMessage, this.fromUser);

  factory ChatNotificationData.fromRemoteMessage({
    required RemoteMessage remoteMessage,
  }) {
    final data = remoteMessage.data;

    final ChatMessage receivedMessage = ChatMessage.fromJson(
      jsonDecode(data['chat_message'].toString()) ?? {},
    );

    final ChatUser fromUser = data['chat_user']?.isEmpty ?? true
        ? ChatUser(
            id: "0",
            name: "customerSupport",
            translatedName: "customerSupport",
            chatUserType: ChatUserType.adminSupport,
            partnerId: null,
            unReadChats: 0,
          )
        : ChatUser.fromJson(jsonDecode(data['chat_user'].toString()) ?? {});

    return ChatNotificationData(
      receivedMessage,
      fromUser.copyWith(lastMessage: receivedMessage),
    );
  }

  ChatNotificationData copyWith({
    ChatMessage? receivedMessage,
    ChatUser? fromUser,
  }) {
    return ChatNotificationData(
      receivedMessage ?? this.receivedMessage,
      fromUser ?? this.fromUser,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chat_message': receivedMessage.toJson(),
      'chat_user': fromUser.toJson(),
    };
  }

  factory ChatNotificationData.fromMap(Map<String, dynamic> map) {
    return ChatNotificationData(
      ChatMessage.fromJson(map['chat_message'] as Map<String, dynamic>),
      ChatUser.fromJson(map['chat_user'] as Map<String, dynamic>),
    );
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory ChatNotificationData.fromJson(String source) =>
      ChatNotificationData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ChatNotificationData(receivedMessage: $receivedMessage, fromUser: $fromUser)';
}
