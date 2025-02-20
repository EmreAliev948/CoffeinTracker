import 'package:flutter/material.dart';
import 'dart:math' as math;

class CaffeineClock extends StatelessWidget {
  final double currentLevel;
  final double effectiveLevel;
  final double maxLevel;
  final double halfLifeProgress;
  final String peakStatus;

  const CaffeineClock({
    super.key,
    required this.currentLevel,
    required this.effectiveLevel,
    this.maxLevel = 400,
    required this.halfLifeProgress,
    required this.peakStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.brown.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Caffeine level indicator
          CustomPaint(
            size: const Size(200, 200),
            painter: CaffeineClockPainter(
              progress: currentLevel / maxLevel,
              halfLifeProgress: halfLifeProgress,
            ),
          ),
          // Current level text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${effectiveLevel.round()}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'mg caffeine',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                peakStatus,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.brown.shade600,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CaffeineClockPainter extends CustomPainter {
  final double progress;
  final double halfLifeProgress;

  CaffeineClockPainter({
    required this.progress,
    required this.halfLifeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.brown.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawCircle(center, radius - 10, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = _getProgressColor(progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -math.pi / 2,
      2 * math.pi * math.min(1, progress),
      false,
      progressPaint,
    );

    // Draw half-life indicator
    final halfLifePaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final halfLifeRadius = radius - 20;
    final halfLifeAngle = 2 * math.pi * halfLifeProgress - math.pi / 2;
    final halfLifeX = center.dx + halfLifeRadius * math.cos(halfLifeAngle);
    final halfLifeY = center.dy + halfLifeRadius * math.sin(halfLifeAngle);

    canvas.drawLine(center, Offset(halfLifeX, halfLifeY), halfLifePaint);
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.5) return Colors.orange;
    return Colors.green;
  }

  @override
  bool shouldRepaint(CaffeineClockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.halfLifeProgress != halfLifeProgress;
  }
}
