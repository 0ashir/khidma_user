import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class DeleteAddressSheet extends StatelessWidget {
  final VoidCallback onConfirmButtonPressed;

  const DeleteAddressSheet({super.key, required this.onConfirmButtonPressed});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colors.surfacePrimary,
      borderRadiusStyle: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomSizedBox(height: 8),
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.backgroundTertiary,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const CustomSizedBox(height: 16),
          CustomContainer(
            width: 64,
            height: 64,
            color: context.colors.backgroundBrandSubtle,
            shape: BoxShape.circle,
            padding: const EdgeInsets.all(16),
            child: CustomSvgPicture(
              svgImage: AppAssets.warning,
              height: 32,
              width: 32,
              color: context.colors.iconBrand,
            ),
          ),
          const CustomSizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CustomText(
                  'removeAddressTitle'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 4),
                CustomText(
                  'removeAddressDescription'.translate(context: context),
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          const CustomSizedBox(height: 16),
          ClipShadowBottom(
            child: CustomContainer(
              color: context.colors.surfacePrimary,
              padding: const EdgeInsets.all(
                16,
              ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                  color: context.colors.overlayFooterShadow,
                ),
              ],
              child: Row(
                children: [
                  Expanded(
                    child: CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf12,
                      ),
                      onTap: () => Navigator.pop(context),
                      child: CustomContainer(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: context.colors.backgroundBrandSubtle,
                        border: Border.all(color: context.colors.borderBrand),
                        borderRadius: UiUtils.borderRadiusOf12,
                        child: Center(
                          child: CustomText(
                            'keepAddress'.translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textBrand,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const CustomSizedBox(width: 12),
                  Expanded(
                    child: CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf12,
                      ),
                      onTap: onConfirmButtonPressed,
                      child: CustomContainer(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: context.colors.backgroundBrand,
                        borderRadius: UiUtils.borderRadiusOf12,
                        child: Center(
                          child: CustomText(
                            'removeAddress'.translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textInverseLight,
                          ),
                        ),
                      ),
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
}
