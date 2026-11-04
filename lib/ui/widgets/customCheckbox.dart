import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.onChanged,
    this.value,
    this.isCircular = false,
  });

  final Function(bool?) onChanged;
  final bool? value;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      activeColor: context.colors.backgroundSecondary,
      fillColor: WidgetStateProperty.all(context.colors.backgroundSecondary),
      side: WidgetStateBorderSide.resolveWith(
        (states) =>
            BorderSide(width: 1.0, color: context.colors.backgroundBrand),
      ),
      shape: isCircular
          ? const CircleBorder()
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
            ),
      visualDensity: VisualDensity.standard,
      checkColor: context.colors.textBrand,
      value: value,
      onChanged: (bool? val) {
        onChanged.call(val);
      },
    );
  }
}
