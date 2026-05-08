import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'food_tile.dart';

const List<String> kMeals = [
  'Desayuno',
  'Almuerzo',
  'Comida',
  'Merienda',
  'Cena',
  'Snack'
];

class MealSection extends StatelessWidget {
  final String meal;
  final List<FoodEntry> foods;
  final Function(FoodEntry) onFoodTap;
  final Function(FoodEntry) onDelete;

  const MealSection({
    super.key,
    required this.meal,
    required this.foods,
    required this.onFoodTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _mealIcon(meal),
              const SizedBox(width: 8),
              Text(
                meal,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${foods.length}',
                  style: const TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...foods.map((food) => FoodTile(
              food: food,
              onTap: () => onFoodTap(food),
              onDelete: () => onDelete(food),
            )),
      ],
    );
  }

  static Widget _mealIcon(String meal) {
    IconData icon;
    Color color;
    switch (meal) {
      case 'Desayuno':
        icon = Icons.bedtime;
        color = const Color(0xFFFFB347);
        break;
      case 'Almuerzo':
        icon = Icons.lunch_dining;
        color = const Color(0xFF00D4AA);
        break;
      case 'Comida':
        icon = Icons.dinner_dining;
        color = const Color(0xFF4FC3F7);
        break;
      case 'Merienda':
        icon = Icons.cake;
        color = const Color(0xFFA78BFA);
        break;
      case 'Cena':
        icon = Icons.nightlife;
        color = const Color(0xFFFF6B6B);
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.white54;
    }
    return Icon(icon, color: color, size: 16);
  }
}
