import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const GoalSelector({super.key, required this.value, required this.onChanged});

  static const _goals = [
    ('Definición',    Icons.trending_down, 'Perder grasa (déficit -400 kcal)'),
    ('Mantenimiento', Icons.trending_flat, 'Mantener peso'),
    ('Volumen',       Icons.trending_up,   'Ganar músculo (superávit +300 kcal)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _goals.map((g) {
        final selected = value == g.$1;
        return GestureDetector(
          onTap: () => onChanged(g.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF00D4AA).withOpacity(0.1)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF00D4AA) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(g.$2,
                    color: selected ? const Color(0xFF00D4AA) : Colors.white38,
                    size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.$1,
                        style: TextStyle(
                          color: selected ? const Color(0xFF00D4AA) : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                    Text(g.$3,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
                if (selected) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Color(0xFF00D4AA), size: 20),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
