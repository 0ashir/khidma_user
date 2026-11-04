import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderLocationBottomSheet extends StatelessWidget {
  const ProviderLocationBottomSheet({
    super.key,
    required this.providerAddress,
    required this.providerLatitude,
    required this.providerLongitude,
  });

  final String providerAddress;
  final double providerLatitude;
  final double providerLongitude;

  Widget _buildHeader(final BuildContext context) => Column(
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
      Row(
        children: [
          Expanded(
            child: CustomText(
              'location'.translate(context: context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
      const CustomSizedBox(height: 16),
      Divider(height: 1, color: context.colors.borderDefault),
    ],
  );

  Widget _buildProviderLocationCard(final BuildContext context) =>
      CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: context.colors.surfacePrimary,
        border: Border.all(color: context.colors.borderDefault),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CustomContainer(
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundSecondary,
                  borderRadius: 8,
                  child: CustomSvgPicture(
                    svgImage: AppAssets.storeOutline,
                    color: context.colors.iconPrimary,
                    height: 24,
                    width: 24,
                    avoideResponsive: true,
                  ),
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: CustomText(
                    'providerLocation'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const CustomSizedBox(height: 12),
            CustomText(
              providerAddress,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      );

  Widget _buildFooter(final BuildContext context) => ClipShadowBottom(
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
      child: CustomRoundedButton(
        buttonTitle: 'getDirection'.translate(context: context),
        showBorder: false,
        widthPercentage: 1,
        backgroundColor: context.colors.backgroundBrand,
        radius: UiUtils.borderRadiusOf12,
        textSize: 16,
        fontWeight: FontWeight.w500,
        onTap: () {
          Navigator.pop(context);
          UiUtils.openMap(
            context,
            latitude: providerLatitude,
            longitude: providerLongitude,
          );
        },
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.surfacePrimary,
    borderRadiusStyle: const BorderRadius.vertical(top: Radius.circular(16)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildHeader(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: _buildProviderLocationCard(context),
        ),
        _buildFooter(context),
      ],
    ),
  );
}
