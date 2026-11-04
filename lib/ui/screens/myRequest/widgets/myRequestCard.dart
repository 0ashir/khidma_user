import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestCardContainer extends StatelessWidget {
  const MyRequestCardContainer({
    super.key,
    required this.myRequestDetails,
    this.fillAvailableHeight = false,
  });

  final MyRequestListModel myRequestDetails;

  /// Fills the height its parent gives it (e.g. stretched next to a taller
  /// card on tablet) by letting the description area absorb the extra space,
  /// so budget, divider and bids rows line up between neighbouring cards.
  /// Needs a bounded height, so only set it where the parent provides one.
  final bool fillAvailableHeight;

  void _openDetails(
    final BuildContext context, {
    final bool openProviderBidTab = false,
  }) {
    Navigator.pushNamed(
      context,
      myRequestDetailsScreen,
      arguments: {
        'customJobRequestId': myRequestDetails.id,
        'status': myRequestDetails.status,
        // get_custom_job_request_details doesn't return price — carried
        // over from the list item so the details card can still show it.
        'minPrice': myRequestDetails.minPrice,
        'maxPrice': myRequestDetails.maxPrice,
        'initialTabIndex': openProviderBidTab ? 1 : 0,
      },
    );
  }

  void _openChatWithBidder(
    final BuildContext context,
    final MyRequestBidderSummary bidder,
  ) {
    Navigator.pushNamed(
      context,
      chatMessages,
      arguments: {
        "chatUser": ChatUser(
          partnerId: bidder.id ?? '',
          name: bidder.companyName ?? '',
          translatedName: bidder.companyName ?? '',
          chatUserType: ChatUserType.providerBooking,
          unReadChats: 0,
          profile: bidder.profileImage,
          id: bidder.id ?? '',
          bookingId: myRequestDetails.id ?? '',
          bookingStatus: myRequestDetails.status ?? '',
        ),
      },
    );
  }

  ({Color background, Color text}) _statusColors(
    final BuildContext context,
    final String status,
  ) {
    switch (status) {
      case 'booked':
        return (
          background: context.colors.backgroundSuccessSubtle,
          text: context.colors.textSuccess,
        );
      case 'cancelled':
      case 'expiry':
        return (
          background: context.colors.backgroundErrorSubtle,
          text: context.colors.textError,
        );
      case 'pending':
      default:
        return (
          background: context.colors.backgroundWarningSubtle,
          text: context.colors.textWarning,
        );
    }
  }

  String _statusLabel(final BuildContext context, final String status) {
    switch (status) {
      case 'booked':
        return 'booked'.translate(context: context);
      case 'cancelled':
        return 'cancelled'.translate(context: context);
      case 'expiry':
        return 'expiry'.translate(context: context);
      case 'pending':
      default:
        return 'requested'.translate(context: context);
    }
  }

  Widget _buildHeader(final BuildContext context) {
    final statusColors = _statusColors(context, myRequestDetails.status ?? '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                myRequestDetails.title ?? '',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                myRequestDetails.categoryName ?? '',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.colors.textBrand,
              ),
            ],
          ),
        ),
        const CustomSizedBox(width: 12),
        CustomContainer(
          padding: const EdgeInsets.all(8),
          color: statusColors.background,
          borderRadius: 8,
          child: CustomText(
            _statusLabel(context, myRequestDetails.status ?? ''),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: statusColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetRange(final BuildContext context) {
    final String min = (myRequestDetails.minPrice ?? '0').priceFormat(context);
    final String max = (myRequestDetails.maxPrice ?? '0').priceFormat(context);
    final bool isSinglePrice =
        myRequestDetails.minPrice == myRequestDetails.maxPrice;
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: context.colors.backgroundSecondary,
      borderRadius: 8,
      child: CustomText(
        isSinglePrice ? min : '$min - $max',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildBidderAvatars(final List<MyRequestBidderSummary> bidders) =>
      SizedBox(
        height: 20,
        width: 20 + (bidders.length.clamp(0, 4) - 1) * 12.0,
        child: Stack(
          children: [
            for (int i = 0; i < bidders.length.clamp(0, 4); i++)
              Positioned(
                left: i * 12.0,
                child: ClipOval(
                  child: CustomCachedNetworkImage(
                    avoideResponsive: true,
                    height: 20,
                    width: 20,
                    networkImageUrl: bidders[i].profileImage ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildBottomSection(final BuildContext context) {
    if (myRequestDetails.status == 'booked') {
      final MyRequestBidderSummary? provider =
          myRequestDetails.bidders?.isNotEmpty ?? false
          ? myRequestDetails.bidders!.first
          : null;
      if (provider == null) return const CustomSizedBox();
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.4),
            child: CustomCachedNetworkImage(
              avoideResponsive: true,
              height: 40,
              width: 40,
              networkImageUrl: provider.profileImage ?? '',
              fit: BoxFit.cover,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'provider'.translate(context: context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
                const CustomSizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: CustomText(
                        provider.companyName ?? '',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const CustomSizedBox(width: 4),
                    if (provider.isVerified == 1)
                      CustomSvgPicture(
                        svgImage: AppAssets.verified,
                        height: 16,
                        width: 16,
                        color: context.colors.iconBrand,
                        avoideResponsive: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const CustomSizedBox(width: 8),
          if (provider.postBookingChat == 1)
            CustomInkWellContainer(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openChatWithBidder(context, provider),
              child: CustomContainer(
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundBrandSubtle,
                borderRadius: 8,
                child: CustomSvgPicture(
                  svgImage: AppAssets.chat,
                  height: 24,
                  width: 24,
                  color: context.colors.iconBrand,
                  avoideResponsive: true,
                ),
              ),
            ),
        ],
      );
    }

    final int totalBids = myRequestDetails.totalBids ?? 0;
    if (totalBids == 0) {
      return CustomText(
        'noBidsAvailable'.translate(context: context),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textSecondary,
      );
    }

    final List<MyRequestBidderSummary> bidders = myRequestDetails.bidders ?? [];
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBidderAvatars(bidders),
              const CustomSizedBox(height: 4),
              CustomText(
                '$totalBids ${'bidsReceived'.translate(context: context)}',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
        const CustomSizedBox(width: 8),
        if (myRequestDetails.status != 'cancelled' &&
            myRequestDetails.status != 'expiry')
          CustomInkWellContainer(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openDetails(context, openProviderBidTab: true),
            child: CustomContainer(
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundBrand,
              borderRadius: 8,
              child: CustomText(
                'viewBid'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textInverseLight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(final BuildContext context) {
    final CustomText description = CustomText(
      myRequestDetails.description ?? '',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      maxLines: 2,
      color: context.colors.textSecondary,
    );
    if (!fillAvailableHeight) return description;
    return Expanded(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: description,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: CustomInkWellContainer(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openDetails(context),
      child: CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: context.colors.surfacePrimary,
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: fillAvailableHeight
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            _buildHeader(context),
            const CustomSizedBox(height: 8),
            _buildDescription(context),
            const CustomSizedBox(height: 8),
            _buildBudgetRange(context),
            const CustomSizedBox(height: 12),
            CustomSizedBox(
              height: 1,
              width: double.infinity,
              child: DashedRect(
                color: context.colors.borderDefault,
                strokeWidth: 1,
                gap: 4,
              ),
            ),
            const CustomSizedBox(height: 12),
            fillAvailableHeight
                ? ConstrainedBox(
                    // Bids, no-bids and booked states differ in height, so a
                    // shared minimum keeps the divider in line between cards.
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: _buildBottomSection(context),
                    ),
                  )
                : _buildBottomSection(context),
          ],
        ),
      ),
    ),
  );
}
