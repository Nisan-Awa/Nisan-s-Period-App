import 'package:flutter/material.dart';
import 'dart:math';

class CycleRingWidget extends StatelessWidget {
  final int currentDay;
  final int totalDays;

  const CycleRingWidget({
    super.key,
    required this.currentDay,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: _CycleRingPainter(
        currentDay: currentDay,
        totalDays: totalDays,
        theme: Theme.of(context),
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final int currentDay;
  final int totalDays;
  final ThemeData theme;

  _CycleRingPainter({
    required this.currentDay,
    required this.totalDays,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 16;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    
    canvas.drawCircle(center, radius, bgPaint);

    // Period phase (assuming ~5 days average flow)
    final periodPaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final sweepAnglePeriod = (5 / totalDays) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start at top
      sweepAnglePeriod,
      false,
      periodPaint,
    );

    // Current day marker
    final currentAngle = -pi / 2 + ((currentDay / totalDays) * 2 * pi);
    final markerX = center.dx + radius * cos(currentAngle);
    final markerY = center.dy + radius * sin(currentAngle);

    final markerOuterPaint = Paint()
      ..color = theme.scaffoldBackgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(markerX, markerY), 14, markerOuterPaint);

    final markerInnerPaint = Paint()
      ..color = theme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 10, markerInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay || oldDelegate.totalDays != totalDays;
  }
}
