import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/food_api_service.dart';
import 'app_colors.dart';
import 'meal_selector.dart';

class SearchTab extends StatelessWidget {
  final TextEditingController controller;
  final List<FoodSearchResult> results;
  final bool searching;
  final String selectedMeal;
  final List<String> meals;
  final ValueChanged<String> onMealChanged;
  final ValueChanged<String> onSearch;
  final ValueChanged<FoodSearchResult> onSelectResult;

  const SearchTab({
    super.key,
    required this.controller,
    required this.results,
    required this.searching,
    required this.selectedMeal,
    required this.meals,
    required this.onMealChanged,
    required this.onSearch,
    required this.onSelectResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              MealSelector(selected: selectedMeal, meals: meals, onChanged: onMealChanged),
              const SizedBox(height: 12),
              _SearchField(controller: controller, searching: searching, onSubmitted: onSearch),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const _EmptyState()
              : _ResultsList(results: results, onTap: onSelectResult),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String> onSubmitted;

  const _SearchField({
    required this.controller,
    required this.searching,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar alimento (ej: pollo pechuga)',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
        suffixIcon: searching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
              )
            : null,
      ),
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text('No se encontraron alimentos',
              style: TextStyle(color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 8),
          Text('Usa el escáner 📷 o la pestaña "Manual"',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<FoodSearchResult> results;
  final ValueChanged<FoodSearchResult> onTap;

  const _ResultsList({required this.results, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (_, i) {
        final r = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          title: Text(r.name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${r.calories.toStringAsFixed(0)} kcal  •  '
            'P:${r.protein.toStringAsFixed(1)}g  '
            'C:${r.carbs.toStringAsFixed(1)}g  '
            'G:${r.fat.toStringAsFixed(1)}g',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          trailing: const Icon(Icons.add_circle, color: AppColors.accent),
          onTap: () => onTap(r),
        );
      },
    );
  }
}
