import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const GenderSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF252525),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: Icon(Icons.expand_more, color: Colors.white.withOpacity(0.4)),
          isExpanded: true,
          items: ['Hombre', 'Mujer', 'Otro']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}
