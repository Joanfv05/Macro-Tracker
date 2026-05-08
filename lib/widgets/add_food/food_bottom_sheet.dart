import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/food_api_service.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';

class FoodBottomSheet extends StatefulWidget {
  final FoodSearchResult result;
  final String meal;
  final bool editable;
  final ValueChanged<FoodEntry> onConfirm;

  const FoodBottomSheet({
    super.key,
    required this.result,
    required this.meal,
    required this.onConfirm,
    this.editable = false,
  });

  @override
  State<FoodBottomSheet> createState() => _FoodBottomSheetState();
}

class _FoodBottomSheetState extends State<FoodBottomSheet> {
  double _grams = 100;
  late double _calPer100, _protPer100, _carbPer100, _fatPer100;

  late final TextEditingController _gramsCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _protCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;

  @override
  void initState() {
    super.initState();
    _calPer100  = widget.result.calories;
    _protPer100 = widget.result.protein;
    _carbPer100 = widget.result.carbs;
    _fatPer100  = widget.result.fat;

    _gramsCtrl = TextEditingController(text: '100');
    _calCtrl   = TextEditingController(text: _calPer100.toStringAsFixed(0));
    _protCtrl  = TextEditingController(text: _protPer100.toStringAsFixed(1));
    _carbCtrl  = TextEditingController(text: _carbPer100.toStringAsFixed(1));
    _fatCtrl   = TextEditingController(text: _fatPer100.toStringAsFixed(1));
  }

  @override
  void dispose() {
    for (final c in [_gramsCtrl, _calCtrl, _protCtrl, _carbCtrl, _fatCtrl]) c.dispose();
    super.dispose();
  }

  double get _f => _grams / 100;

  void _parseMacros() => setState(() {
        _calPer100  = double.tryParse(_calCtrl.text)  ?? 0;
        _protPer100 = double.tryParse(_protCtrl.text) ?? 0;
        _carbPer100 = double.tryParse(_carbCtrl.text) ?? 0;
        _fatPer100  = double.tryParse(_fatCtrl.text)  ?? 0;
      });

  void _confirm() {
    widget.onConfirm(FoodEntry(
      name:     widget.result.name,
      calories: _calPer100  * _f,
      protein:  _protPer100 * _f,
      carbs:    _carbPer100 * _f,
      fat:      _fatPer100  * _f,
      grams:    _grams,
      date:     DateFormat('yyyy-MM-dd').format(DateTime.now()),
      meal:     widget.meal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(result: widget.result, meal: widget.meal, editable: widget.editable),
            const SizedBox(height: 20),
            _GramsInput(
              controller: _gramsCtrl,
              onChanged: (v) => setState(() => _grams = double.tryParse(v) ?? 100),
            ),
            const SizedBox(height: 16),
            if (widget.editable) ...[
              _EditableMacrosCard(
                calCtrl: _calCtrl, protCtrl: _protCtrl,
                carbCtrl: _carbCtrl, fatCtrl: _fatCtrl,
                onChanged: _parseMacros,
              ),
              const SizedBox(height: 16),
            ],
            MacroSummaryCard(
              calories: _calPer100 * _f,
              protein:  _protPer100 * _f,
              carbs:    _carbPer100 * _f,
              fat:      _fatPer100  * _f,
              showTotalLabel: widget.editable,
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Añadir', onPressed: _confirm),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Subwidgets internos del sheet ─────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final FoodSearchResult result;
  final String meal;
  final bool editable;

  const _SheetHeader({required this.result, required this.meal, required this.editable});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 2),
        const SizedBox(height: 4),
        Text(
          editable
              ? '$meal  •  Ajusta los valores si es necesario'
              : '$meal  •  por 100g: ${result.calories.toStringAsFixed(0)} kcal',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ],
    );
  }
}

class _GramsInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GramsInput({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: 'Cantidad (g)',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: AppColors.cardAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _EditableMacrosCard extends StatelessWidget {
  final TextEditingController calCtrl, protCtrl, carbCtrl, fatCtrl;
  final VoidCallback onChanged;

  const _EditableMacrosCard({
    required this.calCtrl, required this.protCtrl,
    required this.carbCtrl, required this.fatCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardAlt, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _MacroRow(icon: Icons.local_fire_department, iconColor: AppColors.accent, label: 'Calorías (por 100g)',      controller: calCtrl,  textColor: AppColors.accent, onChanged: (_) => onChanged()),
          const Divider(color: Colors.white24, height: 20),
          _MacroRow(icon: Icons.fitness_center,        iconColor: AppColors.accent, label: 'Proteína (por 100g)',      controller: protCtrl, textColor: Colors.white,      onChanged: (_) => onChanged()),
          const Divider(color: Colors.white24, height: 20),
          _MacroRow(icon: Icons.grain,                 iconColor: AppColors.orange, label: 'Carbohidratos (por 100g)', controller: carbCtrl, textColor: Colors.white,      onChanged: (_) => onChanged()),
          const Divider(color: Colors.white24, height: 20),
          _MacroRow(icon: Icons.opacity,               iconColor: AppColors.red,    label: 'Grasas (por 100g)',        controller: fatCtrl,  textColor: Colors.white,      onChanged: (_) => onChanged()),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextEditingController controller;
  final Color textColor;
  final ValueChanged<String> onChanged;

  const _MacroRow({
    required this.icon, required this.iconColor, required this.label,
    required this.controller, required this.textColor, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── MacroSummaryCard (público, reutilizable en otros sitios) ──────────────────

class MacroSummaryCard extends StatelessWidget {
  final double calories, protein, carbs, fat;
  final bool showTotalLabel;

  const MacroSummaryCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.showTotalLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: showTotalLabel ? AppColors.card : AppColors.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: showTotalLabel
            ? Border.all(color: AppColors.accent.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroChip(label: showTotalLabel ? 'Total Kcal' : 'Kcal', value: calories.toStringAsFixed(0),        color: AppColors.accent),
          _MacroChip(label: 'Prot',  value: '${protein.toStringAsFixed(1)}g', color: AppColors.accent),
          _MacroChip(label: 'Carbs', value: '${carbs.toStringAsFixed(1)}g',   color: AppColors.orange),
          _MacroChip(label: 'Grasas',value: '${fat.toStringAsFixed(1)}g',     color: AppColors.red),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label, value;
  final Color color;

  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}
