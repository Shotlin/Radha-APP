import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// Circular 0-100 score gauge — the "82/100" ring used on the OHS dashboard.
/// Pure painter, no charting package: a track ring plus a colored progress
/// arc starting at 12 o'clock, with the score rendered mono in the center.
class RadhaScoreGauge extends StatelessWidget {
  const RadhaScoreGauge({
    super.key,
    required this.score,
    required this.color,
    this.size = 112,
    this.strokeWidth = 10,
  });

  final int score;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: RadhaMotion.slow,
            curve: RadhaMotion.easeOut,
            tween: Tween<double>(begin: 0, end: score.clamp(0, 100) / 100),
            builder: (context, t, _) => CustomPaint(
              size: Size.square(size),
              painter: _GaugePainter(
                progress: t,
                color: color,
                trackColor: theme.colorScheme.outline,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: radhaMonoStyle(
                  fontSize: size * 0.28,
                  weight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '/100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
