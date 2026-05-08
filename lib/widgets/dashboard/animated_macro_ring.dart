import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedMacroRing extends StatefulWidget {
  final double calories;
  final double goalCalories;
  final double protein;
  final double carbs;
  final double fat;

  const AnimatedMacroRing({
    super.key,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  State<AnimatedMacroRing> createState() => _AnimatedMacroRingState();
}

class _AnimatedMacroRingState extends State<AnimatedMacroRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousCalories = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _previousCalories = widget.calories;
  }

  @override
  void didUpdateWidget(AnimatedMacroRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calories != widget.calories) {
      _previousCalories = oldWidget.calories;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCalorieColor() {
    final progress = widget.goalCalories > 0 ? widget.calories / widget.goalCalories : 0;
    if (progress >= 1.0) return const Color(0xFFFF4444);
    if (progress >= 0.8) return const Color(0xFFFFB347);
    return const Color(0xFF00D4AA);
  }

  String _getStatusText() {
    final remaining = (widget.goalCalories - widget.calories).clamp(0, widget.goalCalories);
    final over = widget.calories > widget.goalCalories;
    if (over) {
      return '+${(widget.calories - widget.goalCalories).toStringAsFixed(0)} exceso';
    }
    return '${remaining.toStringAsFixed(0)} restantes';
  }

  Color _getStatusColor() {
    final progress = widget.goalCalories > 0 ? widget.calories / widget.goalCalories : 0;
    if (progress >= 1.0) return const Color(0xFFFF4444);
    if (progress >= 0.9) return const Color(0xFFFFB347);
    return const Color(0xFF00D4AA);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goalCalories > 0
        ? (widget.calories / widget.goalCalories).clamp(0.0, 1.0)
        : 0.0;
    final over = widget.calories > widget.goalCalories;
    final ringColor = _getCalorieColor();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedProgress = _controller.isAnimating
            ? (_previousCalories / widget.goalCalories).clamp(0.0, 1.0) +
                (_animation.value *
                    (progress - (_previousCalories / widget.goalCalories).clamp(0.0, 1.0)))
            : progress;

        final animatedCalories = _controller.isAnimating
            ? _previousCalories + (_animation.value * (widget.calories - _previousCalories))
            : widget.calories;

        return Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _RingPainterWidget(
                  progress: animatedProgress,
                  color: ringColor,
                  over: over,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(
                          begin: _previousCalories, end: widget.calories),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: ringColor,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    const Text(
                      'kcal',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
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
      },
    );
  }
}

class _RingPainterWidget extends StatelessWidget {
  final double progress;
  final Color color;
  final bool over;

  const _RingPainterWidget({
    required this.progress,
    required this.color,
    required this.over,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _RingCustomPainter(progress: progress, color: color, over: over),
    );
  }
}

class _RingCustomPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool over;

  _RingCustomPainter(
      {required this.progress, required this.color, required this.over});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingCustomPainter old) {
    return old.progress != progress || old.color != color;
  }
}
