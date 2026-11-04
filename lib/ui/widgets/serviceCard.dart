import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    required this.serviceId,
    required this.providerId,
    required this.title,
    required this.image,
    required this.price,
    required this.discountedPrice,
    required this.duration,
    required this.numberOfMembersRequired,
    required this.averageRating,
    required this.maximumAllowedQuantity,
    super.key,
    this.width,
    this.height,
    this.imageWidth = 56,
    this.imageHeight = 68,
    this.useDashedDivider = true,
    this.showBorder = true,
    this.addButtonBackgroundColor,
    this.discountPercentage,
    this.description,
    this.companyName,
    this.showProviderName = true,
    this.showRatingAsBadge,
    this.isProviderVerified = false,
    this.isBookmarked,
    this.isProviderAvailableAtLocation,
    this.serviceProviderName,
    this.onTap,
    this.onBookmarkChanged,
    this.durationType,
  });

  final String serviceId;
  final String providerId;
  final String? title;
  final String? image;
  final String? price;
  final String? discountedPrice;
  final String? discountPercentage;
  final String? duration;
  final String? numberOfMembersRequired;
  final String? averageRating;
  final int maximumAllowedQuantity;
  final double? width;
  final double? height;
  final double imageWidth;
  final double imageHeight;
  final bool useDashedDivider;
  final bool showBorder;
  final Color? addButtonBackgroundColor;
  final String? description;
  final String? companyName;
  final bool showProviderName;
  final bool? showRatingAsBadge;
  final bool isProviderVerified;
  final bool? isBookmarked;
  final String? isProviderAvailableAtLocation;
  final String? serviceProviderName;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onBookmarkChanged;
  final String? durationType;

  @override
  Widget build(final BuildContext context) {
    final bool viewRating =
        double.tryParse(averageRating ?? '0') != null &&
        double.parse(averageRating!).toStringAsFixed(1) != '0.0';
    final bool useRatingBadge = showRatingAsBadge ?? !showProviderName;

    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        width: width,
        height: height,
        color: context.colors.backgroundPrimary,
        borderRadius: UiUtils.borderRadiusOf12,
        border: showBorder
            ? Border.all(color: context.colors.borderDefault)
            : null,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: imageWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomCachedNetworkImage(
                      networkImageUrl: image ?? '',
                      height: imageHeight,
                      width: imageWidth,
                      fit: BoxFit.cover,
                      avoideResponsive: true,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (useRatingBadge && viewRating) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomContainer(
                              height: 24,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: context.colors.backgroundWarningSubtle,
                              borderRadius: UiUtils.borderRadiusOf8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomSvgPicture(
                                    avoideResponsive: true,
                                    svgImage: AppAssets.icStar,
                                    color: context.colors.iconWarning,
                                    height: 16,
                                    width: 16,
                                  ),
                                  const CustomSizedBox(width: 4),
                                  CustomText(
                                    double.parse(
                                      averageRating!,
                                    ).toStringAsFixed(1),
                                    fontSize: 12,
                                    color: context.colors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                            if (isBookmarked != null)
                              ServiceBookmarkIcon(
                                key: ValueKey('bookmark-$serviceId'),
                                serviceId: serviceId,
                                isBookmarked: isBookmarked!,
                                onChanged: onBookmarkChanged,
                              ),
                          ],
                        ),
                        const CustomSizedBox(height: 4),
                        CustomText(
                          title ?? '',
                          maxLines: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: context.colors.textPrimary,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                title ?? '',
                                maxLines: 1,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            if (isBookmarked != null)
                              ServiceBookmarkIcon(
                                key: ValueKey('bookmark-$serviceId'),
                                serviceId: serviceId,
                                isBookmarked: isBookmarked!,
                                onChanged: onBookmarkChanged,
                              ),
                          ],
                        ),
                      ],
                      const CustomSizedBox(height: 4),
                      if ((description ?? '').isNotEmpty) ...[
                        CustomText(
                          description!,
                          maxLines: 2,
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                        const CustomSizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          if (!useRatingBadge && viewRating) ...[
                            CustomSvgPicture(
                              avoideResponsive: true,
                              svgImage: AppAssets.icStar,
                              color: context.colors.iconWarning,
                              height: 16,
                              width: 16,
                            ),
                            const CustomSizedBox(width: 4),
                            CustomText(
                              double.parse(averageRating!).toStringAsFixed(1),
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                            const CustomSizedBox(width: 4),
                            CustomContainer(
                              height: 4,
                              width: 4,
                              shape: BoxShape.circle,
                              color: context.colors.backgroundTertiary,
                            ),
                            const CustomSizedBox(width: 4),
                          ],
                          CustomSvgPicture(
                            avoideResponsive: true,
                            svgImage: AppAssets.users,
                            height: 16,
                            width: 16,
                            color: context.colors.iconSecondary,
                          ),
                          const CustomSizedBox(width: 4),
                          Flexible(
                            child: CustomText(
                              '${numberOfMembersRequired ?? '0'} ${'person'.translate(context: context)}',
                              maxLines: 1,
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const CustomSizedBox(width: 4),
                          CustomContainer(
                            height: 4,
                            width: 4,
                            shape: BoxShape.circle,
                            color: context.colors.backgroundTertiary,
                          ),
                          const CustomSizedBox(width: 4),
                          CustomSvgPicture(
                            avoideResponsive: true,
                            svgImage: AppAssets.clock,
                            height: 16,
                            width: 16,
                            color: context.colors.iconSecondary,
                          ),
                          const CustomSizedBox(width: 4),
                          Flexible(
                            child: CustomText(
                              '${duration ?? '0'} ${(durationType ?? 'minutes').translate(context: context)}',
                              maxLines: 1,
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      if (showProviderName &&
                          (companyName ?? '').isNotEmpty) ...[
                        const CustomSizedBox(height: 8),
                        CustomInkWellContainer(
                          onTap: () => Navigator.pushNamed(
                            context,
                            providerRoute,
                            arguments: {"providerId": providerId},
                          ),
                          child: Row(
                            children: [
                              CustomText(
                                '${'by'.translate(context: context)} ',
                                fontSize: 11,
                                color: context.colors.textSecondary,
                              ),
                              Flexible(
                                child: CustomText(
                                  companyName ?? '',
                                  maxLines: 1,
                                  fontSize: 12,
                                  color: context.colors.textPrimary,
                                  showUnderline: true,
                                ),
                              ),
                              if (isProviderVerified) ...[
                                const CustomSizedBox(width: 4),
                                CustomSvgPicture(
                                  avoideResponsive: true,
                                  svgImage: AppAssets.verified,
                                  height: 16,
                                  width: 16,
                                  color: context.colors.iconBrand,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            useDashedDivider
                ? CustomSizedBox(
                    height: 1,
                    width: double.infinity,
                    child: DashedRect(
                      color: context.colors.borderStrong,
                      strokeWidth: 1,
                      gap: 4,
                    ),
                  )
                : CustomDivider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.borderMuted,
                  ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: CustomText(
                              (discountedPrice != '0'
                                      ? discountedPrice ?? '0'
                                      : price ?? '0')
                                  .countryPriceFormat(context),
                              maxLines: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          if (discountedPrice != '0')
                            Flexible(
                              child: CustomText(
                                (price ?? '0').countryPriceFormat(context),
                                maxLines: 1,
                                fontSize: 12,
                                color: context.colors.textTertiary,
                                showLineThrough: true,
                                underlineOrLineColor:
                                    context.colors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                        child:
                            discountedPrice != '0' &&
                                (double.tryParse(discountPercentage ?? '0') ??
                                        0) >
                                    0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 4,
                                children: [
                                  CustomSvgPicture(
                                    avoideResponsive: true,
                                    svgImage: AppAssets.icOff,
                                    height: 16,
                                    width: 16,
                                    color: context.colors.iconSuccess,
                                  ),
                                  CustomText(
                                    '${double.parse(discountPercentage!).round()}% ${'off'.translate(context: context)}',
                                    fontSize: 12,
                                    color: context.colors.textSuccess,
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                MultiBlocProvider(
                  providers: [
                    BlocProvider<AddServiceIntoCartCubit>(
                      create: (final BuildContext context) =>
                          AddServiceIntoCartCubit(CartRepository()),
                    ),
                    BlocProvider<RemoveServiceFromCartCubit>(
                      create: (final BuildContext context) =>
                          RemoveServiceFromCartCubit(CartRepository()),
                    ),
                  ],
                  child: AddButton(
                    serviceId: serviceId,
                    providerId: providerId,
                    isProviderAvailableAtLocation:
                        isProviderAvailableAtLocation,
                    backgroundColor:
                        addButtonBackgroundColor ??
                        context.colors.backgroundBrandSubtle,
                    maximumAllowedQuantity: maximumAllowedQuantity,
                    alreadyAddedQuantity: isProviderAvailableAtLocation == '0'
                        ? 0
                        : int.parse(
                            context.read<CartCubit>().getServiceCartQuantity(
                              serviceId: serviceId,
                            ),
                          ),
                    height: 32,
                    padding: 10,
                    iconSize: 16,
                    countFontSize: 14,
                    serviceProviderName: serviceProviderName,
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
