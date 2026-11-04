import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestSummaryCard extends StatelessWidget {
  const MyRequestSummaryCard({
    required this.job,
    required this.minPrice,
    required this.maxPrice,
    required this.timeLeft,
    super.key,
  });

  final CustomJob job;
  final String? minPrice;
  final String? maxPrice;

  /// Remaining time until the request expires, driven by the parent's timer.
  final Duration? timeLeft;

  String _formatCountdown(final Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s Hrs Left';
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

  @override
  Widget build(final BuildContext context) {
    final statusColors = _statusColors(context, job.status ?? '');
    final bool hasBudget =
        (minPrice?.isNotEmpty ?? false) && (maxPrice?.isNotEmpty ?? false);
    final endDt = DateTime.tryParse(job.endDateTime ?? '');
    final bool isPending = job.status == 'pending';

    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 8,
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
                      job.title ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                    const CustomSizedBox(height: 4),
                    CustomText(
                      job.categoryName ?? '',
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
                  _statusLabel(context, job.status ?? ''),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColors.text,
                ),
              ),
            ],
          ),
          if (hasBudget) ...[
            const CustomSizedBox(height: 12),
            CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundSecondary,
              borderRadius: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'budgetRange'.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textTertiary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    minPrice == maxPrice
                        ? minPrice!.priceFormat(context)
                        : '${minPrice!.priceFormat(context)} - ${maxPrice!.priceFormat(context)}',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
          if (isPending && endDt != null) ...[
            const CustomSizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'expiresOn'.translate(context: context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textTertiary,
                      ),
                      const CustomSizedBox(height: 4),
                      CustomText(
                        (job.endDateTime ?? '').formatTimestampDate(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                ),
                if (timeLeft != null && timeLeft! > Duration.zero)
                  CustomContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: context.colors.backgroundInfoSubtle,
                    borderRadius: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSvgPicture(
                          svgImage: AppAssets.clock,
                          height: 16,
                          width: 16,
                          color: context.colors.iconInfo,
                          avoideResponsive: true,
                        ),
                        const CustomSizedBox(width: 4),
                        CustomText(
                          _formatCountdown(timeLeft!),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textInfo,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const CustomSizedBox(height: 8),
            CustomText(
              'chooseProviderBeforeExpiry'.translate(context: context),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textError,
            ),
          ],
          if (job.status == 'cancelled' &&
              (job.cancelReason ?? '').isNotEmpty) ...[
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
            CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundErrorSubtle,
              borderRadius: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    'cancellationReason'.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    job.cancelReason ?? '',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
          if (job.status == 'expiry') ...[
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
            CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundErrorSubtle,
              borderRadius: 8,
              child: CustomText(
                'requestExpiredMessage'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
