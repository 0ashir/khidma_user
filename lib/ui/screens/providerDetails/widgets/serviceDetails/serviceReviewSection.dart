import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'serviceSectionTitle.dart';

class ServiceReviewSection extends StatelessWidget {
  const ServiceReviewSection({
    required this.details,
    required this.reviewList,
    required this.serviceId,
    required this.providerId,
    super.key,
  });

  final ServiceDetailsModel details;
  final List<Reviews> reviewList;
  final String serviceId;
  final String providerId;

  Widget _buildRatingBreakdownRow(
    final BuildContext context,
    final String star,
    final int count,
    final int total,
  ) {
    final double fraction = total > 0 ? count / total : 0;
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              star,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
            const CustomSizedBox(width: 4),
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.icStar,
              color: context.colors.iconWarning,
              height: 16,
              width: 16,
            ),
          ],
        ),
        const CustomSizedBox(width: 4),
        Expanded(
          child: LayoutBuilder(
            builder: (final _, final constraints) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                CustomContainer(
                  height: 12,
                  width: double.infinity,
                  borderRadius: 24,
                  color: context.colors.backgroundSecondary,
                ),
                CustomContainer(
                  height: 12,
                  width: constraints.maxWidth * fraction,
                  borderRadius: 24,
                  color: context.colors.backgroundWarning,
                ),
              ],
            ),
          ),
        ),
        const CustomSizedBox(width: 4),
        SizedBox(
          width: 28,
          child: CustomText(
            '${(fraction * 100).round()}%',
            fontSize: 12,
            textAlign: TextAlign.end,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(final BuildContext context, final Reviews review) {
    final List images = review.images ?? [];
    final int extraImageCount = images.length - 4;
    return CustomContainer(
      width: 264,
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      border: Border.all(color: context.colors.borderDefault, width: 1.5),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
                child: CustomCachedNetworkImage(
                  networkImageUrl: review.profileImage ?? '',
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const CustomSizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    CustomText(
                      review.userName ?? '',
                      maxLines: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                    CustomText(
                      UiUtils.getTimeAgo(
                        context,
                        date: DateTime.tryParse(review.ratedOn ?? ''),
                      ),
                      fontSize: 12,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
              const CustomSizedBox(width: 8),
              CustomContainer(
                color: context.colors.backgroundWarningSubtle,
                borderRadius: UiUtils.borderRadiusOf8,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      double.parse(review.rating ?? '0').toStringAsFixed(1),
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          CustomText(
            review.comment ?? '',
            fontSize: 12,
            maxLines: 2,
            color: context.colors.textSecondary,
          ),
          if (images.isNotEmpty)
            Row(
              children: List.generate(images.length > 4 ? 4 : images.length, (
                final int index,
              ) {
                final bool isLast =
                    index == 3 && extraImageCount > 0 && images.length > 4;
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: index == 3 ? 0 : 8),
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(
                      UiUtils.borderRadiusOf8,
                    ),
                    onTap: () => isLast
                        ? UiUtils.showBottomSheet(
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            child: ServiceImagesList(
                              imageList: images
                                  .map((final e) => e.toString())
                                  .toList(),
                              reviewDetails: review,
                            ),
                          )
                        : Navigator.pushNamed(
                            context,
                            imagePreview,
                            arguments: {
                              "startFrom": index,
                              "reviewDetails": review,
                              "isReviewType": true,
                              "dataURL": images,
                            },
                          ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf8,
                      ),
                      child: Stack(
                        children: [
                          CustomCachedNetworkImage(
                            networkImageUrl: images[index],
                            height: 32,
                            width: 32,
                            fit: BoxFit.cover,
                          ),
                          if (isLast)
                            CustomContainer(
                              height: 32,
                              width: 32,
                              color: context.colors.overlayDefault,
                              child: Center(
                                child: CustomText(
                                  '+$extraImageCount',
                                  fontSize: 12,
                                  color: context.colors.textInverseLight,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final int total = int.tryParse(details.numberOfRatings ?? '0') ?? 0;
    final Map<String, int> starCounts = {
      '5': details.ratingBreakdown['5'] ?? 0,
      '4': details.ratingBreakdown['4'] ?? 0,
      '3': details.ratingBreakdown['3'] ?? 0,
      '2': details.ratingBreakdown['2'] ?? 0,
      '1': details.ratingBreakdown['1'] ?? 0,
    };
    final double averageRating =
        double.tryParse(details.averageRating ?? '0') ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        ServiceSectionTitle('ratingsAndReviews'.translate(context: context)),
        CustomContainer(
          color: context.colors.backgroundPrimary,
          borderRadius: UiUtils.borderRadiusOf12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
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
                          'customerReviews'.translate(context: context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                        CustomText(
                          '${'basedOn'.translate(context: context)} $total ${'reviews'.translate(context: context)}',
                          fontSize: 12,
                          color: context.colors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    spacing: 4,
                    children: [
                      CustomText(
                        averageRating.toStringAsFixed(1),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                      AverageRatingStars(rating: averageRating),
                    ],
                  ),
                ],
              ),
              CustomContainer(height: 1, color: context.colors.borderDefault),
              Column(
                spacing: 8,
                children: ['5', '4', '3', '2', '1']
                    .map(
                      (final star) => _buildRatingBreakdownRow(
                        context,
                        star,
                        starCounts[star]!,
                        total,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        if (reviewList.isNotEmpty) ...[
          CustomText(
            'customerReviews'.translate(context: context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: List.generate(
                  reviewList.length,
                  (final int index) =>
                      _buildReviewCard(context, reviewList[index]),
                ),
              ),
            ),
          ),
          CustomInkWellContainer(
            onTap: () {
              Navigator.pushNamed(
                context,
                reviewScreen,
                arguments: {
                  'providerDetails': Providers(
                    providerId: providerId,
                    ratings: details.averageRating,
                    numberOfRatings: details.numberOfRatings,
                    fiveStar: starCounts['5'].toString(),
                    fourStar: starCounts['4'].toString(),
                    threeStar: starCounts['3'].toString(),
                    twoStar: starCounts['2'].toString(),
                    oneStar: starCounts['1'].toString(),
                  ),
                  'serviceId': serviceId,
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  'viewAllReviews'.translate(context: context),
                  fontSize: 14,
                  color: context.colors.textBrand,
                ),
                const CustomSizedBox(width: 4),
                CustomSvgPicture(
                  svgImage: Directionality.of(context) == TextDirection.rtl
                      ? AppAssets.backArrow
                      : AppAssets.backArrowLtr,
                  height: 16,
                  width: 16,
                  color: context.colors.iconBrand,
                  avoideResponsive: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
