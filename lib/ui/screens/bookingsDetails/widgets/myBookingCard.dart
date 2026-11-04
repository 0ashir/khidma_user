import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyBookingCard extends StatelessWidget {
  const MyBookingCard({
    super.key,
    required this.booking,
    this.isCustomJobBooking = false,
    this.reserveMoreServicesLine = false,
  });

  final BookingListItem booking;

  /// Whether this card came from the "My Requests" (custom job) tab —
  /// forwarded so booking details knows to pass custom_request_order.
  final bool isCustomJobBooking;

  /// Keeps the "+N more" line's space when this card has none, so cards
  /// sitting side by side on tablet end up the same height.
  final bool reserveMoreServicesLine;

  bool get _isCompleted => booking.status == 'completed';

  bool get _isCancelled => booking.status == 'cancelled';

  void _openDetails(final BuildContext context) {
    Navigator.pushNamed(
      context,
      bookingDetails,
      arguments: {
        "bookingId": booking.id,
        if (isCustomJobBooking) "customRequestOrder": "1",
      },
    );
  }

  void _openChat(final BuildContext context) {
    final provider = booking.provider;
    if (provider == null) return;
    Navigator.pushNamed(
      context,
      chatMessages,
      arguments: {
        "chatUser": ChatUser(
          id: provider.providerId ?? '',
          bookingId: booking.id.toString(),
          bookingStatus: booking.status,
          partnerId: provider.providerId ?? '',
          name: provider.companyName ?? '',
          translatedName: provider.companyName ?? '',
          chatUserType: ChatUserType.providerBooking,
          unReadChats: 0,
          profile: provider.profileImage,
        ),
      },
    );
  }

  Widget _buildHeader(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              'invoiceNumber'.translate(context: context),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              '#${booking.id ?? ''}',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
      const CustomSizedBox(width: 12),
      BookingStatusChip(status: booking.status ?? ''),
    ],
  );

  Widget _buildServiceDetails(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomText(
        booking.serviceName ?? '',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        maxLines: 1,
        color: context.colors.textPrimary,
      ),
      if ((booking.otherServicesCount ?? 0) > 0 || reserveMoreServicesLine) ...[
        const CustomSizedBox(height: 4),
        Opacity(
          opacity: (booking.otherServicesCount ?? 0) > 0 ? 1 : 0,
          child: CustomText(
            (booking.otherServicesCount ?? 0) > 0
                ? '+${booking.otherServicesCount} ${'more'.translate(context: context)}'
                : ' ',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.colors.textBrand,
          ),
        ),
      ],
    ],
  );

  Widget _buildPriceAndDateTime(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomText(
        (booking.finalTotal ?? '0').priceFormat(
          context,
          currencySymbol: booking.currencySymbol,
          decimalPlaces: booking.currencyDecimalPlaces,
        ),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      ),
      const CustomSizedBox(width: 12),
      Container(width: 1, height: 16, color: context.colors.borderDefault),
      const CustomSizedBox(width: 12),
      CustomSvgPicture(
        svgImage: AppAssets.calendar,
        height: 16,
        width: 16,
        color: context.colors.iconSecondary,
        avoideResponsive: true,
      ),
      const CustomSizedBox(width: 4),
      CustomText(
        booking.startDate?.formatDate() ?? '',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textSecondary,
      ),
      const CustomSizedBox(width: 8),
      CustomSvgPicture(
        svgImage: AppAssets.clock,
        height: 16,
        width: 16,
        color: context.colors.iconSecondary,
        avoideResponsive: true,
      ),
      const CustomSizedBox(width: 4),
      CustomText(
        booking.startTime?.localeFormatTime() ?? '',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textSecondary,
      ),
    ],
  );

  Widget _buildProviderRow(final BuildContext context) => Row(
    children: [
      SizedBox(
        height: 32,
        width: 32,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.4),
          child: CustomCachedNetworkImage(
            avoideResponsive: true,
            height: 32,
            width: 32,
            networkImageUrl: booking.provider?.profileImage ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
      const CustomSizedBox(width: 8),
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
                    booking.provider?.companyName ?? '',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    maxLines: 1,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (booking.provider?.isProviderVerified ?? false) ...[
                  const CustomSizedBox(width: 4),
                  CustomSvgPicture(
                    svgImage: AppAssets.verified,
                    height: 16,
                    width: 16,
                    avoideResponsive: true,
                    color: context.colors.iconBrand,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      const CustomSizedBox(width: 8),
      if (_isCompleted)
        if (!isCustomJobBooking && !booking.isCustomJobRequest)
          ReOrderButton(
            bookingId: booking.id ?? '0',
            listBooking: booking,
            isReorderFrom: 'bookingsList',
            cardFrom: 'home',
            compact: true,
          )
        else if (!_isCancelled &&
            (booking.provider?.postBookingAllowed ?? false))
          CustomInkWellContainer(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openChat(context),
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

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const CustomSizedBox(height: 12),
            _buildServiceDetails(context),
            const CustomSizedBox(height: 12),
            _buildPriceAndDateTime(context),
            const CustomSizedBox(height: 12),
            CustomSizedBox(
              height: 1,
              width: double.infinity,
              child: DashedRect(
                color: context.colors.borderStrong,
                strokeWidth: 1,
                gap: 4,
              ),
            ),
            const CustomSizedBox(height: 12),
            _buildProviderRow(context),
          ],
        ),
      ),
    ),
  );
}
