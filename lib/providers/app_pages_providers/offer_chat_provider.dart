import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common_tap.dart';
import '../../config.dart';
import '../../firebase/firebase_api.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';
import '../../widgets/alert_message_common.dart';

class OfferChatProvider with ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode chatFocus = FocusNode();
  List<ChatModel> chatList = [];
  String? chatId, image, name, role, token, code, phone;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages = [];
  List<DateTimeChip> localMessage = [];
  int? userId;
  StreamSubscription? messageSub;
  XFile? imageFile;
  Services? services;
  bool isExpand = false;

  onExpand(data) {
    isExpand = !isExpand;
    log("isExpand::$isExpand");
    notifyListeners();
  }

  onReady(context) async {
    try {
      showLoading(context);
      notifyListeners();

// Clear existing subscription and data
      messageSub?.cancel();
      messageSub = null;
      allMessages = [];
      localMessage = [];

// Retrieve arguments
      @override
      void initState() {
        Future.microtask(() {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;

          if (args != null) {
            chatId = args['chatId']?.toString() ?? "0"; // ✅ set it
            userId = int.tryParse(args['userId'].toString()) ?? 0;
            name = args['name'];
            image = args['image'];
            role = args['role'];
            token = args['receiverToken'];
            phone = args['phone'].toString();
            code = args['code']?.toString();
          }

          Provider.of<OfferChatProvider>(context, listen: false)
              .onReady(context);
        });
      }

      log("name:$name // chatId:$chatId");

// Fetch chat data
      await getChatData(context);
      hideLoading(context);
      notifyListeners();
    } catch (e) {
      log("EEEE onREADY CHAT : $e");
      hideLoading(context);
      notifyListeners();
    }
  }

  Future getChatIdAvailable(context) async {
    try {
      // 🔍 Try finding chat under current user
      var querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.chats)
          .where('isOffer', isEqualTo: true)
          .where('senderId', isEqualTo: userModel!.id.toString())
          .where('receiverId', isEqualTo: userId.toString())
          .get();

      if (querySnapshot.docs.isEmpty) {
        // 🔁 Try reverse (you might be receiver)
        querySnapshot = await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userModel!.id.toString())
            .collection(collectionName.chats)
            .where('isOffer', isEqualTo: true)
            .where('senderId', isEqualTo: userId.toString())
            .where('receiverId', isEqualTo: userModel!.id.toString())
            .get();
      }

      // ✅ If still not found, check in *other user's* path
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userId.toString()) // 👈 switch to other user's path
            .collection(collectionName.chats)
            .where('isOffer', isEqualTo: true)
            .where('senderId', isEqualTo: userModel!.id.toString())
            .where('receiverId', isEqualTo: userId.toString())
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userId.toString()) // 👈 still in other user's path
            .collection(collectionName.chats)
            .where('isOffer', isEqualTo: true)
            .where('senderId', isEqualTo: userId.toString())
            .where('receiverId', isEqualTo: userModel!.id.toString())
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        chatId = querySnapshot.docs.first.data()['chatId'];
        log("✅ Found existing chatId: $chatId");
      } else {
        log("❌ No chat found, using default");
        chatId = "0";
      }

      notifyListeners();
    } catch (e) {
      log("❌ Error in getChatIdAvailable: $e");
      notifyListeners();
    }
  }

  
  onBack(context, isBack) {
    messageSub?.cancel();
    messageSub = null;
    allMessages = [];
    localMessage = [];
// Preserve chatId to allow reloading the same chat session
    image = null;
    name = null;
    role = null;
    token = null;
    code = null;
    phone = null;
    notifyListeners();
    if (isBack) {
      route.pop(context);
    }
  }

  showLayout(context) async {
    showModalBottomSheet(
        context: context,
        builder: (context1) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(language(context, appFonts.selectOne),
                  style: appCss.dmDenseBold18
                      .textColor(appColor(context).darkText)),
              const Icon(CupertinoIcons.multiply)
                  .inkWell(onTap: () => route.pop(context))
            ]),
            const VSpace(Sizes.s20),
            ...appArray.selectList
                .asMap()
                .entries
                .map((e) => SelectOptionLayout(
                    data: e.value,
                    index: e.key,
                    list: appArray.selectList,
                    onTap: () {
                      log("dsf :${e.key}");
                      if (e.key == 0) {
                        pickAndUploadFile(context, ImageSource.gallery);
                      } else {
                        pickAndUploadFile(context, ImageSource.camera);
                      }
                    }))
          ]).padding(all: Sizes.s20);
        });
  }

  Future pickAndUploadFile(BuildContext context, ImageSource source,
      {bool isVideo = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;

      if (isVideo) {
        pickedFile = await picker.pickVideo(
            source: source, maxDuration: const Duration(minutes: 2));
      } else {
        pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      }

      if (pickedFile != null) {
        log("Picked file path: ${pickedFile.path}");
        route.pop(context); // Close the bottom sheet immediately
        notifyListeners();
        await uploadFile(context, pickedFile,
            isVideo: pickedFile.name.contains(".mp4"));
      } else {
        log("No file selected.");
      }
    } catch (e) {
      log("Error picking file: $e");
      snackBarMessengers(
        context,
        color: appColor(context).red,
        message: "Error picking file: $e",
      );
    }
  }

  Future uploadFile(BuildContext context, XFile file,
      {bool isVideo = false}) async {
    try {
      showLoading(context);
      notifyListeners();
      FocusScope.of(context).requestFocus(FocusNode());

      String fileName = "${DateTime.now().millisecondsSinceEpoch}${file.name}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      File localFile = File(file.path);
      UploadTask uploadTask = reference.putFile(localFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      log("File uploaded successfully: $downloadUrl");
      await setMessage(
          downloadUrl, isVideo ? MessageType.video : MessageType.image, context,
          isShowLoader: false);

      imageFile = null;
      notifyListeners();
      hideLoading(context);
    } catch (e) {
      log("Error uploading file: $e");
      hideLoading(context);
      notifyListeners();
      snackBarMessengers(
        context,
        color: appColor(context).red,
        message: "Failed to upload file: $e",
      );
    }
  }

  Future<void> makePhoneCall(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  onTapPhone(context) async {
    log("CODE :$code $phone");
    launchCall(context, phone);
    notifyListeners();
  }

  Future getChatData(context) async {
    log("chatIdsd :$chatId ///$userId // ${userModel!.id}");
    try {
      if (chatId != null && chatId != "0") {
        messageSub?.cancel();
        messageSub = FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userModel!.id.toString())
            .collection(collectionName.messages)
            .doc(chatId)
            .collection(collectionName.chat)
            .orderBy("timestamp", descending: true)
            .snapshots()
            .listen((event) async {
          allMessages = event.docs;
          await FirebaseApi().getLocalMessageOffer(context);
          seenMessage();
          notifyListeners();
        });
      } else {
        await getChatIdAvailable(context);
        if (chatId != null && chatId != "0") {
          messageSub?.cancel();
          messageSub = FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(userModel!.id.toString())
              .collection(collectionName.messages)
              .doc(chatId)
              .collection(collectionName.chat)
              .orderBy("timestamp", descending: true)
              .snapshots()
              .listen((event) async {
            allMessages = event.docs;
            await FirebaseApi().getLocalMessageOffer(context);
            seenMessage();
            notifyListeners();
          });
        }
      }
      // hideLoading(context);
      notifyListeners();
    } catch (e) {
      log("Error in getChatData: $e");
      hideLoading(context);
      notifyListeners();
    }
  }

  seenMessage() async {
    try {
      log("chatId.toString():${chatId.toString()}");
      var batch = FirebaseFirestore.instance.batch();

// Update isSeen for messages where the current user is the receiver
      var receiverMessages = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.messages)
          .doc(chatId.toString())
          .collection(collectionName.chat)
          .where("receiverId", isEqualTo: userModel!.id.toString())
          .get();
      for (var element in receiverMessages.docs) {
        batch.update(element.reference, {"isSeen": true});
      }

// Update isSeen for chat entry in the user's chats collection
      var userChats = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get();
      if (userChats.docs.isNotEmpty) {
        batch.update(userChats.docs[0].reference, {"isSeen": true});
      }

// Update isSeen for messages in the receiver's messages collection
      var receiverMessagesOther = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userId.toString())
          .collection(collectionName.messages)
          .doc(chatId.toString())
          .collection(collectionName.chat)
          .where("receiverId", isEqualTo: userModel!.id.toString())
          .get();
      for (var element in receiverMessagesOther.docs) {
        batch.update(element.reference, {"isSeen": true});
      }

// Update isSeen for chat entry in the receiver's chats collection
      var receiverChats = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userId.toString())
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get();
      if (receiverChats.docs.isNotEmpty) {
        batch.update(receiverChats.docs[0].reference, {"isSeen": true});
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      log("Error in seenMessage: $e");
    }
  }

  Widget timeLayout(BuildContext context) {
    final reversedLocalMessage = localMessage.reversed.toList();

    return ListView.builder(
      reverse: true,
      // Reverse the entire scroll direction
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // If inside another scrollable
      itemCount: reversedLocalMessage.length,
      itemBuilder: (context, index) {
        final timeGroup = reversedLocalMessage[index];
        final timeLabel = timeGroup.time!.contains("-other")
            ? timeGroup.time!.split("-other")[0]
            : timeGroup.time!;

        final messages = timeGroup.message!.toList();
        log("messages list => ${messages.map((e) => e.toJson()).toList()}");
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
      },
    );
  }

  Future<String?> getExistingChatIdForUser({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final chatCollection = FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc()
        .collection('chats');

    // Query for chat where current user is sender and other user is receiver
    final query1 = await chatCollection
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherUserId)
        .limit(1)
        .get();

    if (query1.docs.isNotEmpty) {
      return query1.docs.first.id;
    }

    // Query for chat where current user is receiver and other user is sender
    final query2 = await chatCollection
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .limit(1)
        .get();

    if (query2.docs.isNotEmpty) {
      return query2.docs.first.id;
    }

    // No chat found between these two users
    return null;
  }

  Widget buildItem(
      int index, MessageModel document, documentId, title, context) {
    if (document.senderId.toString() == userModel!.id.toString()) {
      return ChatLayout(
              document: document,
              isSentByMe: true,
              isEmailOrPhone:
                  Validation().emailValidation(context, document.content) ==
                          null ||
                      Validation().validateMobile(document.content))
          .padding(vertical: Sizes.s10);
    } else {
      log("document:::${document.content}");

      return ChatLayout(
              document: document,
              isSentByMe: false,
              pay: () {
                log("kladhjaksdh ${document.content}");
                log("fedifndsnfkdnsk");
                var serviceId = document.content['service_id'];

                log("serviceId::$serviceId");
                getService(context,
                    providerId: document.content['provider_id'], id: serviceId);
              },
              accept: () => offerCreateApi(
                  context, document.docId!, "accepted", document.content),
              reject: () => offerCreateApi(
                  context, document.docId!, "rejected", document.content),
              isEmailOrPhone: (document.content.toString().contains("@") ||
                      document.content.toString().contains(".com") ||
                      document.content.toString().contains(".gmail"))
                  ? Validation().emailValidation(context, document.content) ==
                          null ||
                      Validation().validateMobile(document.content)
                  : false)
          .padding(vertical: Sizes.s10);
    }
  }

  Future<void> setMessage(String content, MessageType? type, context,
      {bool isShowLoader = true}) async {
    if (content.trim().isNotEmpty) {
      try {
        if (isShowLoader) showLoading(context);
// Use existing chatId if available, otherwise fetch or generate
        if (chatId == null || chatId == "0") {
          await getChatIdAvailable(context);
          if (chatId == null || chatId == "0") {
            final s = int.parse(userModel!.id.toString());
            final r = int.parse(userId.toString());
            final low = s < r ? s : r;
            final high = s < r ? r : s;
            chatId = "${low}_$high";
          }
        }
        log("chatID::$chatId");
        log("content::$content");
        log("type::$type");
        log("userId::$userId");
        log("userModel::${userModel?.id} ${userModel?.name} ");
        log("name::$name");
        log("image::$image");
        log("token::$token");
        log("phone::$phone");
        log("code::${type!.name}");

        String time = DateTime.now().millisecondsSinceEpoch.toString();
        MessageModel messageModel = MessageModel(
          chatId: chatId,
          content: content,
          docId: time,
          messageType: "sender",
          receiverId: userId!.toString(),
          senderId: userModel!.id.toString(),
          timestamp: time,
          type: type.name,
          receiverImage: image,
          receiverName: name,
          senderImage: userModel!.media.isNotEmpty
              ? userModel!.media[0].originalUrl
              : null,
          senderName: userModel!.name,
          role: "user",
        );
        log("Sending notification to token: $token////${userModel!.name}");
        if (token != null && token!.isNotEmpty) {
          FirebaseApi().sendNotification(
              title: "${userModel!.name} sent you a message",
              msg: content,
              chatId: chatId,
              token: token,
              pId: userModel!.id.toString(),
              image: image ?? "",
              name: userModel!.name,
              phone: phone,
              code: code);
        }
        // Update localMessage
        bool isEmpty =
            localMessage.where((element) => element.time == "Today").isEmpty;
        if (isEmpty) {
          List<MessageModel> message = [messageModel];
          DateTimeChip dateTimeChip =
              DateTimeChip(time: getDate(time), message: message);
          localMessage.add(dateTimeChip);
        } else {
          int index =
              localMessage.indexWhere((element) => element.time == "Today");
          localMessage[index].message =
              localMessage[index].message!.reversed.toList();
          if (!localMessage[index].message!.contains(messageModel)) {
            localMessage[index].message!.add(messageModel);
          }
          localMessage[index].message =
              localMessage[index].message!.reversed.toList();
        }

        controller.text = "";
        notifyListeners();

        if (Validation().emailValidation(context, content) == null ||
            Validation().validateMobile(content) == null) {
          alertEmailPhone(context, content);
        }

// Save message to Firebase
        await FirebaseApi().saveMessageByOffer(
            role: "user",
            receiverName: name,
            type: type,
            dateTime: time,
            encrypted: content,
            isSeen: false,
            newChatId: chatId,
            pId: userId,
            receiverImage: image,
            senderId: userModel!.id);

        await FirebaseApi().saveMessageByOffer(
            role: "user",
            receiverName: name,
            type: type,
            dateTime: time,
            encrypted: content,
            isSeen: false,
            newChatId: chatId,
            pId: userId,
            receiverImage: image,
            senderId: userId.toString());

        await FirebaseApi().saveMessageInUserCollectionByOffer(
            senderId: userModel!.id,
            rToken: token,
            sToken: userModel!.fcmToken,
            receiverImage: image,
            newChatId: chatId,
            type: type,
            receiverName: name,
            content: content,
            receiverId: userId,
            id: userModel!.id,
            role: "user",
            isOffer: true);

        await FirebaseApi().saveMessageInUserCollectionByOffer(
            senderId: userModel!.id,
            receiverImage: image,
            newChatId: chatId,
            rToken: token,
            sToken: userModel!.fcmToken,
            type: type,
            receiverName: name,
            content: content,
            receiverId: userId,
            id: userId,
            role: "user",
            isOffer: true);

        await getChatData(context);
        if (isShowLoader) hideLoading(context);
        notifyListeners();
      } catch (e) {
        log("Error in setMessage: $e");
        if (isShowLoader) hideLoading(context);
        notifyListeners();
        snackBarMessengers(
          context,
          color: appColor(context).red,
          message: "Failed to send message: $e",
        );
      }
    }

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
    chat.onReady(context);
  }

  onClearChat(context, sync) {
    final value = Provider.of<DeleteDialogProvider>(context, listen: false);
    value.onDeleteDialog(sync, context, eImageAssets.clearChat,
        appFonts.clearChat, appFonts.areYouClearChat, () async {
      route.pop(context);
      await FirebaseApi().clearChat(context);
      value.onResetPass(context, language(context, appFonts.hurrayChatDelete),
          language(context, appFonts.okay), () => Navigator.pop(context));
    });
    value.notifyListeners();
  }

  alertEmailPhone(context, message) async {
    try {
      showLoading(context);
      var data = {
        "user_id": userModel!.id,
        "provider_id": userId,
        "message": message
      };
      await apiServices
          .postApi(api.sendMessage, data, isToken: true)
          .then((value) {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          log("SAVE");
        } else {
          snackBarMessengers(context,
              color: appColor(context).red, message: value.message);
        }
      });
    } catch (e) {
      log("EEEE alertEmailPhone : $e");
      hideLoading(context);
      notifyListeners();
    }
  }

// First, modify your getCustomerApi method to return the data
  Future<Map<String, dynamic>?> getCustomerApi(context,
      {id, docId, status, content, providerId}) async {
    try {
      var result = await apiServices.getApi(
          "${api.customOffer}?serviceId=$id&providerIds=$providerId", [],
          isToken: true);

      hideLoading(context);
      if (result.isSuccess! && result.data.isNotEmpty) {
        var firstData = result.data[0];
        statusUpdateInFirebase(
          context,
          docId,
          status,
          content,
          id,
          firstData['type'] ?? "",
        );
        notifyListeners();
        return firstData; // Return the data
      } else {
        log("No data found or API failed.");
        return null;
      }
    } catch (e) {
      log("Error in getCustomerApi: $e");
      hideLoading(context);
      notifyListeners();
      return null;
    }
  }

  // getCustomerApi(context, {id, docId, status, content, providerId}) async {
  //   try {
  //     await apiServices
  //         .getApi(
  //             "${api.customOffer}?serviceId=$id&providerIds=$providerId", [],
  //             isToken: true)
  //         .then((value) {
  //       hideLoading(context);
  //       if (value.isSuccess! && value.data.isNotEmpty) {
  //         var firstData = value.data[0];
  //         statusUpdateInFirebase(
  //           context,
  //           docId,
  //           status,
  //           content,
  //           firstData['service_id'] ?? "",
  //           firstData['type'] ?? "",
  //         );
  //         notifyListeners();
  //       } else {
  //         log("No data found or API failed.");
  //       }
  //     });
  //   } catch (e) {
  //     log(": $e");
  //     hideLoading(context);
  //     notifyListeners();
  //   }
  // }

  bool isLoaderforBooking = false;

  getService(context, {id, providerId}) async {
    log("IDDDD:$id///$providerId");
    isLoaderforBooking = true;
    notifyListeners();
    try {
      showLoading(context);
      await apiServices
          .getApi("${api.customService}/?service_id=$id", [], isToken: true)
          .then((value) {
        hideLoading(context);
        log("value.isSuccess::${value.isSuccess}");
        if (value.isSuccess!) {
          isLoaderforBooking = false;
          log("response:::${value.data}");
          services = Services.fromJson(value.data);
          onBook(context, services!,
                  addTap: () => onAdd(),
                  minusTap: () => onRemoveService(context))!
              .then((e) {
            notifyListeners();
          });
        } else {}
        isLoaderforBooking = false;
        notifyListeners();
      });
    } catch (e) {
      isLoaderforBooking = false;
      log("fuydsfgdsufgds:$e");
      hideLoading(context);
      notifyListeners();
    }
  }

  onRemoveService(context) async {
    if ((services!.selectedRequiredServiceMan!) == 1) {
      route.pop(context);
      isAlert = false;
      notifyListeners();
    } else {
      if ((services!.requiredServicemen!) ==
          (services!.selectedRequiredServiceMan!)) {
        isAlert = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);
        isAlert = false;
        notifyListeners();
      } else {
        isAlert = false;
        notifyListeners();
        services!.selectedRequiredServiceMan =
            ((services!.selectedRequiredServiceMan!) - 1);
      }
    }
    notifyListeners();
  }

  onAdd() {
    isAlert = false;
    notifyListeners();
    int count = (services!.selectedRequiredServiceMan!);
    count++;
    services!.selectedRequiredServiceMan = count;
    notifyListeners();
  }

  updateCustomOffer(context, {id, status}) async {
    try {
      notifyListeners();
      dynamic body = {'status': status};
      await apiServices
          .putApi("${api.customOffer}/$id", body, isToken: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          log("update Successfully :${value.isSuccess}");
        } else {
          snackBarMessengers(context,
              message: value.message, color: appColor(context).red);
        }
      });
    } catch (e) {
      log("EEEE :$e");
      hideLoading(context);
      notifyListeners();
    }
  }

  statusUpdateInFirebase(context, docId, status, content, service, type) async {
    try {
      dynamic data = content;
      data['status'] = status;
      data['service_id'] = service;
      data['type'] = type;

      var batch = FirebaseFirestore.instance.batch();
      batch.update(
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(userModel!.id.toString())
              .collection(collectionName.messages)
              .doc(chatId)
              .collection(collectionName.chat)
              .doc(docId),
          {"content": data});
      batch.update(
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(userId!.toString())
              .collection(collectionName.messages)
              .doc(chatId)
              .collection(collectionName.chat)
              .doc(docId),
          {"content": data});

      var userChats = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userModel!.id.toString())
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get();
      if (userChats.docs.isNotEmpty) {
        batch.update(userChats.docs[0].reference, {
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": "You $status the offer",
          "messageType": MessageType.offer.name
        });
      }

      var receiverChats = await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userId.toString())
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get();
      if (receiverChats.docs.isNotEmpty) {
        batch.update(receiverChats.docs[0].reference, {
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": "You $status the offer",
          "messageType": MessageType.text.name
        });
      }

      await batch.commit();
    } catch (e) {
      log("Error in statusUpdateInFirebase: $e");
    }
  }

  offerCreateApi(BuildContext context, docId, status, content) async {
    try {
      showLoading(context);
      var data = {
        "title": content['title'],
        "description": content['description'],
        "category_ids": [],
        "is_servicemen_required": content['is_servicemen_required'],
        "required_servicemen": content['required_servicemen'] ?? 1,
        "price": content['price'],
        "provider_id": content['provider_id'],
        "status": status,
        "service_id": content['service_id'],
        "started_at": content['started_at'],
        "ended_at": content['ended_at'],
        "user_id": content['user_id'],
        "duration": content['duration'],
        "duration_unit": content['duration_unit'],
      };

      List<dynamic> categoryIds = [];
      content.forEach((key, value) {
        if (key.startsWith("category_ids")) {
          categoryIds.add(value);
        }
      });
      data["category_ids"] = categoryIds;

      await apiServices
          .postApi(api.customOffer, data, isToken: true, isData: true)
          .then((value) async {
        hideLoading(context);
        notifyListeners();

        if (value.isSuccess!) {
          snackBarMessengers(
            context,
            color: appColor(context).green,
            message:
                "Offer successfully ${status == 'accepted' ? 'accepted' : 'rejected'}",
          );

          String newServiceId = value.data['service_id'].toString();

          log("CREATE: $newServiceId");

          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(userId!.toString())
              .collection(collectionName.chat)
              .doc(chatId)
              .update({"content.service_id": newServiceId});

          // Continue with customer API
          getCustomerApi(
            context,
            id: newServiceId,
            content: content,
            docId: docId,
            status: status,
            providerId: content['provider_id'],
          );
        } else {
          getCustomerApi(
            context,
            content: content,
            docId: docId,
            status: status,
          );
          snackBarMessengers(
            context,
            color: appColor(context).red,
            message:
                value.message.isNotEmpty ? value.message : "Offer Rejected",
          );
        }
      });
    } catch (e, s) {
      log("Error in createOffer: $e,$s");
      hideLoading(context);
      notifyListeners();
    }
  }

/*offerCreateApi(BuildContext context, docId, status, content) async {
    try {
      showLoading(context);
      var data = {
        "title": content['title'],
        "description": content['description'],
        "category_ids": [],
        "is_servicemen_required": content['is_servicemen_required'],
        "required_servicemen": content['required_servicemen'] ?? 1,
        "price": content['price'],
        "provider_id": content['provider_id'],
        "status": status,
        "service_id": content['service_id'],
        "started_at": content['started_at'],
        "ended_at": content['ended_at'],
        "user_id": content['user_id'],
        "duration": content['duration'],
        "duration_unit": content['duration_unit'],
      };

      List<dynamic> categoryIds = [];
      content.forEach((key, value) {
        if (key.startsWith("category_ids")) {
          categoryIds.add(value);
        }
      });
      data["category_ids"] = categoryIds;

      await apiServices
          .postApi(api.customOffer, data, isToken: true, isData: true)
          .then((value) {
        hideLoading(context);
        notifyListeners();
        if (value.isSuccess!) {
          snackBarMessengers(
            context,
            color: appColor(context).green,
            message:
            "Offer successfully ${status == 'accepted' ? 'accepted' : 'rejected'}",
          );

          log("CREATE: ${value.data['service_id']}");
          sharedPreferences.setString("service_id", value.data['service_id'].toString());
          getCustomerApi(context,

              id: value.data['id'],
              content: content,
              docId: docId,
              status: status,
              providerId: content['provider_id']);
        } else {
          getCustomerApi(
            context,
            content: content,
            docId: docId,
            status: status,
          );
          snackBarMessengers(
            context,
            color: appColor(context).red,
            message:
            value.message.isNotEmpty ? value.message : "Offer Rejected",
          );
        }
      });
    } catch (e,s) {
      log("Error in createOffer: $e,$s");
      hideLoading(context);
      notifyListeners();
    }
  }*/
}
// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../common_tap.dart';
// import '../../config.dart';
// import '../../firebase/firebase_api.dart';
// import '../../models/chat_model.dart';
// import '../../models/message_model.dart';
// import '../../screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';
// import '../../users_services.dart';
// import '../../widgets/alert_message_common.dart';
//
// class OfferChatProvider with ChangeNotifier {
//   final TextEditingController controller = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   final FocusNode chatFocus = FocusNode();
//   List<ChatModel> chatList = [];
//   String? chatId, image, name, role, token, code, phone;
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages = [];
//   List<DateTimeChip> localMessage = [];
//   int? userId;
//   StreamSubscription? messageSub;
//   XFile? imageFile;
//   Services? services;
//   bool isExpand = false;
//   onExpand(data) {
//     isExpand = !isExpand;
//     log("isExpand::$isExpand");
//     notifyListeners();
//   }
//
//   onReady(context) async {
//     try {
//       showLoading(context);
//       notifyListeners();
//
//       messageSub = null;
//       allMessages = [];
//       localMessage = [];
//
//       dynamic data = ModalRoute.of(context)!.settings.arguments ?? "";
//       if (data != "") {
//         userId = int.parse(data['userId'].toString());
//         name = data['name'];
//         image = data['image'];
//         role = data['role'];
//         token = data['token'];
//         phone = data['phone'].toString();
//         code = data['code']?.toString();
//         chatId = data['chatId']?.toString();
//       }
//       log("name;$name");
//       //bookingId = booking!.id;
//       await Future.wait([getChatData(context)]);
//       notifyListeners();
//
//       log("BOOKINGID :${userModel!.id}");
//       log("getCustomerApi::");
//       // getCustomerApi(context,id:userModel!.id);
//     } catch (e) {
//       log("EEEE onREADY CHAT : $e");
//     }
//   }
//
//   Future getChatIdAvailable(context) async {
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id.toString())
//         .collection(collectionName.chats)
//         .get()
//         .then(
//       (value) {
//         if (value.docs.isNotEmpty) {
//           for (var d in value.docs) {
//             if (d.data()['senderId'].toString() == userModel!.id.toString() &&
//                     d.data()['receiverId'].toString() == userId.toString() ||
//                 d.data()['receiverId'].toString() == userModel!.id.toString() &&
//                     d.data()['senderId'].toString() == userId.toString()) {
//               log("CHAT ID L:${d.data()['chatId']}");
//               if ((d.data()).containsKey('isOffer') &&
//                   d.data()['isOffer'] == true) {
//                 chatId = d.data()['chatId'];
//                 notifyListeners();
//                 getChatData(context);
//               }
//             }
//           }
//           notifyListeners();
//         }
//       },
//     );
//   }
//
//   onBack(context, isBack) {
//     hideLoading(context);
//     allMessages = [];
//     localMessage = [];
//     messageSub = null;
//     chatId = null;
//     image = null;
//     name = null;
//     role = null;
//     token = null;
//     code = null;
//     phone = null;
//     notifyListeners();
//     if (isBack) {
//       route.pop(context);
//     }
//   }
//
//   showLayout(context) async {
//     showModalBottomSheet(
//         context: context,
//         builder: (context1) {
//           return Column(mainAxisSize: MainAxisSize.min, children: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Text(language(context, appFonts.selectOne),
//                   style: appCss.dmDenseBold18
//                       .textColor(appColor(context).darkText)),
//               const Icon(CupertinoIcons.multiply)
//                   .inkWell(onTap: () => route.pop(context))
//             ]),
//             const VSpace(Sizes.s20),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               const Icon(
//                 Icons.image,
//                 size: Sizes.s24,
//                 weight: Sizes.s24,
//               )
//                   .padding(all: Sizes.s20)
//                   .decorated(
//                       color: appColor(context).primary, shape: BoxShape.circle)
//                   .inkWell(onTap: () {
//                 route.pop(context);
//                 showModalBottomSheet(
//                     context: context,
//                     builder: (context1) {
//                       return Column(mainAxisSize: MainAxisSize.min, children: [
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(language(context, appFonts.selectOne),
//                                   style: appCss.dmDenseBold18
//                                       .textColor(appColor(context).darkText)),
//                               const Icon(CupertinoIcons.multiply)
//                                   .inkWell(onTap: () => route.pop(context))
//                             ]),
//                         const VSpace(Sizes.s20),
//                         ...appArray.selectList
//                             .asMap()
//                             .entries
//                             .map((e) => SelectOptionLayout(
//                                 data: e.value,
//                                 index: e.key,
//                                 list: appArray.selectList,
//                                 onTap: () {
//                                   log("dsf :${e.key}");
//                                   if (e.key == 0) {
//                                     pickAndUploadFile(
//                                         context, ImageSource.gallery);
//                                   } else {
//                                     pickAndUploadFile(
//                                         context, ImageSource.camera);
//                                   }
//                                 }))
//                       ]).padding(all: Sizes.s20);
//                     }).then((value) => route.pop(context));
//               }),
//               // HSpace(Sizes.s20),
//               const Icon(Icons.video_camera_back_outlined)
//                   .padding(all: Sizes.s20)
//                   .decorated(
//                       color: appColor(context).primary, shape: BoxShape.circle)
//                   .inkWell(
//                 onTap: () {
//                   route.pop(context);
//                   showModalBottomSheet(
//                       context: context,
//                       builder: (context1) {
//                         return Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(language(context, appFonts.selectOne),
//                                         style: appCss.dmDenseBold18.textColor(
//                                             appColor(context).darkText)),
//                                     const Icon(CupertinoIcons.multiply).inkWell(
//                                         onTap: () => route.pop(context))
//                                   ]),
//                               const VSpace(Sizes.s20),
//                               ...appArray.selectList
//                                   .asMap()
//                                   .entries
//                                   .map((e) => SelectOptionLayout(
//                                       data: e.value,
//                                       index: e.key,
//                                       list: appArray.selectList,
//                                       onTap: () {
//                                         log("dsf :${e.key}");
//                                         if (e.key == 0) {
//                                           pickAndUploadFile(
//                                               context, ImageSource.gallery,
//                                               isVideo: true);
//                                         } else {
//                                           pickAndUploadFile(
//                                               context, ImageSource.camera,
//                                               isVideo: true);
//                                         }
//                                       }))
//                             ]).padding(all: Sizes.s20);
//                       }).then((value) => route.pop(context));
//                 },
//               )
//             ]).padding(horizontal: Sizes.s40, vertical: Sizes.s20)
//           ]).padding(all: Sizes.s20);
//         });
//   }
//
//   // Function to pick and upload files (images or videos)
//   Future pickAndUploadFile(BuildContext context, ImageSource source,
//       {bool isVideo = false}) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       XFile? pickedFile;
//
//       // Pick image or video based on the flag
//       if (isVideo) {
//         pickedFile = await picker.pickVideo(
//             source: source, maxDuration: const Duration(minutes: 2));
//       } else {
//         pickedFile = await picker.pickImage(source: source, imageQuality: 70);
//       }
//
//       if (pickedFile != null) {
//         log("Picked file path: ${pickedFile.path}");
//
//         // Notify listeners (if required in your state management)
//         notifyListeners();
//
//         // Upload the file
//         await uploadFile(context, pickedFile,
//             isVideo: pickedFile.name.contains(".mp4") ? true : false);
//
//         // Close the current context (if needed)
//         route.pop(context);
//       } else {
//         log("No file selected.");
//       }
//     } catch (e) {
//       log("Error picking file: $e");
//       snackBarMessengers(
//         context,
//         color: appColor(context).red,
//         message: "Error picking file: $e",
//       );
//     }
//   }
//
// // UPLOAD SELECTED IMAGE TO FIREBASE
//   Future uploadFile(BuildContext context, XFile file,
//       {bool isVideo = false}) async {
//     try {
//       showLoading(context);
//       notifyListeners();
//       FocusScope.of(context).requestFocus(FocusNode());
//
//       // Generate unique filename with appropriate extension
//       // String fileExtension = isVideo ? ".mp4" : ".jpg"; // Adjust as needed
//
//       String fileName = "${DateTime.now().millisecondsSinceEpoch}${file.name}";
//
//       // Get reference to Firebase Storage
//       Reference reference = FirebaseStorage.instance.ref().child(fileName);
//
//       // Convert XFile to File for upload
//       File localFile = File(file.path);
//
//       // Upload the file
//       UploadTask uploadTask = reference.putFile(localFile);
//
//       // Wait for upload completion
//       TaskSnapshot snapshot = await uploadTask;
//
//       // Get download URL
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       log("File uploaded successfully: $downloadUrl");
//
//       // Handle success (e.g., update UI or send data to server)
//       setMessage(downloadUrl, isVideo ? MessageType.video : MessageType.image,
//           context);
//
//       imageFile = null;
//       notifyListeners();
//       hideLoading(context);
//     } catch (e) {
//       log("Error uploading file: $e");
//       hideLoading(context);
//       notifyListeners();
//
//       snackBarMessengers(
//         context,
//         color: appColor(context).red,
//         message: "Failed to upload file: $e",
//       );
//     }
//   }
//
//   Future<void> makePhoneCall(Uri url) async {
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   onTapPhone(context) async {
//     log("CODE :$code $phone");
//     launchCall(context, phone);
//     notifyListeners();
//   }
//
//   Future getChatData(context) async {
//     log("chatIdsd :$chatId ///$userId // ${userModel!.id}");
//
//     if (chatId != null && chatId != "0") {
//       messageSub = FirebaseFirestore.instance
//           .collection(collectionName.users)
//           .doc(userModel!.id.toString())
//           .collection(collectionName.messages)
//           .doc(chatId)
//           .collection(collectionName.chat)
//           .snapshots()
//           .listen((event) async {
//         allMessages = event.docs;
//         notifyListeners();
//
//         FirebaseApi().getLocalMessageOffer(context);
//         // log("allMessages :$allMessages");
//         notifyListeners();
//         seenMessage();
//       });
//       hideLoading(context);
//       notifyListeners();
//     } else {
//       log("CHEC");
//       getChatIdAvailable(context);
//       hideLoading(context);
//       notifyListeners();
//     }
//
//     notifyListeners();
//   }
//
//   //seen all message
//   seenMessage() async {
//     log("chatId.toString():${chatId.toString()}");
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id.toString())
//         .collection(collectionName.messages)
//         .doc(chatId.toString())
//         .collection(collectionName.chat)
//         .where("receiverId", isEqualTo: userModel!.id.toString())
//         .get()
//         .then((value) {
//       log("RECEIVER : ${value.docs.length}");
//       value.docs.asMap().entries.forEach((element) async {
//         await FirebaseFirestore.instance
//             .collection(collectionName.users)
//             .doc(userModel!.id.toString())
//             .collection(collectionName.messages)
//             .doc(chatId.toString())
//             .collection(collectionName.chat)
//             .doc(element.value.id)
//             .update({"isSeen": true});
//       });
//     });
//
//     log("userModel!.id.toString() :${userModel!.id.toString()} ||$userId");
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id.toString())
//         .collection(collectionName.chats)
//         .where("chatId", isEqualTo: chatId)
//         .get()
//         .then((value) async {
//       if (value.docs.isNotEmpty) {
//         await FirebaseFirestore.instance
//             .collection(collectionName.users)
//             .doc(userModel!.id.toString())
//             .collection(collectionName.chats)
//             .doc(value.docs[0].id)
//             .update({"isSeen": true});
//       }
//     });
//
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id.toString())
//         .collection(collectionName.messages)
//         .doc(chatId.toString())
//         .collection(collectionName.chat)
//         .where("receiverId", isEqualTo: userModel!.id.toString())
//         .get()
//         .then((value) {
//       log("RECEIVER : ${value.docs.length}");
//       value.docs.asMap().entries.forEach((element) async {
//         await FirebaseFirestore.instance
//             .collection(collectionName.users)
//             .doc(userModel!.id.toString())
//             .collection(collectionName.messages)
//             .doc(chatId.toString())
//             .collection(collectionName.chat)
//             .doc(element.value.id)
//             .update({"isSeen": true});
//       });
//     });
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userId.toString())
//         .collection(collectionName.chats)
//         .where("bookingId", isEqualTo: chatId)
//         .get()
//         .then((value) async {
//       if (value.docs.isNotEmpty) {
//         await FirebaseFirestore.instance
//             .collection(collectionName.users)
//             .doc(userId.toString())
//             .collection(collectionName.chats)
//             .doc(value.docs[0].id)
//             .update({"isSeen": true});
//       }
//     });
//   }
//
//   Widget timeLayout(context) {
//     return Column(
//         children: localMessage.reversed.toList().asMap().entries.map((a) {
//       List<MessageModel> newMessageList = a.value.message!.toList();
//       // log("localMessage::${newMessageList}");
//       return Column(children: [
//         Text(
//                 a.value.time!.contains("-other")
//                     ? a.value.time!.split("-other")[0]
//                     : a.value.time!,
//                 style: appCss.dmDenseMedium14
//                     .textColor(appColor(context).lightText))
//             .marginSymmetric(vertical: Insets.i5),
//         ...newMessageList.reversed.toList().asMap().entries.map((e) {
//           log("newMessageList::${e.value.docId}");
//           return buildItem(
//               e.key,
//               e.value,
//               e.value.docId,
//               a.value.time!.contains("-other")
//                   ? a.value.time!.split("-other")[0]
//                   : a.value.time!,
//               context);
//         })
//       ]);
//     }).toList());
//   }
//
// // BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
//   Widget buildItem(
//       int index, MessageModel document, documentId, title, context) {
//     if (document.senderId.toString() == userModel!.id.toString()) {
//       return ChatLayout(
//               document: document,
//               isSentByMe: true,
//               isEmailOrPhone:
//                   Validation().emailValidation(context, document.content) ==
//                           null ||
//                       Validation().validateMobile(document.content))
//           .padding(vertical: Sizes.s10);
//     } else {
//       // RECEIVER MESSAGE
//       log("document:::${document.content}");
//       return ChatLayout(
//               document: document,
//               isSentByMe: false,
//               pay: () {
//                 log("fedifndsnfkdnsk");
//                 log("document.content['provider_id']::${document.content['service_id']}");
//                 getService(context,
//                     providerId: document.content['provider_id'],
//                     id: document.content['service_id']);
//               },
//               accept: () => offerCreateApi(
//                   context, document.docId!, "accepted", document.content),
//               reject: () => offerCreateApi(
//                   context, document.docId!, "rejected", document.content),
//               isEmailOrPhone: (document.content.toString().contains("@") ||
//                       document.content.toString().contains(".com") ||
//                       document.content.toString().contains(".gmail"))
//                   ? Validation().emailValidation(context, document.content) ==
//                           null ||
//                       Validation().validateMobile(document.content)
//                   : false)
//           .padding(vertical: Sizes.s10);
//     }
//   }
//
//   // SEND MESSAGE CLICK
//   void setMessage(String content, MessageType? type, context) async {
//     if (content.trim() != '') {
//       // Use the existing chatId if available, otherwise generate a new one
//       chatId = chatId ?? DateTime.now().microsecondsSinceEpoch.toString();
//       notifyListeners();
//
//       String time = DateTime.now().millisecondsSinceEpoch.toString();
//
//       // Create the message model
//       MessageModel messageModel = MessageModel(
//         chatId: chatId,
//         content: content,
//         docId: time,
//         messageType: "sender",
//         receiverId: userId!.toString(),
//         senderId: userModel!.id!.toString(),
//         timestamp: time,
//         type: type!.name,
//         receiverImage: image,
//         receiverName: name,
//         senderImage: userModel!.media != null && userModel!.media!.isNotEmpty
//             ? userModel!.media![0].originalUrl!
//             : null,
//         senderName: userModel!.name,
//         role: "user",
//       );
//
//       controller.text = "";
//
//       // Check if there are messages for today in the local messages
//       bool isEmpty =
//           localMessage.where((element) => element.time == "Today").isEmpty;
//
//       if (isEmpty) {
//         List<MessageModel> message = [messageModel];
//         DateTimeChip dateTimeChip =
//             DateTimeChip(time: getDate(time), message: message);
//         localMessage.add(dateTimeChip);
//       } else {
//         int index =
//             localMessage.indexWhere((element) => element.time == "Today");
//
//         if (!localMessage[index].message!.contains(messageModel)) {
//           localMessage[index].message!.add(messageModel);
//         }
//       }
//
//       // Validate email and phone content
//       if (Validation().emailValidation(context, content) == null) {
//         log("CHECK");
//         alertEmailPhone(context, content);
//       }
//       if (Validation().validateMobile(content) == null) {
//         alertEmailPhone(context, content);
//         log("CHECK1");
//       }
//
//       String date = DateTime.now().millisecondsSinceEpoch.toString();
//       notifyListeners();
//
//       // Save the message to Firebase
//       await FirebaseApi()
//           .saveMessageByOffer(
//               role: "user",
//               receiverName: name,
//               type: type,
//               dateTime: date,
//               encrypted: content,
//               isSeen: false,
//               newChatId: chatId,
//               pId: userId,
//               receiverImage: image,
//               senderId: userModel!.id)
//           .then((value) async {
//         await FirebaseApi()
//             .saveMessageByOffer(
//                 role: "user",
//                 receiverName: name,
//                 type: type,
//                 dateTime: date,
//                 encrypted: content,
//                 isSeen: false,
//                 newChatId: chatId,
//                 pId: userId,
//                 receiverImage: image,
//                 senderId: userId.toString())
//             .then((snap) async {
//           await FirebaseApi().saveMessageInUserCollectionByOffer(
//               senderId: userModel!.id,
//               rToken: token,
//               sToken: userModel!.fcmToken,
//               receiverImage: image,
//               newChatId: chatId,
//               type: type,
//               receiverName: name,
//               content: content,
//               receiverId: userId,
//               id: userModel!.id,
//               role: "user",
//               isOffer: true);
//           await FirebaseApi().saveMessageInUserCollectionByOffer(
//               senderId: userModel!.id,
//               receiverImage: image,
//               newChatId: chatId,
//               rToken: token,
//               sToken: userModel!.fcmToken,
//               type: type,
//               receiverName: name,
//               content: content,
//               receiverId: userId,
//               id: userId,
//               role: "user",
//               isOffer: true);
//         });
//       }).then((value) async {
//         notifyListeners();
//         getChatData(context);
//         log("userModel!.name${userModel!.id}");
//         if (token != "" && token != null) {
//           FirebaseApi().sendNotification(
//               title: "${userModel!.name} send you message",
//               msg: content,
//               chatId: chatId,
//               token: token,
//               pId: userModel!.id,
//               image: image ?? "",
//               name: userModel!.name,
//               phone: phone,
//               code: code);
//         }
//       });
//     }
//
//     final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
//     chat.onReady(context);
//   }
//
// /*  void setMessage(String content, MessageType? type, context) async {
//     // isLoading = true;
//     if (content.trim() != '') {
//       final now = DateTime.now();
//       String newChatId = now.microsecondsSinceEpoch.toString();
//       chatId = newChatId;
//       notifyListeners();
//       String time = DateTime.now().millisecondsSinceEpoch.toString();
//       MessageModel messageModel = MessageModel(
//         chatId: newChatId,
//         content: content,
//         docId: time,
//         messageType: "sender",
//         receiverId: userId!.toString(),
//         senderId: userModel!.id!.toString(),
//         timestamp: time,
//         type: type!.name,
//         receiverImage: image,
//         receiverName: name,
//         senderImage: userModel!.media != null && userModel!.media!.isNotEmpty
//             ? userModel!.media![0].originalUrl!
//             : null,
//         senderName: userModel!.name,
//         role: "user",
//       );
//       controller.text = "";
//       bool isEmpty =
//           localMessage.where((element) => element.time == "Today").isEmpty;
//       if (isEmpty) {
//         List<MessageModel>? message = [];
//         if (message.isNotEmpty) {
//           message.add(messageModel);
//           message[0].docId = time;
//         } else {
//           message = [messageModel];
//           message[0].docId = time;
//         }
//         DateTimeChip dateTimeChip =
//             DateTimeChip(time: getDate(time), message: message);
//         localMessage.add(dateTimeChip);
//       } else {
//         int index =
//             localMessage.indexWhere((element) => element.time == "Today");
//
//         if (!localMessage[index].message!.contains(messageModel)) {
//           localMessage[index].message!.add(messageModel);
//         }
//       }
//       if (Validation().emailValidation(context, content) == null) {
//         log("CHECK");
//         alertEmailPhone(context, content);
//       }
//       if (Validation().validateMobile(content) == null) {
//         alertEmailPhone(context, content);
//         log("CHECK1");
//       }
//       String date = DateTime.now().millisecondsSinceEpoch.toString();
//       notifyListeners();
//       await FirebaseApi()
//           .saveMessageByOffer(
//               role: "user",
//               receiverName: name,
//               type: type,
//               dateTime: date,
//               encrypted: content,
//               isSeen: false,
//               newChatId: newChatId,
//               pId: userId,
//               receiverImage: image,
//               senderId: userModel!.id)
//           .then((value) async {
//         await FirebaseApi()
//             .saveMessageByOffer(
//                 role: "user",
//                 receiverName: name,
//                 type: type,
//                 dateTime: date,
//                 encrypted: content,
//                 isSeen: false,
//                 newChatId: newChatId,
//                 pId: userId,
//                 receiverImage: image,
//                 senderId: userId.toString())
//             .then((snap) async {
//           await FirebaseApi().saveMessageInUserCollectionByOffer(
//               senderId: userModel!.id,
//               rToken: token,
//               sToken: userModel!.fcmToken,
//               receiverImage: image,
//               newChatId: newChatId,
//               type: type,
//               receiverName: name,
//               content: content,
//               receiverId: userId,
//               id: userModel!.id,
//               role: "user",
//               isOffer: true);
//           await FirebaseApi().saveMessageInUserCollectionByOffer(
//               senderId: userModel!.id,
//               receiverImage: image,
//               newChatId: newChatId,
//               rToken: token,
//               sToken: userModel!.fcmToken,
//               type: type,
//               receiverName: name,
//               content: content,
//               receiverId: userId,
//               id: userId,
//               role: "user",
//               isOffer: true);
//         });
//       }).then((value) async {
//         notifyListeners();
//         getChatData(context);
//         log("userModel!.name${userModel!.id}");
//         if (token != "" && token != null) {
//           FirebaseApi().sendNotification(
//               title: "${userModel!.name} send you message",
//               msg: content,
//               chatId: newChatId,
//               token: token,
//               pId: userModel!.id,
//               image: image ?? "",
//               name: userModel!.name,
//               phone: phone,
//               code: code);
//         }
//       });
//     }
//     final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
//     chat.onReady(context);
//   }*/
//
//   onClearChat(context, sync) {
//     final value = Provider.of<DeleteDialogProvider>(context, listen: false);
//
//     value.onDeleteDialog(sync, context, eImageAssets.clearChat,
//         appFonts.clearChat, appFonts.areYouClearChat, () async {
//       route.pop(context);
//       await FirebaseApi().clearChat(context);
//       value.onResetPass(context, language(context, appFonts.hurrayChatDelete),
//           language(context, appFonts.okay), () => Navigator.pop(context));
//     });
//     value.notifyListeners();
//   }
//
//   alertEmailPhone(context, message) async {
//     try {
//       showLoading(context);
//       var data = {
//         "user_id": userModel!.id,
//         "provider_id": userId,
//         "message": message
//       };
//       log("data :$data");
//       await apiServices
//           .postApi(api.sendMessage, data, isToken: true)
//           .then((value) {
//         log("ZOOOO :${value.data}");
//         hideLoading(context);
//
//         notifyListeners();
//         if (value.isSuccess!) {
//           log("SAVE");
//         } else {
//           snackBarMessengers(context,
//               color: appColor(context).red, message: value.message);
//         }
//       });
//     } catch (e) {
//       hideLoading(context);
//       notifyListeners();
//       log("EEEE alertEmailPhone : $e");
//     }
//   }
//
//   getCustomerApi(context, {id, docId, status, content, providerId}) async {
//     try {
//       await apiServices
//           .getApi(
//               "${api.customOffer}?serviceId=$id&providerIds=$providerId", [],
//               isToken: true)
//           .then((value) {
//         hideLoading(context);
//         log("value :${value.data.isNotEmpty ? value.data[0] : 'Empty Data'}");
//         if (value.isSuccess! && value.data.isNotEmpty) {
//           var firstData = value.data[0];
//           statusUpdateInFirebase(
//             context,
//             docId,
//             status,
//             content,
//             firstData['service_id'] ?? "",
//             firstData['type'] ?? "",
//           );
//           debugPrint("BOOKING DATA : ${value.data}");
//           notifyListeners();
//         } else {
//           log("No data found or API failed.");
//         }
//       });
//     } catch (e) {
//       log(": $e");
//       hideLoading(context);
//       notifyListeners();
//     }
//   }
//
//   bool isLoaderforBooking = false;
//   getService(context, {id, providerId}) async {
//     isLoaderforBooking = true;
//     notifyListeners();
//     log("id::::$id");
//     try {
//       showLoading(context);
//       await apiServices
//           .getApi("${api.service}?service_id=$id&providerIds=$providerId", [],
//               isToken: true)
//           .then((value) {
//         hideLoading(context);
//         log("value :${value.data[0]}");
//         if (value.isSuccess!) {
//           isLoaderforBooking = false;
//           services = Services.fromJson(value.data[0]);
//           onBook(context, services!,
//                   // provider: provider,
//                   addTap: () => onAdd(),
//                   minusTap: () => onRemoveService(context))!
//               .then((e) {
//             notifyListeners();
//           });
//         }
//         isLoaderforBooking = false;
//         notifyListeners();
//       });
//     } catch (e) {
//       isLoaderforBooking = false;
//       log("fuydsfgdsufgds:$e");
//       hideLoading(context);
//       notifyListeners();
//     }
//   }
//
//   onRemoveService(context) async {
//     if ((services!.selectedRequiredServiceMan!) == 1) {
//       route.pop(context);
//       isAlert = false;
//       notifyListeners();
//     } else {
//       if ((services!.requiredServicemen!) ==
//           (services!.selectedRequiredServiceMan!)) {
//         isAlert = true;
//         notifyListeners();
//         await Future.delayed(DurationClass.s3);
//         isAlert = false;
//         notifyListeners();
//       } else {
//         isAlert = false;
//         notifyListeners();
//         services!.selectedRequiredServiceMan =
//             ((services!.selectedRequiredServiceMan!) - 1);
//       }
//     }
//     notifyListeners();
//   }
//
//   onAdd() {
//     isAlert = false;
//     notifyListeners();
//     int count = (services!.selectedRequiredServiceMan!);
//     count++;
//     services!.selectedRequiredServiceMan = count;
//
//     notifyListeners();
//   }
//
//   updateCustomOffer(context, {id, status}) async {
//     try {
//       notifyListeners();
//       dynamic body = {'status': status};
//       log("body:::${body}");
//       await apiServices
//           .putApi("${api.customOffer}/$id", body, isToken: true)
//           .then((value) async {
//         hideLoading(context);
//         notifyListeners();
//         if (value.isSuccess!) {
//           log("update Successfully :${value.isSuccess}");
//         } else {
//           log("value.message :${value.message}");
//           snackBarMessengers(context,
//               message: value.message, color: appColor(context).red);
//         }
//       });
//     } catch (e) {
//       log("EEEE :$e");
//       hideLoading(context);
//       notifyListeners();
//     }
//   }
//
//   statusUpdateInFirebase(context, docId, status, content, service, type) async {
//     log("docId:${content['service_id']}");
//     dynamic data = content;
//     data['status'] = status;
//     data['service_id'] = service;
//     data['type'] = type;
//
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id!.toString())
//         .collection(collectionName.messages)
//         .doc(chatId)
//         .collection(collectionName.chat)
//         .doc(docId)
//         .update({"content": data});
//
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userId!.toString())
//         .collection(collectionName.messages)
//         .doc(chatId)
//         .collection(collectionName.chat)
//         .doc(docId)
//         .update({"content": data});
//
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userModel!.id!.toString())
//         .collection(collectionName.chats)
//         .where("chatId", isEqualTo: chatId)
//         .get()
//         .then(
//       (value) {
//         if (value.docs.isNotEmpty) {
//           FirebaseFirestore.instance
//               .collection(collectionName.users)
//               .doc(userModel!.id!.toString())
//               .collection(collectionName.chats)
//               .doc(value.docs[0].id)
//               .update({
//             "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
//             "lastMessage": "You $status the offer",
//             "messageType": MessageType.offer.name
//           });
//         }
//       },
//     );
//
//     await FirebaseFirestore.instance
//         .collection(collectionName.users)
//         .doc(userId.toString())
//         .collection(collectionName.chats)
//         .where("chatId", isEqualTo: chatId)
//         .get()
//         .then(
//       (value) {
//         if (value.docs.isNotEmpty) {
//           FirebaseFirestore.instance
//               .collection(collectionName.users)
//               .doc(userModel!.id!.toString())
//               .collection(collectionName.chats)
//               .doc(value.docs[0].id)
//               .update({
//             "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
//             "lastMessage": "You $status the offer",
//             "messageType": MessageType.text.name
//           });
//         }
//       },
//     );
//   }
//
//   offerCreateApi(BuildContext context, docId, status, content) async {
//     try {
//       showLoading(context);
//       log("content::${status}");
//
//       var data = {
//         "title": content['title'], // Trim to remove extra spaces
//         "description": content['description'],
//         "category_ids": [], // Static category IDs for now
//         "is_servicemen_required": content['is_servicemen_required'],
//         "required_servicemen": content['required_servicemen'] ?? 1,
//         "price": content['price'], // Parse price safely
//         "provider_id": content['provider_id'], // Static provider ID
//         "status": status,
//         "service_id": content['service_id'],
//         "started_at": content['started_at'],
//         "ended_at": content['ended_at'],
//         "user_id": content['user_id'],
//         "duration": content['duration'],
//         "duration_unit": content['duration_unit'],
//       };
//
//       log("data::$data");
//
//       // Merge category_ids into a single array
//       List<dynamic> categoryIds = [];
//       content.forEach((key, value) {
//         if (key.startsWith("category_ids")) {
//           categoryIds.add(value);
//         }
//       });
//
// // Assign the merged array to category_ids in the data map
//       data["category_ids"] = categoryIds;
//
//       log("Final Data: $data");
//
//       log("dataPost : $data");
//
//       // Make API request
//       await apiServices
//           .postApi(api.customOffer, data, isToken: true, isData: true)
//           .then((value) {
//         log("message");
//         log("Response : ${value.data}// ${value.message}");
//         hideLoading(context);
//         notifyListeners();
//         if (value.isSuccess!) {
//           log("Offer created successfully");
//           log("status: status::$status ");
//           snackBarMessengers(
//             context,
//             color: appColor(context).green,
//             message:
//                 "Offer successfully ${status == 'accepted' ? 'accepted' : 'rejected'}",
//           );
//
//           getCustomerApi(context,
//               id: value.data['id'],
//               content: content,
//               docId: docId,
//               status: status,
//               providerId: content['provider_id']);
//         } else {
//           log("status: status::${status} : status");
//
//           getCustomerApi(
//             context,
//             content: content,
//             docId: docId,
//             status: status,
//           );
//           // Log response details for debugging
//           log("API Error: ${value.message}");
//           log("Status Code: ${value.isSuccess}");
//           log("Full Response: ${value.data}");
//
//           // Notify the user of the error
//           snackBarMessengers(
//             context,
//             color: appColor(context).red,
//             message:
//                 value.message.isNotEmpty ? value.message : "Offer Rejected",
//             // snackBarMessengers(
//             //   context,
//             //   color: appColor(context).red,
//             //   message: value.message.isNotEmpty
//             //       ? value.message
//             //       : "Failed to process the offer",
//           );
//         }
//       });
//     } catch (e) {
//       hideLoading(context);
//       notifyListeners();
//       log("Error in createOffer: $e");
//     }
//   }
// }
