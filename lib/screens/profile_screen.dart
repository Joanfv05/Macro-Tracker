import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';
import '../widgets/profile/profile_field.dart';
import '../widgets/profile/section_label.dart';
import '../widgets/profile/imc_card.dart';
import '../widgets/profile/gender_selector.dart';
import '../widgets/profile/activity_selector.dart';
import '../widgets/profile/goal_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name   = TextEditingController();
  final _age    = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  String _gender   = 'Hombre';
  String _goal     = 'Definición';
  String _activity = 'moderate';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _age, _weight, _height]) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.delayed(Duration.zero);
    final profile = context.read<NutritionProvider>().profile;
    setState(() {
      _name.text   = profile.name;
      _age.text    = profile.age.toString();
      _weight.text = profile.weight.toString();
      _height.text = profile.height.toString();
      _gender      = profile.gender;
      _goal        = profile.goal;
      _activity    = profile.activity;
      _loaded      = true;
    });
  }

  // ── Cálculos nutricionales ────────────────────────────────────────────────

  double _bmr(double weight, double height, int age, String gender) {
    // Fórmula Mifflin-St Jeor (1990)
    final base = (10 * weight) + (6.25 * height) - (5 * age);
    return gender == 'Mujer' ? base - 161 : base + 5;
  }

  double _activityFactor(String activity) => switch (activity) {
    'sedentary'  => 1.2,
    'light'      => 1.375,
    'moderate'   => 1.55,
    'active'     => 1.725,
    'very_active'=> 1.9,
    _            => 1.55,
  };

  int _calorieAdjustment(String goal) => switch (goal) {
    'Definición' => -400,
    'Volumen'    => 300,
    _            => 0,
  };

  double _proteinPerKg(String goal) => switch (goal) {
    'Definición' => 2.2,
    'Volumen'    => 1.8,
    _            => 1.6,
  };

  double _fatPercentage(String goal) => switch (goal) {
    'Definición' => 0.25,
    'Volumen'    => 0.28,
    _            => 0.30,
  };

  // ── Guardar ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final weight = double.tryParse(_weight.text) ?? 70;
    final height = double.tryParse(_height.text) ?? 170;
    final age    = int.tryParse(_age.text)        ?? 25;

    await context.read<NutritionProvider>().saveProfile(UserProfile(
      name: _name.text.trim(),
      age: age, weight: weight, height: height,
      gender: _gender, goal: _goal, activity: _activity,
    ));

    final tdee               = _bmr(weight, height, age, _gender) * _activityFactor(_activity);
    final recommendedCalories = tdee + _calorieAdjustment(_goal);
    final protein            = weight * _proteinPerKg(_goal);
    final fat                = recommendedCalories * _fatPercentage(_goal) / 9;
    final carbs              = (recommendedCalories - (protein * 4) - (fat * 9)) / 4;

    await context.read<NutritionProvider>().saveGoals(UserGoals(
      calories: recommendedCalories,
      protein:  protein,
      carbs:    carbs.clamp(0, 999),
      fat:      fat,
      water:    weight * 0.035,
      steps:    8000,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Perfil y objetivos actualizados ✓\nCalorías: ${recommendedCalories.toStringAsFixed(0)} kcal'),
        backgroundColor: const Color(0xFF00D4AA),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  // ── IMC ───────────────────────────────────────────────────────────────────

  double? get _imc {
    final w = double.tryParse(_weight.text);
    final h = double.tryParse(_height.text);
    if (w == null || h == null || h <= 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA))),
      );
    }

    final imc = _imc;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text('Mi perfil',
                  style: TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text('Tus datos personales para cálculos precisos',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
              const SizedBox(height: 28),

              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00D4AA), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF00D4AA), size: 40),
                    ),
                    const SizedBox(height: 12),
                    if (_name.text.isNotEmpty)
                      Text(_name.text,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // IMC
              if (imc != null) ...[
                ImcCard(imc: imc),
                const SizedBox(height: 20),
              ],

              // Información personal
              const SectionLabel('Información personal'),
              const SizedBox(height: 12),
              ProfileField(controller: _name, label: 'Nombre', icon: Icons.person_outline),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ProfileField(
                      controller: _age,
                      label: 'Edad',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      suffix: 'años',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GenderSelector(
                      value: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Medidas
              const SectionLabel('Medidas'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProfileField(
                      controller: _weight,
                      label: 'Peso',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      suffix: 'kg',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ProfileField(
                      controller: _height,
                      label: 'Altura',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      suffix: 'cm',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Actividad
              const SectionLabel('Nivel de actividad'),
              const SizedBox(height: 12),
              ActivitySelector(
                value: _activity,
                onChanged: (v) => setState(() => _activity = v),
              ),
              const SizedBox(height: 20),

              // Objetivo
              const SectionLabel('Objetivo'),
              const SizedBox(height: 12),
              GoalSelector(
                value: _goal,
                onChanged: (v) => setState(() => _goal = v),
              ),
              const SizedBox(height: 32),

              // Guardar
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Guardar perfil',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
