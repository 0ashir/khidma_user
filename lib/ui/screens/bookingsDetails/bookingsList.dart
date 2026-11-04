import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingsList extends StatefulWidget {
  const BookingsList({
    super.key,
    required this.onRefresh,
    this.isCustomBooking = false,
  });

  final VoidCallback onRefresh;
  final bool isCustomBooking;

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  bool _ongoingCollapsed = false;
  bool _upcomingCollapsed = false;
  bool _completedCollapsed = false;
  bool _cancelledCollapsed = false;

  Widget _getBookingShimmerLoading(final BuildContext context) {
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    return isTablet
        ? GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  height: 230.rh(context),
                ),
            itemCount: UiUtils.numberOfShimmerContainer,
            itemBuilder: (context, index) {
              return const CustomShimmerLoadingContainer(
                height: 260,
                borderRadius: 10,
              );
            },
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemCount: UiUtils.numberOfShimmerContainer,
            itemBuilder: (context, index) {
              return const CustomShimmerLoadingContainer(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                height: 240,
                borderRadius: 10,
              );
            },
          );
  }

  Widget _buildSectionHeader(
    final BuildContext context,
    final String titleKey,
    final bool isCollapsed,
    final VoidCallback onToggle,
  ) => CustomInkWellContainer(
    showRippleEffect: false,
    onTap: onToggle,
    child: Row(
      children: [
        Expanded(
          child: CustomText(
            titleKey.translate(context: context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
        AnimatedRotation(
          duration: const Duration(milliseconds: 300),
          turns: isCollapsed ? 0.5 : 0,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildOngoingSection(
    final BuildContext context,
    final List<BookingListItem> items,
  ) {
    final bool anyHasMoreServices = items.any(
      (final b) => (b.otherServicesCount ?? 0) > 0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          'ongoingBooking',
          _ongoingCollapsed,
          () => setState(() => _ongoingCollapsed = !_ongoingCollapsed),
        ),
        const CustomSizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: _ongoingCollapsed
              ? const CustomSizedBox()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (i > 0) const CustomSizedBox(width: 12),
                        OngoingBookingCard(
                          booking: items[i],
                          reserveMoreServicesLine: anyHasMoreServices,
                          isCustomJobBooking: widget.isCustomBooking,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Whether either card in the tablet row starting at [start] shows a
  /// "+N more" line.
  bool _pairHasMoreServices(
    final List<BookingListItem> items,
    final int start,
  ) => items
      .skip(start)
      .take(2)
      .any((final b) => (b.otherServicesCount ?? 0) > 0);

  Widget _buildCardsBody(
    final BuildContext context,
    final List<BookingListItem> items,
  ) {
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    if (!isTablet) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items)
            MyBookingCard(
              booking: item,
              isCustomJobBooking: widget.isCustomBooking,
            ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MyBookingCard(
                    booking: items[i],
                    isCustomJobBooking: widget.isCustomBooking,
                    reserveMoreServicesLine: _pairHasMoreServices(items, i),
                  ),
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: i + 1 < items.length
                      ? MyBookingCard(
                          booking: items[i + 1],
                          isCustomJobBooking: widget.isCustomBooking,
                          reserveMoreServicesLine: _pairHasMoreServices(
                            items,
                            i,
                          ),
                        )
                      : const CustomSizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalSection(
    final BuildContext context,
    final String titleKey,
    final List<BookingListItem> items,
    final bool isCollapsed,
    final VoidCallback onToggle,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildSectionHeader(context, titleKey, isCollapsed, onToggle),
      const CustomSizedBox(height: 8),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        child: isCollapsed
            ? const CustomSizedBox()
            : _buildCardsBody(context, items),
      ),
    ],
  );

  Widget _buildBucketsBody(
    final BuildContext context,
    final BookingBuckets buckets,
  ) {
    final ongoing = buckets.ongoingBookings ?? [];
    final upcoming = buckets.upcomingBookings ?? [];
    final completed = buckets.completedBookings ?? [];
    final cancelled = buckets.cancelledBookings ?? [];

    if (ongoing.isEmpty &&
        upcoming.isEmpty &&
        completed.isEmpty &&
        cancelled.isEmpty) {
      return Center(
        child: NoDataFoundWidget(
          titleKey: 'noBookingFound'.translate(context: context),
          subtitleKey: 'noBookingFoundSubTitle'.translate(context: context),
        ),
      );
    }

    return CustomRefreshIndicator(
      onRefreshCallback: widget.onRefresh,
      displacment: 12,
      child: ListView(
        padding: EdgeInsetsDirectional.only(
          start: 10,
          end: 10,
          top: 16,
          bottom: UiUtils.getScrollViewBottomPadding(context) + 16,
        ),
        children: [
          if (ongoing.isNotEmpty) ...[
            _buildOngoingSection(context, ongoing),
            const CustomSizedBox(height: 16),
          ],
          if (upcoming.isNotEmpty) ...[
            _buildVerticalSection(
              context,
              'upcomingBooking',
              upcoming,
              _upcomingCollapsed,
              () => setState(() => _upcomingCollapsed = !_upcomingCollapsed),
            ),
            const CustomSizedBox(height: 16),
          ],
          if (completed.isNotEmpty) ...[
            _buildVerticalSection(
              context,
              'completedBooking',
              completed,
              _completedCollapsed,
              () => setState(() => _completedCollapsed = !_completedCollapsed),
            ),
            const CustomSizedBox(height: 16),
          ],
          if (cancelled.isNotEmpty)
            _buildVerticalSection(
              context,
              'cancelledBooking',
              cancelled,
              _cancelledCollapsed,
              () => setState(() => _cancelledCollapsed = !_cancelledCollapsed),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<BookingCubit, BookingState>(
        builder: (final BuildContext context, final BookingState state) {
          if (state is BookingFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              onTapRetry: widget.onRefresh,
            );
          }
          if (state is BookingFetchSuccess) {
            return _buildBucketsBody(context, state.buckets);
          }
          return _getBookingShimmerLoading(context);
        },
      );
}
