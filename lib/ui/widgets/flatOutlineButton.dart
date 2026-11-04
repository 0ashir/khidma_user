import 'package:flutter/material.dart';

import "../../app/generalImports.dart";

class FlatOutlinedButton extends StatelessWidget {
  const FlatOutlinedButton({
    required this.name,
    required this.onTap,
    required this.isSelected,
    final Key? key,
    this.icon,
  }) : super(key: key);

  final bool isSelected;
  final String name;
  final String? icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
    onTap: onTap,
    child: CustomContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: UiUtils.borderRadiusOf12,
      color: isSelected
          ? context.colors.backgroundBrandSubtle
          : context.colors.backgroundSecondary,
      border: isSelected ? Border.all(color: context.colors.borderBrand) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: icon!,
              color: isSelected
                  ? context.colors.iconBrand
                  : context.colors.iconPrimary,
              height: 20,
              width: 20,
            ),
            const CustomSizedBox(width: 8),
          ],
          CustomText(
            name,
            color: isSelected
                ? context.colors.textBrand
                : context.colors.textPrimary,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
          ),
        ],
      ),
    ),
  );
}
