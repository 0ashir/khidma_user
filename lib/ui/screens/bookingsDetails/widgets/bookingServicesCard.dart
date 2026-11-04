import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/bookingsDetails/rateReviewsScreen.dart';
import 'package:flutter/material.dart';

class RatingPromptRow extends StatelessWidget {
  const RatingPromptRow({
    super.key,
    required this.title,
    required this.subtitleKey,
    required this.onRate,
    this.buttonLabelKey,
  });

  final String title;
  final String subtitleKey;
  final VoidCallback onRate;
  final String? buttonLabelKey;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundWarningSubtle,
              borderRadius: 24,
              child: CustomSvgPicture(
                svgImage: AppAssets.icStar,
                height: 20,
                width: 20,
                color: context.colors.iconWarning,
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
                    title,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    subtitleKey.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const CustomSizedBox(width: 12),
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(8),
        onTap: onRate,
        child: CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.backgroundBrand,
          borderRadius: 8,
          child: CustomText(
            buttonLabelKey!.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colors.textInverseLight,
          ),
        ),
      ),
    ],
  );
}

class BookingServicesCard extends StatefulWidget {
  const BookingServicesCard({super.key, required this.bookingDetails});

  final BookingDetailModel bookingDetails;

  @override
  State<BookingServicesCard> createState() => _BookingServicesCardState();
}

class _BookingServicesCardState extends State<BookingServicesCard> {
  bool get _canRate => widget.bookingDetails.status == 'completed';

  List<BookingDetailsService> get _services =>
      widget.bookingDetails.services ?? [];

  int get _ratedCount => _services.where((s) => s.hasReview).length;

  int get _totalCount => _services.length;

  RateableCardConfig _buildRateConfig(final BookingDetailsService service) {
    final BookingRepository repository = BookingRepository();
    return RateableCardConfig(
      avatarUrl: service.image ?? '',
      avatarSize: 40,
      avatarRadius: 8,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          CustomText(
            service.title ?? '',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            maxLines: 1,
            color: context.colors.textPrimary,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              CustomText(
                '${service.quantity ?? '1'} ${'qty'.translate(context: context)}',
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
              Container(
                width: 1,
                height: 12,
                color: context.colors.borderBlack,
              ),
              CustomText(
                (service.price ?? '0').priceFormat(
                  context,
                  currencySymbol: widget.bookingDetails.currencySymbol,
                  decimalPlaces: widget.bookingDetails.currencyDecimalPlaces,
                ),
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
      existingRating: service.hasReview ? service.rating : null,
      existingReview: service.review ?? '',
      existingImages: service.reviewImages ?? [],
      onSubmit:
          ({
            required final rating,
            required final review,
            required final newImages,
            required final deletedImages,
          }) => repository.submitReviewToService(
            serviceId: service.serviceId ?? '',
            ratingStar: rating.toString(),
            reviewComment: review,
            reviewImages: newImages,
            customJobRequestId: widget.bookingDetails.customJobRequest?.id,
            deletedPastReviewImages: deletedImages,
          ),
      onSuccess: (final data) {
        if (!mounted) return;
        final int i = _services.indexOf(service);
        if (i == -1) return;
        setState(() {
          _services[i] = service.copyWith(
            rating: int.tryParse(data?['rating']?.toString() ?? ''),
            review: data?['comment']?.toString(),
            reviewImages: (data?['images'] as List?)
                ?.map((final e) => e.toString())
                .toList(),
          );
        });
      },
    );
  }

  Future<void> _rateNextService() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final _) => RateReviewsScreen(
          title: 'rateServices'.translate(context: context),
          items: _services.map(_buildRateConfig).toList(),
        ),
      ),
    );
  }

  Widget _buildServiceRow(
    final BuildContext context,
    final BookingDetailsService service,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.8),
        child: CustomCachedNetworkImage(
          avoideResponsive: true,
          height: 44,
          width: 44,
          networkImageUrl: service.image ?? '',
          fit: BoxFit.cover,
        ),
      ),
      const CustomSizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              service.title ?? '',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              maxLines: 1,
              color: context.colors.textPrimary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              service.categoryName ?? '',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textBrand,
            ),
            const CustomSizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  '${service.quantity ?? '1'} ${'qty'.translate(context: context)}',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(width: 8),
                Container(
                  width: 1,
                  height: 12,
                  color: context.colors.borderBlack,
                ),
                const CustomSizedBox(width: 8),
                CustomText(
                  (service.price ?? '0').priceFormat(
                    context,
                    currencySymbol: widget.bookingDetails.currencySymbol,
                    decimalPlaces: widget.bookingDetails.currencyDecimalPlaces,
                  ),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildDivider() =>
      CustomContainer(height: 1, color: context.colors.borderDefault);

  @override
  Widget build(final BuildContext context) {
    final bool fullyRated = _totalCount > 0 && _ratedCount >= _totalCount;

    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            '${'servicesCount'.translate(context: context)} ($_totalCount)',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          _buildDivider(),
          const CustomSizedBox(height: 12),
          for (int i = 0; i < _services.length; i++) ...[
            _buildServiceRow(context, _services[i]),
            if (i != _services.length - 1) ...[
              const CustomSizedBox(height: 12),
              _buildDivider(),
              const CustomSizedBox(height: 12),
            ],
          ],
          if (_canRate && _services.isNotEmpty) ...[
            const CustomSizedBox(height: 12),
            _buildDivider(),
            const CustomSizedBox(height: 12),
            RatingPromptRow(
              title:
                  '$_ratedCount ${'of'.translate(context: context)} $_totalCount ${'serviceRated'.translate(context: context)}',
              subtitleKey: 'rateYourExperienceWithService',
              onRate: _rateNextService,
              buttonLabelKey: fullyRated
                  ? 'edit'.translate(context: context)
                  : 'rate'.translate(context: context),
            ),
          ],
        ],
      ),
    );
  }
}
