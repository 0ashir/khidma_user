import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceStatusRow extends StatelessWidget {
  const ServiceStatusRow({super.key, required this.bookingDetails});

  final BookingDetailModel bookingDetails;

  ServiceStatusTimelineEntry? get _lastEntry {
    final timeline = bookingDetails.serviceStatusTimeline;
    if (timeline == null || timeline.isEmpty) return null;
    return timeline.last;
  }

  bool get _hasHandymen => bookingDetails.assignedHandymen?.isNotEmpty ?? false;

  String _titleFor(final BuildContext context, final String status) {
    switch (status) {
      case 'on_the_way':
        return (_hasHandymen ? 'handymenOnTheWay' : 'providerOnTheWay')
            .translate(context: context);
      case 'arrived':
        return (_hasHandymen ? 'handymenArrived' : 'providerArrived').translate(
          context: context,
        );
      case 'booking_ended':
        return 'serviceEnded'.translate(context: context);
      case 'confirmed':
        return 'serviceConfirmed'.translate(context: context);
      case 'started':
        return 'serviceStarted'.translate(context: context);
      case 'rescheduled':
        return 'serviceRescheduled'.translate(context: context);
      case 'cancelled':
        return 'serviceCancelled'.translate(context: context);
      case 'completed':
        return 'serviceCompleted'.translate(context: context);
      default:
        return BookingStatusChip.labelFor(context, status);
    }
  }

  void _openTimeline(final BuildContext context) {
    final timeline = bookingDetails.serviceStatusTimeline ?? [];
    if (timeline.isEmpty) return;
    UiUtils.showBottomSheet(
      enableDrag: true,
      context: context,
      child: SafeArea(
        top: false,
        child: CustomContainer(
          color: context.colors.surfacePrimary,
          borderRadiusStyle: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 16),
              CustomText(
                'statusTimeline'.translate(context: context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 16),
              Divider(height: 1, color: context.colors.borderDefault),
              const CustomSizedBox(height: 16),
              for (int i = 0; i < timeline.length; i++)
                _buildTimelineEntry(
                  context,
                  status: timeline[i].status ?? '',
                  timestamp: timeline[i].timestamp ?? '',
                  isLast: i == timeline.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineEntry(
    final BuildContext context, {
    required final String status,
    required final String timestamp,
    required final bool isLast,
  }) {
    final colors = BookingStatusChip.colorsFor(context, status);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomContainer(
                padding: const EdgeInsets.all(8),
                color: colors.background,
                borderRadius: 12,
                child: CustomSvgPicture(
                  svgImage: AppAssets.checkCircleFill,
                  height: 16,
                  width: 16,
                  color: colors.text,
                  avoideResponsive: true,
                ),
              ),
              if (!isLast) ...[
                const CustomSizedBox(height: 8),
                Container(
                  width: 1,
                  height: 18,
                  color: context.colors.borderStrong,
                ),
              ],
            ],
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  _titleFor(context, status),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 4),
                CustomText(
                  timestamp.formatDateAndTime(),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final String status = bookingDetails.status ?? '';
    final colors = BookingStatusChip.colorsFor(context, status);
    final bool hasTimeline =
        bookingDetails.serviceStatusTimeline?.isNotEmpty ?? false;

    if (!hasTimeline) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        CustomContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: context.colors.surfacePrimary,
          borderRadius: 12,
          child: CustomInkWellContainer(
            showRippleEffect: false,
            onTap: () => _openTimeline(context),
            child: Row(
              children: [
                CustomContainer(
                  padding: const EdgeInsets.all(8),
                  color: colors.background,
                  borderRadius: 72,
                  child: CustomSvgPicture(
                    svgImage: AppAssets.checkCircleFill,
                    height: 16,
                    width: 16,
                    color: colors.text,
                    avoideResponsive: true,
                  ),
                ),
                const CustomSizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        _titleFor(context, status),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                      const CustomSizedBox(height: 4),
                      CustomText(
                        _lastEntry?.timestamp?.formatDateAndTime() ?? '',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (hasTimeline) ...[
                  const CustomSizedBox(width: 8),
                  CustomContainer(
                    padding: const EdgeInsets.all(8),
                    color: context.colors.backgroundSecondary,
                    borderRadius: 24,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: context.colors.iconPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const CustomSizedBox(height: 16),
      ],
    );
  }
}
