import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyRequestBidderCard extends StatelessWidget {
  const MyRequestBidderCard({
    required this.bidder,
    required this.currentStatus,
    required this.canBook,
    required this.customJobRequestId,
    super.key,
  });

  final BidProvider bidder;
  final String currentStatus;

  /// Show the "book provider" action instead of a read-only state.
  final bool canBook;
  final String customJobRequestId;

  void _openChatWithBidder(
    final BuildContext context,
    final BidProvider bidder,
    final String currentStatus,
  ) {
    Navigator.pushNamed(
      context,
      chatMessages,
      arguments: {
        "chatUser": ChatUser(
          partnerId: bidder.providerId.toString(),
          name: bidder.companyName,
          translatedName: bidder.translatedProviderName ?? bidder.companyName,
          chatUserType: currentStatus == 'booked'
              ? ChatUserType.providerBooking
              : ChatUserType.providerEnquiry,
          unReadChats: 0,
          profile: bidder.providerImage,
          id: bidder.providerId.toString(),
          bookingId: customJobRequestId,
          bookingStatus: currentStatus,
        ),
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.76),
                child: CustomCachedNetworkImage(
                  networkImageUrl: bidder.providerImage ?? '',
                  height: 36,
                  width: 36,
                  fit: BoxFit.cover,
                  avoideResponsive: true,
                ),
              ),
              const CustomSizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: CustomText(
                            bidder.companyName,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            maxLines: 1,
                          ),
                        ),
                        if (bidder.isVerified) ...[
                          const CustomSizedBox(width: 8),
                          CustomSvgPicture(
                            svgImage: AppAssets.verified,
                            height: 16,
                            width: 16,
                            color: context.colors.iconBrand,
                            avoideResponsive: true,
                          ),
                        ],
                      ],
                    ),
                    const CustomSizedBox(height: 4),
                    Row(
                      children: [
                        CustomSvgPicture(
                          svgImage: AppAssets.icStar,
                          height: 16,
                          width: 16,
                          color: context.colors.iconWarning,
                          avoideResponsive: true,
                        ),
                        const CustomSizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${bidder.averageRating} ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '(${bidder.totalRatings})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bidder.distance != null) ...[
                          const CustomSizedBox(width: 8),
                          CustomText(
                            '|',
                            fontSize: 12,
                            color: context.colors.textPrimary,
                          ),
                          const CustomSizedBox(width: 8),
                          CustomSvgPicture(
                            svgImage: AppAssets.mapPinArea,
                            height: 16,
                            width: 16,
                            color: context.colors.iconPrimary,
                            avoideResponsive: true,
                          ),
                          const CustomSizedBox(width: 4),
                          CustomText(
                            '${bidder.distance!.toStringAsFixed(1)} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textPrimary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const CustomSizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentStatus != 'cancelled' &&
                      (currentStatus == 'booked'
                          ? bidder.isPostBookingChatAllowed
                          : bidder.isPreBookingChatAllowed)) ...[
                    CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          _openChatWithBidder(context, bidder, currentStatus),
                      child: CustomContainer(
                        padding: const EdgeInsets.all(8),
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
                    const CustomSizedBox(width: 8),
                  ],
                  CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {
                        'providerId': bidder.providerId.toString(),
                        'type': ProviderDetailsParamType.id,
                      },
                    ),
                    child: CustomContainer(
                      padding: const EdgeInsets.all(8),
                      color: context.colors.backgroundSecondary,
                      borderRadius: 8,
                      child: CustomSvgPicture(
                        svgImage:
                            Directionality.of(context).toString().contains(
                              TextDirection.RTL.value.toLowerCase(),
                            )
                            ? AppAssets.backArrow
                            : AppAssets.backArrowLtr,
                        height: 20,
                        width: 20,
                        color: context.colors.iconSecondary,
                        avoideResponsive: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const CustomSizedBox(height: 16),
          CustomSizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderDefault,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
          const CustomSizedBox(height: 16),

          Row(
            children: [
              CustomContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                color: context.colors.backgroundBrandSubtle,
                borderRadius: 8,
                child: CustomText(
                  bidder.counterPrice.priceFormat(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ),
              const CustomSizedBox(width: 8),
              CustomContainer(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: context.colors.backgroundBrandSubtle,
                borderRadius: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.clock,
                      height: 16,
                      width: 16,
                      color: context.colors.iconPrimary,
                      avoideResponsive: true,
                    ),
                    const CustomSizedBox(width: 4),
                    CustomText(
                      '${bidder.duration} ${'min'.translate(context: context)}',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (bidder.message.isNotEmpty) ...[
            const CustomSizedBox(height: 12),
            CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundSecondary,
              borderRadius: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    'providerMessage'.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    bidder.message,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],

          const CustomSizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      (currentStatus == 'booked' ? 'bookedOn' : 'bidPlacedOn')
                          .translate(context: context),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                    ),
                    const CustomSizedBox(height: 4),
                    CustomText(
                      (currentStatus == 'booked'
                              ? bidder.bookedOn ?? ''
                              : bidder.bidDate)
                          .formatDateAndTime(),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
              if (canBook)
                CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pushNamed(
                    context,
                    scheduleScreenRoute,
                    arguments: {
                      'isFrom': 'customJobRequest',
                      'providerName':
                          bidder.translatedProviderName ?? bidder.companyName,
                      'providerId': bidder.providerId.toString(),
                      'companyName': bidder.companyName,
                      'providerAdvanceBookingDays': bidder.advanceBookingDays,
                      'customJobRequestId':
                          bidder.customJobRequestId ?? customJobRequestId,
                      'bidder': bidder,
                    },
                  ),
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    color: context.colors.backgroundBrand,
                    borderRadius: 8,
                    child: CustomText(
                      'bookProvider'.translate(context: context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textInverseLight,
                    ),
                  ),
                )
              else if (currentStatus == 'booked')
                CustomContainer(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  color: context.colors.backgroundSuccess,
                  borderRadius: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomSvgPicture(
                        svgImage: AppAssets.checkCircleFill,
                        height: 20,
                        width: 20,
                        color: context.colors.iconInverseLight,
                        avoideResponsive: true,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomText(
                        'booked'.translate(context: context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textInverseLight,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
