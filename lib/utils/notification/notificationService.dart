import 'package:e_demand/app/generalImports.dart';
import 'dart:developer' as developer;

import 'package:e_demand/cubits/fetchBookingDetailsCubit.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessageHandler(final RemoteMessage message) async {
  if (message.data["type"] == "chat") {
    //background chat message storing
    final List<ChatNotificationData> oldList =
        await ChatNotificationsRepository().getBackgroundChatNotificationData();
    final messageChatData =
        ChatNotificationData.fromRemoteMessage(remoteMessage: message);
    oldList.add(messageChatData);
    ChatNotificationsRepository()
        .setBackgroundChatNotificationData(data: oldList);
    if (Platform.isAndroid) {
      ChatNotificationsUtils.createChatNotification(
          chatData: messageChatData, message: message);
    }
  } else {
    if (message.data["image"] == null) {
      localNotification.createNotification(
          isLocked: false, notificationData: message);
    } else {
      localNotification.createImageNotification(
          isLocked: false, notificationData: message);
    }
  }
}

LocalAwesomeNotification localNotification = LocalAwesomeNotification();

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  final notification = AwesomeNotifications();
  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static Future<void> requestPermission() async {
    try {
      final notificationSettings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.notDetermined ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.denied) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  static Future<void> init(final context) async {
    try {
      await ChatNotificationsUtils.initialize();
      await requestPermission();
      await registerListeners(context);
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static Future<void> handleNotificationRedirection(
      Map<String, dynamic> data) async {
    developer.log('HERE: NOTIFICATION TAP DATA: $data');
    if (data["type"] == "chat") {
      //get off the route if already on it
      if (Routes.currentRoute == chatMessages) {
        UiUtils.rootNavigatorKey.currentState?.pop();
      }
      await UiUtils.rootNavigatorKey.currentState?.pushNamed(chatMessages,
          arguments: {"chatUser": ChatUser.fromNotificationData(data)});
    } else if (data["type"] == "category") {
      if (data["parent_id"] == "0") {
        await UiUtils.rootNavigatorKey.currentState?.pushNamed(
          subCategoryRoute,
          arguments: {
            'subCategoryId': '',
            'categoryId': data["category_id"],
            'appBarTitle': data["category_name"],
            'type': CategoryType.category
          },
        );
      } else {
        await UiUtils.rootNavigatorKey.currentState?.pushNamed(
          subCategoryRoute,
          arguments: {
            'subCategoryId': data["category_id"],
            'categoryId': '',
            'appBarTitle': data["category_name"],
            'type': CategoryType.subcategory
          },
        );
      }
    } else if (data["type"] == "provider") {
      await UiUtils.rootNavigatorKey.currentState?.pushNamed(
        providerRoute,
        arguments: {'providerId': data["provider_id"]},
      );
    } else if (data["type"] == "order") {
      try {
        final String orderId = data['order_id']?.toString() ?? '';

        if (orderId.isEmpty) {
          return;
        }

        final FetchBookingDetailsCubit bookingDetailsCubit =
            FetchBookingDetailsCubit();

        await bookingDetailsCubit.fetchBookingDetails(
          bookingId: orderId,
        );

        final state = bookingDetailsCubit.state;
        if (state is FetchBookingDetailsSuccess) {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(
            bookingDetails,
            arguments: {
              'bookingDetails': state.booking,
            },
          );
        }
      } catch (_) {}
    } else if (data["type"] == "url") {
      final url = data["url"].toString();
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        throw 'Something went wrong';
      }
    }
  }

  static Future foregroundNotificationHandler() async {
    try {
      foregroundStream = FirebaseMessaging.onMessage.listen(
        (final RemoteMessage message) async {
          debugPrint('Received foreground message: ${message.messageId}');

          if (message.data["type"] == "chat") {
            ChatNotificationsUtils.addChatStreamAndShowNotification(
                message: message);
          } else {
            if (message.data.isEmpty) {
              await localNotification.createNotification(
                isLocked: false,
                notificationData: message,
              );
            } else if (message.data["image"] == null) {
              await localNotification.createNotification(
                isLocked: false,
                notificationData: message,
              );
            } else {
              await localNotification.createImageNotification(
                isLocked: false,
                notificationData: message,
              );
            }
          }
        },
        onError: (error) {
          debugPrint('Error in foreground notification handler: $error');
        },
      );
    } catch (e) {
      debugPrint('Error setting up foreground notification handler: $e');
    }
  }

  static Future terminatedStateNotificationHandler() async {
    FirebaseMessaging.instance.getInitialMessage().then(
      (final RemoteMessage? message) async {
        if (message == null) {
          return;
        }
        await handleNotificationRedirection(message.data);
      },
    );
  }

  static Future<void> onTapNotificationHandler() async {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen(
      (final message) async {
        await handleNotificationRedirection(message.data);
      },
    );
  }

  static Future<void> registerListeners(final context) async {
    try {
      await terminatedStateNotificationHandler();

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
      await foregroundNotificationHandler();
      await onTapNotificationHandler();
    } catch (e) {
      debugPrint('Error registering notification listeners: $e');
    }
  }

  static void disposeListeners() {
    ChatNotificationsUtils.dispose();

    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
