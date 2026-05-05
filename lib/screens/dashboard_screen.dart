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
                // ─── Header ────────────────────────────────────────────────
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

                // ─── Calorie Ring ───────────────────────────────────────────
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

                // ─── Macros Row ─────────────────────────────────────────────
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

                // ─── Agua y Pasos ───────────────────────────────────────────
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

                // ─── Comidas del día ────────────────────────────────────────
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
        step: 500,
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

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_value % 1 == 0 ? _value.toStringAsFixed(0) : _value.toStringAsFixed(2)}${widget.unit}',
            style: const TextStyle(
                color: Color(0xFF00D4AA), fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > widget.min
                    ? () => setState(() => _value = (_value - widget.step).clamp(widget.min, widget.max))
                    : null,
                icon: const Icon(Icons.remove_circle, color: Color(0xFF00D4AA), size: 36),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _value < widget.max
                    ? () => setState(() => _value = (_value + widget.step).clamp(widget.min, widget.max))
                    : null,
                icon: const Icon(Icons.add_circle, color: Color(0xFF00D4AA), size: 36),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Colors.white.withOpacity(0.4))),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_value);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D4AA),
            foregroundColor: Colors.black,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
