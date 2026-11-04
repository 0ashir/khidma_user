import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class PriceRangeSlider extends StatelessWidget {
  const PriceRangeSlider({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double trackStart = 24.0;
        final double trackEnd = width - 24.0;
        final double trackWidth = trackEnd - trackStart;
        final double totalRange = max - min;
        final double fraction = totalRange > 0
            ? ((value - min) / totalRange).clamp(0.0, 1.0)
            : 1.0;
        final double thumbCenterX = trackStart + (trackWidth * fraction);

        return Column(
          children: [
            SizedBox(
              height: 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: thumbCenterX,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.backgroundBrand,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: CustomText(
                              NumberFormat('#,###').format(value.round()),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textInverseLight,
                            ),
                          ),
                          CustomPaint(
                            size: const Size(10, 5),
                            painter: TrianglePainter(
                              color: context.colors.backgroundBrand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 5,
                activeTrackColor: context.colors.backgroundBrand,
                inactiveTrackColor: context.colors.borderMuted,
                thumbColor: context.colors.backgroundBrand,
                overlayColor: Colors.transparent,
                trackShape: PriceSliderTrackShape(
                  startDotColor: context.colors.backgroundBrand,
                  startDotRadius: 6.5,
                ),
                thumbShape: PriceSliderThumbShape(
                  brandColor: context.colors.backgroundBrand,
                  haloColor: context.colors.backgroundBrandSubtle,
                  ringColor: context.colors.surfaceSecondary,
                ),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    NumberFormat('#,###').format(min.round()),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  CustomText(
                    NumberFormat('#,###').format(max.round()),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PriceSliderTrackShape extends RoundedRectSliderTrackShape {
  const PriceSliderTrackShape({
    required this.startDotColor,
    this.startDotRadius = 6.5,
  });

  final Color startDotColor;
  final double startDotRadius;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Offset startDotCenter = Offset(trackRect.left, trackRect.center.dy);
    final Paint dotPaint = Paint()..color = startDotColor;
    context.canvas.drawCircle(startDotCenter, startDotRadius, dotPaint);
  }
}

class PriceSliderThumbShape extends SliderComponentShape {
  const PriceSliderThumbShape({
    required this.brandColor,
    required this.haloColor,
    required this.ringColor,
  });

  final Color brandColor;
  final Color haloColor;
  final Color ringColor;
  static const double _outerRadius = 15.0;
  static const double _ringRadius = 11.5;
  static const double _dotRadius = 7.5;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_outerRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    canvas.drawCircle(center, _outerRadius, Paint()..color = haloColor);
    canvas.drawCircle(center, _ringRadius, Paint()..color = ringColor);
    canvas.drawCircle(center, _dotRadius, Paint()..color = brandColor);
  }
}
