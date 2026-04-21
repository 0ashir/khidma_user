import 'dart:developer';

import 'package:fixit_user/widgets/no_internet_layout.dart';

import '../../../config.dart';

import '../../../firebase/firebase_api.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    log("appSettingModel ====---->${appSettingModel?.activation}");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      log("fdftsf :$state");
      FirebaseApi().onlineActiveStatusChange(false);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      log("fdft :$state");
      FirebaseApi().onlineActiveStatusChange(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<LanguageProvider, DashboardProvider, ThemeService,
            CommonPermissionProvider, LocationProvider>(
        builder:
            (context1, lang, value, theme, permission, locationCtrl, child) {
      return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            value.onBack(context);
          },
          child: StatefulWrapper(
              onInit: () async {
                value.initDashboardData(context);
              },
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  floatingActionButton:
                      MediaQuery.of(context).viewInsets.bottom != 0 &&
                              value.isTap == true
                          ? null
                          : FloatingActionButton(
                              backgroundColor: appColor(context).primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r50)),
                              onPressed: () => value.cartTap(context),
                              child: Consumer<CartProvider>(
                                  builder: (context4, cart, child) {
                                return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(cart.cartList.isEmpty
                                          ? eSvgAssets.cart
                                          : eSvgAssets.cartFill),
                                      if (cart.cartList.isNotEmpty)
                                        Positioned(
                                            top: -4.4,
                                            right: 0,
                                            child: Container(
                                                    child: Text(
                                                            cart.cartList.length
                                                                .toString(),
                                                            style: appCss
                                                                .dmDenseMedium8
                                                                .textColor(appColor(
                                                                        context)
                                                                    .whiteColor))
                                                        .paddingAll(Insets.i5))
                                                .decorated(
                                                    color:
                                                        appColor(context).red,
                                                    shape: BoxShape.circle)
                                                .paddingOnly(
                                                    top: Insets.i2,
                                                    left: Insets.i2))
                                    ]).height(Sizes.s38).width(Sizes.s30);
                              })),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  extendBody: true,
                  bottomNavigationBar: Container(
                      decoration: ShapeDecoration(
                          shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.only(
                                  topLeft: SmoothRadius(
                                      cornerRadius: 18, cornerSmoothing: 1),
                                  topRight: SmoothRadius(
                                      cornerRadius: 18, cornerSmoothing: 1))),
                          shadows: [
                            BoxShadow(
                                color: appColor(context)
                                    .darkText
                                    .withValues(alpha: 0.10),
                                blurRadius: 4,
                                spreadRadius: 0)
                          ]),
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          child: BottomAppBar(
                              elevation: 10,
                              shape: const CircularNotchedRectangle(),
                              padding: EdgeInsets.zero,
                              shadowColor: appColor(context).darkText.withValues(alpha: 0.5),
                              notchMargin: 6,
                              child: IntrinsicHeight(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: value
                                          .dashboardList(context)
                                          .asMap()
                                          .entries
                                          .map((e) => Expanded(
                                                child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      isDark(context)
                                                          ? AnimatedScale(
                                                              curve: Curves
                                                                  .fastOutSlowIn,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              scale: value.selectIndex ==
                                                                          e.key &&
                                                                      value.expanded
                                                                  ? 1.3
                                                                  : 1,
                                                              child: SvgPicture
                                                                  .asset(
                                                                      value.selectIndex ==
                                                                              e
                                                                                  .key
                                                                          ? e.value
                                                                              .icon2 // Access as property
                                                                          : e.value
                                                                              .icon,
                                                                      // Access as property
                                                                      height: Sizes
                                                                          .s24,
                                                                      width: Sizes
                                                                          .s24,
                                                                      colorFilter: ColorFilter.mode(
                                                                          (isDark(context) && value.selectIndex == e.key)
                                                                              ? appColor(context)
                                                                                  .primary
                                                                              : appColor(context)
                                                                                  .darkText,
                                                                          BlendMode
                                                                              .srcIn),
                                                                      fit: BoxFit
                                                                          .scaleDown),
                                                            )
                                                          : AnimatedScale(
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                              scale: value.selectIndex ==
                                                                          e.key &&
                                                                      value.expanded
                                                                  ? 1.3
                                                                  : 1,
                                                              child: SvgPicture
                                                                  .asset(
                                                                      value.selectIndex ==
                                                                              e
                                                                                  .key
                                                                          ? e.value
                                                                              .icon2 // Access as property
                                                                          : e.value
                                                                              .icon,
                                                                      // Access as property
                                                                      height: Sizes
                                                                          .s24,
                                                                      colorFilter: ColorFilter.mode(
                                                                          value.selectIndex == e.key
                                                                              ? appColor(context)
                                                                                  .primary
                                                                              : appColor(context)
                                                                                  .darkText,
                                                                          BlendMode
                                                                              .srcIn),
                                                                      width: Sizes
                                                                          .s24,
                                                                      fit: BoxFit
                                                                          .scaleDown),
                                                            ),
                                                      const VSpace(Sizes.s5),
                                                      Text(e.value.title,
                                                          // Access as property
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: value.selectIndex ==
                                                                  e.key
                                                              ? appCss
                                                                  .dmDenseMedium14
                                                                  .textColor(appColor(
                                                                          context)
                                                                      .primary)
                                                              : appCss
                                                                  .dmDenseRegular14
                                                                  .textColor(appColor(
                                                                          context)
                                                                      .darkText))
                                                    ])
                                                    .marginOnly(
                                                        right: e.key == 1 &&
                                                                lang.getLocal() !=
                                                                    "ar"
                                                            ? 25
                                                            : 0,
                                                        left: e.key == 2 &&
                                                                lang.getLocal() !=
                                                                    "ar"
                                                            ? 25
                                                            : 0)
                                                    .inkWell(
                                                        onTap: () =>
                                                            value.onTap(e.key,
                                                                context)),
                                              ))
                                          .toList()))))),
                  body: NoInternetLayout(child: Center(child: value.pages[value.selectIndex])))));
    });
  }
}
