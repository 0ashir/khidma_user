import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Read-only row of 5 stars for an average rating. Any fractional part
/// (e.g. 4.3) renders a half star: 4 full + 1 half.
class AverageRatingStars extends StatelessWidget {
  const AverageRatingStars({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    Widget star(final Color color) => CustomSvgPicture(
      avoideResponsive: true,
      svgImage: AppAssets.icStar,
      color: color,
      height: 16,
      width: 16,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: List.generate(5, (final int index) {
        if (index + 1 <= rating) return star(context.colors.iconWarning);
        if (index < rating) {
          return Stack(
            children: [
              star(context.colors.borderDefault),
              ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 0.5,
                  child: star(context.colors.iconWarning),
                ),
              ),
            ],
          );
        }
        return star(context.colors.borderDefault);
      }),
    );
  }
}
