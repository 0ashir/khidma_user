import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ConfirmActionBottomSheet extends StatelessWidget {
  const ConfirmActionBottomSheet({
    super.key,
    required this.titleText,
    required this.questionText,
    required this.descriptionText,
    required this.confirmButtonText,
    required this.closeButtonText,
    required this.onTapConfirm,
    required this.onTapClose,
    this.isInProgress = false,
  });

  final String titleText;
  final String questionText;
  final String descriptionText;
  final String confirmButtonText;
  final String closeButtonText;
  final VoidCallback onTapConfirm;
  final VoidCallback onTapClose;
  final bool isInProgress;

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.component.bottomSheetBackground,
    borderRadiusStyle: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      titleText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const CustomSizedBox(height: 16),
              CustomContainer(height: 1, color: context.colors.borderDefault),
              const CustomSizedBox(height: 16),
              CustomSvgPicture(
                svgImage: AppAssets.confirmUser,
                height: 124,
                width: 124,
                avoideResponsive: true,
                colorMapper: IllustrationBrandColorMapper(
                  primaryColor: context.colors.iconBrand,
                  primaryLightColor: context.colors.backgroundBrandSubtle,
                ),
              ),
              const CustomSizedBox(height: 16),
              CustomText(
                questionText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const CustomSizedBox(height: 4),
              CustomText(
                descriptionText,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const CustomSizedBox(height: 16),
            ],
          ),
        ),
        ClipShadowBottom(
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.surfacePrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(
              16,
            ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
            child: Row(
              children: [
                Expanded(
                  child: CustomRoundedButton(
                    onTap: isInProgress ? null : onTapClose,
                    widthPercentage: 1,
                    backgroundColor: context.colors.backgroundBrandSubtle,
                    showBorder: true,
                    borderColor: context.colors.borderBrand,
                    buttonTitle: closeButtonText,
                    titleColor: context.colors.textBrand,
                  ),
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: CustomRoundedButton(
                    onTap: isInProgress ? null : onTapConfirm,
                    widthPercentage: 1,
                    backgroundColor: isInProgress
                        ? context.colors.textTertiary
                        : context.colors.backgroundBrand,
                    showBorder: false,
                    buttonTitle: confirmButtonText,
                    titleColor: context.colors.textInverseLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
