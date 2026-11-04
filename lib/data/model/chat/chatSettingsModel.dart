class ChatSettings {
  final int maxFilesOrImagesInOneMessage;
  final int maxFileSizeInMBCanBeSent;
  final int maxCharactersInATextMessage;
  final bool isPreBookingChatAllowed;
  final bool isPostBookingChatAllowed;
  final bool isImageUploadAllowed;
  final bool isFileUploadAllowed;

  ChatSettings({
    required this.maxFilesOrImagesInOneMessage,
    required this.maxFileSizeInMBCanBeSent,
    required this.maxCharactersInATextMessage,
    required this.isPreBookingChatAllowed,
    required this.isPostBookingChatAllowed,
    required this.isImageUploadAllowed,
    required this.isFileUploadAllowed,
  });

  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      maxFilesOrImagesInOneMessage:
          int.tryParse(json['maxFilesOrImagesInOneMessage']?.toString() ?? '0') ??
              0,
      maxFileSizeInMBCanBeSent:
          int.tryParse(json['maxFileSizeInMBCanBeSent']?.toString() ?? '0') ?? 0,
      maxCharactersInATextMessage:
          int.tryParse(json['maxCharactersInATextMessage']?.toString() ?? '0') ??
              0,
      isPreBookingChatAllowed: json['allow_pre_booking_chat']?.toString() == '1',
      isPostBookingChatAllowed:
          json['allow_post_booking_chat']?.toString() == '1',
      isImageUploadAllowed: json['enable_chat_image_upload']?.toString() == '1',
      isFileUploadAllowed: json['enable_chat_file_upload']?.toString() == '1',
    );
  }
}
