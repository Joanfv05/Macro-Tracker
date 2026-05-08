import 'package:flutter/material.dart';
import 'app_colors.dart';

class MealSelector extends StatelessWidget {
  final String selected;
  final List<String> meals;
  final ValueChanged<String> onChanged;

  const MealSelector({
    super.key,
    required this.selected,
    required this.meals,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final m = meals[i];
          final active = m == selected;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                m,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
