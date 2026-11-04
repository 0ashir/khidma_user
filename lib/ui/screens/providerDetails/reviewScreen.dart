import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final Providers providerDetails;
  final String? serviceId;

  const ReviewScreen({
    super.key,
    required this.providerDetails,
    this.serviceId,
  });

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<AddTransactionCubit>(
        create: (final BuildContext context) =>
            AddTransactionCubit(bookingRepository: BookingRepository()),
        child: ReviewScreen(
          providerDetails: arguments["providerDetails"] as Providers,
          serviceId: arguments["serviceId"] as String?,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'ratingsAndReviews'.translate(context: context),
        ),
        body: ReviewContent(
          providerDetails: providerDetails,
          serviceId: serviceId,
          bottomInset: MediaQuery.viewPaddingOf(context).bottom,
        ),
      ),
    );
  }
}

/// Reusable review content (rating breakdown + sortable review list),
/// shared between the standalone [ReviewScreen] route and the provider
/// details screen's Review tab.
class ReviewContent extends StatefulWidget {
  final Providers providerDetails;
  final String? serviceId;

  /// Extra bottom padding for the list (used when the screen draws behind the
  /// system navigation bar).
  final double bottomInset;

  const ReviewContent({
    super.key,
    required this.providerDetails,
    this.serviceId,
    this.bottomInset = 0,
  });

  @override
  State<ReviewContent> createState() => _ReviewContentState();
}

class _ReviewContentState extends State<ReviewContent> {
  String _sort = 'newest';

  static const Map<String, String> _sortLabels = {
    'newest': 'newest',
    'rating-desc': 'highestRating',
    'rating-asc': 'lowestRating',
    'all': 'allOption',
  };

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().fetchReview(
      providerId: widget.providerDetails.providerId ?? "0",
      serviceId: widget.serviceId,
      sort: _sort,
    );
  }

  Future<void> _pickSort() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (final BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.borderDefault,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CustomText(
                  'sortBy'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              const CustomSizedBox(height: 8),
              Container(
                height: 1,
                width: double.infinity,
                color: context.colors.borderMuted,
              ),
              const CustomSizedBox(height: 16),
              ..._sortLabels.entries.expand((final entry) {
                final bool isLast = entry.key == _sortLabels.keys.last;
                final bool isSelected = entry.key == _sort;
                return [
                  CustomInkWellContainer(
                    onTap: () => Navigator.pop(context, entry.key),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            entry.value.translate(context: context),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 24,
                          color: isSelected
                              ? context.colors.backgroundBrand
                              : context.colors.borderDefault,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) ...[
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
                  ],
                ];
              }),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (selected != null && selected != _sort) {
      setState(() => _sort = selected);
      context.read<ReviewCubit>().fetchReview(
        providerId: widget.providerDetails.providerId ?? "0",
        serviceId: widget.serviceId,
        sort: _sort,
      );
    }
  }

  Widget _buildRatingBreakdownRow(
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
          width: 32.rf(context),
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

  Widget _buildBreakdownCard() {
    final int total =
        int.tryParse(widget.providerDetails.numberOfRatings ?? '0') ?? 0;
    final Map<String, int> starCounts = {
      '5': int.tryParse(widget.providerDetails.fiveStar ?? '0') ?? 0,
      '4': int.tryParse(widget.providerDetails.fourStar ?? '0') ?? 0,
      '3': int.tryParse(widget.providerDetails.threeStar ?? '0') ?? 0,
      '2': int.tryParse(widget.providerDetails.twoStar ?? '0') ?? 0,
      '1': int.tryParse(widget.providerDetails.oneStar ?? '0') ?? 0,
    };
    final double averageRating =
        double.tryParse(widget.providerDetails.ratings ?? '0') ?? 0;
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: const EdgeInsets.all(12),
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
                  (final star) =>
                      _buildRatingBreakdownRow(star, starCounts[star]!, total),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(final Reviews review) {
    final List images = review.images ?? [];
    final int extraImageCount = images.length - 4;
    final bool isServiceScoped = widget.serviceId != null;
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
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
                    if (isServiceScoped)
                      CustomText(
                        UiUtils.getTimeAgo(
                          context,
                          date: DateTime.tryParse(review.ratedOn ?? ''),
                        ),
                        fontSize: 12,
                        color: context.colors.textTertiary,
                      )
                    else
                      Row(
                        spacing: 4,
                        children: [
                          CustomSvgPicture(
                            avoideResponsive: true,
                            svgImage: AppAssets.icStar,
                            color: context.colors.iconWarning,
                            height: 16,
                            width: 16,
                          ),
                          CustomText(
                            double.parse(
                              review.rating ?? '0',
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
                          Flexible(
                            child: CustomText(
                              UiUtils.getTimeAgo(
                                context,
                                date: DateTime.tryParse(review.ratedOn ?? ''),
                              ),
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (isServiceScoped) ...[
                const CustomSizedBox(width: 8),
                CustomContainer(
                  color: context.colors.backgroundWarningSubtle,
                  borderRadius: UiUtils.borderRadiusOf8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
              ] else if ((review.translatedServiceName ?? '').isNotEmpty) ...[
                const CustomSizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: CustomContainer(
                    color: context.colors.backgroundBrandSubtle,
                    borderRadius: UiUtils.borderRadiusOf8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: CustomText(
                      review.translatedServiceName ?? '',
                      maxLines: 1,
                      fontSize: 12,
                      color: context.colors.textBrand,
                    ),
                  ),
                ),
              ],
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
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, reviewState) {
        if (reviewState is ReviewFetchFailure) {
          return ErrorContainer(
            errorMessage: reviewState.errorMessage.translate(context: context),
            onTapRetry: () {
              context.read<ReviewCubit>().fetchReview(
                providerId: widget.providerDetails.providerId ?? "0",
                serviceId: widget.serviceId,
                sort: _sort,
              );
            },
          );
        } else if (reviewState is ReviewFetchSuccess) {
          if (reviewState.reviewList.isEmpty) {
            return Center(
              child: NoDataFoundWidget(
                titleKey: "noReviewsFound".translate(context: context),
                subtitleKey: 'noReviewsFoundSubTitle'.translate(
                  context: context,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              top: 16.rh(context),
              start: 16.rw(context),
              end: 16.rw(context),
              bottom:
                  widget.bottomInset +
                  (context.read<CartCubit>().getProviderIDFromCartData() == '0'
                      ? 36.rh(context)
                      : kBottomNavigationBarHeight.rh(context) +
                            36.rh(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                _buildBreakdownCard(),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        'allReviews'.translate(context: context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf8,
                      ),
                      onTap: _pickSort,
                      child: CustomContainer(
                        color: context.colors.backgroundPrimary,
                        border: Border.all(color: context.colors.borderDefault),
                        borderRadius: UiUtils.borderRadiusOf8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            CustomText(
                              'sortBy'.translate(context: context),
                              fontSize: 12,
                              color: context.colors.textPrimary,
                            ),
                            CustomSvgPicture(
                              avoideResponsive: true,
                              svgImage: AppAssets.downArrow,
                              color: context.colors.iconPrimary,
                              height: 16,
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ...reviewState.reviewList.map(_buildReviewCard),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 12,
            children: [
              CustomShimmerLoadingContainer(
                borderRadius: UiUtils.borderRadiusOf12,
                height: 220,
                width: context.screenWidth,
              ),
              CustomShimmerLoadingContainer(
                borderRadius: UiUtils.borderRadiusOf12,
                height: 140,
                width: context.screenWidth,
              ),
            ],
          ),
        );
      },
    );
  }
}
