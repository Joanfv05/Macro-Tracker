import 'package:flutter/material.dart';

class ImcCard extends StatelessWidget {
  final double imc;

  const ImcCard({super.key, required this.imc});

  String get _label {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25)   return 'Normal';
    if (imc < 30)   return 'Sobrepeso';
    if (imc < 35)   return 'Obesidad I';
    if (imc < 40)   return 'Obesidad II';
    return 'Obesidad III';
  }

  Color get _color {
    if (imc < 18.5) return const Color(0xFF4FC3F7);
    if (imc < 25)   return const Color(0xFF00D4AA);
    if (imc < 30)   return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                imc.toStringAsFixed(1),
                style: TextStyle(color: _color, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IMC', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text(_label,
                  style: TextStyle(color: _color, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
