import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/chatUnreadCountBadge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({final Key? key}) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => CustomNavigationBarState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final BuildContext context) =>
        CustomNavigationBar(key: UiUtils.bottomNavigationBarGlobalKey),
  );
}

class CustomNavigationBarState extends State<CustomNavigationBar>
    with WidgetsBindingObserver {
  String? currentVersion;
  ValueNotifier<int> selectedIndexOfBottomNavigationBar = ValueNotifier(0);
  List<ScrollController> scrollControllerList = [];

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final backgroundChatMessages = await ChatNotificationsRepository()
          .getBackgroundChatNotificationData();

      if (backgroundChatMessages.isNotEmpty) {
        //empty any old data and stream new once
        ChatNotificationsRepository().setBackgroundChatNotificationData(
          data: [],
        );
        for (int i = 0; i < backgroundChatMessages.length; i++) {
          ChatNotificationsUtils.addChatStreamValue(
            chatData: backgroundChatMessages[i],
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (enableAds) {
      MobileAds.instance.initialize();
    }

    WidgetsBinding.instance.addObserver(this);

    for (int i = 0; i < 5; i++) {
      scrollControllerList.add(ScrollController());
    }
    Future.delayed(Duration.zero).then((final value) {
      if (!mounted) return;
      context.read<VerifyOtpCubit>().setInitialState();
      context.read<SendVerificationCodeCubit>().setInitialState();
    });
    fetchCurrentVersion();

    if (Routes.globelProviderSlugForDeeplink != '') {
      Navigator.pushNamed(
        context,
        providerRoute,
        arguments: {
          "providerId": Routes.globelProviderSlugForDeeplink,
          'type': ProviderDetailsParamType.slug,
        },
      );
    }
  }

  Future<void> fetchCurrentVersion() async {
    try {
      currentVersion = await PackageInfo.fromPlatform().then(
        (final value) => value.version,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    selectedIndexOfBottomNavigationBar.dispose();

    // Use a more robust disposal approach
    for (int i = 0; i < scrollControllerList.length; i++) {
      final controller = scrollControllerList[i];
      try {
        // Check if controller is still valid before disposing
        if (controller.hasClients) {
          controller.dispose();
        }
      } catch (e) {
        // Log the error but don't crash the app
        debugPrint('Error disposing ScrollController $i: $e');
      }
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(
    final BuildContext context,
  ) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedIndexOfBottomNavigationBar,
        builder: (final context, final Object? value, final Widget? child) =>
            PopScope(
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  selectedIndexOfBottomNavigationBar.value = 0;
                  return;
                }
              },
              canPop: selectedIndexOfBottomNavigationBar.value == 0,
              child: Stack(
                children: [
                  IndexedStack(
                    sizing: StackFit.passthrough,
                    index: selectedIndexOfBottomNavigationBar.value,
                    children: [
                      HomeScreen(scrollController: scrollControllerList[0]),
                      BookingsScreen(
                        key: UiUtils.bookingScreenGlobalKey,
                        scrollController: scrollControllerList[1],
                      ),
                      const ChatUsersScreen(),
                      MyRequestListScreen(
                        scrollController: scrollControllerList[3],
                      ),
                      ProfileScreen(
                        scrollController: scrollControllerList[4],
                        currentVersion: '1.0.0',
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (final context, final cartState) {
                        // The Home tab draws its own cart bar (see
                        // homeScreen.dart) flush above this bar with zero
                        // gap. When it's showing, this bar must render flat
                        // (no top radius/shadow of its own) so the two read
                        // as one seamless card with a single hairline
                        // divider — matching Figma's combined component.
                        final hasCartItems =
                            cartState is CartFetchSuccess &&
                            (int.tryParse(
                                      cartState.cartData.totalQuantity ?? '0',
                                    ) ??
                                    0) !=
                                0 &&
                            (cartState.cartData.cartDetails?.isNotEmpty ??
                                false);
                        final attachedToCartBar =
                            selectedIndexOfBottomNavigationBar.value == 0 &&
                            hasCartItems;

                        // Clip the shadow at the bar's bottom edge so it does
                        // not bleed onto the system navigation bar area.
                        return ClipShadowBottom(
                          child: CustomContainer(
                            width: double.infinity,
                            color: context.colors.backgroundPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            borderRadiusStyle: attachedToCartBar
                                ? null
                                : const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                            clipBehavior: Clip.antiAlias,
                            border: attachedToCartBar
                                ? Border(
                                    top: BorderSide(
                                      color: context.colors.borderDefault,
                                      width: 1,
                                    ),
                                  )
                                : null,
                            boxShadow: attachedToCartBar
                                ? null
                                : [
                                    BoxShadow(
                                      color: context.colors.overlayFooterShadow,
                                      blurRadius: 16,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                            child: BottomNavigationBar(
                              backgroundColor: Colors.transparent,
                              selectedItemColor: context.colors.textBrand,
                              unselectedItemColor: context.colors.textSecondary,
                              selectedLabelStyle: const TextStyle(
                                fontSize: 12,
                                height: 18 / 12,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 12,
                                height: 18 / 12,
                                fontWeight: FontWeight.w400,
                              ),
                              currentIndex:
                                  selectedIndexOfBottomNavigationBar.value,
                              showUnselectedLabels: true,
                              showSelectedLabels: true,
                              elevation: 0,
                              type: BottomNavigationBarType.fixed,
                              onTap: (final int selectedIndex) {
                                final previousSelectedIndex =
                                    selectedIndexOfBottomNavigationBar.value;
                                selectedIndexOfBottomNavigationBar.value =
                                    selectedIndex;
                                //animate scroll to top when pressing the item twice
                                if (previousSelectedIndex == selectedIndex &&
                                    scrollControllerList[selectedIndex]
                                        .hasClients &&
                                    scrollControllerList[selectedIndex]
                                        .positions
                                        .isNotEmpty) {
                                  try {
                                    scrollControllerList[selectedIndex]
                                        .animateTo(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                  } catch (e) {
                                    debugPrint('Error animating scroll: $e');
                                  }
                                }

                                if (HiveRepository.getUserToken == '' &&
                                    selectedIndex == 1 &&
                                    previousSelectedIndex != 1) {
                                  UiUtils.showBottomSheet(
                                    context: context,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    child: const LoginRequiredBottomSheet(),
                                  );
                                }
                                if (HiveRepository.getUserToken == '' &&
                                    selectedIndex == 3 &&
                                    previousSelectedIndex != 3) {
                                  UiUtils.showBottomSheet(
                                    context: context,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    child: const LoginRequiredBottomSheet(),
                                  );
                                }
                              },
                              items: [
                                _getBottomNavigationBarItem(
                                  activeImage: AppAssets.activeExplore,
                                  deActiveImage: AppAssets.inactiveExplore,
                                  title: 'explore'.translate(context: context),
                                  index: 0,
                                  currentIndex:
                                      selectedIndexOfBottomNavigationBar.value,
                                ),
                                _getBottomNavigationBarItem(
                                  activeImage: AppAssets.activeBooking,
                                  deActiveImage: AppAssets.inactiveBooking,
                                  title: 'booking'.translate(context: context),
                                  index: 1,
                                  currentIndex:
                                      selectedIndexOfBottomNavigationBar.value,
                                ),
                                _getBottomNavigationBarItem(
                                  activeImage: AppAssets.activeChat,
                                  deActiveImage: AppAssets.inactiveChat,
                                  title: 'chat'.translate(context: context),
                                  index: 2,
                                  currentIndex:
                                      selectedIndexOfBottomNavigationBar.value,
                                  iconBuilder: (icon) =>
                                      _ChatNavIconWithBadge(icon: icon),
                                ),
                                _getBottomNavigationBarItem(
                                  activeImage: AppAssets.activeMyReq,
                                  deActiveImage: AppAssets.inactiveMyReq,
                                  title: 'myRequests'.translate(
                                    context: context,
                                  ),
                                  index: 3,
                                  currentIndex:
                                      selectedIndexOfBottomNavigationBar.value,
                                ),
                                _getBottomNavigationBarItem(
                                  activeImage: AppAssets.activeProfile,
                                  deActiveImage: AppAssets.inactiveProfile,
                                  title: 'profile'.translate(context: context),
                                  index: 4,
                                  currentIndex:
                                      selectedIndexOfBottomNavigationBar.value,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    ),
  );

  BottomNavigationBarItem _getBottomNavigationBarItem({
    required final String activeImage,
    required final String deActiveImage,
    required final String title,
    required final int index,
    required final int currentIndex,
    final Widget Function(Widget icon)? iconBuilder,
  }) {
    final icon = currentIndex == index
        ? CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            borderRadius: 16,
            color: context.colors.backgroundBrandSubtle,
            child: CustomSvgPicture(
              svgImage: activeImage,
              height: 24,
              width: 24,
              color: context.colors.textBrand,
              avoideResponsive: true,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: CustomSvgPicture(
              svgImage: deActiveImage,
              color: context.colors.iconSecondary,
              height: 24,
              width: 24,
              avoideResponsive: true,
            ),
          );
    return BottomNavigationBarItem(
      icon: iconBuilder != null ? iconBuilder(icon) : icon,
      label: title,
    );
  }
}

class _ChatNavIconWithBadge extends StatelessWidget {
  final Widget icon;
  const _ChatNavIconWithBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnquiryChatUserCubit, ChatUsersState>(
      builder: (context, enquiryState) {
        return BlocBuilder<BookingChatUserCubit, ChatUsersState>(
          builder: (context, bookingState) {
            final enquiryUnread = enquiryState is ChatUsersFetchSuccess
                ? enquiryState.totalUnreadUsers
                : 0;
            final bookingUnread = bookingState is ChatUsersFetchSuccess
                ? bookingState.totalUnreadUsers
                : 0;
            final totalUnread = enquiryUnread + bookingUnread;
            if (totalUnread <= 0) {
              return icon;
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                icon,
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: ChatUnreadCountBadge(
                    count: totalUnread,
                    fontSize: 10.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    borderColor: context.colors.borderWhite,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
