import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceUnavailableBanner extends StatelessWidget {
  const ServiceUnavailableBanner({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final String latitude;
  final String longitude;
  final String address;

  @override
  Widget build(final BuildContext context) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    color: context.colors.backgroundWarningSubtle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'serviceUnavailableInYourArea'.translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textWarning,
        ),
        const CustomSizedBox(height: 4),
        CustomText(
          'serviceUnavailableInYourAreaDescription'.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textSecondary,
        ),
        const CustomSizedBox(height: 12),
        BlocConsumer<RequestAreaCoverageCubit, RequestAreaCoverageState>(
          listener: (context, state) {
            if (state is RequestAreaCoverageSuccess) {
              UiUtils.showMessage(
                context,
                state.message,
                ToastificationType.success,
              );
            } else if (state is RequestAreaCoverageFailure) {
              UiUtils.showMessage(
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            final bool isRequesting = state is RequestAreaCoverageInProgress;
            return CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
              onTap: isRequesting
                  ? null
                  : () => context
                        .read<RequestAreaCoverageCubit>()
                        .requestAreaCoverage(
                          latitude: latitude,
                          longitude: longitude,
                          address: address,
                          isAuthTokenRequired:
                              HiveRepository.getUserToken.isNotEmpty,
                        ),
              child: CustomContainer(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: context.colors.backgroundWarning,
                borderRadius: UiUtils.borderRadiusOf8,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: !isRequesting,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: CustomText(
                        'requestServiceInYourArea'.translate(context: context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textInverseLight,
                      ),
                    ),
                    if (isRequesting)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CustomCircularProgressIndicator(
                          color: context.colors.textInverseLight,
                          widthAndHeight: 18,
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
