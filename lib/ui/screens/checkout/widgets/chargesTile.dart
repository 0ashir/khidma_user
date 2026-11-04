import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class ChargesTile extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;
  final FontWeight? fontweight;
  final Color? titleColor;
  final Color? valueColor;

  const ChargesTile({
    super.key,
    required this.title,
    required this.value,
    required this.fontSize,
    this.fontweight,
    this.titleColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomText(
            title,
            fontSize: fontSize,
            fontWeight: fontweight,
            maxLines: 1,
            color: titleColor ?? context.colors.textSecondary,
          ),
        ),
        CustomText(
          value,
          textAlign: TextAlign.end,
          maxLines: 2,
          fontWeight: fontweight,
          fontSize: fontSize,
          color: valueColor ?? context.colors.textPrimary,
        ),
      ],
    );
  }
}
