import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, _) {
        final history = provider.weekHistory;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: const Text(
                      'Historial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                if (history.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Sin datos aún.\nEmpieza a registrar comidas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3), height: 1.5),
                      ),
                    ),
                  )
                else ...[
                  // ─── Calorías chart ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartCard(
                      title: 'Calorías',
                      color: const Color(0xFF00D4AA),
                      history: history,
                      getValue: (d) => d.calories,
                      goal: provider.goals.calories,
                      unit: 'kcal',
                    ),
                  ),

                  // ─── Proteína chart ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartCard(
                      title: 'Proteína',
                      color: const Color(0xFF00D4AA),
                      history: history,
                      getValue: (d) => d.protein,
                      goal: provider.goals.protein,
                      unit: 'g',
                    ),
                  ),

                  // ─── Carbs chart ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartCard(
                      title: 'Carbohidratos',
                      color: const Color(0xFFFFB347),
                      history: history,
                      getValue: (d) => d.carbs,
                      goal: provider.goals.carbs,
                      unit: 'g',
                    ),
                  ),

                  // ─── Grasas chart ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartCard(
                      title: 'Grasas',
                      color: const Color(0xFFFF6B6B),
                      history: history,
                      getValue: (d) => d.fat,
                      goal: provider.goals.fat,
                      unit: 'g',
                    ),
                  ),

                  // ─── Agua chart ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ChartCard(
                      title: 'Agua',
                      color: const Color(0xFF4FC3F7),
                      history: history,
                      getValue: (d) => d.water,
                      goal: provider.goals.water,
                      unit: 'L',
                      decimals: 1,
                    ),
                  ),

                  // ─── Promedio resumen ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: _AverageSummary(history: history, goals: provider.goals),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<DayLog> history;
  final double Function(DayLog) getValue;
  final double goal;
  final String unit;
  final int decimals;

  const _ChartCard({
    required this.title,
    required this.color,
    required this.history,
    required this.getValue,
    required this.goal,
    required this.unit,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final values = history.map(getValue).toList();
    final maxVal = values.fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = (maxVal > goal ? maxVal : goal) * 1.2;
    if (chartMax <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              Text(
                'Objetivo: ${goal % 1 == 0 ? goal.toStringAsFixed(0) : goal.toStringAsFixed(1)} $unit',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF252525),
                    getTooltipItem: (group, _, rod, __) {
                      final d = history[group.x];
                      final v = getValue(d);
                      return BarTooltipItem(
                        '${decimals == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} $unit',
                        TextStyle(color: color, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal,
                      color: color.withOpacity(0.4),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (x, _) {
                        if (x.toInt() >= history.length) return const SizedBox.shrink();
                        final d = history[x.toInt()];
                        final date = DateFormat('yyyy-MM-dd').parse(d.date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(history.length, (i) {
                  final v = getValue(history[i]);
                  final ok = v >= goal * 0.8;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v.clamp(0, chartMax),
                        color: ok ? color : color.withOpacity(0.4),
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageSummary extends StatelessWidget {
  final List<DayLog> history;
  final UserGoals goals;

  const _AverageSummary({required this.history, required this.goals});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    double avgCal = 0, avgProt = 0, avgCarb = 0, avgFat = 0;
    int count = 0;
    for (final d in history) {
      if (d.calories > 0) {
        avgCal += d.calories;
        avgProt += d.protein;
        avgCarb += d.carbs;
        avgFat += d.fat;
        count++;
      }
    }
    if (count == 0) return const SizedBox.shrink();
    avgCal /= count;
    avgProt /= count;
    avgCarb /= count;
    avgFat /= count;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Promedio últimos días',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _AvgRow('Calorías', avgCal, goals.calories, 'kcal', const Color(0xFF00D4AA)),
          _AvgRow('Proteína', avgProt, goals.protein, 'g', const Color(0xFF00D4AA)),
          _AvgRow('Carbs', avgCarb, goals.carbs, 'g', const Color(0xFFFFB347)),
          _AvgRow('Grasas', avgFat, goals.fat, 'g', const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }
}

class _AvgRow extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _AvgRow(this.label, this.value, this.goal, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (value / goal * 100).round() : 0;
    final ok = pct >= 80 && pct <= 115;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child: Text(label,
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))),
          Text(
            '${value.toStringAsFixed(0)} $unit',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ok
                  ? const Color(0xFF00D4AA).withOpacity(0.15)
                  : const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                color: ok ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
