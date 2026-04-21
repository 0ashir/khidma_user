import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixit_user/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../screens/app_pages_screens/profile_detail_screen/layouts/selection_option_layout.dart';
import '../../screens/app_pages_screens/chat_with_staff_screen/layouts/staff_chat_layout.dart';

class ChatWithStaffProvider with ChangeNotifier {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? chatId;
  StreamSubscription? messageSub;
  List message = [];
  bool isLoading = false;
  XFile? imageFile;

  // Initialize chat with Admin (ID 1)
  onReady(context) async {
    try {
      isLoading = true;
      showLoading(context);
      notifyListeners();

      // Chat ID format: smallerId_largerId
      int? currentUserId = userModel!.id;
      int adminId = 1;

      if (currentUserId < adminId) {
        chatId = "${currentUserId}_$adminId";
      } else {
        chatId = "${adminId}_$currentUserId";
      }

      log("Support Chat ID: $chatId");

      await getChatData(context);
    } catch (e) {
      log("Error in ChatWithStaffProvider onReady: $e");
    } finally {
      isLoading = false;
      hideLoading(context);
      notifyListeners();
    }
  }

  // Get Chat Data
  getChatData(context) async {
    log("getChatData called for $chatId");
    messageSub = FirebaseFirestore.instance
        .collection(collectionName.supportChats)
        .doc(chatId)
        .collection(collectionName.messages)
        .orderBy("timestamp",
            descending: false) // Ascending for Column in Reverse Scroll logic
        .snapshots()
        .listen((event) async {
      message = [];
      log("Received ${event.docs.length} messages");
      for (var element in event.docs) {
        message.add(element.data());
            }

      message.sort((a, b) {
        var t1 = a['timestamp'];
        var t2 = b['timestamp'];
        int time1 = 0;
        int time2 = 0;

        if (t1 is Timestamp) {
          time1 = t1.millisecondsSinceEpoch;
        } else if (t1 is String) {
          time1 = int.tryParse(t1) ?? 0;
        }

        if (t2 is Timestamp) {
          time2 = t2.millisecondsSinceEpoch;
        } else if (t2 is String) {
          time2 = int.tryParse(t2) ?? 0;
        }
        return time1.compareTo(time2);
      });
      notifyListeners();
    });
  }

  // Set Message
  Future<void> setMessage(String message, MessageType type, context,
      {bool isShowLoader = true}) async {
    if (message.isEmpty && type == MessageType.text) {
      return;
    }

    if (isShowLoader && type != MessageType.text) {
      showLoading(context);
    }

    String dateTime = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Save Message to Subcollection
    var messageData = {
      "senderId": userModel!.id.toString(),
      "senderName": userModel!.name,
      "receiverId": "1", // Admin ID
      "receiverName": "Admin",
      "timestamp": FieldValue.serverTimestamp(),
      "isRead": false,
    };

    if (type == MessageType.text) {
      messageData["message"] = message;
    } else {
      messageData["images"] = [message];
    }

    controller.clear();
    notifyListeners();

    log("Attempting to send message to $chatId");
    try {
      await FirebaseFirestore.instance
          .collection(collectionName.supportChats)
          .doc(chatId)
          .collection(collectionName.messages)
          .doc() // Auto-generated ID
          .set(messageData, SetOptions(merge: true));

      log("Message subcollection updated");

      // 2. Update Chat Document
      var chatData = {
        "senderId": userModel!.id.toString(),
        "senderName": userModel!.name,
        "receiverId": "1",
        "receiverName": "Admin",
        "participants": [userModel!.id.toString(), "1"],
        "lastMessageTime": dateTime,
        "unreadCount": {
          "1": FieldValue.increment(1),
        },
        "LastMessage": {
          "message": type == MessageType.text ? message : "Image",
          "timestamp": FieldValue.serverTimestamp(),
          "senderId": userModel!.id.toString(),
          "senderName": userModel!.name,
          "receiverId": "1",
          "receiverName": "Admin",
        }
      };

      await FirebaseFirestore.instance
          .collection(collectionName.supportChats)
          .doc(chatId)
          .set(chatData, SetOptions(merge: true));

      log("Chat document updated");

      if (isShowLoader && type != MessageType.text) {
        hideLoading(context);
      }
    } catch (e) {
      if (isShowLoader && type != MessageType.text) {
        hideLoading(context);
      }
      log("Error sending support message: $e");
    }
  }

  // Image Picker Logic (Copied from previous similar implementations)
  Future<void> onImagePick(context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageFile = image;
      notifyListeners();
      await uploadFile(context);
    }
  }

  Future<void> onCameraPick(context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      imageFile = image;
      notifyListeners();
      await uploadFile(context);
    }
  }

  Future<void> uploadFile(context) async {
    try {
      if (imageFile != null) {
        showLoading(context);
        isLoading = true;
        notifyListeners();
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        var ref =
            FirebaseStorage.instance.ref().child("support_chat/$fileName");

        var uploadTask = await ref.putFile(File(imageFile!.path));
        var imageUrl = await uploadTask.ref.getDownloadURL();

        await setMessage(imageUrl, MessageType.image, context,
            isShowLoader: false);
        imageFile = null;
      }
    } catch (e) {
      log("Upload Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
      hideLoading(context);
    }
  }

  void showLayout(context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(Insets.i20),
          decoration: BoxDecoration(
            color: appColor(context).whiteBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.r20),
              topRight: Radius.circular(AppRadius.r20),
            ),
          ),
          child: Column(
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
                          route.pop(context);
                          onImagePick(context);
                        } else if (e.key == 1) {
                          route.pop(context);
                          onCameraPick(context);
                        }
                      })),
            ],
          ),
        );
      },
    );
  }

  // Back navigation
  onBack(context, isBack) {
    route.pop(context);
  }

  // Time Layout (Chat Bubbles)
  Widget timeLayout(context) {
    return Column(
      children: message.map((data) {
        bool isMe = data['senderId'] == userModel!.id.toString();
        Map<String, dynamic> msgData = data as Map<String, dynamic>;
        return StaffChatLayout(data: msgData, isMe: isMe);
      }).toList(),
    );
  }
}
