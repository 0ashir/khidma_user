import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/bookingsDetails/rateReviewsScreen.dart';
import 'package:flutter/material.dart';

class ServiceTeamCard extends StatefulWidget {
  const ServiceTeamCard({super.key, required this.bookingDetails});

  final BookingDetailModel bookingDetails;

  @override
  State<ServiceTeamCard> createState() => _ServiceTeamCardState();
}

class _ServiceTeamCardState extends State<ServiceTeamCard> {
  bool get _canRate => widget.bookingDetails.status == 'completed';

  List<BookingAssignedHandyman> get _handymen =>
      widget.bookingDetails.assignedHandymen ?? [];

  int get _ratedCount => _handymen.where((final h) => h.hasReview).length;

  int get _totalCount => _handymen.length;

  void _openProvider(final BuildContext context) {
    final providerId = widget.bookingDetails.provider?.providerId;
    if (providerId == null || providerId.isEmpty) return;
    Navigator.pushNamed(
      context,
      providerRoute,
      arguments: {"providerId": providerId},
    );
  }

  bool get _isChatAllowed =>
      widget.bookingDetails.provider?.postBookingChat ?? false;

  void _openChat(final BuildContext context) {
    final provider = widget.bookingDetails.provider;
    Navigator.pushNamed(
      context,
      chatMessages,
      arguments: {
        "chatUser": ChatUser(
          id: provider?.providerId ?? "",
          bookingId: widget.bookingDetails.id.toString(),
          bookingStatus: widget.bookingDetails.status.toString(),
          name: provider?.companyName ?? '',
          translatedName: provider?.companyName ?? '',
          chatUserType: ChatUserType.providerBooking,
          unReadChats: 0,
          profile: provider?.profileImage,
          partnerId: provider?.providerId ?? "",
        ),
      },
    );
  }

  RateableCardConfig _buildRateConfig(final BookingAssignedHandyman handyman) {
    final HandymanReviewRepository repository = HandymanReviewRepository();
    return RateableCardConfig(
      avatarUrl: handyman.profileImage ?? '',
      avatarSize: 24,
      avatarRadius: 4.8,
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Flexible(
            child: CustomText(
              handyman.username ?? '',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              maxLines: 1,
              color: context.colors.textPrimary,
            ),
          ),
          if (handyman.isLeadHandyman)
            CustomContainer(
              padding: const EdgeInsets.all(4),
              color: context.colors.backgroundBrandSubtle,
              borderRadius: 4,
              child: CustomText(
                'lead'.translate(context: context),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: context.colors.textBrand,
              ),
            ),
        ],
      ),
      existingRating: handyman.hasReview ? handyman.rating : null,
      existingReview: handyman.review ?? '',
      existingImages: handyman.reviewImages ?? [],
      onSubmit:
          ({
            required final rating,
            required final review,
            required final newImages,
            required final deletedImages,
          }) => repository.saveHandymanReview(
            ratingId: handyman.ratingId,
            orderId: widget.bookingDetails.id ?? '',
            handymanId: handyman.id ?? '',
            rating: rating.toString(),
            review: review,
            reviewImages: newImages,
            deletedPastReviewImages: deletedImages,
          ),
      onSuccess: (final data) {
        if (!mounted) return;
        setState(() {
          handyman
            ..rating = int.tryParse(data?['rating']?.toString() ?? '')
            ..review = data?['review']?.toString() ?? handyman.review
            ..ratingId = data?['id']?.toString() ?? handyman.ratingId
            ..reviewImages =
                (data?['images'] as List?)
                    ?.map((final e) => e.toString())
                    .toList() ??
                handyman.reviewImages;
        });
      },
    );
  }

  Future<void> _rateNextHandyman() async {
    if (_handymen.isEmpty) return;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final _) => RateReviewsScreen(
          title: 'rateServiceTeam'.translate(context: context),
          items: _handymen.map(_buildRateConfig).toList(),
        ),
      ),
    );
  }

  Widget _buildProviderRow(final BuildContext context) {
    final provider = widget.bookingDetails.provider;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          width: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.8),
            child: CustomCachedNetworkImage(
              avoideResponsive: true,
              height: 64,
              width: 64,
              networkImageUrl: provider?.profileImage ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const CustomSizedBox(width: 12),
        Expanded(
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: CustomText(
                                provider?.companyName ?? '',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                maxLines: 1,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            if (provider?.isVerified ?? false) ...[
                              const CustomSizedBox(width: 4),
                              CustomSvgPicture(
                                svgImage: AppAssets.verified,
                                height: 16,
                                width: 16,
                                avoideResponsive: true,
                                color: context.colors.iconBrand,
                              ),
                            ],
                          ],
                        ),
                        const CustomSizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvgPicture(
                              svgImage: AppAssets.icStar,
                              height: 16,
                              width: 16,
                              color: context.colors.iconWarning,
                              avoideResponsive: true,
                            ),
                            const CustomSizedBox(width: 4),
                            CustomText(
                              double.parse(
                                provider!.averageRating!,
                              ).toStringAsFixed(1),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: context.colors.textSecondary,
                            ),
                            if ((provider.distance ?? '').isNotEmpty) ...[
                              const CustomSizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 12,
                                color: context.colors.iconSecondary,
                              ),
                              const CustomSizedBox(width: 8),
                              CustomSvgPicture(
                                svgImage: AppAssets.mapPinArea,
                                height: 16,
                                width: 16,
                                color: context.colors.iconSecondary,
                                avoideResponsive: true,
                              ),
                              const CustomSizedBox(width: 4),
                              CustomText(
                                '${provider.distance ?? ''} ${context.read<SystemSettingCubit>().systemDistanceUnit}',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isChatAllowed) ...[
                    const CustomSizedBox(width: 8),
                    CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf8,
                      ),
                      onTap: () => _openChat(context),
                      child: CustomContainer(
                        padding: const EdgeInsets.all(8),
                        color: context.colors.backgroundBrandSubtle,
                        borderRadius: UiUtils.borderRadiusOf8,
                        child: CustomSvgPicture(
                          avoideResponsive: true,
                          svgImage: AppAssets.chat,
                          height: 20,
                          width: 20,
                          color: context.colors.iconBrand,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const CustomSizedBox(height: 8),
              CustomInkWellContainer(
                showRippleEffect: false,
                onTap: () => _openProvider(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      'exploreAllServices'.translate(context: context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textBrand,
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: context.colors.iconBrand,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandymanRow(
    final BuildContext context,
    final BookingAssignedHandyman handyman,
  ) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(4.8),
        child: CustomCachedNetworkImage(
          avoideResponsive: true,
          height: 24,
          width: 24,
          networkImageUrl: handyman.profileImage ?? '',
          fit: BoxFit.cover,
        ),
      ),
      const CustomSizedBox(width: 8),
      Flexible(
        child: CustomText(
          handyman.username ?? '',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          maxLines: 1,
          color: context.colors.textPrimary,
        ),
      ),
      if (handyman.isLeadHandyman) ...[
        const CustomSizedBox(width: 8),
        CustomContainer(
          padding: const EdgeInsets.all(4),
          color: context.colors.backgroundBrandSubtle,
          borderRadius: 4,
          child: CustomText(
            'lead'.translate(context: context),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: context.colors.textBrand,
          ),
        ),
      ],
    ],
  );

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
            'serviceTeam'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          _buildProviderRow(context),
          if (_handymen.isNotEmpty) ...[
            const CustomSizedBox(height: 16),
            CustomText(
              'assignedHandymen'.translate(context: context),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
            const CustomSizedBox(height: 12),
            for (int i = 0; i < _handymen.length; i++) ...[
              _buildHandymanRow(context, _handymen[i]),
              if (i != _handymen.length - 1) const CustomSizedBox(height: 8),
            ],
          ],
          if (_canRate && _handymen.isNotEmpty) ...[
            const CustomSizedBox(height: 12),
            CustomContainer(height: 1, color: context.colors.borderDefault),
            const CustomSizedBox(height: 12),
            RatingPromptRow(
              title:
                  '$_ratedCount ${'of'.translate(context: context)} $_totalCount ${'handymenRated'.translate(context: context)}',
              subtitleKey: 'rateYourExperienceWithTeam',
              onRate: _rateNextHandyman,
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
