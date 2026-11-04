import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const NotificationScreen());

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _processingNotificationId;

  void fetchNotifications() {
    context.read<NotificationsCubit>().fetchNotifications();
  }

  /// Returns the date group key for a notification (used for grouping)
  String _getDateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else {
      return '${date.day}_${date.month}_${date.year}';
    }
  }

  /// Returns the translated title for a date group
  String _getGroupTitle(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) {
      return 'today'.translate(context: context);
    } else if (difference == 1) {
      return 'yesterday'.translate(context: context);
    } else {
      // Format as "1 March, 2025" using intl DateFormat with locale
      final languageCode =
          StringExtension.getValidLanguageCode(
            HiveRepository.getCurrentLanguage()?.languageCode,
          ) ??
          'en';
      return DateFormat('d MMMM, y', languageCode).format(date);
    }
  }

  /// Determines the location of the notification item within its group
  NotificationItemLocation _getItemLocation(
    List<NotificationDataModel> notifications,
    int index,
  ) {
    final currentKey = _getDateGroupKey(notifications[index].dateSent);

    final bool hasPreviousInGroup =
        index > 0 &&
        _getDateGroupKey(notifications[index - 1].dateSent) == currentKey;

    final bool hasNextInGroup =
        index < notifications.length - 1 &&
        _getDateGroupKey(notifications[index + 1].dateSent) == currentKey;

    if (!hasPreviousInGroup && !hasNextInGroup) {
      return NotificationItemLocation.onlyOne;
    } else if (!hasPreviousInGroup && hasNextInGroup) {
      return NotificationItemLocation.first;
    } else if (hasPreviousInGroup && !hasNextInGroup) {
      return NotificationItemLocation.last;
    } else {
      return NotificationItemLocation.middle;
    }
  }

  bool _shouldShowArrow(dynamic notification) {
    final String? notificationType = notification.type;
    if (notificationType == null) return false;

    final String lowerType = notificationType.toLowerCase();
    return lowerType != 'general' &&
        lowerType != 'personal' &&
        lowerType != 'cart_reminder';
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((final value) {
      fetchNotifications();
    });

    _scrollController.addListener(() {
      if (!context.read<NotificationsCubit>().hasMoreNotification()) {
        return;
      }
      final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > nextPageTrigger) {
        if (mounted) {
          context.read<NotificationsCubit>().fetchMoreNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget notificationShimmerLoadingContainer({
    required final int noOfShimmerContainer,
  }) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    child: Column(
      children: List.generate(
        noOfShimmerContainer,
        (final int index) => Padding(
          padding: const EdgeInsets.all(8),
          child: CustomShimmerLoadingContainer(
            borderRadius: UiUtils.borderRadiusOf10,
            width: context.screenWidth,
            height: 92,
          ),
        ),
      ).toList(),
    ),
  );

  @override
  Widget build(final BuildContext context) => InterstitialAdWidget(
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'notification'.translate(context: context),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: const BannerAdWidget(),
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (final BuildContext context, final NotificationsState state) {
            if (state is NotificationFetchFailure) {
              return ErrorContainer(
                onTapRetry: () {
                  fetchNotifications();
                },
                errorMessage: state.errorMessage.translate(context: context),
              );
            }
            if (state is NotificationFetchSuccess) {
              return state.notificationsList.isEmpty
                  ? Center(
                      child: NoDataFoundWidget(
                        imagePath: AppAssets.noNotifications,
                        titleKey: 'noNotificationsFound'.translate(
                          context: context,
                        ),
                        subtitleKey: 'noNotificationsFoundSubTitle'.translate(
                          context: context,
                        ),
                      ),
                    )
                  : CustomRefreshIndicator(
                      displacment: 12,
                      onRefreshCallback: () {
                        fetchNotifications();
                      },
                      child: BlocProvider(
                        create: (context) => DeleteNotificationCubit(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              state.notificationsList.length +
                              (state.isLoadingMoreData ? 1 : 0),
                          itemBuilder: (final BuildContext context, final index) {
                            if (index >= state.notificationsList.length) {
                              return Center(
                                child: notificationShimmerLoadingContainer(
                                  noOfShimmerContainer: 1,
                                ),
                              );
                            }
                            final notification = state.notificationsList[index];

                            final NotificationItemLocation itemLocation =
                                _getItemLocation(
                                  state.notificationsList,
                                  index,
                                );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (itemLocation ==
                                        NotificationItemLocation.first ||
                                    itemLocation ==
                                        NotificationItemLocation.onlyOne) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 4,
                                    ),
                                    child: CustomText(
                                      _getGroupTitle(
                                        context,
                                        notification.dateSent,
                                      ),
                                      maxLines: 1,
                                      color: context.colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                                NotificationItemContainer(
                                  notification: notification,
                                  showArrow: _shouldShowArrow(notification),
                                  isLoading:
                                      _processingNotificationId ==
                                      notification.id.toString(),
                                  onSlideTap: () async {
                                    if (!_shouldShowArrow(notification)) {
                                      return;
                                    }
                                    if (_processingNotificationId != null) {
                                      return;
                                    }

                                    final String? notificationType =
                                        notification.type;
                                    if (notificationType != null &&
                                        notificationType.toLowerCase() ==
                                            'provider') {
                                      if (notification.translatedProviderName
                                              .toString() ==
                                          '') {
                                        UiUtils.showMessage(
                                          context,
                                          'thisProviderIsNotAvailable'
                                              .translate(context: context),
                                          ToastificationType.error,
                                        );
                                        return;
                                      }
                                    }

                                    final String lowerType =
                                        notificationType?.toLowerCase() ?? '';

                                    final Map<String, dynamic>
                                    notificationData = {
                                      'type': notificationType ?? '',
                                      'type_id': notification.typeId ?? '',
                                      'order_id': notification.orderId ?? '',
                                      'booking_id': notification.orderId ?? '',
                                      'provider_id': notification.typeId ?? '',
                                      'category_id': notification.typeId ?? '',
                                      'category_name':
                                          notification.translatedCategoryName ??
                                          '',
                                      'url': notification.url ?? '',
                                      'body': notification.message ?? '',
                                      'title': notification.title ?? '',
                                      'custom_job_request_id':
                                          notification.customJobRequestId ?? '',
                                      'blog_id': notification.typeId ?? '',
                                      // Set parent_id for category/subcategory handling
                                      'parent_id': (lowerType == 'category')
                                          ? '0'
                                          : (lowerType == 'subcategory' ||
                                                lowerType.replaceAll(' ', '') ==
                                                    'subcategory')
                                          ? '1'
                                          : '',
                                    };

                                    // Set loading state before async call
                                    setState(() {
                                      _processingNotificationId = notification
                                          .id
                                          .toString();
                                    });

                                    try {
                                      // Handle notification redirection using the same logic as notificationService
                                      await NotificationService.handleNotificationRedirection(
                                        notificationData,
                                      );
                                    } finally {
                                      // Clear loading state after async call completes
                                      if (mounted) {
                                        setState(() {
                                          _processingNotificationId = null;
                                        });
                                      }
                                    }
                                  },
                                  slidableChild: notification.type != 'personal'
                                      ? null
                                      : BlocConsumer<
                                          DeleteNotificationCubit,
                                          DeleteNotificationsState
                                        >(
                                          listener:
                                              (
                                                final BuildContext context,
                                                final DeleteNotificationsState
                                                removeNotificationState,
                                              ) {
                                                if (removeNotificationState
                                                    is DeleteNotificationSuccess) {
                                                  UiUtils.showMessage(
                                                    context,
                                                    'notificationDeletedSuccessfully'
                                                        .translate(
                                                          context: context,
                                                        ),
                                                    ToastificationType.success,
                                                  );
                                                  context
                                                      .read<
                                                        NotificationsCubit
                                                      >()
                                                      .removeNotificationFromList(
                                                        removeNotificationState
                                                            .notificationId,
                                                      );
                                                } else if (removeNotificationState
                                                    is DeleteNotificationFailure) {
                                                  UiUtils.showMessage(
                                                    context,
                                                    removeNotificationState
                                                        .errorMessage,
                                                    ToastificationType.error,
                                                  );
                                                }
                                              },
                                          builder:
                                              (
                                                final BuildContext context,
                                                final DeleteNotificationsState
                                                removeNotificationState,
                                              ) {
                                                if (removeNotificationState
                                                    is DeleteNotificationInProgress) {
                                                  if (notification.id ==
                                                      removeNotificationState
                                                          .notificationId) {
                                                    return Center(
                                                      child: CustomContainer(
                                                        color:
                                                            Colors.transparent,
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CustomCircularProgressIndicator(
                                                              color: context
                                                                  .colors
                                                                  .iconTertiary,
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                }

                                                return SlidableAction(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  autoClose: false,
                                                  onPressed: (final context) {
                                                    context
                                                        .read<
                                                          DeleteNotificationCubit
                                                        >()
                                                        .deleteNotification(
                                                          state
                                                              .notificationsList[index]
                                                              .id
                                                              .toString(),
                                                        );
                                                  },
                                                  icon: Icons.delete,
                                                  label: 'delete'.translate(
                                                    context: context,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        UiUtils
                                                            .borderRadiusOf10,
                                                      ),
                                                );
                                              },
                                        ),
                                ),
                                const CustomSizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      ),
                    );
            }
            return notificationShimmerLoadingContainer(
              noOfShimmerContainer: UiUtils.numberOfShimmerContainer,
            );
          },
        ),
      ),
    ),
  );
}
