import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixit_user/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../../config.dart';
import 'package:http/http.dart' as http;


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
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message ${message.messageId}');
  debugPrint("message.datass : ${message.data}");
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBLT6o5-8VqNKJNlkTaIRq2RVeN5xE5zGA",
          projectId: "fixit-db226",
          messagingSenderId: "186901032010",
          appId: "1:186901032010:android:b5c732cd46b148cb740ab3"));
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  showFlutterNotification(message);
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  RemoteNotification? notification = message.notification;

  if (message.data["image"] != null || message.data["image"] != "") {
    final http.Response response =
        await http.get(Uri.parse(message.data["image"]));
    BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
      largeIcon: ByteArrayAndroidBitmap.fromBase64String(
          base64Encode(response.bodyBytes)),
    );
    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(channel!.id, channel!.name,
            channelDescription: channel!.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            styleInformation: bigPictureStyleInformation,

            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
            showProgress: true),
      ),
    );
  } else {
    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(channel!.id, channel!.name,
            channelDescription: channel!.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
            showProgress: true),
      ),
    );
  }
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

        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

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
    FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null &&
            message.notification!.title!.isNotEmpty &&
            message.notification!.body!.isNotEmpty) {
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications for Astrologically',
            description: 'This channel is used for important notifications.',
            importance: Importance.high,
            playSound: true,
          );
          showNotification(message, channel);
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

    //when app in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (!kIsWeb && Platform.isAndroid) {
      channel = const AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          showBadge: true);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel!);
    }

    //when app is [closed | killed | terminated]
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        flutterLocalNotificationsPlugin.cancelAll();
        debugPrint("CHECK NOTI");
        showFlutterNotification(message, true, context);
      }
    });
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //when app in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;

      log("Njdfh :$notification");
      log("Njdfh :${message.data["image"]}");

      if (!kIsWeb) {
        final NotificationDetails details;
        if (Platform.isAndroid) {
          details = NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id, channel!.name,
              channelDescription: channel!.description,
              icon: '@mipmap/ic_launcher',
              showProgress: true,
              channelShowBadge: true,
              fullScreenIntent: true,
            ),
          );
        } else {
          details = const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          );
        }
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          details,
        );
      }
      // ignore: unnecessary_null_comparison
      log("notification1 : ${message.data}");
      flutterLocalNotificationsPlugin.cancelAll();

      showFlutterNotification(message, false, context);
    });

    //when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('A new onMessageOpenedApp event was published!');
      log("onMessageOpenedApp: $message");
      flutterLocalNotificationsPlugin.cancelAll();
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        showFlutterNotification(message, true, context);
      }
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
    }
    log("fullScreenIntent: true,");
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
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
        ),
      ),
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
              sound: (message.data['title'] != 'Incoming Audio Call...' ||
                      message.data['title'] != 'Incoming Video Call...')
                  ? null
                  : const RawResourceAndroidNotificationSound('callsound'),
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
            ),
          ),
        );
      }
      // ignore: unnecessary_null_comparison
      debugPrint("notification1 : ${message.data}");
      flutterLocalNotificationsPlugin.cancelAll();

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
