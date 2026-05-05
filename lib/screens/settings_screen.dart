import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _calories;
  late TextEditingController _protein;
  late TextEditingController _carbs;
  late TextEditingController _fat;
  late TextEditingController _water;
  late TextEditingController _steps;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final goals = context.read<NutritionProvider>().goals;
      _calories = TextEditingController(text: goals.calories.toStringAsFixed(0));
      _protein = TextEditingController(text: goals.protein.toStringAsFixed(0));
      _carbs = TextEditingController(text: goals.carbs.toStringAsFixed(0));
      _fat = TextEditingController(text: goals.fat.toStringAsFixed(0));
      _water = TextEditingController(text: goals.water.toStringAsFixed(1));
      _steps = TextEditingController(text: goals.steps.toString());
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _water.dispose();
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis objetivos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ajusta tus objetivos diarios manualmente',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 14),
                ),

                const SizedBox(height: 28),

                _SectionHeader('Macros diarios'),
                const SizedBox(height: 12),

                _GoalField(
                  controller: _calories,
                  label: 'Calorías',
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFF00D4AA),
                ),
                const SizedBox(height: 10),
                _GoalField(
                  controller: _protein,
                  label: 'Proteína',
                  unit: 'g',
                  icon: Icons.fitness_center,
                  color: const Color(0xFF00D4AA),
                ),
                const SizedBox(height: 10),
                _GoalField(
                  controller: _carbs,
                  label: 'Carbohidratos',
                  unit: 'g',
                  icon: Icons.grain,
                  color: const Color(0xFFFFB347),
                ),
                const SizedBox(height: 10),
                _GoalField(
                  controller: _fat,
                  label: 'Grasas',
                  unit: 'g',
                  icon: Icons.opacity,
                  color: const Color(0xFFFF6B6B),
                ),

                const SizedBox(height: 24),
                _SectionHeader('Actividad'),
                const SizedBox(height: 12),

                _GoalField(
                  controller: _water,
                  label: 'Agua',
                  unit: 'L/día',
                  icon: Icons.water_drop,
                  color: const Color(0xFF4FC3F7),
                  decimal: true,
                ),
                const SizedBox(height: 10),
                _GoalField(
                  controller: _steps,
                  label: 'Pasos',
                  unit: 'pasos/día',
                  icon: Icons.directions_walk,
                  color: const Color(0xFFA78BFA),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Guardar objetivos',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goals = UserGoals(
      calories: double.tryParse(_calories.text) ?? 2000,
      protein: double.tryParse(_protein.text) ?? 150,
      carbs: double.tryParse(_carbs.text) ?? 200,
      fat: double.tryParse(_fat.text) ?? 60,
      water: double.tryParse(_water.text) ?? 2.5,
      steps: int.tryParse(_steps.text) ?? 8000,
    );
    context.read<NutritionProvider>().saveGoals(goals);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Objetivos guardados ✓'),
        backgroundColor: Color(0xFF00D4AA),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final bool decimal;

  const _GoalField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        suffixText: unit,
        suffixStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        if (double.tryParse(v) == null) return 'Número inválido';
        return null;
      },
    );
  }
}