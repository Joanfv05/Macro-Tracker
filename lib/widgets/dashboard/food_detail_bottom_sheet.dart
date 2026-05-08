import 'package:flutter/material.dart';
import '../../models/models.dart';

class FoodDetailBottomSheet extends StatefulWidget {
  final FoodEntry food;
  final Function(FoodEntry) onUpdate;
  final VoidCallback onDelete;

  const FoodDetailBottomSheet({
    super.key,
    required this.food,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<FoodDetailBottomSheet> createState() => _FoodDetailBottomSheetState();
}

class _FoodDetailBottomSheetState extends State<FoodDetailBottomSheet> {
  late double _grams;
  late double _totalCalories;
  late double _totalProtein;
  late double _totalCarbs;
  late double _totalFat;
  late String _name;

  late double _per100gCalories;
  late double _per100gProtein;
  late double _per100gCarbs;
  late double _per100gFat;

  final _gramsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.food.name;
    _grams = widget.food.grams;
    _totalCalories = widget.food.calories;
    _totalProtein = widget.food.protein;
    _totalCarbs = widget.food.carbs;
    _totalFat = widget.food.fat;

    _per100gCalories = _grams > 0 ? (_totalCalories / _grams) * 100 : 0;
    _per100gProtein = _grams > 0 ? (_totalProtein / _grams) * 100 : 0;
    _per100gCarbs = _grams > 0 ? (_totalCarbs / _grams) * 100 : 0;
    _per100gFat = _grams > 0 ? (_totalFat / _grams) * 100 : 0;

    _nameController.text = _name;
    _gramsController.text = _grams.toStringAsFixed(0);
    _caloriesController.text = _per100gCalories.toStringAsFixed(0);
    _proteinController.text = _per100gProtein.toStringAsFixed(1);
    _carbsController.text = _per100gCarbs.toStringAsFixed(1);
    _fatController.text = _per100gFat.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _updateValues() {
    setState(() {
      _per100gCalories = double.tryParse(_caloriesController.text) ?? 0;
      _per100gProtein = double.tryParse(_proteinController.text) ?? 0;
      _per100gCarbs = double.tryParse(_carbsController.text) ?? 0;
      _per100gFat = double.tryParse(_fatController.text) ?? 0;

      _grams = double.tryParse(_gramsController.text) ?? 0;
      _name = _nameController.text.trim();

      _totalCalories = (_per100gCalories * _grams) / 100;
      _totalProtein = (_per100gProtein * _grams) / 100;
      _totalCarbs = (_per100gCarbs * _grams) / 100;
      _totalFat = (_per100gFat * _grams) / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Editar alimento',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFFF6B6B)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        title: const Text('Eliminar',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                            '¿Seguro que quieres eliminar este alimento?',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onDelete();
                              Navigator.pop(context);
                            },
                            child: const Text('Eliminar',
                                style: TextStyle(color: Color(0xFFFF6B6B))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Edita los valores por 100g y la cantidad',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ─── Nombre ───────────────────────────────────────────────────────
            _buildTextField(
                controller: _nameController,
                label: 'Nombre',
                keyboardType: TextInputType.text),
            const SizedBox(height: 16),

            // ─── Cantidad ─────────────────────────────────────────────────────
            _buildTextField(
              controller: _gramsController,
              label: 'Cantidad (g)',
              suffix: 'g',
            ),
            const SizedBox(height: 16),

            // ─── Valores por 100g ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valores por 100g',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  const SizedBox(height: 8),
                  _MacroEditRow(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFF00D4AA),
                    label: 'Calorías',
                    controller: _caloriesController,
                    unit: 'kcal',
                    onChanged: (_) => _updateValues(),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  _MacroEditRow(
                    icon: Icons.fitness_center,
                    iconColor: const Color(0xFF00D4AA),
                    label: 'Proteína',
                    controller: _proteinController,
                    unit: 'g',
                    onChanged: (_) => _updateValues(),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  _MacroEditRow(
                    icon: Icons.grain,
                    iconColor: const Color(0xFFFFB347),
                    label: 'Carbohidratos',
                    controller: _carbsController,
                    unit: 'g',
                    onChanged: (_) => _updateValues(),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  _MacroEditRow(
                    icon: Icons.opacity,
                    iconColor: const Color(0xFFFF6B6B),
                    label: 'Grasas',
                    controller: _fatController,
                    unit: 'g',
                    onChanged: (_) => _updateValues(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Preview totales ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroPreview(
                    label: 'kcal',
                    value: _totalCalories.toStringAsFixed(0),
                    color: const Color(0xFF00D4AA),
                  ),
                  _MacroPreview(
                    label: 'Prot',
                    value: '${_totalProtein.toStringAsFixed(1)}g',
                    color: const Color(0xFF00D4AA),
                  ),
                  _MacroPreview(
                    label: 'Carbs',
                    value: '${_totalCarbs.toStringAsFixed(1)}g',
                    color: const Color(0xFFFFB347),
                  ),
                  _MacroPreview(
                    label: 'Grasas',
                    value: '${_totalFat.toStringAsFixed(1)}g',
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedFood = FoodEntry(
                        id: widget.food.id,
                        name: _name,
                        calories: _totalCalories,
                        protein: _totalProtein,
                        carbs: _totalCarbs,
                        fat: _totalFat,
                        grams: _grams,
                        date: widget.food.date,
                        meal: widget.food.meal,
                      );
                      await widget.onUpdate(updatedFood);
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4AA),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar cambios',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.5)),
        suffixText: suffix,
        suffixStyle:
            TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => _updateValues(),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _MacroEditRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextEditingController controller;
  final String unit;
  final Function(String) onChanged;

  const _MacroEditRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.controller,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12),
              suffixText: unit,
              suffixStyle:
                  TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _MacroPreview extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroPreview(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }
}
