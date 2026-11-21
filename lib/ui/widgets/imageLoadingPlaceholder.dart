import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Soft shimmering box shown while a network image loads (replaces the old
/// app-logo placeholder). It takes the image's own size; without one it fills
/// the space it is given. Corners come from the parent's clip, so it matches
/// rounded cards, circles and banners alike.
class ImageLoadingPlaceholder extends StatelessWidget {
  const ImageLoadingPlaceholder({
    super.key,
    this.width,
    this.height,
    this.avoideResponsive = false,
  });

  final double? width;
  final double? height;
  final bool avoideResponsive;

  @override
  Widget build(final BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return LayoutBuilder(
      builder: (context, constraints) {
        double? resolve(final double? value, final double max) {
          if (value != null) {
            return avoideResponsive ? value : value.rs(context);
          }
          // No size given: fill the parent, or a small square when unbounded.
          return max.isFinite ? max : 24;
        }

        return Shimmer.fromColors(
          baseColor: AppPalette.shimmerBase(brightness),
          highlightColor: AppPalette.shimmerHighlight(brightness),
          child: Container(
            width: resolve(width, constraints.maxWidth),
            height: resolve(height, constraints.maxHeight),
            color: AppPalette.shimmerContent(brightness),
          ),
        );
      },
    );
  }
}
