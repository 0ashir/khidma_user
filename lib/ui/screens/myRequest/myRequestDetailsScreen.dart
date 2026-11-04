import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/myRequestDetails/myRequestAttachmentCard.dart';
import 'widgets/myRequestDetails/myRequestBidTab.dart';
import 'widgets/myRequestDetails/myRequestBidderCard.dart';
import 'widgets/myRequestDetails/myRequestCancelButton.dart';
import 'widgets/myRequestDetails/myRequestDetailsCard.dart';
import 'widgets/myRequestDetails/myRequestSummaryCard.dart';

class MyRequestDetailsScreen extends StatefulWidget {
  const MyRequestDetailsScreen({
    final Key? key,
    required this.customJobRequestId,
    required this.status,
    this.minPrice,
    this.maxPrice,
    this.bookingId,
    this.initialTabIndex = 0,
  }) : super(key: key);

  final String customJobRequestId;
  final String status;
  final String? minPrice;
  final String? maxPrice;
  final String? bookingId;
  final int initialTabIndex;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => MyRequestDetailsScreen(
        customJobRequestId: arguments['customJobRequestId'],
        status: arguments['status'],
        minPrice: arguments['minPrice'],
        maxPrice: arguments['maxPrice'],
        bookingId: arguments['bookingId'],
        initialTabIndex: arguments['initialTabIndex'] ?? 0,
      ),
    );
  }

  @override
  State<MyRequestDetailsScreen> createState() => _MyRequestDetailsScreenState();
}

class _MyRequestDetailsScreenState extends State<MyRequestDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    fetchServiceDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void fetchServiceDetails() {
    context.read<MyRequestDetailsCubit>().fetchRequestDetails(
      customJobRequestId: widget.customJobRequestId,
    );
  }

  void _startCountdown(final CustomJob job) {
    _countdownTimer?.cancel();
    final endDt = _parseDateTime(job.endDateTime ?? '');
    if (endDt == null) return;
    _tick(endDt);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick(endDt);
    });
  }

  void _tick(final DateTime expiry) {
    final remaining = expiry.difference(DateTime.now());
    if (mounted)
      setState(
        () => _timeLeft = remaining.isNegative ? Duration.zero : remaining,
      );
  }

  DateTime? _parseDateTime(final String raw) {
    if (raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  bool _canCancel(final String? status) =>
      status != 'cancelled' && status != 'booked' && status != 'expiry';

  Widget _buildShimmer() => const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        CustomShimmerLoadingContainer(borderRadius: 8, height: 180),
        CustomSizedBox(height: 12),
        CustomShimmerLoadingContainer(borderRadius: 8, height: 220),
        CustomSizedBox(height: 12),
        CustomShimmerLoadingContainer(borderRadius: 8, height: 120),
      ],
    ),
  );

  Widget _buildRequestDetailsTab(
    final BuildContext context,
    final CustomJob job,
  ) => SingleChildScrollView(
    controller: _scrollController,
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      UiUtils.getScrollViewBottomPadding(context) + 25,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyRequestSummaryCard(
          job: job,
          minPrice: widget.minPrice,
          maxPrice: widget.maxPrice,
          timeLeft: _timeLeft,
        ),
        const CustomSizedBox(height: 12),
        MyRequestDetailsCard(job: job),
        const CustomSizedBox(height: 12),
        MyRequestAttachmentCard(job: job),
        const CustomSizedBox(height: 12),
      ],
    ),
  );

  Widget _buildBookedRequestBody(
    final BuildContext context,
    final CustomJob job,
    final String currentStatus,
  ) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      UiUtils.getScrollViewBottomPadding(context) + 25,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyRequestSummaryCard(
          job: job,
          minPrice: widget.minPrice,
          maxPrice: widget.maxPrice,
          timeLeft: _timeLeft,
        ),
        if (job.bidDetails != null) ...[
          const CustomSizedBox(height: 16),
          CustomText(
            'selectedProviderBid'.translate(context: context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 8),
          MyRequestBidderCard(
            bidder: job.bidDetails!,
            currentStatus: currentStatus,
            canBook: _canCancel(currentStatus),
            customJobRequestId: widget.customJobRequestId,
          ),
        ],
        const CustomSizedBox(height: 12),
        MyRequestDetailsCard(job: job),
        const CustomSizedBox(height: 12),
        MyRequestAttachmentCard(job: job),
      ],
    ),
  );

  Widget _buildBottomButton({
    required final String label,
    required final VoidCallback onTap,
  }) => ClipShadowBottom(
    child: CustomContainer(
      width: double.infinity,
      color: context.colors.backgroundPrimary,
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
      boxShadow: [
        BoxShadow(
          color: context.colors.overlayFooterShadow,
          offset: const Offset(0, -2),
          blurRadius: 8,
        ),
      ],
      child: CustomRoundedButton(
        widthPercentage: 1,
        height: 48,
        radius: UiUtils.borderRadiusOf12,
        backgroundColor: context.colors.backgroundBrand,
        titleColor: context.colors.textInverseLight,
        buttonTitle: label,
        showBorder: false,
        textSize: 16,
        fontWeight: FontWeight.w500,
        onTap: onTap,
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) {
    return BlocConsumer<MyRequestDetailsCubit, MyRequestDetailsState>(
      listener: (ctx, state) {
        if (state is MyRequestDetailsSuccess) {
          _startCountdown(state.requestCustomJob);
        }
      },
      builder: (ctx, state) {
        final String currentStatus = state is MyRequestDetailsSuccess
            ? (state.requestCustomJob.status ?? widget.status)
            : widget.status;

        final int bidCount = state is MyRequestDetailsSuccess
            ? state.bidders.length
            : 0;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: UiUtils.getSystemUiOverlayStyle(context: context),
          child: AnnotatedSafeArea(
            isAnnotated: true,
            applyBottomInset: false,
            child: Scaffold(
              backgroundColor: context.colors.backgroundSecondary,
              appBar: UiUtils.getSimpleAppBar(
                context: context,
                title: 'requestDetails'.translate(context: context),
                isLeadingIconEnable: true,
                bottom: currentStatus == 'booked'
                    ? null
                    : PreferredSize(
                        preferredSize: const Size.fromHeight(44),
                        child: TopRoundedUnderlineTabBar(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              color: context.colors.overlayHeaderShadow,
                            ),
                          ],
                          controller: _tabController,
                          height: 44,
                          tabs: [
                            Text('requestDetails'.translate(context: context)),
                            Text(
                              '${'providerBid'.translate(context: context)} ($bidCount)',
                            ),
                          ],
                        ),
                      ),
              ),
              body: () {
                if (state is MyRequestDetailsInProgress) {
                  return _buildShimmer();
                }
                if (state is MyRequestDetailsFailure) {
                  return ErrorContainer(
                    errorMessage: state.errorMessage.translate(
                      context: context,
                    ),
                    onTapRetry: fetchServiceDetails,
                    showRetryButton: true,
                  );
                }
                if (state is MyRequestDetailsSuccess) {
                  final job = state.requestCustomJob;
                  if (currentStatus == 'booked') {
                    return _buildBookedRequestBody(context, job, currentStatus);
                  }
                  return Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRequestDetailsTab(context, job),
                          MyRequestBidTab(
                            bidders: state.bidders,
                            currentStatus: currentStatus,
                            canBook: _canCancel(currentStatus),
                            customJobRequestId: widget.customJobRequestId,
                            selectedSortBy: state.selectedSortBy,
                            isSorting: state.isSortingBidders,
                          ),
                        ],
                      ),
                      if (_canCancel(currentStatus))
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: MyRequestCancelButton(
                            job: job,
                            customJobRequestId: widget.customJobRequestId,
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }(),
              bottomNavigationBar: currentStatus == 'booked'
                  ? _buildBottomButton(
                      label: 'viewBooking'.translate(context: context),
                      onTap: () => Navigator.pushNamed(
                        context,
                        bookingDetails,
                        arguments: {
                          'bookingId': state is MyRequestDetailsSuccess
                              ? state.requestCustomJob.orderId
                              : widget.bookingId,
                        },
                      ),
                    )
                  : currentStatus == 'expiry'
                  ? _buildBottomButton(
                      label: 'requestNewService'.translate(context: context),
                      onTap: () => Navigator.pushNamed(
                        context,
                        requestServiceCategorySelectionScreen,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
