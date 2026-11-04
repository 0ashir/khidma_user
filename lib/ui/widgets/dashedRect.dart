import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class DashedRect extends StatelessWidget {
  const DashedRect({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 0.0,
  });
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.all(strokeWidth / 2),
    child: CustomPaint(
      painter: DashRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
        borderRadius: borderRadius,
      ),
    ),
  );
}

class DashRectPainter extends CustomPainter {
  DashRectPainter({
    this.strokeWidth = 2.0,
    this.color = Colors.red,
    this.gap = 5.0,
    this.borderRadius = 0.0,
  });
  double strokeWidth;
  Color color;
  double gap;
  double borderRadius;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double x = size.width;
    final double y = size.height;
    // Straight sides stop short of the corners so the (optional) rounded
    // corner arcs below have room to draw without overlapping them.
    final double r = borderRadius.clamp(0, min(x, y) / 2);

    final Path topPath = getDashedPath(
      a: Point(r, 0),
      b: Point(x - r, 0),
      gap: gap,
    );

    final Path rightPath = getDashedPath(
      a: Point(x, r),
      b: Point(x, y - r),
      gap: gap,
    );

    final Path bottomPath = getDashedPath(
      a: Point(r, y),
      b: Point(x - r, y),
      gap: gap,
    );

    final Path leftPath = getDashedPath(
      a: Point(0, r),
      b: Point(0.001, y - r),
      gap: gap,
    );

    canvas.drawPath(topPath, dashedPaint);
    canvas.drawPath(rightPath, dashedPaint);
    canvas.drawPath(bottomPath, dashedPaint);
    canvas.drawPath(leftPath, dashedPaint);

    if (r > 0) {
      canvas.drawPath(
        getDashedArcPath(
          center: Offset(x - r, r),
          radius: r,
          startAngle: -pi / 2,
          sweepAngle: pi / 2,
          gap: gap,
        ),
        dashedPaint,
      );
      canvas.drawPath(
        getDashedArcPath(
          center: Offset(x - r, y - r),
          radius: r,
          startAngle: 0,
          sweepAngle: pi / 2,
          gap: gap,
        ),
        dashedPaint,
      );
      canvas.drawPath(
        getDashedArcPath(
          center: Offset(r, y - r),
          radius: r,
          startAngle: pi / 2,
          sweepAngle: pi / 2,
          gap: gap,
        ),
        dashedPaint,
      );
      canvas.drawPath(
        getDashedArcPath(
          center: Offset(r, r),
          radius: r,
          startAngle: pi,
          sweepAngle: pi / 2,
          gap: gap,
        ),
        dashedPaint,
      );
    }
  }

  Path getDashedPath({
    required final Point<double> a,
    required final Point<double> b,
    required final gap,
  }) {
    final Size size = Size(b.x - a.x, b.y - a.y);
    final path = Path();
    path.moveTo(a.x, a.y);

    bool shouldDraw = true;
    Point<double> currentPoint = Point<double>(a.x, a.y);

    final num radians = atan(size.height / size.width);

    final num dx = cos(radians) * gap < 0
        ? cos(radians) * gap * -1
        : cos(radians) * gap;

    final num dy = sin(radians) * gap < 0
        ? sin(radians) * gap * -1
        : sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x, currentPoint.y)
          : path.moveTo(currentPoint.x, currentPoint.y);

      shouldDraw = !shouldDraw;
      currentPoint = Point(currentPoint.x + dx, currentPoint.y + dy);
    }
    return path;
  }

  // Corner arcs are dashed by walking the arc's own path metrics rather
  // than the point-stepping approach above, so the dashes stay curved
  // instead of being approximated with straight chords.
  Path getDashedArcPath({
    required final Offset center,
    required final double radius,
    required final double startAngle,
    required final double sweepAngle,
    required final double gap,
  }) {
    final Path arc = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );

    final Path dashed = Path();
    for (final metric in arc.computeMetrics()) {
      double distance = 0;
      bool shouldDraw = true;
      while (distance < metric.length) {
        final double next = (distance + gap).clamp(0, metric.length);
        if (shouldDraw) {
          dashed.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        shouldDraw = !shouldDraw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(final CustomPainter oldDelegate) => true;
}
