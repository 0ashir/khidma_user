import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    required this.booking,
    super.key,
    this.reserveMoreServicesLine = false,
    this.onTap,
  });

  final BookingListItem booking;
  final bool reserveMoreServicesLine;
  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final String? mainServiceTitle = booking.serviceName;
    final int moreCount = booking.otherServicesCount ?? 0;
    final String dateTime = [
      booking.startDate?.formatDate() ?? '',
      booking.startTime?.localeFormatTime() ?? '',
    ].where((final String part) => part.isNotEmpty).join(', ');
    final double? rating = double.tryParse(booking.averageRating ?? '');
    final String providerName = booking.provider?.companyName ?? '';

    Widget? pill;
    if (rating != null && rating > 0) {
      pill = CustomContainer(
        padding: const EdgeInsets.all(8),
        color: context.colors.backgroundWarningSubtle,
        borderRadius: UiUtils.borderRadiusOf8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            CustomText(
              'yourRatings'.translate(context: context),
              fontSize: 12,
              color: context.colors.textPrimary,
            ),
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.icStar,
              height: 16,
              width: 16,
              color: context.colors.iconWarning,
            ),
            CustomText(
              rating.toStringAsFixed(1),
              fontSize: 12,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      );
    }

    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        borderRadius: UiUtils.borderRadiusOf12,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          CustomText(
                            'dateAndTime'.translate(context: context),
                            fontSize: 12,
                            color: context.colors.textTertiary,
                          ),
                          CustomText(
                            dateTime,
                            fontSize: 12,
                            color: context.colors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                    if (pill != null) pill,
                  ],
                ),
                CustomSizedBox(
                  height: 1,
                  width: double.infinity,
                  child: DashedRect(
                    color: context.colors.borderStrong,
                    strokeWidth: 1,
                    gap: 4,
                  ),
                ),
                if (mainServiceTitle != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      CustomText(
                        mainServiceTitle,
                        maxLines: 1,
                        fontSize: 14,
                        color: context.colors.textPrimary,
                      ),
                      if (moreCount > 0 || reserveMoreServicesLine)
                        Opacity(
                          opacity: moreCount > 0 ? 1 : 0,
                          child: CustomText(
                            moreCount > 0
                                ? '+$moreCount ${'more'.translate(context: context)}'
                                : ' ',
                            fontSize: 12,
                            color: context.colors.textBrand,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if (providerName.isNotEmpty)
              Row(
                spacing: 4,
                children: [
                  CustomText(
                    'by'.translate(context: context),
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Flexible(
                          child: CustomText(
                            providerName,
                            maxLines: 1,
                            fontSize: 12,
                            color: context.colors.textPrimary,
                            showUnderline: true,
                          ),
                        ),
                        if (booking.provider?.isProviderVerified == true)
                          CustomSvgPicture(
                            avoideResponsive: true,
                            svgImage: AppAssets.verified,
                            height: 16,
                            width: 16,
                            color: context.colors.iconBrand,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: DownloadInvoiceButton(
                    bookingId: booking.id ?? '',
                    buttonScreenName: 'home',
                    compact: true,
                  ),
                ),
                if (!booking.isCustomJobRequest)
                  Expanded(
                    child: ReOrderButton(
                      bookingId: booking.id ?? '',
                      isReorderFrom: 'home',
                      listBooking: booking,
                      cardFrom: 'home',
                      compact: true,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
