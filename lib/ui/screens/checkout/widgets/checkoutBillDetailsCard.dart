import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CheckoutBillDetailsCard extends StatelessWidget {
  const CheckoutBillDetailsCard({
    required this.rows,
    required this.showSavedBanner,
    required this.savedAmountText,
    required this.finalTotalText,
    required this.isExpanded,
    required this.onToggle,
    this.originalTotalText,
    this.savedBadgeText,
    super.key,
  });

  final List<Widget> rows;
  final bool showSavedBanner;
  final String savedAmountText;
  final String finalTotalText;
  final String? originalTotalText;
  final String? savedBadgeText;
  final bool isExpanded;
  final VoidCallback onToggle;

  Widget _buildBillToggleButton(final BuildContext context) =>
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(24),
        onTap: onToggle,
        child: CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.backgroundSecondary,
          shape: BoxShape.circle,
          child: CustomSvgPicture(
            svgImage: isExpanded ? AppAssets.upArrow : AppAssets.downArrow,
            height: 20,
            width: 20,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
      );

  Widget _buildCollapsedBillSummary(
    final BuildContext context, {
    required final String finalTotalText,
    final String? originalTotalText,
    final String? savedBadgeText,
  }) {
    final bool hasDiscount = originalTotalText != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.backgroundSecondary,
          borderRadius: 12,
          child: CustomSvgPicture(
            svgImage: AppAssets.fileText,
            height: 16,
            width: 16,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
        const CustomSizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    '${'totalBill'.translate(context: context)} ',
                    fontSize: 14,
                    color: context.colors.textPrimary,
                  ),
                  if (hasDiscount) ...[
                    CustomText(
                      '$originalTotalText, ',
                      fontSize: 14,
                      color: context.colors.textPrimary,
                      showLineThrough: true,
                    ),
                  ],
                  CustomText(
                    finalTotalText,
                    fontSize: 14,
                    fontWeight: hasDiscount ? FontWeight.w600 : FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
              if (savedBadgeText != null) ...[
                const CustomSizedBox(height: 4),
                CustomContainer(
                  padding: const EdgeInsets.all(4),
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: 4,
                  child: CustomText(
                    savedBadgeText,
                    fontSize: 11,
                    color: context.colors.textBrand,
                  ),
                ),
              ],
            ],
          ),
        ),
        const CustomSizedBox(width: 8),
        _buildBillToggleButton(context),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: CustomContainer(
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded) ...[
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    'billDetails'.translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                _buildBillToggleButton(context),
              ],
            ),
            const CustomSizedBox(height: 12),
            Divider(height: 1, color: context.colors.borderDefault),
            const CustomSizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
            if (showSavedBanner) ...[
              const CustomSizedBox(height: 12),
              CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: context.colors.backgroundSuccessSubtle,
                borderRadius: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.verified,
                      height: 24,
                      width: 24,
                      avoideResponsive: true,
                      color: context.colors.backgroundSuccess,
                    ),
                    const CustomSizedBox(width: 8),
                    Flexible(
                      child: CustomText(
                        savedAmountText,
                        fontSize: 12,
                        color: context.colors.textSuccess,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            _buildCollapsedBillSummary(
              context,
              finalTotalText: finalTotalText,
              originalTotalText: originalTotalText,
              savedBadgeText: savedBadgeText,
            ),
        ],
      ),
    ),
  );
}
