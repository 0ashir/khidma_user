import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomReadMoreTextContainer extends StatelessWidget {
  final String text;
  final int? trimLines;
  final TextStyle? textStyle;

  const CustomReadMoreTextContainer({
    super.key,
    required this.text,
    this.trimLines,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimLines: trimLines ?? 3,
      trimMode: TrimMode.Line,
      style: textStyle,
      trimCollapsedText: "more".translate(context: context),
      trimExpandedText: "less".translate(context: context),
      lessStyle: TextStyle(
        color: context.colors.textBrand,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      moreStyle: TextStyle(
        color: context.colors.textBrand,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
