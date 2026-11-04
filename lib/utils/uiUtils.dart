// ignore_for_file: prefer_final_locals

import 'dart:ui' as ui;

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:e_demand/utils/custom_timeago.dart';

class UiUtils {
  static bool authenticationError = false;

  /// True while the top-most screen draws behind the Android navigation bar
  /// (see [AnnotatedSafeArea.applyBottomInset]). The root SafeArea in app.dart
  /// stops applying its bottom inset while this is true.
  static final ValueNotifier<bool> drawBehindNavigationBar = ValueNotifier(
    false,
  );

  static const int minimumMobileNumberDigit = 6;
  static const int maximumMobileNumberDigit = 15;
  static const int chatLimit = 25;

  //constant variables
  static const String limitOfAPIData = "10";

  static const String animationPath = "assets/animation/";

  //global key
  static GlobalKey<CustomNavigationBarState> bottomNavigationBarGlobalKey =
      GlobalKey<CustomNavigationBarState>();

  static GlobalKey<BookingsScreenState> bookingScreenGlobalKey =
      GlobalKey<BookingsScreenState>();

  //key for global navigation
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  //border radius
  static const double borderRadiusOf5 = 5;
  static const double borderRadiusOf6 = 6;
  static const double borderRadiusOf8 = 8;
  static const double borderRadiusOf10 = 10;
  static const double borderRadiusOf12 = 12;
  static const double borderRadiusOf20 = 20;
  static const double borderRadiusOf50 = 50;

  // Toast message display duration
  static const int messageDisplayDuration = 3000;

  //shimmerLoadingContainer value
  static int numberOfShimmerContainer = 7;

  //to give bottom scroll padding in screen where
  //bottom navigation bar is displayed
  static double getScrollViewBottomPadding(final BuildContext context) =>
      kBottomNavigationBarHeight.rh(context) + 5.rh(context);

  static Locale getLocaleFromLanguageCode(final String languageCode) {
    final result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static String getTimeAgo(BuildContext context, {required DateTime? date}) {
    if (date == null) {
      return "";
    }
    // Force incoming date to be treated as UTC
    final utcDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );

    final localDate = utcDate.toLocal();

    return CustomTimeago.format(
      localDate,
      locale: context.read<LanguageDataCubit>().state is GetLanguageDataSuccess
          ? (context.read<LanguageDataCubit>().state as GetLanguageDataSuccess)
                .currentLanguage
                .languageCode
          : null,
    );
  }

  static void showMessage(
    BuildContext context,
    String? message,
    ToastificationType? type, {
    VoidCallback? onMessageClosed,
  }) {
    toastification
      ..dismissAll()
      ..show(
        context: context,
        type: type,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          message!,
          maxLines: 100,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: TextStyle(fontSize: 14.rf(context), color: Colors.white),
        ),
        alignment: Alignment.bottomCenter,
        direction: ui.TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        // icon: const Icon(Icons.check),
        showIcon: true,
        padding: EdgeInsets.symmetric(
          horizontal: 12.rw(context),
          vertical: 16.rh(context),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 12.rw(context),
          vertical: 8.rh(context),
        ),
        borderRadius: BorderRadius.circular(12.rw(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
          ),
        ],
        showProgressBar: false,
        closeButton: const ToastCloseButton(
          showType: CloseButtonShowType.always,
        ),
        // closeButtonShowType: CloseButtonShowType.always,
        closeOnClick: false,
        pauseOnHover: false,
        dragToClose: true,
        applyBlurEffect: true,
      );

    // Trigger the callback after the duration (if provided)
    if (onMessageClosed != null) {
      Future.delayed(const Duration(seconds: 3), onMessageClosed);
    }
  }

  // Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Scaffold strips the bottom system inset from its body's MediaQuery when a
  /// `bottomNavigationBar` is set (even an empty banner slot). Wrap the body
  /// with this, passing `MediaQuery.viewPaddingOf(context).bottom` read from
  /// the screen's own build context, so `viewPaddingOf` in the body is real.
  static Widget restoreBottomInset({
    required final double inset,
    required final Widget child,
  }) => Builder(
    builder: (final BuildContext context) {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
          viewPadding: data.viewPadding.copyWith(bottom: inset),
        ),
        child: child,
      );
    },
  );

  static Future<dynamic> showBottomSheet({
    required final BuildContext context,
    required final Widget child,
    final Color? backgroundColor,
    final bool? enableDrag,
    final bool? isScrollControlled,
    final bool? useSafeArea,
  }) async {
    final result = await showModalBottomSheet(
      backgroundColor: backgroundColor ?? context.colors.surfaceElevated,
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      // Material 3 caps modal sheets at 640dp, which leaves a narrow floating
      // sheet on tablets — lift the cap so the sheet spans the full width.
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (final _) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        );
      },
    );

    return result;
  }

  static Widget getBackArrow(
    BuildContext context, {
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return CustomInkWellContainer(
      onTap: () {
        if (onTap != null) {
          onTap.call();
        } else {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: CustomContainer(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        color: backgroundColor ?? context.colors.backgroundPrimary,
        shape: BoxShape.circle,
        child: Center(
          child: CustomSvgPicture(
            width: 24,
            height: 24,
            svgImage:
                Directionality.of(
                  context,
                ).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? AppAssets.rightArrow
                : AppAssets.leftArrow,
            color: context.colors.iconPrimary,
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget getSimpleAppBar({
    required final BuildContext context,
    final String? title,
    final Widget? titleWidget,
    final Color? backgroundColor,
    final bool? centerTitle,
    final bool? isLeadingIconEnable,
    final double? elevation,
    final List<Widget>? actions,
    final FontWeight? fontWeight,
    final double? fontSize,
    final PreferredSize? bottom,
    final VoidCallback? onLeadingTap,
    final double? titleSpacing,
  }) {
    final double resolvedElevation = elevation ?? (bottom != null ? 0 : 3);

    final AppBar appBar = AppBar(
      titleSpacing: titleSpacing,
      leadingWidth: isLeadingIconEnable ?? true ? null : 0,
      surfaceTintColor: backgroundColor ?? context.colors.backgroundPrimary,
      systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
      leading: isLeadingIconEnable ?? true
          ? getBackArrow(context, onTap: onLeadingTap)
          : const CustomSizedBox(),
      title: title != null
          ? CustomText(
              title,
              color: context.colors.textPrimary,
              fontWeight: fontWeight ?? FontWeight.w500,
              fontSize: fontSize ?? 16,
            )
          : titleWidget,
      centerTitle: centerTitle ?? false,
      elevation: 0,
      backgroundColor: backgroundColor ?? context.colors.backgroundPrimary,
      actions: actions ?? [],
      bottom: bottom,
    );

    if (resolvedElevation <= 0) {
      return appBar;
    }

    // Matches Figma spec: 0 8px 16px 0 var(--Overlay-Header-Shadow).
    // AppBar's own elevation/shadowColor draws Material's fixed elevation
    // shadow shape, not this literal offset/blur, so it's applied manually.
    return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayHeaderShadow,
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: appBar,
      ),
    );
  }

  /// Returns the correct [SystemUiOverlayStyle] for the current theme.
  ///
  /// Uses [SystemUiOverlayStyle.light] / [.dark] as the base so Flutter's
  /// built-in defaults for status-bar icons are inherited automatically,
  /// then [copyWith] overrides only the nav-bar properties we care about.
  ///
  /// [scaffoldColor] — the dominant background colour of the current screen.
  /// Pass the Scaffold's `backgroundColor` so the gesture navigation area
  /// blends with the screen. Defaults to [backgroundPrimary].
  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
    Color? backgroundColor,
  }) {
    final bool isDark =
        context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark;
    final Color navBarColor =
        backgroundColor ?? context.colors.backgroundPrimary;

    return (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          // Always transparent so the AppBar's own colour shows through.
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: navBarColor,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        );
  }

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void navigateToCategoryDetails(
    final BuildContext context, {
    required final String? categoryId,
    required final String? categoryName,
  }) {
    if (context.read<SystemSettingCubit>().isCategoryDetailsViewTypeServices) {
      Navigator.pushNamed(
        context,
        categoryServicesRoute,
        arguments: {'categoryId': categoryId, 'categoryName': categoryName},
      );
      return;
    }
    Navigator.pushNamed(
      context,
      categoryProvidersRoute,
      arguments: {'categoryId': categoryId, 'categoryName': categoryName},
    );
  }

  static Future<bool> clearUserData() async {
    try {
      final String? latitude = HiveRepository.getLatitude;
      final String? longitude = HiveRepository.getLongitude;
      final String? currentLocationName = HiveRepository.getLocationName;
      final String? currentLocationArea = HiveRepository.getLocationArea;

      await FirebaseAuth.instance.signOut();

      HiveRepository.setUserLoggedIn = false;

      await HiveRepository.clearBoxValues(
        boxName: HiveRepository.userDetailBoxKey,
      );

      //we will store latitude,longitude and location name to fetch data based on latitude and longitude

      HiveRepository.setLongitude = longitude;
      HiveRepository.setLatitude = latitude;
      HiveRepository.setLocationName = currentLocationName;
      HiveRepository.setLocationArea = currentLocationArea;

      NotificationService.disposeListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Color getBookingStatusColor({
    required final BuildContext context,
    required final String statusVal,
  }) {
    switch (statusVal) {
      case "awaiting":
        return context.colors.textPrimary;
      case "pending":
        return context.colors.iconWarning;
      case "confirmed":
        return context.colors.iconInfo;
      case "started":
        return context.colors.backgroundBrand;
      case "rescheduled": //Rescheduled
        return context.colors.iconWarning;
      case "cancelled" || "cancel": //Cancelled
        return context.colors.iconError;
      case "completed":
        return context.colors.iconSuccess;
      case "booked":
        return context.colors.iconSuccess;
      case "ended" || "booking_ended":
        return context.colors.backgroundBrand;
      default:
        return context.colors.textError;
    }
  }

  static Color getPaymentStatusColor({
    required final BuildContext context,
    required final String paymentStatus,
  }) {
    switch (paymentStatus) {
      case "pending":
        return context.colors.iconWarning;
      case "failed":
        return context.colors.iconError;
      case "success":
        return context.colors.iconSuccess;
      case "1":
        return context.colors.iconSuccess;
      case "2":
        return context.colors.iconError;
      case "0":
        return context.colors.iconWarning;
      default:
        return context.colors.iconWarning;
    }
  }

  static Future<void> getVibrationEffect() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> showAnimatedDialog({
    required BuildContext context,
    required Widget child,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const CustomSizedBox(),
      transitionBuilder:
          (
            final context,
            final animation,
            final secondaryAnimation,
            Widget _,
          ) => Transform.scale(
            scale: Curves.easeInOut.transform(animation.value),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusOf10),
                ),
                child: child,
              ),
            ),
          ),
    );
  }

  static Future<void> openMap(
    BuildContext context, {
    required dynamic latitude,
    required dynamic longitude,
  }) async {
    bool isAppleMap = await mapLocationPlatformSelection(context);

    //final String appleMapsUrl = "http://maps.apple.com/?ll=$latitude,$longitude";
    final String appleMapsUrl =
        "https://maps.apple.com/?q=$latitude,$longitude";
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    // Determine primary and fallback URLs based on platform
    final Uri primaryUrl = Uri.parse(isAppleMap ? appleMapsUrl : googleMapsUrl);
    final Uri fallbackUrl = Uri.parse(googleMapsUrl);

    // Try to launch the primary map URL
    if (await canLaunchUrl(primaryUrl)) {
      await launchUrl(primaryUrl, mode: LaunchMode.externalApplication);
    }
    // Fallback for iOS if Apple Maps fails
    else if (Platform.isIOS && await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
    // Show error if both fail
    else {
      UiUtils.showMessage(
        context,
        'somethingWentWrong'.translate(context: context),
        ToastificationType.error,
      );
    }
  }

  static Future<bool> mapLocationPlatformSelection(BuildContext context) async {
    if (Platform.isAndroid) return false;
    bool isAppleMap = false;
    await UiUtils.showBottomSheet(
      enableDrag: true,
      context: context,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                'select'.translate(context: context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              const Divider(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: CustomText(
                  'googleMap'.translate(context: context),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: CustomText(
                  'appleMap'.translate(context: context),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) async {
      if (value != null) {
        isAppleMap = value;
      }
    });
    return isAppleMap;
  }

  static Future<void> share(
    String text, {
    required BuildContext context,
    List<XFile>? files,
    String? subject,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  static String formatDateTime(
    DateTime dateTime, {
    bool convertToLocal = true,
  }) {
    try {
      final languageCode =
          Hive.box(
            HiveRepository.languageBoxKey,
          ).get(HiveRepository.currentLanguageKey)?['code'] ??
          'en';

      if (convertToLocal) {
        // Force incoming date to be treated as UTC
        final utcDate = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond,
        );

        dateTime = utcDate.toLocal();
      }

      if (dateAndTimeSetting["use24HourFormat"]) {
        return DateFormat('dd MMM, y - kk:mm', languageCode).format(dateTime);
      }
      return DateFormat('dd MMM, y - h:mm a', languageCode).format(dateTime);
    } catch (e) {
      if (dateAndTimeSetting["use24HourFormat"]) {
        return DateFormat('dd MMM, y - kk:mm').format(dateTime);
      }
      return DateFormat('dd MMM, y - h:mm a').format(dateTime);
    }
  }

  static String formatTimeWithDateTime(DateTime dateTime) {
    if (dateAndTimeSetting["use24HourFormat"]) {
      return DateFormat("kk:mm").format(dateTime);
    } else {
      return DateFormat("hh:mm a").format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;

      downloadFilePath =
          "$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}";

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFile.open(downloadFilePath);
        } else {
          SharePlus.instance.share(
            ShareParams(text: "Share", files: [XFile(downloadFilePath)]),
          );
        }
        return;
      }

      var httpClient = HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(bytes, flush: !isDownload);
      if (isDownload) {
        OpenFile.open(downloadFilePath);
      } else {
        SharePlus.instance.share(
          ShareParams(text: "Share", files: [XFile(downloadFilePath)]),
        );
        // Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {}
  }
}

class AnnotatedSafeArea extends StatefulWidget {
  final Widget child;
  final bool isAnnotated;

  /// When false, the bottom system inset is not applied here; the screen must
  /// pad its own scrollable/bottom widgets with `viewPaddingOf(context).bottom`.
  final bool applyBottomInset;

  const AnnotatedSafeArea({
    super.key,
    required this.child,
    this.isAnnotated = false,
    this.applyBottomInset = true,
  });

  @override
  State<AnnotatedSafeArea> createState() => _AnnotatedSafeAreaState();
}

class _AnnotatedSafeAreaState extends State<AnnotatedSafeArea> {
  // Screens currently asking the root SafeArea to drop its bottom inset.
  static final Set<State> _drawingBehind = <State>{};

  Animation<double>? _secondaryAnimation;

  // Only the top-most route may switch off the root bottom inset, so a screen
  // pushed over this one gets the normal inset back.
  void _syncRootInset() {
    final bool active =
        !widget.applyBottomInset &&
        (_secondaryAnimation == null || _secondaryAnimation!.value == 0);
    if (active) {
      _drawingBehind.add(this);
    } else {
      _drawingBehind.remove(this);
    }
    _publish();
  }

  static void _publish() {
    final bool value = _drawingBehind.isNotEmpty;
    if (UiUtils.drawBehindNavigationBar.value == value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UiUtils.drawBehindNavigationBar.value = _drawingBehind.isNotEmpty;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? animation = ModalRoute.of(
      context,
    )?.secondaryAnimation;
    if (animation != _secondaryAnimation) {
      _secondaryAnimation?.removeListener(_syncRootInset);
      _secondaryAnimation = animation;
      _secondaryAnimation?.addListener(_syncRootInset);
    }
    _syncRootInset();
  }

  @override
  void dispose() {
    _secondaryAnimation?.removeListener(_syncRootInset);
    _drawingBehind.remove(this);
    _publish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      color: context.colors.surfaceElevated,
      padding: EdgeInsets.only(
        bottom: widget.applyBottomInset
            ? MediaQuery.paddingOf(context).bottom
            : 0,
      ),
      child: widget.child,
    );

    if (widget.isAnnotated) {
      content = AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.applyBottomInset
            ? UiUtils.getSystemUiOverlayStyle(context: context)
            : UiUtils.getSystemUiOverlayStyle(
                context: context,
              ).copyWith(systemNavigationBarColor: Colors.transparent),
        child: content,
      );
    }

    return content;
  }
}

/// Clips [child]'s shadow at its bottom edge so a footer's upward shadow does
/// not bleed onto the area below it (e.g. the system navigation bar strip).
class ClipShadowBottom extends StatelessWidget {
  const ClipShadowBottom({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ClipRect(clipper: const _BottomEdgeClipper(), child: child);
}

class _BottomEdgeClipper extends CustomClipper<Rect> {
  const _BottomEdgeClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-32, -32, size.width + 32, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
