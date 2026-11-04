import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceHeaderSection extends StatelessWidget {
  const ServiceHeaderSection({
    required this.details,
    required this.serviceId,
    required this.providerId,
    required this.isProviderAvailableAtLocation,
    super.key,
  });

  final ServiceDetailsModel details;
  final String serviceId;
  final String providerId;
  final String? isProviderAvailableAtLocation;

  Widget _buildRatingRow(
    final BuildContext context,
    final ServiceDetailsModel details,
  ) {
    final bool viewRating =
        double.tryParse(details.averageRating ?? '0') != null &&
        double.parse(details.averageRating!).toStringAsFixed(1) != '0.0';
    if (!viewRating) return const CustomSizedBox();
    return Row(
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
          double.parse(details.averageRating!).toStringAsFixed(1),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
        Expanded(
          child: CustomText(
            ' (${details.numberOfRatings} ${details.numberOfRatings.toString().convertToInt() > 1 ? 'reviewers'.translate(context: context) : 'reviewer'.translate(context: context)})',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textTertiary,
          ),
        ),
        ServiceBookmarkIcon(
          serviceId: serviceId,
          isBookmarked: details.isBookmarked == '1',
        ),
      ],
    );
  }

  Widget _buildAllowedBadge(
    final BuildContext context, {
    required final String label,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomSvgPicture(
        avoideResponsive: true,
        svgImage: AppAssets.verified,
        height: 16,
        width: 16,
        color: context.colors.iconBrand,
      ),
      const CustomSizedBox(width: 4),
      CustomText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
    ],
  );

  Widget _buildPriceAndActionRow(
    final BuildContext context,
    final ServiceDetailsModel details,
  ) {
    final double price = double.tryParse(details.price ?? '0') ?? 0;
    final double discountedPrice =
        double.tryParse(details.discountedPrice ?? '0') ?? 0;
    final bool hasDiscount = discountedPrice > 0 && discountedPrice < price;
    final double effectivePrice = hasDiscount ? discountedPrice : price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  CustomText(
                    effectivePrice.toString().countryPriceFormat(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: context.colors.textPrimary,
                  ),
                  if (hasDiscount)
                    CustomText(
                      price.toString().countryPriceFormat(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: context.colors.textTertiary,
                      showLineThrough: true,
                      underlineOrLineColor: context.colors.textTertiary,
                    ),
                ],
              ),
              if (hasDiscount && (details.discountPercentage ?? '0') != '0')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      avoideResponsive: true,
                      svgImage: AppAssets.icOff,
                      height: 14,
                      width: 14,
                      color: context.colors.textSuccess,
                    ),
                    const CustomSizedBox(width: 4),
                    CustomText(
                      '${double.parse(details.discountPercentage!).toStringAsFixed(0)}% ${'off'.translate(context: context)}',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSuccess,
                    ),
                  ],
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
          child: BlocConsumer<CartCubit, CartState>(
            listener: (final BuildContext context, final CartState state) {
              if (state is CartFetchSuccess) {
                try {
                  UiUtils.getVibrationEffect();
                } catch (_) {}
              }
            },
            builder: (final BuildContext context, final CartState state) =>
                AddButton(
                  height: 40,
                  padding: 8,
                  backgroundColor: context.colors.backgroundBrandSubtle,
                  serviceId: serviceId,
                  providerId: providerId,
                  isProviderAvailableAtLocation: isProviderAvailableAtLocation,
                  maximumAllowedQuantity: int.parse(
                    details.maxQuantityAllowed ?? '10',
                  ),
                  alreadyAddedQuantity: isProviderAvailableAtLocation == "0"
                      ? 0
                      : int.parse(
                          context.read<CartCubit>().getServiceCartQuantity(
                            serviceId: serviceId,
                          ),
                        ),
                  serviceProviderName: details.provider?.companyName,
                ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingRow(context, details),
        const CustomSizedBox(height: 8),
        CustomText(
          details.title ?? '',
          maxLines: 2,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: context.colors.textPrimary,
        ),
        if ((details.shortDescription ?? '').isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CustomText(
              details.shortDescription!,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
        ],
        const CustomSizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.users,
              height: 20,
              width: 20,
              color: context.colors.iconPrimary,
            ),
            const CustomSizedBox(width: 4),
            CustomText(
              '${details.numberOfMembersRequired} ${"person".translate(context: context)}',
              fontSize: 14,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            const CustomSizedBox(width: 8),
            CustomContainer(
              width: 1,
              height: 10,
              color: context.colors.textPrimary,
            ),
            const CustomSizedBox(width: 8),
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.clock,
              height: 20,
              width: 20,
              color: context.colors.iconPrimary,
            ),
            const CustomSizedBox(width: 4),
            CustomText(
              '${details.duration} ${(details.durationType ?? 'minutes').translate(context: context)}',
              fontSize: 14,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
        if (details.atDoorstep == '1' ||
            details.atStore == '1' ||
            details.isCancellable == '1' ||
            details.payLater == '1') ...[
          const CustomSizedBox(height: 10),
          CustomContainer(
            width: double.infinity,
            color: context.colors.backgroundSecondary,
            borderRadius: UiUtils.borderRadiusOf8,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (details.payLater == '1') ...[
                    _buildAllowedBadge(
                      context,
                      label: 'payLaterAllowed'.translate(context: context),
                    ),
                    const CustomSizedBox(width: 12),
                  ],
                  if (details.atDoorstep == '1') ...[
                    _buildAllowedBadge(
                      context,
                      label: 'doorstepAllowed'.translate(context: context),
                    ),
                    const CustomSizedBox(width: 12),
                  ],
                  if (details.atStore == '1') ...[
                    _buildAllowedBadge(
                      context,
                      label: 'atStoreAllowed'.translate(context: context),
                    ),
                    const CustomSizedBox(width: 12),
                  ],
                  if (details.isCancellable == '1') ...[
                    _buildAllowedBadge(
                      context,
                      label: 'cancellableAllowed'.translate(context: context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const CustomSizedBox(height: 12),
        _buildPriceAndActionRow(context, details),
      ],
    );
  }
}
