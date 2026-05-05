import 'dart:math';
import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final double calories;
  final double goalCalories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroRing({
    super.key,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (goalCalories - calories).clamp(0, goalCalories);
    final progress = goalCalories > 0 ? (calories / goalCalories).clamp(0.0, 1.0) : 0.0;
    final over = calories > goalCalories;

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 200),
              painter: _RingPainter(
                progress: progress,
                over: over,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calories.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Text(
                  'kcal',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  over
                      ? '+${(calories - goalCalories).toStringAsFixed(0)} exceso'
                      : '${remaining.toStringAsFixed(0)} restantes',
                  style: TextStyle(
                    color: over ? const Color(0xFFFF6B6B) : const Color(0xFF00D4AA),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool over;

  _RingPainter({required this.progress, required this.over});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: over
            ? [const Color(0xFFFF4444), const Color(0xFFFF6B6B)]
            : [const Color(0xFF00D4AA), const Color(0xFF00F5C8)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.over != over;
}
