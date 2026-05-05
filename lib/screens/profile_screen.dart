import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  String _gender = 'Hombre';
  String _goal = 'Definición';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(Duration.zero);
    final profile = context.read<NutritionProvider>().profile;
    setState(() {
      _name.text = profile.name;
      _age.text = profile.age.toString();
      _weight.text = profile.weight.toString();
      _height.text = profile.height.toString();
      _gender = profile.gender;
      _goal = profile.goal;
      _loaded = true;
    });
  }

  // Calcular calorías recomendadas según perfil
  double _calculateRecommendedCalories(double weight, double height, int age, String gender, String goal) {
    // Calcular BMR (Harris-Benedict)
    double bmr;
    if (gender == 'Mujer') {
      bmr = 655.1 + (9.563 * weight) + (1.85 * height) - (4.676 * age);
    } else {
      bmr = 66.47 + (13.75 * weight) + (5.003 * height) - (6.755 * age);
    }

    // Factor de actividad (asumimos moderado = 1.55)
    final tdee = bmr * 1.55;

    // Ajuste según objetivo
    switch (goal) {
      case 'Definición': return tdee - 400;
      case 'Volumen': return tdee + 300;
      default: return tdee;
    }
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weight.text) ?? 70;
    final height = double.tryParse(_height.text) ?? 170;
    final age = int.tryParse(_age.text) ?? 25;

    final profile = UserProfile(
      name: _name.text.trim(),
      age: age,
      weight: weight,
      height: height,
      gender: _gender,
      goal: _goal,
    );

    await context.read<NutritionProvider>().saveProfile(profile);

    // Recalcular objetivos según el nuevo perfil
    final recommendedCalories = _calculateRecommendedCalories(weight, height, age, _gender, _goal);
    final recommendedProtein = weight * 2.2; // 2.2g por kg de peso
    final recommendedFat = recommendedCalories * 0.25 / 9; // 25% de grasas
    final recommendedCarbs = (recommendedCalories - (recommendedProtein * 4) - (recommendedFat * 9)) / 4;

    final goals = UserGoals(
      calories: recommendedCalories,
      protein: recommendedProtein,
      carbs: recommendedCarbs.clamp(0, 999),
      fat: recommendedFat,
      water: 2.5,
      steps: 8000,
    );

    await context.read<NutritionProvider>().saveGoals(goals);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil y objetivos actualizados ✓'),
          backgroundColor: Color(0xFF00D4AA),
        ),
      );
    }
  }

  double? get _imc {
    final w = double.tryParse(_weight.text);
    final h = double.tryParse(_height.text);
    if (w == null || h == null || h <= 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  String _imcLabel(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _imcColor(double imc) {
    if (imc < 18.5) return const Color(0xFF4FC3F7);
    if (imc < 25) return const Color(0xFF00D4AA);
    if (imc < 30) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

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
              const Text(
                'Mi perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tus datos personales',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),

              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00D4AA), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF00D4AA), size: 40),
                    ),
                    const SizedBox(height: 12),
                    if (_name.text.isNotEmpty)
                      Text(
                        _name.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (imc != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _imcColor(imc).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _imcColor(imc).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            imc.toStringAsFixed(1),
                            style: TextStyle(
                              color: _imcColor(imc),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('IMC',
                              style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(
                            _imcLabel(imc),
                            style: TextStyle(
                              color: _imcColor(imc),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _SectionLabel('Información personal'),
              const SizedBox(height: 12),

              _ProfileField(
                controller: _name,
                label: 'Nombre',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
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
                    child: _GenderSelector(
                      value: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionLabel('Medidas'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
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
                    child: _ProfileField(
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
              _SectionLabel('Objetivo'),
              const SizedBox(height: 12),

              _GoalSelector(
                value: _goal,
                onChanged: (v) => setState(() => _goal = v),
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
                  'Guardar perfil',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffix;
  final Function(String)? onChanged;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        suffixText: suffix,
        suffixStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00D4AA), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const _GenderSelector({required this.value, required this.onChanged});

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
          items: ['Hombre', 'Mujer'].map((g) => DropdownMenuItem(
            value: g,
            child: Text(g),
          )).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const _GoalSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('Definición', Icons.trending_down, 'Perder grasa manteniendo músculo'),
      ('Mantenimiento', Icons.trending_flat, 'Mantener peso y composición'),
      ('Volumen', Icons.trending_up, 'Ganar masa muscular'),
    ];

    return Column(
      children: goals.map((g) {
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
                color: selected
                    ? const Color(0xFF00D4AA)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(g.$2,
                    color: selected
                        ? const Color(0xFF00D4AA)
                        : Colors.white38,
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
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 11)),
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