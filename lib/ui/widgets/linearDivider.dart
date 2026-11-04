import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class LinearDivider extends StatelessWidget {
  final double? height;
  LinearDivider({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      height: height ?? 0.5,
      gradient: LinearGradient(
        colors: [
          context.colors.surfaceElevated,
          context.colors.borderDefault.withAlpha(80),
          context.colors.borderDefault,
          context.colors.borderDefault.withAlpha(80),
          context.colors.surfaceElevated,
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1],
      ),
    );
  }
}
