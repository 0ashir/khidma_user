import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.providerDetails,
    super.key,
    this.highlightStat,
    this.showBanner = false,
    this.onTap,
    this.width,
    this.height,
  });

  final Providers providerDetails;
  final String? highlightStat;
  final bool showBanner;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  String? _nextAvailableText(final BuildContext context) {
    final NextAvailableSlot? slot = providerDetails.nextAvailableSlot;
    if (slot == null ||
        (slot.date ?? '').isEmpty ||
        (slot.startingTime ?? '').isEmpty ||
        (slot.endingTime ?? '').isEmpty) {
      return null;
    }

    String dayLabel;
    try {
      dayLabel = DateTime.parse(slot.date!).isToday()
          ? 'today'.translate(context: context)
          : slot.date!.formatDate();
    } catch (_) {
      dayLabel = slot.date!;
    }

    String formatSlotTime(final String rawTime) {
      try {
        // Provider shifts/slots are country wall-clock values, not UTC stamps.
        return rawTime.formatTime();
      } catch (_) {
        return rawTime;
      }
    }

    return '${'nextAvailable'.translate(context: context)} : $dayLabel, '
        '${formatSlotTime(slot.startingTime!)} ${'to'.translate(context: context)} '
        '${formatSlotTime(slot.endingTime!)}';
  }

  Widget _buildPlainHeader(final BuildContext context) {
    final bool viewRating =
        double.tryParse(providerDetails.ratings ?? '0') != null &&
        double.parse(providerDetails.ratings!).toStringAsFixed(1) != '0.0';
    final String? providerType = providerDetails.providerType?.toLowerCase();
    final bool hasProviderType =
        providerType != null && providerType.isNotEmpty;
    final bool isOrganization =
        providerType == 'organisation' || providerType == 'organization';
    final int membersCount =
        int.tryParse(providerDetails.numberOfMembers ?? '0') ?? 0;
    final bool hasMembers = isOrganization && membersCount > 0;
    final bool useCompactStats = highlightStat != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SizedBox(
          height: height ?? 48,
          width: width ?? 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            child: CustomCachedNetworkImage(
              networkImageUrl: providerDetails.image ?? '',
              height: height ?? 48,
              width: width ?? 48,
              fit: BoxFit.cover,
              avoideResponsive: true,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 4,
                          children: [
                            Flexible(
                              child: CustomText(
                                providerDetails.translatedCompanyName ?? '',
                                maxLines: 1,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            if (providerDetails.isVerified == true)
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
                      BookMarkIcon(providerData: providerDetails),
                    ],
                  ),
                  if (useCompactStats)
                    CustomContainer(
                      padding: const EdgeInsets.all(4),
                      color: highlightStat == 'rating'
                          ? context.colors.backgroundWarningSubtle
                          : context.colors.backgroundBrandSubtle,
                      borderRadius: UiUtils.borderRadiusOf8,
                      child: highlightStat == 'rating'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                CustomSvgPicture(
                                  avoideResponsive: true,
                                  svgImage: AppAssets.icStar,
                                  height: 16,
                                  width: 16,
                                  color: context.colors.iconWarning,
                                ),
                                CustomText(
                                  double.tryParse(
                                        providerDetails.ratings ?? '0',
                                      )?.toStringAsFixed(1) ??
                                      '0.0',
                                  fontSize: 12,
                                  color: context.colors.textPrimary,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                CustomSvgPicture(
                                  avoideResponsive: true,
                                  svgImage: AppAssets.mapPinArea,
                                  height: 16,
                                  width: 16,
                                  color: context.colors.iconBrand,
                                ),
                                CustomText(
                                  '${double.tryParse(providerDetails.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                                  fontSize: 12,
                                  color: context.colors.textBrand,
                                ),
                              ],
                            ),
                    )
                  else if (hasProviderType)
                    CustomContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: context.colors.backgroundSecondary,
                      borderRadius: UiUtils.borderRadiusOf8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          CustomText(
                            (isOrganization ? 'organization' : 'individual')
                                .translate(context: context),
                            fontSize: 12,
                            color: context.colors.textPrimary,
                          ),
                          if (hasMembers) ...[
                            CustomContainer(
                              height: 4,
                              width: 4,
                              shape: BoxShape.circle,
                              color: context.colors.backgroundTertiary,
                            ),
                            CustomSvgPicture(
                              avoideResponsive: true,
                              svgImage: AppAssets.users,
                              height: 16,
                              width: 16,
                              color: context.colors.iconSecondary,
                            ),
                            CustomText(
                              '$membersCount ${'person'.translate(context: context)}',
                              fontSize: 12,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
              if (useCompactStats)
                Row(
                  spacing: 4,
                  children: [
                    if (highlightStat != 'rating' && viewRating) ...[
                      CustomSvgPicture(
                        avoideResponsive: true,
                        svgImage: AppAssets.icStar,
                        height: 16,
                        width: 16,
                        color: context.colors.iconWarning,
                      ),
                      CustomText(
                        double.parse(
                          providerDetails.ratings!,
                        ).toStringAsFixed(1),
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                      CustomContainer(
                        height: 4,
                        width: 4,
                        shape: BoxShape.circle,
                        color: context.colors.backgroundTertiary,
                      ),
                    ],
                    CustomSvgPicture(
                      avoideResponsive: true,
                      svgImage: AppAssets.service,
                      height: 16,
                      width: 16,
                      color: context.colors.iconSecondary,
                    ),
                    CustomText(
                      '${providerDetails.totalServices ?? '0'} ${'service'.translate(context: context)}',
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                    if (highlightStat == 'rating') ...[
                      CustomContainer(
                        height: 4,
                        width: 4,
                        shape: BoxShape.circle,
                        color: context.colors.backgroundTertiary,
                      ),
                      CustomSvgPicture(
                        avoideResponsive: true,
                        svgImage: AppAssets.mapPinArea,
                        height: 16,
                        width: 16,
                        color: context.colors.iconSecondary,
                      ),
                      CustomText(
                        '${double.tryParse(providerDetails.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ],
                )
              else
                Row(
                  spacing: 8,
                  children: [
                    if (viewRating) ...[
                      CustomSvgPicture(
                        avoideResponsive: true,
                        svgImage: AppAssets.icStar,
                        height: 16,
                        width: 16,
                        color: context.colors.iconWarning,
                      ),
                      CustomText(
                        double.parse(
                          providerDetails.ratings!,
                        ).toStringAsFixed(1),
                        fontSize: 14,
                        color: context.colors.textSecondary,
                      ),
                      CustomContainer(
                        height: 12,
                        width: 1,
                        color: context.colors.borderDefault,
                      ),
                    ],
                    CustomSvgPicture(
                      avoideResponsive: true,
                      svgImage: AppAssets.mapPinArea,
                      height: 16,
                      width: 16,
                      color: context.colors.iconSecondary,
                    ),
                    Flexible(
                      child: CustomText(
                        '${double.tryParse(providerDetails.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                        maxLines: 1,
                        fontSize: 14,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    CustomContainer(
                      height: 12,
                      width: 1,
                      color: context.colors.borderDefault,
                    ),
                    Flexible(
                      child: CustomText(
                        '${providerDetails.totalServices ?? '0'} ${'service'.translate(context: context)}',
                        maxLines: 1,
                        fontSize: 14,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(final BuildContext context) {
    final String? nextAvailable = _nextAvailableText(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: showBanner ? 12 : 0,
        end: showBanner ? 12 : 0,
        bottom: showBanner ? 12 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Always reserve this row's height — even absent, so cards with
          // and without a next-available slot stay the same height in a
          // horizontally-scrolled row of them.
          Opacity(
            opacity: nextAvailable != null ? 1 : 0,
            child: CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: context.colors.backgroundSuccessSubtle,
              borderRadius: 4,
              child: CustomText(
                nextAvailable ?? ' ',
                maxLines: 1,
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderStrong,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    CustomText(
                      'startingFrom'.translate(context: context),
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                    CustomText(
                      (providerDetails.startingPrice ?? '0').countryPriceFormat(
                        context,
                      ),
                      maxLines: 1,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
              CustomContainer(
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundSecondary,
                shape: BoxShape.circle,
                child: CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: Directionality.of(context) == TextDirection.rtl
                      ? AppAssets.backArrow
                      : AppAssets.backArrowLtr,
                  height: 20,
                  width: 20,
                  color: context.colors.iconPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap:
          onTap ??
          () => Navigator.pushNamed(
            context,
            providerRoute,
            arguments: {
              'providers': providerDetails,
              'providerId': providerDetails.providerId,
            },
          ),
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        borderRadius: UiUtils.borderRadiusOf12,
        clipBehavior: Clip.antiAlias,
        padding: showBanner ? EdgeInsets.zero : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: showBanner ? 25 : 12,
          children: [
            showBanner
                ? _ProviderBannerHeader(
                    providerDetails: providerDetails,
                    highlightRating: highlightStat == 'rating',
                  )
                : _buildPlainHeader(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}

class _ProviderBannerHeader extends StatelessWidget {
  const _ProviderBannerHeader({
    required this.providerDetails,
    required this.highlightRating,
  });

  final Providers providerDetails;
  final bool highlightRating;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: CustomCachedNetworkImage(
            networkImageUrl:
                providerDetails.bannerImage ?? providerDetails.image ?? '',
            height: 162,
            width: double.infinity,
            fit: BoxFit.cover,
            avoideResponsive: true,
          ),
        ),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: CustomContainer(
            padding: const EdgeInsets.all(4),
            color: context.colors.overlayHeaderShadow,
            borderRadius: 4,
            child: BookMarkIcon(
              providerData: providerDetails,
              bookmarkedColor: Colors.white,
              unbookmarkedColor: Colors.white,
            ),
          ),
        ),
        PositionedDirectional(
          start: 12,
          end: 12,
          bottom: -17,
          child: _floatingInfoCard(context),
        ),
      ],
    );
  }

  Widget _floatingInfoCard(final BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(12),
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf8,
      boxShadow: [
        BoxShadow(
          color: context.colors.overlayHeaderShadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Row(
        spacing: 12,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomCachedNetworkImage(
              networkImageUrl: providerDetails.image ?? '',
              height: 48,
              width: 48,
              fit: BoxFit.cover,
              avoideResponsive: true,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [_nameRow(context), _statsRow(context)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameRow(final BuildContext context) => Row(
    spacing: 4,
    children: [
      Flexible(
        child: CustomText(
          providerDetails.translatedCompanyName ?? '',
          maxLines: 1,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: context.colors.textPrimary,
        ),
      ),
      if (providerDetails.isVerified == true)
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.verified,
          height: 16,
          width: 16,
          color: context.colors.iconBrand,
        ),
    ],
  );

  Widget _ratingPill(final BuildContext context) => CustomContainer(
    padding: const EdgeInsets.all(4),
    color: context.colors.backgroundWarningSubtle,
    borderRadius: UiUtils.borderRadiusOf8,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.icStar,
          height: 16,
          width: 16,
          color: context.colors.iconWarning,
        ),
        CustomText(
          double.tryParse(providerDetails.ratings ?? '0')?.toStringAsFixed(1) ??
              '0.0',
          fontSize: 12,
          color: context.colors.textPrimary,
        ),
      ],
    ),
  );

  Widget _distancePill(final BuildContext context) => CustomContainer(
    padding: const EdgeInsets.all(4),
    color: context.colors.backgroundBrandSubtle,
    borderRadius: UiUtils.borderRadiusOf8,
    child: Row(
      spacing: 4,
      children: [
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.mapPinArea,
          height: 16,
          width: 16,
          color: context.colors.iconBrand,
        ),
        CustomText(
          '${double.tryParse(providerDetails.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
          fontSize: 12,
          color: context.colors.textBrand,
        ),
      ],
    ),
  );

  Widget _dot(final BuildContext context) => CustomContainer(
    height: 4,
    width: 4,
    shape: BoxShape.circle,
    color: context.colors.backgroundTertiary,
  );

  Widget _servicesStat(final BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      _dot(context),
      CustomSvgPicture(
        avoideResponsive: true,
        svgImage: AppAssets.service,
        height: 16,
        width: 16,
        color: context.colors.iconSecondary,
      ),
      Flexible(
        child: CustomText(
          '${providerDetails.totalServices ?? '0'} ${'service'.translate(context: context)}',
          maxLines: 1,
          fontSize: 12,
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );

  Widget _ratingStat(final BuildContext context) {
    final bool viewRating =
        double.tryParse(providerDetails.ratings ?? '0') != null &&
        double.parse(providerDetails.ratings!).toStringAsFixed(1) != '0.0';
    if (!viewRating) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _dot(context),
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.icStar,
          height: 16,
          width: 16,
          color: context.colors.iconWarning,
        ),
        CustomText(
          double.parse(providerDetails.ratings!).toStringAsFixed(1),
          fontSize: 12,
          color: context.colors.textSecondary,
        ),
      ],
    );
  }

  Widget _distanceStat(final BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      CustomSvgPicture(
        avoideResponsive: true,
        svgImage: AppAssets.mapPinArea,
        height: 16,
        width: 16,
        color: context.colors.iconSecondary,
      ),
      Flexible(
        child: CustomText(
          '${double.tryParse(providerDetails.distance ?? '0')?.ceil() ?? 0} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
          maxLines: 1,
          fontSize: 12,
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );

  /// top_rated_partner: [rating pill] [• services • distance]
  /// near_by_provider:  [distance pill] [• rating • services]
  Widget _statsRow(final BuildContext context) {
    if (highlightRating) {
      return Row(
        spacing: 4,
        children: [
          _ratingPill(context),
          _servicesStat(context),
          _dot(context),
          Flexible(child: _distanceStat(context)),
        ],
      );
    }
    return Row(
      spacing: 4,
      children: [
        _distancePill(context),
        _ratingStat(context),
        Flexible(child: _servicesStat(context)),
      ],
    );
  }
}
