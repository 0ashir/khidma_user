import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixit_user/firebase_options.dart';
import 'package:fixit_user/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;
import '../services/google_translation_service.dart';


Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

enum NotificationType {
  createBookingEvent,
  updateBookingStatusEvent,
  assignBooking,
  createProvider,
  extraChargeEvent,
  createBid,
  updateBidEvent,
  createServicemanWithdraw,
  createWithdrawRequest,
  createServiceRequest
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.createBookingEvent:
        return "createBookingEvent";
      case NotificationType.updateBookingStatusEvent:
        return "updateBookingStatusEvent";
      case NotificationType.assignBooking:
        return "assingBooking";
      case NotificationType.createProvider:
        return "createProvider";
      case NotificationType.extraChargeEvent:
        return "extraChargeEvent";
      case NotificationType.createBid:
        return "createBid";
      case NotificationType.updateBidEvent:
        return "updateBidEvent";
      case NotificationType.createServicemanWithdraw:
        return "createServicemanWithdraw";
      case NotificationType.createWithdrawRequest:
        return "createWithdrawRequest";
      case NotificationType.createServiceRequest:
        return "createServiceRequest";
    }
  }
}

Future<void> createBookingNotification(NotificationType type) async {
  log("Calling API for type: ${type.value}");
  try {
    final response = await apiServices
        .getApi("${api.notification}?type=${type.value}", [], isToken: true);

    if (response.isSuccess!) {
      log("Notification success: ${response.message}");
    } else {
      log("Notification failed");
    }
  } catch (e) {
    log("Error in notification: $e");
  }
}

bool isFlutterLocalNotificationsInitialized = false;

//when app in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message ${message.messageId}');
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  await showFlutterNotification(message);
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  isFlutterLocalNotificationsInitialized = true;
}

// ---------------------------------------------------------------------------
// Custom notification sound
// Android : place file at  android/app/src/main/res/raw/notification_sound.mp3
// iOS     : add file to   ios/Runner/notification_sound.aiff  (via Xcode)
// ---------------------------------------------------------------------------
const String _kAndroidSoundName = 'notification_sound';
const String _kIosSoundName     = 'notification_sound.aiff';

Future<void> showFlutterNotification(RemoteMessage message) async {
  // Ensure channel and plugin are ready in case this is called from the
  // background isolate where main() did not run.
  if (flutterLocalNotificationsPlugin == null) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  const AndroidNotificationChannel bgChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(_kAndroidSoundName),
  );
  channel = bgChannel;

  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(bgChannel);

  RemoteNotification? notification = message.notification;

  // Translate title and body for the user's preferred language
  final locale = await GoogleTranslationService.getCurrentLocale();
  final translated = await GoogleTranslationService.translateBatch(
    [notification?.title ?? '', notification?.body ?? ''],
    locale,
  );
  final notifTitle = translated[0];
  final notifBody = translated[1];

  BigPictureStyleInformation? bigPicture;
  final imageUrl = message.data["image"] as String?;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      final bytes = base64Encode(response.bodyBytes);
      bigPicture = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(bytes),
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(bytes),
      );
    } catch (_) {}
  }

  await flutterLocalNotificationsPlugin!.show(
    message.hashCode,
    notifTitle,
    notifBody,
    NotificationDetails(
      android: AndroidNotificationDetails(
        bgChannel.id,
        bgChannel.name,
        channelDescription: bgChannel.description,
        styleInformation: bigPicture,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound(_kAndroidSoundName),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _kIosSoundName,
      ),
    ),
  );
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

class CustomNotificationController {
  AndroidNotificationChannel? channel;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initFirebaseMessaging() async {
    await FirebaseMessaging.instance
        .requestPermission(
            alert: true, badge: true, provisional: false, sound: true)
        .then((value) async {
      if (value.authorizationStatus == AuthorizationStatus.authorized) {
        await registerNotificationListeners().catchError((e) {
          log('Notification Listener REGISTRATION ERROR : $e');
        });

        // Background handler is already registered in main() before runApp().
        // Do NOT register it again here — a second registration overrides the
        // first and the notification.dart handler uses hardcoded Android-only
        // Firebase options, which crashes on iOS.

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
                alert: true, badge: true, sound: true)
            .catchError((e) {
          log('setForegroundNotificationPresentationOptions ERROR: $e');
        });
      }
    });
  }

  // String parseHtmlString(String? htmlString) {
  //   return parse(parse(htmlString).body!.text).documentElement!.text;
  // }

  Future<void> registerNotificationListeners() async {
    // Ensure the foreground channel exists with the correct sound before the
    // first message arrives.  createNotificationChannel is a no-op on Android
    // if the channel already exists with the same ID.
    const AndroidNotificationChannel foregroundChannel =
        AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_kAndroidSoundName),
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? '';
        final body = message.notification?.body ?? '';
        if (message.notification != null &&
            title.isNotEmpty &&
            body.isNotEmpty) {
          showNotification(message, foregroundChannel);
        }
      }, onError: (e) {
        log("setAutoInitEnabled error $e");
      });

      // replacement for onResume: When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // handleNotificationClick(message);
      }, onError: (e) {
        log("onMessageOpenedApp Error $e");
      });

      // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
      FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) {
        if (message != null) {
          // handleNotificationClick(message);
        }
      }, onError: (e) {
        log("getInitialMessage error : $e");
      });
    }).onError((error, stackTrace) {
      log("onGetInitialMessage error: $error");
    });
  }

  Future<void> initNotification(context) async {
    log('initCall');

    // Do NOT re-register the background handler here — main() already registers
    // the correct one with platform-aware Firebase options and call-sound logic.
    // Do NOT overwrite flutterLocalNotificationsPlugin — main() already
    // initialised it with the channel and correct sound before runApp().
    if (!isFlutterLocalNotificationsInitialized) {
      isFlutterLocalNotificationsInitialized = true;
      if (!kIsWeb && Platform.isAndroid) {
        channel = const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            showBadge: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(_kAndroidSoundName));

        await flutterLocalNotificationsPlugin!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel!);
      }

      await flutterLocalNotificationsPlugin!.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
    }

    // Cold-start: app was killed and user tapped the notification to open it.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        flutterLocalNotificationsPlugin?.cancelAll();
        debugPrint("CHECK NOTI");
        showFlutterNotification(message, true, context);
      }
    });

    // Foreground listener is already registered in registerNotificationListeners().
    // Registering it again here would produce duplicate notifications, so we skip it.

    // Background-to-foreground: user tapped a notification while app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('onMessageOpenedApp: $message');
      // Works on both Android and iOS — no android-specific guard needed.
      showFlutterNotification(message, true, context);
    });

    requestPermissions();
  }

  void showFlutterNotification(RemoteMessage message, isOpen, context) async {
    RemoteNotification? notification = message.notification;
    if (isOpen) {
      if (message.data["type"] == "booking") {
        getBookingDetailById(message.data['booking_id'], context);
      } else if (message.data["type"] == "service") {
        Provider.of<ServicesDetailsProvider>(context, listen: false)
            .getServiceById(context, message.data["service_id"]);
        Navigator.pushNamed(context, routeName.servicesDetailsScreen,
            arguments: {"serviceId": message.data["service_id"]}).then((e) {
          navigatorKey.currentState!
              .pushNamedAndRemoveUntil(routeName.chatHistory, (route) => false);
        });
      } else if (message.data["type"] == "provider") {
        Provider.of<ProviderDetailsProvider>(context, listen: false)
            .getProviderById(context, message.data["provider_id"]);
        Navigator.pushNamed(context, routeName.providerDetailsScreen,
            arguments: {"providerId": message.data["provider_id"]}).then((e) {
          navigatorKey.currentState!
              .pushNamedAndRemoveUntil(routeName.chatHistory, (route) => false);
        });
      } else if (message.data["type"] == "chat") {
        debugPrint("djgfhjd:");
        Navigator.pushNamed(context, routeName.chatScreen, arguments: {
          "image": message.data['image'],
          "name": message.data["name"],
          "role": "serviceman",
          "userId": message.data['pId'],
          "token": message.data['token'],
          "phone": message.data['phone'],
          "code": message.data['code'],
          "bookingId": message.data['bookingId'] ?? 0
        }).then((e) {
          navigatorKey.currentState!
              .pushNamedAndRemoveUntil(routeName.chatHistory, (route) => false);
        });
      }
      // Navigation done — do not re-post the notification when the user tapped it.
      return;
    }

    // Translate notification content for the user's preferred language
    final locale = await GoogleTranslationService.getCurrentLocale();
    final translated = await GoogleTranslationService.translateBatch(
      [notification?.title ?? '', notification?.body ?? ''],
      locale,
    );
    final notifTitle = translated[0];
    final notifBody = translated[1];

    final NotificationDetails details;
    if (Platform.isAndroid && channel != null) {
      details = NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channelDescription: channel!.description,
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: true,
          playSound: true,
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          sound: const RawResourceAndroidNotificationSound(_kAndroidSoundName),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: _kIosSoundName,
        ),
      );
    } else {
      details = const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: _kIosSoundName,
        ),
      );
    }

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notifTitle,
      notifBody,
      details,
    );
  }

  //booking detail by id
  getBookingDetailById(id, context) async {
    try {
      await apiServices
          .getApi("${api.booking}/$id", [], isToken: true, isData: true)
          .then((value) {
        if (value.isSuccess!) {
          debugPrint("DHRUVU :${value.data}");

          BookingModel bookingModel = BookingModel.fromJson(value.data);
          if (bookingModel.bookingStatus!.slug == translations!.pending) {
            //route.pushNamed(context, routeName.packageBookingScreen);
            Navigator.pushNamed(context, routeName.pendingBookingScreen,
                arguments: {"bookingId": bookingModel.id}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug ==
              translations!.accepted) {
            Navigator.pushNamed(context, routeName.acceptedBookingScreen,
                arguments: {"booking": bookingModel}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
            /* {"amount": "0", "assign_me": bookingModel.providerId.toString() == userModel!.id.toString()? true: false}*/
          } else if (bookingModel.bookingStatus!.slug == appFonts.onHold) {
            Navigator.pushNamed(context, routeName.ongoingBookingScreen,
                arguments: {"booking": bookingModel}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug == appFonts.onHold) {
            Navigator.pushNamed(context, routeName.ongoingBookingScreen,
                arguments: {"booking": bookingModel}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug ==
                  appFonts.onGoing.toLowerCase() ||
              bookingModel.bookingStatus!.slug == appFonts.ontheway ||
              bookingModel.bookingStatus!.slug == appFonts.ontheway1 ||
              bookingModel.bookingStatus!.slug == appFonts.startAgain ||
              bookingModel.bookingStatus!.slug == appFonts.onHold) {
            Navigator.pushNamed(context, routeName.ongoingBookingScreen,
                arguments: {"booking": bookingModel}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug ==
              translations!.completed) {
            Navigator.pushNamed(context, routeName.completedServiceScreen,
                arguments: {"bookingId": bookingModel.id}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug == appFonts.assigned) {
            Navigator.pushNamed(context, routeName.acceptedBookingScreen,
                arguments: {"bookingId": bookingModel.id}).then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          } else if (bookingModel.bookingStatus!.slug == translations!.cancel) {
            route
                .pushNamed(navigatorKey.currentContext,
                    routeName.cancelledServiceScreen,
                    arg: bookingModel)
                .then((e) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  routeName.chatHistory, (route) => false);
            });
          }
        } else {}
      });
    } catch (e) {
      debugPrint("EEEE NOTI getBookingDetailById $e");
    }
  }

  Future<void> setupListenerCallbacks(context) async {
    //when app in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;

      AndroidNotification? android = message.notification?.android;

      debugPrint("Njdfh :$notification");
      debugPrint("Njdfh :${message.data["image"]}");
      if (android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
              playSound: true,
              importance: Importance.max,
              priority: Priority.high,
              sound: const RawResourceAndroidNotificationSound(_kAndroidSoundName),
            ),
          ),
        );
      }
      debugPrint("notification1 : ${message.data}");
      showFlutterNotification(message, false, context);
    });

    //when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('A new onMessageOpenedApp event was published!');
      debugPrint("onMessageOpenedApp: $message");
      flutterLocalNotificationsPlugin.cancelAll();
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        showFlutterNotification(message, true, context);
      }
    });
  }

  requestPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    debugPrint("settings.authorizationStatus: ${settings.authorizationStatus}");
  }
}
