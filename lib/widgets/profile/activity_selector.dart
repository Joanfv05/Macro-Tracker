import 'package:flutter/material.dart';

class ActivitySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const ActivitySelector({super.key, required this.value, required this.onChanged});

  static const _activities = [
    ('sedentary',  'Sedentario',  'Poco o nada de ejercicio'),
    ('light',      'Ligero',      'Ejercicio 1-3 días/semana'),
    ('moderate',   'Moderado',    'Ejercicio 3-5 días/semana'),
    ('active',     'Activo',      'Ejercicio 6-7 días/semana'),
    ('very_active','Muy activo',  'Ejercicio 2 veces/día o trabajo físico'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _activities.map((act) {
        final selected = value == act.$1;
        return GestureDetector(
          onTap: () => onChanged(act.$1),
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
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? const Color(0xFF00D4AA) : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(act.$2,
                        style: TextStyle(
                          color: selected ? const Color(0xFF00D4AA) : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                    Text(act.$3,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
