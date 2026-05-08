import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import 'meal_selector.dart';
import 'shared_widgets.dart';

class ManualTab extends StatefulWidget {
  final String selectedMeal;
  final List<String> meals;
  final ValueChanged<String> onMealChanged;
  final ValueChanged<FoodEntry> onSave;

  const ManualTab({
    super.key,
    required this.selectedMeal,
    required this.meals,
    required this.onMealChanged,
    required this.onSave,
  });

  @override
  State<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<ManualTab> {
  final _formKey = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _calories = TextEditingController();
  final _protein  = TextEditingController();
  final _carbs    = TextEditingController();
  final _fat      = TextEditingController();
  final _grams    = TextEditingController(text: '100');

  @override
  void dispose() {
    for (final c in [_name, _calories, _protein, _carbs, _fat, _grams]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(FoodEntry(
      name:     _name.text.trim(),
      calories: double.tryParse(_calories.text) ?? 0,
      protein:  double.tryParse(_protein.text)  ?? 0,
      carbs:    double.tryParse(_carbs.text)    ?? 0,
      fat:      double.tryParse(_fat.text)      ?? 0,
      grams:    double.tryParse(_grams.text)    ?? 100,
      date:     DateFormat('yyyy-MM-dd').format(DateTime.now()),
      meal:     widget.selectedMeal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MealSelector(
              selected: widget.selectedMeal,
              meals: widget.meals,
              onChanged: widget.onMealChanged,
            ),
            const SizedBox(height: 16),
            AppField(controller: _name, label: 'Nombre del alimento', required: true),
            const SizedBox(height: 10),
            AppField(controller: _grams, label: 'Cantidad (g / ml)', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            AppField(controller: _calories, label: 'Calorías (kcal)', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: AppField(controller: _protein, label: 'Proteína (g)', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: AppField(controller: _carbs, label: 'Carbs (g)', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: AppField(controller: _fat, label: 'Grasas (g)', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Añadir', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
