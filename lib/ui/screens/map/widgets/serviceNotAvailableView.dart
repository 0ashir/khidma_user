import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceNotAvailableView extends StatelessWidget {
  const ServiceNotAvailableView({
    super.key,
    required this.selectedAddress,
    required this.isResolvingAddress,
    required this.selectedLatitude,
    required this.selectedLongitude,
    required this.onEditLocation,
    required this.onAreaRequestSubmitted,
  });

  final ValueNotifier selectedAddress;
  final ValueNotifier<bool> isResolvingAddress;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final VoidCallback onEditLocation;
  final VoidCallback onAreaRequestSubmitted;

  Widget _buildRequestTitle(
    final BuildContext context, {
    required final bool isTablet,
  }) => CustomText(
    'wantUsToServeYourArea'.translate(context: context),
    textAlign: isTablet ? TextAlign.start : TextAlign.center,
    fontWeight: FontWeight.w500,
    fontSize: isTablet ? 16 : 14,
    color: context.colors.textPrimary,
  );

  Widget _buildRequestSubtitle(
    final BuildContext context, {
    required final bool isTablet,
  }) => CustomText(
    'submitRequestServiceAvailableMessage'.translate(context: context),
    textAlign: isTablet ? TextAlign.start : TextAlign.center,
    fontWeight: FontWeight.w400,
    fontSize: isTablet ? 14 : 12,
    color: context.colors.textSecondary,
  );

  Widget _buildRequestButton(
    final BuildContext context, {
    required final bool isTablet,
  }) => BlocConsumer<RequestAreaCoverageCubit, RequestAreaCoverageState>(
    listener: (context, requestAreaCoverageState) {
      if (requestAreaCoverageState is RequestAreaCoverageSuccess) {
        onAreaRequestSubmitted();
      } else if (requestAreaCoverageState is RequestAreaCoverageFailure) {
        UiUtils.showMessage(
          context,
          requestAreaCoverageState.errorMessage,
          ToastificationType.error,
        );
      }
    },
    builder: (context, requestAreaCoverageState) {
      final isRequesting =
          requestAreaCoverageState is RequestAreaCoverageInProgress;
      return CustomRoundedButton(
        onTap: isRequesting
            ? null
            : () {
                final value = selectedAddress.value as Map;
                final address =
                    "${value["lineOneAddress"] ?? ''} ${value["lineTwoAddress"] ?? ''}"
                        .trim();
                context.read<RequestAreaCoverageCubit>().requestAreaCoverage(
                  latitude: selectedLatitude.toString(),
                  longitude: selectedLongitude.toString(),
                  address: address,
                  isAuthTokenRequired: HiveRepository.getUserToken.isNotEmpty,
                );
              },
        widthPercentage: 1,
        height: 48,
        radius: isTablet ? 12 : 16,
        textSize: isTablet ? 16 : null,
        fontWeight: isTablet ? FontWeight.w500 : null,
        backgroundColor: isRequesting
            ? context.colors.backgroundBrandDisabled
            : context.colors.backgroundBrand,
        titleColor: context.colors.textInverseLight,
        buttonTitle: 'requestServiceHere'.translate(context: context),
        showBorder: false,
      );
    },
  );

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CustomSizedBox(height: 24),
                CustomSvgPicture(
                  svgImage: AppAssets.locationAccess,
                  avoideResponsive: true,
                  width: ResponsiveHelper.isTabletDevice(context) ? 350 : 200,
                  colorMapper: IllustrationBrandColorMapper(
                    primaryColor: context.colors.iconError,
                    primaryLightColor: context.colors.backgroundErrorSubtle,
                  ),
                ),
                const CustomSizedBox(height: 24),
                CustomText(
                  'servicesNotAvailableHereYet'.translate(context: context),
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 8),
                CustomText(
                  'servicesNotAvailableHereYetMessage'.translate(
                    context: context,
                  ),
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
                const CustomSizedBox(height: 24),
                ValueListenableBuilder(
                  valueListenable: selectedAddress,
                  builder: (context, value, child) {
                    value as Map;
                    return CustomInkWellContainer(
                      onTap: onEditLocation,
                      borderRadius: BorderRadius.circular(12),
                      child: CustomContainer(
                        width: context.screenWidth,
                        padding: const EdgeInsets.all(12),
                        color: context.colors.backgroundPrimary,
                        borderRadius: 12,
                        child: Row(
                          children: [
                            CustomContainer(
                              padding: const EdgeInsets.all(8),
                              color: context.colors.backgroundSecondary,
                              borderRadius: 8,
                              child: CustomSvgPicture(
                                svgImage: AppAssets.icLocation,
                                width: 24,
                                height: 24,
                                color: context.colors.iconPrimary,
                                avoideResponsive: true,
                              ),
                            ),
                            const CustomSizedBox(width: 12),
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: isResolvingAddress,
                                builder: (context, resolving, child) =>
                                    resolving
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomShimmerLoadingContainer(
                                            height: 14,
                                            width: context.screenWidth * 0.5,
                                            borderRadius:
                                                UiUtils.borderRadiusOf6,
                                          ),
                                          const CustomSizedBox(height: 6),
                                          CustomShimmerLoadingContainer(
                                            height: 12,
                                            width: context.screenWidth * 0.35,
                                            borderRadius:
                                                UiUtils.borderRadiusOf6,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            value["lineOneAddress"] ?? '',
                                            maxLines: 1,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.textPrimary,
                                          ),
                                          const CustomSizedBox(height: 2),
                                          CustomText(
                                            value["lineTwoAddress"] ?? '',
                                            maxLines: 1,
                                            fontSize: 12,
                                            color: context.colors.textSecondary,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const CustomSizedBox(width: 8),
                            CustomSvgPicture(
                              svgImage: AppAssets.edit,
                              width: 24,
                              height: 24,
                              color: context.colors.iconPrimary,
                              avoideResponsive: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      CustomContainer(
        width: context.screenWidth,
        padding: const EdgeInsets.all(16),
        color: context.colors.backgroundPrimary,
        child: SafeArea(
          top: false,
          child: ResponsiveHelper.isTabletDevice(context)
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequestTitle(context, isTablet: true),
                          const CustomSizedBox(height: 4),
                          _buildRequestSubtitle(context, isTablet: true),
                        ],
                      ),
                    ),
                    const CustomSizedBox(width: 12),
                    SizedBox(
                      width: 358,
                      child: _buildRequestButton(context, isTablet: true),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRequestTitle(context, isTablet: false),
                    const CustomSizedBox(height: 4),
                    _buildRequestSubtitle(context, isTablet: false),
                    const CustomSizedBox(height: 12),
                    CustomContainer(
                      height: 1,
                      color: context.colors.borderDefault,
                    ),
                    const CustomSizedBox(height: 12),
                    _buildRequestButton(context, isTablet: false),
                  ],
                ),
        ),
      ),
    ],
  );
}
