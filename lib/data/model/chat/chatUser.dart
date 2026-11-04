import 'package:e_demand/app/generalImports.dart';

enum ChatUserType { adminSupport, providerBooking, providerEnquiry }

class ChatUser {
  final String? id;
  final String name;
  final String translatedName;
  final String? profile;
  int unReadChats;
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isBlockedByProvider;
  final String? bookingId;
  final String? bookingStatus;
  final String? translatedOrderStatus;
  final String? partnerId;
  final String? lastChatDate;
  final ChatUserType chatUserType;
  final ChatMessage? lastMessage;
  final String? lastMessageText;
  final bool isProviderVerified;

  ChatUser({
    this.id,
    required this.name,
    required this.translatedName,
    required this.chatUserType,
    required this.partnerId,
    required this.unReadChats,
    this.bookingId,
    this.bookingStatus,
    this.translatedOrderStatus,
    this.profile,
    this.isBlocked = false,
    this.isBlockedByUser = false,
    this.isBlockedByProvider = false,
    this.lastChatDate,
    this.lastMessage,
    this.lastMessageText,
    this.isProviderVerified = false,
  });

  //getters for the UI
  int get unreadNotificationsCount => unReadChats;

  bool get hasUnreadMessages => unreadNotificationsCount != 0;

  String get userName =>
      translatedName.toString().isNotEmpty ? translatedName : name;

  String get avatar => profile ?? '';

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    // Determine chat user type
    String? bookingIdStr = json["booking_id"]?.toString();
    if (bookingIdStr == 'null' ||
        bookingIdStr == '0' ||
        bookingIdStr?.isEmpty == true) {
      bookingIdStr = null;
    }

    String? partnerIdStr = json["partner_id"]?.toString();
    if (partnerIdStr == 'null' ||
        partnerIdStr == '0' ||
        partnerIdStr?.isEmpty == true) {
      partnerIdStr = null;
    }

    ChatUserType type = ChatUserType.adminSupport;
    if (bookingIdStr != null) {
      type = ChatUserType.providerBooking;
    } else if (partnerIdStr != null) {
      type = ChatUserType.providerEnquiry;
    }

    return ChatUser(
      id: json['id']?.toString(),
      name: json['partner_name']?.toString() ?? '',
      translatedName: json['translated_partner_name']?.toString() ?? '',
      profile: json['image']?.toString(),
      unReadChats: int.tryParse(json['un_read_chats']?.toString() ?? '0') ?? 0,
      bookingId: bookingIdStr,
      bookingStatus: json["order_status"]?.toString(),
      translatedOrderStatus: json["translated_order_status"]?.toString() ?? '',
      isBlocked: json['is_blocked']?.toString() == "1",
      isBlockedByUser: json['is_block_by_user']?.toString() == "1",
      isBlockedByProvider: json['is_block_by_provider']?.toString() == "1",
      partnerId: partnerIdStr,
      lastChatDate: json['last_chat_date']?.toString(),
      lastMessage: json['last_message'] is Map
          ? ChatMessage.fromJson(
              Map<String, dynamic>.from(json['last_message'] as Map),
            )
          : null,
      lastMessageText: json['last_message'] is String
          ? json['last_message'] as String
          : null,
      chatUserType: type,
      isProviderVerified: json['is_provider_verified']?.toString() == "1",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_name': name,
      'translated_partner_name': translatedName,
      'image': profile,
      'un_read_chats': unReadChats,
      'booking_id': bookingId,
      'order_status': bookingStatus,
      'translated_order_status': translatedOrderStatus,
      'partner_id': partnerId,
      'is_blocked': isBlocked ? 1 : 0,
      'is_block_by_user': isBlockedByUser ? 1 : 0,
      'is_block_by_provider': isBlockedByProvider ? 1 : 0,
      'last_chat_date': lastChatDate,
      'last_message': lastMessage?.toJson() ?? lastMessageText,
      'is_provider_verified': isProviderVerified ? 1 : 0,
    };
  }

  ChatUser copyWith({
    String? id,
    String? name,
    String? translatedName,
    int? unReadChats,
    String? bookingId,
    String? bookingStatus,
    String? translatedOrderStatus,
    String? otherUserId,
    String? profile,
    bool? isBlocked,
    bool? isBlockedByUser,
    bool? isBlockedByProvider,
    String? partnerId,
    String? lastChatDate,
    ChatUserType? chatUserType,
    ChatMessage? lastMessage,
    String? lastMessageText,
    bool? isProviderVerified,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      translatedName: translatedName ?? this.translatedName,
      profile: profile ?? this.profile,
      unReadChats: unReadChats ?? this.unReadChats,
      bookingId: bookingId ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      translatedOrderStatus:
          translatedOrderStatus ?? this.translatedOrderStatus,
      isBlocked: isBlocked ?? this.isBlocked,
      isBlockedByUser: isBlockedByUser ?? this.isBlockedByUser,
      isBlockedByProvider: isBlockedByProvider ?? this.isBlockedByProvider,
      partnerId: partnerId ?? this.partnerId,
      lastChatDate: lastChatDate ?? this.lastChatDate,
      chatUserType: chatUserType ?? this.chatUserType,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      isProviderVerified: isProviderVerified ?? this.isProviderVerified,
    );
  }

  @override
  bool operator ==(covariant ChatUser other) {
    if (chatUserType != other.chatUserType) {
      return false;
    }

    if (chatUserType == ChatUserType.providerBooking) {
      return bookingId == other.bookingId;
    } else if (chatUserType == ChatUserType.providerEnquiry) {
      return partnerId == other.partnerId;
    } else if (chatUserType == ChatUserType.adminSupport) {
      return true; // Any admin support is equal to another admin support
    }

    return false;
  }

  @override
  int get hashCode {
    if (chatUserType == ChatUserType.providerBooking) {
      return bookingId.hashCode;
    } else if (chatUserType == ChatUserType.providerEnquiry) {
      return partnerId.hashCode;
    } else if (chatUserType == ChatUserType.adminSupport) {
      return chatUserType.hashCode;
    }

    return super.hashCode;
  }
}
