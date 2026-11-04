import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class OngoingBookingCard extends StatelessWidget {
  const OngoingBookingCard({
    super.key,
    required this.booking,
    this.reserveMoreServicesLine = false,
    this.isCustomJobBooking = false,
  });

  final BookingListItem booking;
  final bool reserveMoreServicesLine;
  final bool isCustomJobBooking;

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

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(12),
    onTap: () => _openDetails(context),
    child: CustomContainer(
      width: 300,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'dateAndTime'.translate(context: context),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                    ),
                    const CustomSizedBox(height: 4),
                    CustomText(
                      '${booking.startDate?.formatDate() ?? ''}, ${booking.startTime?.localeFormatTime() ?? ''}',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
              const CustomSizedBox(width: 8),
              BookingStatusChip(status: booking.status ?? ''),
            ],
          ),
          const CustomSizedBox(height: 16),
          CustomText(
            booking.serviceName ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            maxLines: 1,
            color: context.colors.textPrimary,
          ),
          if ((booking.otherServicesCount ?? 0) > 0 ||
              reserveMoreServicesLine) ...[
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
          Row(
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
                    networkImageUrl: booking.provider?.profileImage ?? "",
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
              if (booking.provider?.postBookingAllowed ?? false) ...[
                const CustomSizedBox(width: 8),
                CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openChat(context),
                  child: CustomContainer(
                    padding: const EdgeInsets.all(4),
                    color: context.colors.backgroundBrandSubtle,
                    borderRadius: 8,
                    child: CustomSvgPicture(
                      svgImage: AppAssets.chat,
                      height: 20,
                      width: 20,
                      color: context.colors.iconBrand,
                      avoideResponsive: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
