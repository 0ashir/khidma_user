import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomRadioOptionsWidget extends StatelessWidget {
  final String image;
  final String title;
  final String value;
  final String groupValue;
  final Function(Object?)? onChanged;
  final bool? applyAccentColor;

  const CustomRadioOptionsWidget({
    super.key,
    required this.image,
    required this.title,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.applyAccentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return CustomInkWellContainer(
      onTap: () => onChanged?.call(value),
      child: Row(
        children: [
          CustomContainer(
            color: context.colors.backgroundSecondary,
            borderRadius: 7,
            child: CustomSvgPicture(
              svgImage: image,
              height: 40,
              width: 40,
              color: applyAccentColor! ? context.colors.iconBrand : null,
              avoideResponsive: true,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? context.colors.borderBrand
                    : context.colors.borderDefault,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.backgroundBrand,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
