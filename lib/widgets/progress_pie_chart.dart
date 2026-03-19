import 'dart:math';
import 'package:flutter/material.dart';

class PieSegment {
  final double value;
  final Color color;
  final String label;

  PieSegment({
    required this.value,
    required this.color,
    required this.label,
  });
}

class ProgressPieChart extends StatelessWidget {
  final List<PieSegment> segments;
  final double size;

  const ProgressPieChart({
    super.key,
    required this.segments,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PieChartPainter(segments),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<PieSegment> segments;

  _PieChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total =
        segments.fold<double>(0, (sum, segment) => sum + segment.value);
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var startAngle = -pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
