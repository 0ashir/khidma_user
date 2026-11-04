import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/fetchUserCurrentLocationCubit.dart';
import 'package:flutter/material.dart';

class ConfirmAddressCard extends StatelessWidget {
  const ConfirmAddressCard({
    super.key,
    required this.selectedAddress,
    required this.isResolvingAddress,
    required this.showAddressForm,
    required this.onConfirm,
  });

  final ValueNotifier selectedAddress;
  final ValueNotifier<bool> isResolvingAddress;
  final bool showAddressForm;
  final void Function(Map addressValue) onConfirm;

  Widget _buildLocationIcon(final BuildContext context) => CustomContainer(
    borderRadius: 12,
    color: context.colors.backgroundBrandSubtle,
    padding: const EdgeInsets.all(12),
    child: CustomSvgPicture(
      svgImage: AppAssets.currentLocation,
      height: 24,
      width: 24,
      color: context.colors.iconBrand,
      avoideResponsive: true,
    ),
  );

  Widget _buildAddressDetails(
    final BuildContext context,
    final Map value,
    final bool hasError,
    final bool isTablet,
  ) {
    if (hasError) {
      return CustomText(
        "serviceNotAvailableAtSelectedLocation".translate(context: context),
        maxLines: 2,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: context.colors.textPrimary,
      );
    }
    return ValueListenableBuilder<bool>(
      valueListenable: isResolvingAddress,
      builder: (context, resolving, child) => resolving
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmerLoadingContainer(
                  height: 14,
                  width: context.screenWidth * 0.5,
                  borderRadius: UiUtils.borderRadiusOf6,
                ),
                const CustomSizedBox(height: 6),
                CustomShimmerLoadingContainer(
                  height: 12,
                  width: context.screenWidth * 0.35,
                  borderRadius: UiUtils.borderRadiusOf6,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  value["lineOneAddress"] ?? '',
                  maxLines: 1,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: isTablet ? FontWeight.w700 : FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 4),
                CustomText(
                  value["lineTwoAddress"],
                  maxLines: 1,
                  fontSize: isTablet ? 14 : 12,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
    );
  }

  Widget _buildConfirmButton(
    final BuildContext context,
    final Map value,
    final bool isTablet,
  ) =>
      BlocBuilder<FetchUserCurrentLocationCubit, FetchUserCurrentLocationState>(
        builder: (context, fetchCurrentLocationState) {
          final bool isFetchingCurrentLocation =
              fetchCurrentLocationState is FetchUserCurrentLocationInProgress;
          return CustomRoundedButton(
            onTap: isFetchingCurrentLocation ? null : () => onConfirm(value),
            widthPercentage: 1,
            radius: 12,
            height: 48,
            textSize: isTablet ? 16 : null,
            fontWeight: isTablet ? FontWeight.w500 : null,
            titleColor: context.colors.textInverseLight,
            backgroundColor: isFetchingCurrentLocation
                ? context.colors.backgroundBrandDisabled
                : context.colors.backgroundBrand,
            buttonTitle: "confirmAddress".translate(context: context),
            showBorder: false,
          );
        },
      );

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<
        CheckProviderAvailabilityCubit,
        CheckProviderAvailabilityState
      >(
        builder: (final context, final checkProviderAvailabilityState) {
          if (checkProviderAvailabilityState
              is CheckProviderAvailabilityFetchSuccess) {
            return BlocBuilder<AddAddressCubit, AddAddressState>(
              builder:
                  (final BuildContext context, final AddAddressState state) =>
                      CustomContainer(
                        width: context.screenWidth,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        color: context.colors.backgroundPrimary,
                        borderRadius: 16,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.overlayHeaderShadow,
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        child: ValueListenableBuilder(
                          valueListenable: selectedAddress,
                          builder: (context, value, child) {
                            value as Map;
                            final bool isTablet =
                                ResponsiveHelper.isTabletDevice(context);
                            final Widget locationIcon = _buildLocationIcon(
                              context,
                            );
                            final Widget addressDetails = _buildAddressDetails(
                              context,
                              value,
                              checkProviderAvailabilityState.error,
                              isTablet,
                            );
                            final bool showConfirmButton =
                                !checkProviderAvailabilityState.error;

                            if (isTablet) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  locationIcon,
                                  const CustomSizedBox(width: 16),
                                  Expanded(child: addressDetails),
                                  if (showConfirmButton) ...[
                                    const CustomSizedBox(width: 12),
                                    SizedBox(
                                      width: 251,
                                      child: _buildConfirmButton(
                                        context,
                                        value,
                                        isTablet,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    locationIcon,
                                    const CustomSizedBox(width: 16),
                                    Expanded(child: addressDetails),
                                  ],
                                ),
                                if (showConfirmButton) ...[
                                  const CustomSizedBox(height: 12),
                                  CustomContainer(
                                    height: 1,
                                    color: context.colors.borderDefault,
                                  ),
                                  const CustomSizedBox(height: 12),
                                  _buildConfirmButton(context, value, isTablet),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
            );
          }
          return CustomContainer(
            height: 150,
            width: context.screenWidth,
            margin: const EdgeInsets.all(10),
            color: context.colors.surfaceElevated,
            borderRadius: UiUtils.borderRadiusOf20,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomShimmerLoadingContainer(
                        height: 40,
                        width: 40,
                        borderRadius: UiUtils.borderRadiusOf10,
                      ),
                      const CustomSizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomShimmerLoadingContainer(
                              height: 16,
                              width: context.screenWidth * 0.45,
                              borderRadius: UiUtils.borderRadiusOf6,
                            ),
                            const CustomSizedBox(height: 8),
                            CustomShimmerLoadingContainer(
                              height: 12,
                              width: context.screenWidth * 0.6,
                              borderRadius: UiUtils.borderRadiusOf6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const CustomSizedBox(height: 10),
                const CustomShimmerLoadingContainer(
                  height: 44,
                  width: double.infinity,
                  borderRadius: UiUtils.borderRadiusOf10,
                ),
              ],
            ),
          );
        },
      );
}
