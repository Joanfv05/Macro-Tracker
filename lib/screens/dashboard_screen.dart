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
        final Map<String, List<FoodEntry>> groupedFoods = {};
        for (final meal in _meals) {
          groupedFoods[meal] = provider.foods.where((f) => f.meal == meal).toList();
        }

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
                    child: AnimatedMacroRing(
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
                          (context, index) {
                        return _MealSection(
                          meal: _meals[index],
                          foods: groupedFoods[_meals[index]] ?? [],
                          onFoodTap: (food) => _showFoodDetailDialog(context, provider, food),
                          onDelete: (food) => provider.deleteFood(food),
                        );
                      },
                      childCount: _meals.length,
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

  void _showFoodDetailDialog(BuildContext context, NutritionProvider provider, FoodEntry food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FoodDetailBottomSheet(
        food: food,
        onUpdate: (updatedFood) async {
          await provider.deleteFood(food);
          await provider.addFood(updatedFood);
        },
        onDelete: () async {
          await provider.deleteFood(food);
        },
      ),
    );
  }
}

const _meals = ['Desayuno', 'Almuerzo', 'Comida', 'Merienda', 'Cena', 'Snack'];

// ─── Animated Macro Ring Widget ─────────────────────────────────────────────

class AnimatedMacroRing extends StatefulWidget {
  final double calories;
  final double goalCalories;
  final double protein;
  final double carbs;
  final double fat;

  const AnimatedMacroRing({
    super.key,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  State<AnimatedMacroRing> createState() => _AnimatedMacroRingState();
}

class _AnimatedMacroRingState extends State<AnimatedMacroRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousCalories = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _previousCalories = widget.calories;
  }

  @override
  void didUpdateWidget(AnimatedMacroRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calories != widget.calories) {
      _previousCalories = oldWidget.calories;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCalorieColor() {
    final progress = widget.goalCalories > 0 ? widget.calories / widget.goalCalories : 0;
    if (progress >= 1.0) return const Color(0xFFFF4444);
    if (progress >= 0.8) return const Color(0xFFFFB347);
    return const Color(0xFF00D4AA);
  }

  String _getStatusText() {
    final remaining = (widget.goalCalories - widget.calories).clamp(0, widget.goalCalories);
    final over = widget.calories > widget.goalCalories;
    if (over) {
      return '+${(widget.calories - widget.goalCalories).toStringAsFixed(0)} exceso';
    }
    return '${remaining.toStringAsFixed(0)} restantes';
  }

  Color _getStatusColor() {
    final progress = widget.goalCalories > 0 ? widget.calories / widget.goalCalories : 0;
    if (progress >= 1.0) return const Color(0xFFFF4444);
    if (progress >= 0.9) return const Color(0xFFFFB347);
    return const Color(0xFF00D4AA);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goalCalories > 0
        ? (widget.calories / widget.goalCalories).clamp(0.0, 1.0)
        : 0.0;
    final over = widget.calories > widget.goalCalories;
    final ringColor = _getCalorieColor();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedProgress = _controller.isAnimating
            ? (_previousCalories / widget.goalCalories).clamp(0.0, 1.0) +
            (_animation.value * (progress - (_previousCalories / widget.goalCalories).clamp(0.0, 1.0)))
            : progress;

        final animatedCalories = _controller.isAnimating
            ? _previousCalories + (_animation.value * (widget.calories - _previousCalories))
            : widget.calories;

        return Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _RingPainter(
                  progress: animatedProgress,
                  color: ringColor,
                  over: over,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: _previousCalories, end: widget.calories),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: ringColor,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    const Text(
                      'kcal',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends StatelessWidget {
  final double progress;
  final Color color;
  final bool over;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.over,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _RingPainterCustom(progress: progress, color: color, over: over),
    );
  }
}

class _RingPainterCustom extends CustomPainter {
  final double progress;
  final Color color;
  final bool over;

  _RingPainterCustom({required this.progress, required this.color, required this.over});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainterCustom old) {
    return old.progress != progress || old.color != color;
  }
}

// ─── Meal Section Widget ─────────────────────────────────────────────────────

class _MealSection extends StatelessWidget {
  final String meal;
  final List<FoodEntry> foods;
  final Function(FoodEntry) onFoodTap;
  final Function(FoodEntry) onDelete;

  const _MealSection({
    required this.meal,
    required this.foods,
    required this.onFoodTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _getMealIcon(meal),
              const SizedBox(width: 8),
              Text(
                meal,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${foods.length}',
                  style: const TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...foods.map((food) => _FoodTile(
          food: food,
          onTap: () => onFoodTap(food),
          onDelete: () => onDelete(food),
        )),
      ],
    );
  }

  Widget _getMealIcon(String meal) {
    IconData icon;
    Color color;
    switch (meal) {
      case 'Desayuno':
        icon = Icons.bedtime;
        color = const Color(0xFFFFB347);
        break;
      case 'Almuerzo':
        icon = Icons.lunch_dining;
        color = const Color(0xFF00D4AA);
        break;
      case 'Comida':
        icon = Icons.dinner_dining;
        color = const Color(0xFF4FC3F7);
        break;
      case 'Merienda':
        icon = Icons.cake;
        color = const Color(0xFFA78BFA);
        break;
      case 'Cena':
        icon = Icons.nightlife;
        color = const Color(0xFFFF6B6B);
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.white54;
    }
    return Icon(icon, color: color, size: 16);
  }
}

// ─── Food Tile Widget ────────────────────────────────────────────────────────

class _FoodTile extends StatelessWidget {
  final FoodEntry food;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FoodTile({
    required this.food,
    required this.onTap,
    required this.onDelete,
  });

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
      child: GestureDetector(
        onTap: onTap,
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
                      '${food.grams.toStringAsFixed(0)}g  •  ${food.calories.toStringAsFixed(0)} kcal',
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
                    'P:${food.protein.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Color(0xFF00D4AA), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'C:${food.carbs.toStringAsFixed(0)} G:${food.fat.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Food Detail Bottom Sheet CORREGIDA ─────────────────────────────────────

class _FoodDetailBottomSheet extends StatefulWidget {
  final FoodEntry food;
  final Function(FoodEntry) onUpdate;
  final VoidCallback onDelete;

  const _FoodDetailBottomSheet({
    required this.food,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_FoodDetailBottomSheet> createState() => _FoodDetailBottomSheetState();
}

class _FoodDetailBottomSheetState extends State<_FoodDetailBottomSheet> {
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
                Expanded(
                  child: Text(
                    'Editar alimento',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        title: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                        content: const Text('¿Seguro que quieres eliminar este alimento?',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onDelete();
                              Navigator.pop(context);
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFFF6B6B))),
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
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF252525),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _updateValues(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Cantidad (g)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                suffixText: 'g',
                suffixStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF252525),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _updateValues(),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valores por 100g',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
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

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Totales para ${_grams.toStringAsFixed(0)}g',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroPreview(
                        label: 'Kcal',
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
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4AA),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.w600)),
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
}

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
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              suffixText: unit,
              suffixStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
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