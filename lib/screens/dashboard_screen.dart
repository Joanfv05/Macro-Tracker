import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';
import '../widgets/macro_ring.dart';
import '../widgets/stat_card.dart';
import 'add_food_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              DateFormat('d MMMM yyyy', 'es_ES')
                                  .format(DateFormat('yyyy-MM-dd').parse(provider.selectedDate)),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _DateNavButton(
                              icon: Icons.chevron_left,
                              onTap: () {
                                final date = DateFormat('yyyy-MM-dd').parse(provider.selectedDate);
                                provider.goToDate(date.subtract(const Duration(days: 1)));
                              },
                            ),
                            const SizedBox(width: 8),
                            _DateNavButton(
                              icon: Icons.chevron_right,
                              onTap: provider.selectedDate ==
                                  DateFormat('yyyy-MM-dd').format(DateTime.now())
                                  ? null
                                  : () {
                                final date = DateFormat('yyyy-MM-dd').parse(provider.selectedDate);
                                provider.goToDate(date.add(const Duration(days: 1)));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    child: MacroRing(
                      calories: provider.dayLog.calories,
                      goalCalories: provider.goals.calories,
                      protein: provider.dayLog.protein,
                      carbs: provider.dayLog.carbs,
                      fat: provider.dayLog.fat,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MacroBar(
                            label: 'Proteína',
                            value: provider.dayLog.protein,
                            goal: provider.goals.protein,
                            unit: 'g',
                            color: const Color(0xFF00D4AA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroBar(
                            label: 'Carbs',
                            value: provider.dayLog.carbs,
                            goal: provider.goals.carbs,
                            unit: 'g',
                            color: const Color(0xFFFFB347),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroBar(
                            label: 'Grasas',
                            value: provider.dayLog.fat,
                            goal: provider.goals.fat,
                            unit: 'g',
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.water_drop,
                            label: 'Agua',
                            value: '${provider.dayLog.water.toStringAsFixed(1)}L',
                            goal: '${provider.goals.water.toStringAsFixed(1)}L',
                            progress: provider.waterProgress,
                            color: const Color(0xFF4FC3F7),
                            onTap: () => _showWaterDialog(context, provider),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.directions_walk,
                            label: 'Pasos',
                            value: _formatSteps(provider.dayLog.steps),
                            goal: _formatSteps(provider.goals.steps),
                            progress: provider.stepsProgress,
                            color: const Color(0xFFA78BFA),
                            onTap: () => _showStepsDialog(context, provider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Comidas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openAddFood(context),
                          icon: const Icon(Icons.add, color: Color(0xFF00D4AA), size: 18),
                          label: const Text(
                            'Añadir',
                            style: TextStyle(color: Color(0xFF00D4AA)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (provider.foods.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_outlined,
                                size: 48, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'Nada registrado aún',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final food = provider.foods[i];
                        return _FoodTile(
                          food: food,
                          onDelete: () => provider.deleteFood(food),
                        );
                      },
                      childCount: provider.foods.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddFood(context),
            backgroundColor: const Color(0xFF00D4AA),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add),
            label: const Text('Añadir comida', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  void _openAddFood(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return steps.toString();
  }

  void _showWaterDialog(BuildContext context, NutritionProvider provider) {
    double current = provider.dayLog.water;
    showDialog(
      context: context,
      builder: (ctx) => _QuickEditDialog(
        title: 'Agua (litros)',
        initialValue: current,
        unit: 'L',
        min: 0,
        max: 10,
        step: 0.25,
        onSave: (v) => provider.updateWater(v),
      ),
    );
  }

  void _showStepsDialog(BuildContext context, NutritionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => _QuickEditDialog(
        title: 'Pasos',
        initialValue: provider.dayLog.steps.toDouble(),
        unit: ' pasos',
        min: 0,
        max: 50000,
        step: 100,
        onSave: (v) => provider.updateSteps(v.toInt()),
      ),
    );
  }
}

class _DateNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _DateNavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.white.withOpacity(0.2) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}$unit',
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            'de ${goal.toStringAsFixed(0)}$unit',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final FoodEntry food;
  final VoidCallback onDelete;

  const _FoodTile({required this.food, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('food_${food.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant, color: Color(0xFF00D4AA), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${food.grams.toStringAsFixed(0)}g  •  ${food.meal}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  'P:${food.protein.toStringAsFixed(0)} C:${food.carbs.toStringAsFixed(0)} G:${food.fat.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickEditDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final String unit;
  final double min;
  final double max;
  final double step;
  final Function(double) onSave;

  const _QuickEditDialog({
    required this.title,
    required this.initialValue,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.onSave,
  });

  @override
  State<_QuickEditDialog> createState() => _QuickEditDialogState();
}

class _QuickEditDialogState extends State<_QuickEditDialog> {
  late double _value;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller.text = _value % 1 == 0 ? _value.toStringAsFixed(0) : _value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(double newValue) {
    setState(() {
      _value = newValue.clamp(widget.min, widget.max);
      if (widget.title == 'Pasos') {
        _controller.text = _value.toInt().toString();
      } else {
        _controller.text = _value.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSteps = widget.title == 'Pasos';
    final isWater = widget.title == 'Agua (litros)';

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Color(0xFF00D4AA),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: widget.unit,
              suffixStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF252525),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                _value = val.clamp(widget.min, widget.max);
              }
            },
          ),
          const SizedBox(height: 16),

          if (isSteps) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickButton(label: '+100', onTap: () => _updateValue(_value + 100)),
                _QuickButton(label: '+500', onTap: () => _updateValue(_value + 500)),
                _QuickButton(label: '+1000', onTap: () => _updateValue(_value + 1000)),
                _QuickButton(label: '+5000', onTap: () => _updateValue(_value + 5000)),
                _QuickButton(label: '-100', onTap: () => _updateValue(_value - 100)),
                _QuickButton(label: '-500', onTap: () => _updateValue(_value - 500)),
                _QuickButton(label: 'Limpiar', onTap: () => _updateValue(0), isClear: true),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (isWater) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickButton(label: '+0.25L', onTap: () => _updateValue(_value + 0.25)),
                _QuickButton(label: '+0.5L', onTap: () => _updateValue(_value + 0.5)),
                _QuickButton(label: '+1L', onTap: () => _updateValue(_value + 1)),
                _QuickButton(label: '-0.25L', onTap: () => _updateValue(_value - 0.25)),
                _QuickButton(label: '-0.5L', onTap: () => _updateValue(_value - 0.5)),
                _QuickButton(label: 'Limpiar', onTap: () => _updateValue(0), isClear: true),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > widget.min
                    ? () => _updateValue(_value - widget.step)
                    : null,
                icon: const Icon(Icons.remove_circle, color: Color(0xFF00D4AA), size: 40),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _value < widget.max
                    ? () => _updateValue(_value + widget.step)
                    : null,
                icon: const Icon(Icons.add_circle, color: Color(0xFF00D4AA), size: 40),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_value);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D4AA),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isClear;

  const _QuickButton({
    required this.label,
    required this.onTap,
    this.isClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isClear
              ? const Color(0xFFFF6B6B).withOpacity(0.2)
              : const Color(0xFF00D4AA).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isClear ? const Color(0xFFFF6B6B) : const Color(0xFF00D4AA),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}