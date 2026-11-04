import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/unreadChatCounterBadgeContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const SupportHelpScreen());

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen> {
  final ValueNotifier<int> _unreadCustomerSupportChatCounter = ValueNotifier(0);
  StreamSubscription<ChatNotificationData>?
  _chatUserNotificationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _listenToCustomerSupportChatNotifications();
  }

  @override
  void dispose() {
    _unreadCustomerSupportChatCounter.dispose();
    _chatUserNotificationStreamSubscription?.cancel();
    super.dispose();
  }

  void _listenToCustomerSupportChatNotifications() {
    final state = context.read<UserDetailsCubit>().state;
    if (state is UserDetails) {
      _unreadCustomerSupportChatCounter.value =
          state.userDetailsModel.unreadCustomerSupportChatCount ?? 0;
    }
    _chatUserNotificationStreamSubscription = ChatNotificationsUtils
        .notificationStreamController
        .stream
        .listen((event) {
          if (event.fromUser.chatUserType == ChatUserType.adminSupport) {
            _unreadCustomerSupportChatCounter.value++;
          }
        });
  }

  Widget _buildRow({
    required final String icon,
    required final String title,
    required final VoidCallback onTap,
    final int unreadCount = 0,
  }) => CustomContainer(
    width: double.infinity,
    color: context.colors.surfacePrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    padding: const EdgeInsets.all(12),
    child: CustomInkWellContainer(
      onTap: onTap,
      child: Row(
        children: [
          CustomContainer(
            color: context.colors.backgroundSecondary,
            borderRadius: 24,
            padding: const EdgeInsets.all(8),
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: icon,
              color: context.colors.iconPrimary,
              height: 20,
              width: 20,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              title,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          if (unreadCount > 0) ...[
            UnreadChatCounterBadgeContainer(count: unreadCount),
            const CustomSizedBox(width: 8),
          ],
          CustomSvgPicture(
            svgImage:
                Directionality.of(
                  context,
                ).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? AppAssets.backArrow
                : AppAssets.backArrowLtr,
            color: context.colors.iconPrimary,
            height: 24,
            width: 24,
            avoideResponsive: true,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'helpAndSupport'.translate(context: context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder(
              valueListenable: _unreadCustomerSupportChatCounter,
              builder: (_, value, _) => _buildRow(
                icon: AppAssets.support,
                title: 'customerSupport'.translate(context: context),
                unreadCount: value,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    chatMessages,
                    arguments: {
                      "chatUser": ChatUser(
                        id: "",
                        name: "customerSupport".translate(context: context),
                        translatedName: "customerSupport".translate(
                          context: context,
                        ),
                        unReadChats: 0,
                        partnerId: null,
                        chatUserType: ChatUserType.adminSupport,
                      ),
                    },
                  ).then((_) {
                    _unreadCustomerSupportChatCounter.value = 0;
                  });
                },
              ),
            ),
            const CustomSizedBox(height: 16),
            _buildRow(
              icon: AppAssets.drHelp,
              title: 'faqs'.translate(context: context),
              onTap: () {
                Navigator.pushNamed(context, faqsRoute);
              },
            ),
            const CustomSizedBox(height: 16),
            _buildRow(
              icon: AppAssets.drContactUs,
              title: 'contactUs'.translate(context: context),
              onTap: () {
                Navigator.pushNamed(context, contactUsRoute);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
