import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard/animated_macro_ring.dart';
import '../widgets/dashboard/macro_bar.dart';
import '../widgets/dashboard/meal_section.dart';
import '../widgets/dashboard/food_detail_bottom_sheet.dart';
import '../widgets/dashboard/quick_edit_dialog.dart';
import '../widgets/dashboard/date_nav_button.dart';
import '../models/models.dart';
import 'add_food_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, _) {
        final Map<String, List<FoodEntry>> groupedFoods = {
          for (final meal in kMeals)
            meal: provider.foods.where((f) => f.meal == meal).toList(),
        };

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ─── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DateHeader(provider: provider),
                        _DateNavRow(provider: provider),
                      ],
                    ),
                  ),
                ),

                // ─── Calorie ring ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 20),
                    child: AnimatedMacroRing(
                      calories: provider.dayLog.calories,
                      goalCalories: provider.goals.calories,
                      protein: provider.dayLog.protein,
                      carbs: provider.dayLog.carbs,
                      fat: provider.dayLog.fat,
                    ),
                  ),
                ),

                // ─── Macro bars ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: MacroBar(
                            label: 'Proteína',
                            value: provider.dayLog.protein,
                            goal: provider.goals.protein,
                            unit: 'g',
                            color: const Color(0xFF00D4AA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroBar(
                            label: 'Carbs',
                            value: provider.dayLog.carbs,
                            goal: provider.goals.carbs,
                            unit: 'g',
                            color: const Color(0xFFFFB347),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroBar(
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

                // ─── Water & Steps ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.water_drop,
                            label: 'Agua',
                            value:
                                '${provider.dayLog.water.toStringAsFixed(1)}L',
                            goal:
                                '${provider.goals.water.toStringAsFixed(1)}L',
                            progress: provider.waterProgress,
                            color: const Color(0xFF4FC3F7),
                            onTap: () =>
                                _showWaterDialog(context, provider),
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
                            onTap: () =>
                                _showStepsDialog(context, provider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ─── Meals header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
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
                          icon: const Icon(Icons.add,
                              color: Color(0xFF00D4AA), size: 18),
                          label: const Text('Añadir',
                              style:
                                  TextStyle(color: Color(0xFF00D4AA))),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Food list ────────────────────────────────────────────────
                if (provider.foods.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_outlined,
                                size: 48,
                                color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'Nada registrado aún',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MealSection(
                        meal: kMeals[index],
                        foods: groupedFoods[kMeals[index]] ?? [],
                        onFoodTap: (food) =>
                            _showFoodDetailDialog(context, provider, food),
                        onDelete: (food) => provider.deleteFood(food),
                      ),
                      childCount: kMeals.length,
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
            label: const Text('Añadir comida',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void _openAddFood(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddFoodScreen()));
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return steps.toString();
  }

  void _showWaterDialog(BuildContext context, NutritionProvider provider) {
    showDialog(
      context: context,
      builder: (_) => QuickEditDialog(
        title: 'Agua (litros)',
        initialValue: provider.dayLog.water,
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
      builder: (_) => QuickEditDialog(
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

  void _showFoodDetailDialog(
      BuildContext context, NutritionProvider provider, FoodEntry food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => FoodDetailBottomSheet(
        food: food,
        onUpdate: (updated) async {
          await provider.deleteFood(food);
          await provider.addFood(updated);
        },
        onDelete: () async => provider.deleteFood(food),
      ),
    );
  }
}

// ─── Sub-widgets local al dashboard ──────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final NutritionProvider provider;
  const _DateHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          DateFormat('d MMMM yyyy', 'es_ES').format(
              DateFormat('yyyy-MM-dd').parse(provider.selectedDate)),
          style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 13),
        ),
      ],
    );
  }
}

class _DateNavRow extends StatelessWidget {
  final NutritionProvider provider;
  const _DateNavRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Row(
      children: [
        DateNavButton(
          icon: Icons.chevron_left,
          onTap: () {
            final date =
                DateFormat('yyyy-MM-dd').parse(provider.selectedDate);
            provider.goToDate(date.subtract(const Duration(days: 1)));
          },
        ),
        const SizedBox(width: 8),
        DateNavButton(
          icon: Icons.chevron_right,
          onTap: provider.selectedDate == today
              ? null
              : () {
                  final date =
                      DateFormat('yyyy-MM-dd').parse(provider.selectedDate);
                  provider.goToDate(date.add(const Duration(days: 1)));
                },
        ),
      ],
    );
  }
}
