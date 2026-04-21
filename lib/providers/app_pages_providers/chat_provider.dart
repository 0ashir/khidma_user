import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../firebase/firebase_api.dart';
import '../../models/call_model.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';

enum MessageType { text, image, video, offer }

class ChatProvider with ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode chatFocus = FocusNode();

  List<ChatModel> chatList = [];
  String? chatId,
      image,
      name,
      role,
      token,
      code,
      phone,
      bookingId,
      bookingNumber;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages = [];
  List<DateTimeChip> localMessage = [];
  int? userId;
  StreamSubscription? messageSub;
  XFile? imageFile;
  BookingModel? booking;
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    chatFocus.dispose();
    messageSub?.cancel();
    super.dispose();
  }

  Future<void> onReady(context) async {
    try {
      isLoading = true;
      showLoading(context);
      notifyListeners();

      // Reset chat data
      _resetChatData();

      // Get arguments from route
      dynamic data = ModalRoute.of(context)!.settings.arguments ?? "";
      if (data != "") {
        _initializeFromArguments(data);
      }

      // if (bookingId == "0") {
      //   var senderId = userModel!.id;
      //   var receiverId = userId;
      //   if (int.parse(senderId.toString()) > int.parse(receiverId.toString())) {
      //     chatId = "$senderId-$receiverId";
      //   } else {
      //     chatId = "$receiverId-$senderId";
      //   }
      // } else {
      //   var senderId = userModel!.id;
      //   var receiverId = userId;
      //   if (int.parse(senderId.toString()) > int.parse(receiverId.toString())) {
      //     chatId = "${senderId}_${bookingId}_$receiverId";
      //   } else {
      //     chatId = "${receiverId}_${bookingId}_$senderId";
      //   }
      // }
      if (chatId == null || chatId == "0" || chatId!.isEmpty) {
        final senderId = userModel!.id.toString();
        final receiverId = userId.toString();

        chatId = buildChatId(
          senderId: senderId,
          receiverId: receiverId,
          bookingId: bookingId,
        );
        log("Recalculated chatId => $chatId");
      } else {
        log("Using passed chatId from arguments => $chatId");
      }

      log("FINAL chatId => $chatId");
      // Load booking details and chat data concurrently
      await Future.wait([getBookingDetailBy(context), getChatData(context)]);

      log("ChatProvider initialized - BookingId: $bookingId, UserId: $userId");
    } catch (e, s) {
      log("Error in ChatProvider onReady: $e", stackTrace: s);
      Fluttertoast.showToast(msg: "Error loading chat: $e");
    } finally {
      isLoading = false;
      hideLoading(context);
      notifyListeners();
    }
  }

  void _resetChatData() {
    chatId = "0";
    messageSub?.cancel();
    messageSub = null;
    allMessages = [];
    localMessage = [];
  }

  void _initializeFromArguments(dynamic data) {
    userId = int.tryParse(data['userId'].toString()) ?? 0;
    name = data['name']?.toString();
    image = data['image']?.toString();
    role = data['role']?.toString();
    token = data['token']?.toString();
    phone = data['phone']?.toString();
    code = data['code']?.toString();
    bookingId = data['bookingId']?.toString();
    bookingNumber = data['bookingNumber']?.toString();
    chatId = data['chatId']?.toString();

    // If bookingId contains underscores, extract the middle part as the real bookingId
    if (bookingId != null && bookingId!.contains('_')) {
      List<String> parts = bookingId!.split('_');
      if (parts.length == 3) {
        log("Extracted raw bookingId: ${parts[1]} from composite: $bookingId");
        bookingId = parts[1];
      }
    }

    log("Initialized chat with UserId: $userId, BookingId: $bookingId, ChatId: $chatId");
  }

  // Get booking details by ID
  Future<void> getBookingDetailBy(context) async {
    try {
      if (bookingId == null || bookingId!.isEmpty) {
        log("BookingId is null or empty");
        return;
      }

      final value = await apiServices.getApi("${api.booking}/$bookingId", [],
          isToken: true, isData: true);

      if (value.isSuccess ?? false) {
        booking = BookingModel.fromJson(value.data['data']);

        // Update serviceman details if available
        if (booking?.servicemen != null && booking!.servicemen!.isNotEmpty) {
          int index = booking!.servicemen!
              .indexWhere((e) => e.id.toString() == userId.toString());

          if (index >= 0) {
            phone = booking!.servicemen![index].phone.toString();
            token = booking!.servicemen![index].fcmToken;
            code = booking!.servicemen![index].code;
            log("servicemen Token::${booking!.servicemen![index].fcmToken}");
          }
        }

        log("Booking details loaded successfully");
      } else {
        log("Failed to load booking details: ${value.message}");
      }
    } catch (e, s) {
      log("Error in getBookingDetailBy: $e", stackTrace: s);
    }
  }

  // Get chat data from Firestore
  Future<void> getChatData(context) async {
    try {
      if (chatId == null ||
          chatId == "0" ||
          userId == null ||
          userModel?.id == null) {
        log("Invalid chat data - ChatId: $chatId, UserId: $userId, UserModel: ${userModel?.id}");
        return;
      }

      // Cancel existing subscription
      messageSub?.cancel();

      // Create new message subscription
      messageSub = FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.chatWith)
          .doc(userId.toString())
          .collection(collectionName.booking)
          .doc(chatId.toString())
          .collection(collectionName.chat)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((event) async {
        allMessages = event.docs;
        await _processMessages();
        await seenMessage();
        notifyListeners();
      }, onError: (error) {
        log("Error in message stream: $error");
      });

      log("Chat data subscription created successfully");
    } catch (e, s) {
      log("Error in getChatData: $e", stackTrace: s);
    }
  }

  // Process messages for UI display
  Future<void> _processMessages() async {
    try {
      localMessage.clear();

      for (var doc in allMessages) {
        final data = doc.data();
        final messageModel = MessageModel.fromJson(data);
        messageModel.docId = doc.id;

        final dateKey = getDate(doc.id);

        // Find or create date group
        int dateIndex =
            localMessage.indexWhere((element) => element.time == dateKey);

        if (dateIndex == -1) {
          // Create new date group
          localMessage
              .add(DateTimeChip(time: dateKey, message: [messageModel]));
        } else {
          // Add to existing date group
          if (!localMessage[dateIndex]
              .message!
              .any((msg) => msg.docId == messageModel.docId)) {
            localMessage[dateIndex].message!.add(messageModel);
          }
        }
      }

      // Sort messages within each date group
      for (var dateGroup in localMessage) {
        dateGroup.message?.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
      }
    } catch (e, s) {
      log("Error processing messages: $e", stackTrace: s);
    }
  }

  // Send message
  Future<void> setMessage(String content, MessageType type, context) async {
    log("message $content");
    if (content.trim().isEmpty || userId == null || userModel?.id == null) {
      log("Invalid message data");
      return;
    }

    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Update member chatId instead of shadowing it
      chatId = buildChatId(
        senderId: userModel!.id.toString(),
        receiverId: userId.toString(),
        bookingId: bookingId,
      );
      log("message chat id $chatId");
      // Create message model
      MessageModel messageModel = MessageModel(
        chatId: chatId,
        content: content,
        docId: timestamp,
        messageType: "sender",
        receiverId: userId.toString(),
        senderId: userModel!.id.toString(),
        timestamp: timestamp,
        type: type.name,
        receiverImage: image,
        bookingId: bookingId,
        receiverName: name,
        bookingNumber: bookingNumber,
        senderImage: userModel!.media.isNotEmpty == true
            ? userModel!.media[0].originalUrl
            : null,
        senderName: userModel!.name,
        role: "user",
        isSeen: false,
      );

      // Clear input
      controller.clear();

      // Add to local messages immediately for better UX
      _addToLocalMessages(messageModel);
      notifyListeners();

      // Save to Firebase
      await _saveMessageToFirebase(messageModel, content, type, timestamp);

      // Send notification
      await _sendMessageNotification(content, timestamp);

      log("Message sent successfully");
    } catch (e, s) {
      log("Error sending message: $e", stackTrace: s);
      Fluttertoast.showToast(msg: "Failed to send message");
    }
  }

  void _addToLocalMessages(MessageModel messageModel) {
    try {
      String dateKey = "Today"; // You can implement proper date formatting

      int index = localMessage.indexWhere((element) => element.time == dateKey);

      if (index == -1) {
        localMessage.add(DateTimeChip(time: dateKey, message: [messageModel]));
      } else {
        localMessage[index].message!.add(messageModel);
      }
    } catch (e) {
      log("Error adding to local messages: $e");
    }
  }

  Future<void> _saveMessageToFirebase(MessageModel messageModel, String content,
      MessageType type, String timestamp) async {
    log("message inside firebase function  $chatId");
    try {
      // Save message for sender
      await FirebaseApi().saveMessage(
          role: "user",
          receiverName: name,
          type: type,
          dateTime: timestamp,
          encrypted: content,
          isSeen: false,
          newChatId: chatId,
          collectionId: userId.toString(),
          pId: userId,
          bookingId: chatId,
          receiverImage: image,
          bookingNumber: bookingNumber,
          senderId: userModel!.id);

      // Save message for receiver
      await FirebaseApi().saveMessage(
          role: "user",
          receiverName: name,
          type: type,
          collectionId: userModel!.id.toString(),
          bookingId: chatId,
          dateTime: timestamp,
          encrypted: content,
          isSeen: false,
          newChatId: chatId,
          bookingNumber: bookingNumber,
          pId: userId,
          receiverImage: image,
          senderId: userId.toString());

      // Save in user collections for chat history
      await Future.wait([
        FirebaseApi().saveMessageInUserCollection(
            senderId: userModel!.id,
            rToken: token,
            sToken: userModel!.fcmToken,
            receiverImage: image,
            newChatId: chatId,
            type: type,
            receiverName: name,
            bookingId: chatId,
            bookingNumber: bookingNumber,
            content: content,
            receiverId: userId,
            id: userModel!.id,
            role: "user"),
        FirebaseApi().saveMessageInUserCollection(
          senderId: userModel!.id,
          receiverImage: image,
          newChatId: chatId,
          bookingNumber: bookingNumber,
          rToken: token,
          sToken: userModel!.fcmToken,
          type: type,
          bookingId: chatId,
          receiverName: name,
          content: content,
          receiverId: userId,
          id: userId,
          role: "user",
        )
      ]);
    } catch (e, s) {
      log("Error saving message to Firebase: $e", stackTrace: s);
      rethrow;
    }
  }

  Future<void> _sendMessageNotification(
      String content, String timestamp) async {
    try {
      log("Serviceman token::$token");
      if (token?.isNotEmpty == true) {
        await FirebaseApi().sendNotification(
          title: "${userModel!.name} sent you a message",
          msg: content,
          chatId: chatId,
          token: token!,
          pId: userId.toString(),
          image: image ?? "",
          name: userModel!.name,
          phone: phone,
          code: code,
          bookingId: bookingId?.isNotEmpty == true ? bookingId : chatId,
          dataTitle: userModel!.name,
        );
        log("Notification sent successfully");
      } else {
        log("No FCM token available for notification");
      }
    } catch (e, s) {
      log("Error sending notification: $e", stackTrace: s);
    }
  }

  // Mark messages as seen
  Future<void> seenMessage() async {
    try {
      if (chatId == null || userId == null || userModel?.id == null) return;

      // Mark messages as seen in current user's chat
      await _markMessagesAsSeen(
          userModel!.id.toString(), userId.toString(), chatId!);

      // Mark messages as seen in other user's chat
      await _markMessagesAsSeen(
          userId.toString(), userModel!.id.toString(), chatId!);

      // Update chat history seen status
      await _updateChatHistorySeenStatus();
    } catch (e, s) {
      log("Error in seenMessage: $e", stackTrace: s);
    }
  }

  Future<void> _markMessagesAsSeen(
      String docId, String chatWithId, String bookingId) async {
    try {
      final messages = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(docId)
          .collection(collectionName.chatWith)
          .doc(chatWithId)
          .collection(collectionName.booking)
          .doc(bookingId)
          .collection(collectionName.chat)
          .where("receiverId", isEqualTo: userModel!.id.toString())
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in messages.docs) {
        batch.update(doc.reference, {"isSeen": true});
      }

      if (messages.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      log("Error marking messages as seen: $e");
    }
  }

  Future<void> _updateChatHistorySeenStatus() async {
    try {
      // Update for current user
      await _updateUserChatHistory(userModel!.id.toString());

      // Update for other user
      await _updateUserChatHistory(userId.toString());
    } catch (e) {
      log("Error updating chat history seen status: $e");
    }
  }

  Future<void> _updateUserChatHistory(String userId) async {
    try {
      String id1 = chatId!;
      String id2 = chatId!;
      if (chatId!.contains('_')) {
        List<String> parts = chatId!.split('_');
        if (parts.length == 3) {
          id1 = "${parts[0]}_${parts[1]}_${parts[2]}";
          id2 = "${parts[2]}_${parts[1]}_${parts[0]}";
        }
      }

      final chats = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userId)
          .collection(collectionName.chats)
          .where("bookingId", whereIn: [id1, id2]).get();

      if (chats.docs.isNotEmpty) {
        await chats.docs.first.reference.update({"isSeen": true});
      }
    } catch (e) {
      log("Error updating user chat history: $e");
    }
  }

 static String buildChatId({
  required String senderId,
  required String receiverId,
  String? bookingId,
}) {
  try {
    // Guard against null or empty values
    if (senderId.isEmpty || receiverId.isEmpty || 
        senderId == 'null' || receiverId == 'null') {
      return "0_0";
    }

    String? rawBookingId = bookingId;
    if (bookingId != null && bookingId.contains('_')) {
      List<String> parts = bookingId.split('_');
      if (parts.length == 3) {
        rawBookingId = parts[1];
      }
    }

    final s = int.tryParse(senderId) ?? 0;
    final r = int.tryParse(receiverId) ?? 0;

    final low = s < r ? s : r;
    final high = s < r ? r : s;

    if (rawBookingId != null &&
        rawBookingId.isNotEmpty &&
        rawBookingId != "0") {
      return "${low}_${rawBookingId}_$high";
    }
    return "${low}_$high";
  } catch (e) {
    log("Error building chatId: $e");
    return "0_0";
  }
}
  // Handle back navigation
  void onBack(context, isBack) {
    onBackConfirmation(context);
  }

  void onBackConfirmation(context) async {
    if (booking?.service?.type == "remotely") {
      _showCompletionDialog(context);
    } else {
      route.pop(context);
    }
  }

  void _showCompletionDialog(context) {
    showDialog(
        context: context,
        builder: (context1) => AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: Insets.i20),
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.all(SmoothRadius(
                    cornerRadius: AppRadius.r10, cornerSmoothing: 1))),
            backgroundColor: appColor(context).whiteBg,
            content: Stack(alignment: Alignment.topRight, children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VSpace(Sizes.s15),
                  Text(language(context, translations!.alertChatBackDesc),
                      textAlign: TextAlign.center,
                      style: appCss.dmDenseRegular14
                          .textColor(appColor(context).darkText)
                          .textHeight(1.4)),
                  const VSpace(Sizes.s20),
                  BottomSheetButtonCommon(
                      clearTap: () => route.pop(context),
                      applyTap: () => updateStatus(context, booking!.id),
                      textTwo: translations!.goBack,
                      textOne: translations!.cancel)
                ],
              ).padding(horizontal: Insets.i20, top: Insets.i60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(language(context, translations!.alertChatBack),
                        overflow: TextOverflow.ellipsis,
                        style: appCss.dmDenseMedium18
                            .textColor(appColor(context).darkText)),
                  ),
                  Icon(CupertinoIcons.multiply,
                          size: Sizes.s20, color: appColor(context).darkText)
                      .inkWell(onTap: () => route.pop(context))
                ],
              ).paddingAll(Insets.i20)
            ])));
  }

  // Update booking status
  Future<void> updateStatus(context, bookingId,
      {isCancel = false, sync}) async {
    try {
      route.pop(context);
      showLoading(context);

      Map<String, dynamic> data = {"booking_status": translations!.completed};

      final value = await apiServices.putApi("${api.booking}/$bookingId", data,
          isToken: true, isData: true);

      if (value.isSuccess!) {
        final dash = Provider.of<DashboardProvider>(context, listen: false);
        dash.selectIndex = 1;
        dash.getBookingHistory(context);

        route.pushNamed(context, routeName.completedServiceScreen,
            arg: {"bookingId": booking!.id}).then((e) {
          dash.notifyListeners();
          route.pushReplacementNamed(context, routeName.dashboard);
        });

        _cleanupChatData();
      }
    } catch (e, s) {
      log("Error updating status: $e", stackTrace: s);
    } finally {
      hideLoading(context);
      notifyListeners();
    }
  }

  void _cleanupChatData() {
    allMessages.clear();
    localMessage.clear();
    messageSub?.cancel();
    messageSub = null;
    booking = null;
    chatId = null;
    image = null;
    name = null;
    role = null;
    token = null;
    code = null;
    phone = null;
  }

  // Image handling methods
  Future<void> showLayout(context) async {
    showDialog(
        context: context,
        builder: (context1) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppRadius.r12))),
              content:
                  Consumer<LanguageProvider>(builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language(context, translations!.selectOne),
                            style: appCss.dmDenseBold18
                                .textColor(appColor(context).darkText)),
                        const Icon(CupertinoIcons.multiply)
                            .inkWell(onTap: () => route.pop(context))
                      ],
                    ),
                    const VSpace(Sizes.s20),
                    ...appArray.selectList
                        .asMap()
                        .entries
                        .map((e) => SelectOptionLayout(
                            data: e.value,
                            index: e.key,
                            list: appArray.selectList,
                            onTap: () {
                              if (e.key == 0) {
                                getImage(context, ImageSource.gallery);
                              } else {
                                getImage(context, ImageSource.camera);
                              }
                            }))
                  ],
                );
              }));
        });
  }

  Future<void> getImage(context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      imageFile = await picker.pickImage(source: source);

      if (imageFile != null) {
        route.pop(context);
        await uploadFile(context);
      }

      notifyListeners();
    } catch (e) {
      log("Error picking image: $e");
      Fluttertoast.showToast(msg: "Failed to pick image");
    }
  }

  Future<void> uploadFile(context) async {
    if (imageFile == null) return;

    try {
      showLoading(context);
      notifyListeners();

      FocusScope.of(context).requestFocus(FocusNode());

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      File file = File(imageFile!.path);

      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      imageFile = null;
      hideLoading(context);
      notifyListeners();

      await setMessage(downloadUrl, MessageType.image, context);
    } catch (e, s) {
      log("Error uploading file: $e", stackTrace: s);
      hideLoading(context);
      Fluttertoast.showToast(msg: "Failed to upload image");
      notifyListeners();
    }
  }

  // UI Building methods
  // Widget timeLayout(context) {
  //   return Column(
  //     children: localMessage.reversed.toList().asMap().entries.map((a) {
  //       List<MessageModel> newMessageList = a.value.message!.toList();

  //       return Column(
  //         children: [
  //           Text(
  //                   a.value.time!.contains("-other")
  //                       ? a.value.time!.split("-other")[0]
  //                       : a.value.time!,
  //                   style: appCss.dmDenseMedium14
  //                       .textColor(appColor(context).lightText))
  //               .marginSymmetric(vertical: Insets.i5),
  //           ...newMessageList.toList().asMap().entries.map((e) {
  //             return buildItem(
  //                 e.key,
  //                 e.value,
  //                 e.value.docId,
  //                 a.value.time!.contains("-other")
  //                     ? a.value.time!.split("-other")[0]
  //                     : a.value.time!);
  //           })
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  Widget timeLayout(BuildContext context) {
    final reversedLocalMessage = localMessage.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 10),
      itemCount: reversedLocalMessage.length,
      itemBuilder: (context, index) {
        final timeGroup = reversedLocalMessage[index];
        final timeLabel = timeGroup.time!.contains("-other")
            ? timeGroup.time!.split("-other")[0]
            : timeGroup.time!;

        final messages = timeGroup.message!.toList();
        log("messages list => ${messages.map((e) => e.toJson()).toList()}");
        // final item = chatItems[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeLabel,
              style:
                  appCss.dmDenseMedium14.textColor(appColor(context).lightText),
            ).center(),
            ...messages.asMap().entries.map((entry) {
              final msgIndex = entry.key;
              final msg = entry.value;
              // log("newMessageList::${msg.docId}");
              return buildItem(
                msgIndex,
                msg,
                msg.docId,
                timeLabel,
                context,
              );
            }),
          ],
        );
        // DATE HEADER
      },
    );
  }

  Widget buildItem(
      int index, MessageModel document, documentId, title, context) {
    if (document.senderId.toString() == userModel!.id.toString()) {
      return ChatLayout(document: document, isSentByMe: true);
    } else {
      return ChatLayout(document: document, isSentByMe: false);
    }
  }

  // Clear chat functionality
  void onClearChat(context, sync) {
    final value = Provider.of<DeleteDialogProvider>(context, listen: false);

    value.onDeleteDialog(sync, context, eImageAssets.clearChat,
        translations!.clearChat, translations!.areYouClearChat, () async {
      route.pop(context);
      await FirebaseApi().clearChat(context);
      value.onResetPass(
          context,
          language(context, translations!.hurrayChatDelete),
          language(context, translations!.okay),
          () => Navigator.pop(context));
    });
    value.notifyListeners();
  }

  Future<void> makePhoneCall(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

//get camera permission
  static Future<PermissionStatus> getCameraPermission() async {
    PermissionStatus cameraPermission = await Permission.camera.request();
    log("cameraPermission : $cameraPermission");
    if (cameraPermission != PermissionStatus.granted &&
        cameraPermission != PermissionStatus.denied) {
      return Permission.camera as FutureOr<PermissionStatus>? ??
          PermissionStatus.granted;
    } else {
      return cameraPermission;
    }
  }

  // get microphone permission
  static Future<PermissionStatus> getMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      return PermissionStatus.granted;
    } else {
      return PermissionStatus.denied;
    }
  }

  static void _handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  Future<bool> getCameraMicrophonePermissions() async {
    PermissionStatus cameraPermissionStatus = await getCameraPermission();
    PermissionStatus microphonePermissionStatus =
        await getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  onCallTap(context, index) async {
    log("CODE :$index");
    route.pop(context);
    if (index == 0) {
      getCameraMicrophonePermissions().then((value) {
        if (value == true) {
          audioVideoCallTap(context, false);
        }
      });
    } else {
      getCameraMicrophonePermissions().then((value) {
        if (value == true) {
          audioVideoCallTap(context, true);
        }
      });
    }
    notifyListeners();
  }

  //audio and video call tap
  audioVideoCallTap(context, isVideoCall) async {
    await audioAndVideoCallApi(context, isVideoCall);
  }

  audioAndVideoCallApi(context, isVideoCall) async {
    Map<String, dynamic>? response = await getAgoraTokenAndChannelName();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (response != null) {
      String channelId = response["channelName"];
      String token = response["agoraToken"];
      Call call = Call(
          timestamp: timestamp,
          callerId: userModel!.id.toString(),
          callerName: userModel!.name,
          callerPic: userModel!.media.isNotEmpty
              ? userModel!.media[0].originalUrl ?? ""
              : "",
          receiverId: userId.toString(),
          receiverName: name,
          receiverPic: image,
          channelId: channelId,
          isVideoCall: isVideoCall,
          agoraToken: token);

      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call.callerId)
          .collection(collectionName.calling)
          .add({
        "timestamp": timestamp,
        "callerId": call.callerId,
        "callerName": call.callerName,
        "callerPic": call.callerPic,
        "receiverId": call.receiverId,
        "receiverName": call.receiverName,
        "receiverPic": call.receiverPic,
        "hasDialled": true,
        "channelId": response['channelName'],
        "isVideoCall": isVideoCall,
        "agoraToken": token,
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection(collectionName.calls)
            .doc(call.receiverId)
            .collection(collectionName.calling)
            .add({
          "timestamp": timestamp,
          "callerId": call.callerId,
          "callerName": call.callerName,
          "callerPic": call.callerPic,
          "receiverId": call.receiverId,
          "receiverName": call.receiverName,
          "receiverPic": call.receiverPic,
          "hasDialled": false,
          "channelId": response['channelName'],
          "isVideoCall": isVideoCall,
          "agoraToken": token,
        }).then((value) async {
          call.hasDialled = true;
          if (isVideoCall == false) {
            FirebaseApi().sendNotification(
                title: "Incoming Audio Call...",
                msg: "${call.callerName} audio call",
                token: token,
                name: call.callerName,
                image: image,
                dataTitle: call.callerName);
            var data = {
              "channelName": call.channelId,
              "call": call,
              "token": response["agoraToken"]
            };
            log("Audio Call ::$data");
            route.pushNamed(context, routeName.audioCall, arg: data);
          } else {
            FirebaseApi().sendNotification(
                title: "Incoming Video Call...",
                msg: "${call.callerName} video call",
                token: token,
                name: call.callerName,
                image: image,
                dataTitle: call.callerName);

            var data = {
              "channelName": call.channelId,
              "call": call,
              "token": response["agoraToken"]
            };

            route.pushNamed(context, routeName.videoCall, arg: data);
          }
        });
      });
    } else {
      log("messagefhasuifhudfhsu");
      Fluttertoast.showToast(msg: "Failed to call");
    }
  }

  getAgoraTokenAndChannelName() async {
    try {
      HttpsCallable httpsCallable =
          FirebaseFunctions.instance.httpsCallable("generateToken");
      if (appSettingModel!.agora != null) {
        dynamic result = await httpsCallable.call(
          {
            "appId": appSettingModel!.agora!.appId,
            "appCertificate": appSettingModel!.agora!.certificate
          },
        );

        if (result.data != null) {
          Map<String, dynamic> response = {
            "agoraToken": result.data['data']["token"],
            "channelName": result.data['data']["channelName"],
          };

          return response;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log("ERROR WHILE FETCH CREDENTIALS : $e");
    }
  }

// Call functionality methods would go here...
// (keeping existing call methods for brevity)
}
