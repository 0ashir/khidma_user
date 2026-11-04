import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// The "STEP 1 Categories -- STEP 2 Request Details" header shown across
/// the Request Service flow (RequestServiceCategorySelectionScreen and
/// RequestServiceFormScreen). Step 1 shows a completed checkmark once the
/// user has moved on to step 2.
class RequestServiceStepper extends StatelessWidget {
  const RequestServiceStepper({super.key, required this.currentStep});

  /// 1 while picking a category, 2 while filling in request details.
  final int currentStep;

  Widget _buildStepIcon(
    final BuildContext context, {
    required final String svgImage,
    required final bool isActive,
  }) => CustomContainer(
    padding: const EdgeInsets.all(8),
    color: isActive
        ? context.colors.backgroundBrandSubtle
        : context.colors.backgroundSecondary,
    border: isActive ? Border.all(color: context.colors.borderBrand) : null,
    borderRadius: 24,
    child: CustomSvgPicture(
      svgImage: svgImage,
      height: 16,
      width: 16,
      color: isActive ? context.colors.iconBrand : context.colors.iconPrimary,
      avoideResponsive: true,
    ),
  );

  @override
  Widget build(final BuildContext context) {
    final bool isStep1Active = currentStep == 1;
    final bool isStep1Completed = currentStep > 1;
    final bool isStep2Active = currentStep == 2;

    return CustomContainer(
      width: double.infinity,
      color: context.colors.backgroundPrimary,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          offset: const Offset(0, 8),
          color: context.colors.overlayHeaderShadow,
        ),
      ],
      child: Row(
        children: [
          isStep1Completed
              ? CustomContainer(
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundSuccessSubtle,
                  borderRadius: 24,
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: context.colors.iconSuccess,
                  ),
                )
              : _buildStepIcon(
                  context,
                  svgImage: AppAssets.squaresFour,
                  isActive: isStep1Active,
                ),
          const CustomSizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'step1'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isStep1Active
                    ? context.colors.textBrand
                    : context.colors.textSecondary,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                'categories'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isStep1Active
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
            ],
          ),
          const CustomSizedBox(width: 4),
          // Shrinks first so "Request Details" always fits on one line.
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 60),
                child: CustomSizedBox(
                  height: 1,
                  width: double.infinity,
                  child: DashedRect(
                    color: context.colors.borderDefault,
                    strokeWidth: 1,
                    gap: 4,
                  ),
                ),
              ),
            ),
          ),
          const CustomSizedBox(width: 4),
          _buildStepIcon(
            context,
            svgImage: AppAssets.service,
            isActive: isStep2Active,
          ),
          const CustomSizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'step2'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isStep2Active
                    ? context.colors.textBrand
                    : context.colors.textSecondary,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                'requestDetails'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isStep2Active
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
