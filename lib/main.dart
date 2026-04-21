import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixit_user/firebase_options.dart';
import 'package:fixit_user/helper/notification.dart';
import 'package:fixit_user/providers/app_pages_providers/job_request_providers/add_job_request_provider.dart';
import 'package:fixit_user/providers/app_pages_providers/job_request_providers/job_request_details_provider.dart';
import 'package:fixit_user/providers/app_pages_providers/offer_chat_provider.dart';
import 'package:fixit_user/providers/app_pages_providers/referral_provider.dart';
import 'package:fixit_user/providers/app_pages_providers/wallet_bonus_provider.dart';
import 'package:fixit_user/services/environment.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:upgrader/upgrader.dart';
import 'common/theme/app_theme.dart';
import 'config.dart';
import 'package:fixit_user/providers/app_pages_providers/chat_with_staff_provider.dart';

void main() async {
  // var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (Platform.isAndroid) {
    log("app android ");
    await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform

    );
  } else {
    log("app IOS");
   await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeAppSettings();

  sharedPreferences.getString("selectedLocale");
  log("=-=-=-=-=-=-=-=-=- ${sharedPreferences.getString("selectedLocale")}");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // FlutterNativeSplash.remove();
    // Timer(Duration(milliseconds: 500), () {
    //   FlutterNativeSplash.remove();
    // });
    lockScreenPortrait();
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context1, AsyncSnapshot<SharedPreferences> snapData) {
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: [
        // SystemUiOverlay.top,
        //   SystemUiOverlay.bottom,
        // ]);
        if (snapData.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AppSettingProvider(snapData.data!),
              ),
              ChangeNotifierProvider(
                create: (_) => ThemeService(snapData.data!, context),
              ),
              ChangeNotifierProvider(create: (_) => SplashProvider()),
              ChangeNotifierProvider(
                create: (_) => LanguageProvider(snapData.data!, context),
              ),
              ChangeNotifierProvider(create: (_) => CommonApiProvider()),
              ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
              ChangeNotifierProvider(create: (_) => LoginProvider()),
              ChangeNotifierProvider(create: (_) => OfferChatProvider()),
              ChangeNotifierProvider(create: (_) => LoginWithPhoneProvider()),
              ChangeNotifierProvider(create: (_) => VerifyOtpProvider()),
              ChangeNotifierProvider(create: (_) => ForgetPasswordProvider()),
              ChangeNotifierProvider(create: (_) => RegisterProvider()),
              ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
              ChangeNotifierProvider(create: (_) => LoadingProvider()),
              ChangeNotifierProvider(create: (_) => DashboardProvider()),
              ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
              ChangeNotifierProvider(create: (_) => ProfileProvider()),

              ChangeNotifierProvider(create: (_) => CurrencyProvider()),
              ChangeNotifierProvider(create: (_) => ProfileDetailProvider()),
              ChangeNotifierProvider(create: (_) => FavouriteListProvider()),
              ChangeNotifierProvider(create: (_) => CommonPermissionProvider()),
              ChangeNotifierProvider(create: (_) => LocationProvider()),
              ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
              ChangeNotifierProvider(create: (_) => MyReviewProvider()),
              ChangeNotifierProvider(create: (_) => EditReviewProvider()),
              ChangeNotifierProvider(create: (_) => AppDetailsProvider()),
              ChangeNotifierProvider(create: (_) => RateAppProvider()),
              ChangeNotifierProvider(create: (_) => ContactUsProvider()),
              ChangeNotifierProvider(create: (_) => NotificationProvider()),
              ChangeNotifierProvider(create: (_) => NewLocationProvider()),
              ChangeNotifierProvider(create: (_) => SearchProvider()),
              ChangeNotifierProvider(
                create: (_) => LatestBLogDetailsProvider(),
              ),
              ChangeNotifierProvider(create: (_) => NoInternetProvider()),
              ChangeNotifierProvider(create: (_) => CategoriesListProvider()),
              ChangeNotifierProvider(
                create: (_) => CategoriesDetailsProvider(),
              ),
              ChangeNotifierProvider(create: (_) => ServicesDetailsProvider()),
              ChangeNotifierProvider(create: (_) => ServiceReviewProvider()),
              ChangeNotifierProvider(create: (_) => ProviderDetailsProvider()),
              ChangeNotifierProvider(create: (_) => SlotBookingProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => PaymentProvider()),
              ChangeNotifierProvider(create: (_) => WalletProvider()),
              ChangeNotifierProvider(create: (_) => ServicemanListProvider()),
              ChangeNotifierProvider(create: (_) => ServiceSelectProvider()),
              ChangeNotifierProvider(create: (_) => SelectServicemanProvider()),
              ChangeNotifierProvider(create: (_) => BookingProvider()),
              ChangeNotifierProvider(create: (_) => PendingBookingProvider()),
              ChangeNotifierProvider(create: (_) => AcceptedBookingProvider()),
              ChangeNotifierProvider(create: (_) => ChatProvider()),
              ChangeNotifierProvider(create: (_) => WalletBonusProvider()),
              ChangeNotifierProvider(create: (_) => OngoingBookingProvider()),
              ChangeNotifierProvider(create: (_) => CompletedServiceProvider()),
              ChangeNotifierProvider(
                create: (_) => ServicesPackageDetailsProvider(),
              ),
              ChangeNotifierProvider(create: (_) => CheckoutWebViewProvider()),
              ChangeNotifierProvider(create: (_) => CancelledBookingProvider()),
              ChangeNotifierProvider(create: (_) => PackageBookingProvider()),
              ChangeNotifierProvider(create: (_) => ServicemanDetailProvider()),
              ChangeNotifierProvider(create: (_) => FeaturedServiceProvider()),
              ChangeNotifierProvider(create: (_) => ExpertServiceProvider()),
              ChangeNotifierProvider(create: (_) => ChatHistoryProvider()),
              ChangeNotifierProvider(create: (_) => DeleteDialogProvider()),
              ChangeNotifierProvider(create: (_) => JobRequestListProvider()),
              ChangeNotifierProvider(create: (_) => AddJobRequestProvider()),
              // ChangeNotifierProvider(create: (_) => AudioCallProvider()),
              // ChangeNotifierProvider(create: (_) => VideoCallProvider()),
              ChangeNotifierProvider(
                create: (_) => JobRequestDetailsProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ServicePackageAllListProvider(),
              ),
              ChangeNotifierProvider(create: (_) => ChatWithStaffProvider()),
              ChangeNotifierProvider(create: (_) => ReferralProvider()),
            ],
            child: UpgradeAlert(
              dialogStyle: UpgradeDialogStyle.cupertino,
              showIgnore: false,
              showLater: false,
              barrierDismissible: false,
              upgrader: Upgrader(
                storeController: UpgraderStoreController(
                  onAndroid: () => UpgraderPlayStore(),
                ),
              ),
              child: const RouteToPage(),
            ),
          );
        } else {
          return MaterialApp(
            theme: AppTheme.fromType(ThemeType.light).themeData,
            darkTheme: AppTheme.fromType(ThemeType.dark).themeData,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: UpgradeAlert(
              showIgnore: false,
              showLater: false,
              barrierDismissible: false,
              dialogStyle: UpgradeDialogStyle.cupertino,
              upgrader: Upgrader(
                storeController: UpgraderStoreController(
                  onAndroid: () => UpgraderPlayStore(),
                ),
              ),
              child: const SplashLayout(),
            ),
          );
        }
      },
    );
  }

  lockScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

class RouteToPage extends StatefulWidget {
  const RouteToPage({super.key});

  @override
  State<RouteToPage> createState() => _RouteToPageState();
}

class _RouteToPageState extends State<RouteToPage> {
  @override
  void initState() {
    // TODO: implement initState
    // CustomNotificationController().initNotification(context);
    CustomNotificationController().initFirebaseMessaging();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, theme, child) {
        return Consumer<LanguageProvider>(
          builder: (context, lang, child) {
            return Consumer<CurrencyProvider>(
              builder: (context, currency, child) {
                // Check if currency is null, and handle it gracefully.
                if (currency.currency == null) {
                  // Provide a fallback value or handle the null state
                  currency
                      .setVal(); // Initialize or set default value if needed.
                }
                final provider = Provider.of<LanguageProvider>(
                  context,
                  listen: true,
                );

                return MaterialApp(
                  title: 'Khidma User',
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.fromType(ThemeType.light).themeData,
                  darkTheme: AppTheme.fromType(ThemeType.dark).themeData,
                  locale: provider.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    AppLocalizationDelagate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  themeMode: Provider.of<ThemeService>(context).theme,
                  initialRoute: "/",
                  routes: appRoute.route,
                  // Wrap MaterialApp with Directionality
                  builder: (context, child) {
                    return Directionality(
                      textDirection: lang.locale?.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child!,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform

  );

  final title = message.data['title'] ?? '';
  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications for Astrologically',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    sound:
        (title == 'Incoming Audio Call...' || title == 'Incoming Video Call...')
        ? const RawResourceAndroidNotificationSound('callsound')
        : null,
  );

  showNotification(message, channel);
}

Future<void> showNotification(
  RemoteMessage remote,
  AndroidNotificationChannel channel,
) async {
  final String title = remote.notification?.title ?? '';
  final String body = remote.notification?.body ?? '';

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    icon: "ic_notification",
    sound:
        (remote.data['title'] == 'Incoming Audio Call...' ||
            remote.data['title'] == 'Incoming Video Call...')
        ? const RawResourceAndroidNotificationSound('callsound')
        : null,
    fullScreenIntent: true,
    visibility: NotificationVisibility.public,
  );

  DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
    sound: 'callsound.wav',
    presentSound: true,
  );

  NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await flutterLocalNotificationsPlugin?.show(
    0,
    title,
    body,
    notificationDetails,
    payload: remote.data.toString(),
  );
}

