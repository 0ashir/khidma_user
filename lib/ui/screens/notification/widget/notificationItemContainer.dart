import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationItemLocation { first, last, onlyOne, middle }

class NotificationItemContainer extends StatelessWidget {
  const NotificationItemContainer({
    required this.notification,
    final Key? key,
    this.onSlideTap,
    this.slidableChild,
    this.showArrow = false,
    this.isLoading = false,
  }) : super(key: key);

  final NotificationDataModel notification;
  final VoidCallback? onSlideTap;
  final Widget? slidableChild;
  final bool showArrow;
  final bool isLoading;

  CustomContainer _buildNotificationContainer({
    required final BuildContext context,
  }) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        notification.image != ''
            ? CustomContainer(
                height: 50,
                width: 50,
                shape: BoxShape.circle,
                clipBehavior: Clip.antiAlias,
                child: CustomCachedNetworkImage(
                  networkImageUrl: notification.image ?? '',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              )
            : CustomContainer(
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundSecondary,
                shape: BoxShape.circle,
                child: CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: AppAssets.drNotification,
                  color: context.colors.iconPrimary,
                  height: 20,
                  width: 20,
                ),
              ),
        const CustomSizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  Flexible(
                    child: CustomText(
                      notification.title?.trim() ?? '',
                      color: context.colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CustomText(
                    UiUtils.getTimeAgo(context, date: notification.dateSent),
                    maxLines: 1,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              const CustomSizedBox(height: 4),
              CustomReadMoreTextContainer(
                text: notification.message ?? '',
                textStyle: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12,
                ),
                trimLines: 2,
              ),
              if (isLoading) ...[
                const CustomSizedBox(height: 12),
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.iconTertiary,
                  ),
                ),
              ] else if (showArrow) ...[
                const CustomSizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'view'.translate(context: context),
                      color: context.colors.textBrand,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    const CustomSizedBox(width: 4),
                    CustomSvgPicture(
                      height: 20,
                      width: 20,
                      color: context.colors.iconBrand,
                      svgImage:
                          Directionality.of(context).toString().contains(
                            TextDirection.RTL.value.toLowerCase(),
                          )
                          ? AppAssets.backArrow
                          : AppAssets.backArrowLtr,
                      avoideResponsive: true,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    onTap: onSlideTap,
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
    child: CustomContainer(
      clipBehavior: Clip.antiAlias,
      borderRadius: UiUtils.borderRadiusOf12,
      color: context.colors.component.cardBackground,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              if (slidableChild != null) ...[
                Positioned.fill(
                  child: CustomContainer(
                    color: context.colors.textError,
                    borderRadius: UiUtils.borderRadiusOf12,
                  ),
                ),
              ],
              if (slidableChild != null) ...[
                Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.24,
                    children: slidableChild != null ? [slidableChild!] : [],
                  ),
                  child: _buildNotificationContainer(context: context),
                ),
              ] else ...[
                _buildNotificationContainer(context: context),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
