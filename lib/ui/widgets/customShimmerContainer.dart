import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomShimmerLoadingContainer extends StatelessWidget {
  const CustomShimmerLoadingContainer({
    final Key? key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
    this.padding,
  }) : super(key: key);
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(final BuildContext context) => Shimmer.fromColors(
    baseColor: AppPalette.shimmerBase(Theme.of(context).brightness),
    highlightColor: AppPalette.shimmerHighlight(Theme.of(context).brightness),
    child: CustomContainer(
      width: width,
      margin: margin,
      padding: padding,
      height: height ?? 10,
      color: AppPalette.shimmerContent(Theme.of(context).brightness),
      borderRadius: borderRadius ?? UiUtils.borderRadiusOf10,
    ),
  );
}
