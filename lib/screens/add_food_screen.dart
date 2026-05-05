import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';
import '../services/food_api_service.dart';
import 'barcode_scanner_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchController = TextEditingController();
  final _api = OpenFoodFactsService();

  List<FoodSearchResult> _results = [];
  bool _searching = false;
  String _selectedMeal = 'Desayuno';

  final _meals = ['Desayuno', 'Almuerzo', 'Comida', 'Merienda', 'Cena', 'Snack'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _searching = true);

    final results = await _api.search(query.trim());

    if (mounted) {
      setState(() {
        _results = results;
        _searching = false;
      });

      if (results.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron alimentos. Usa "Manual" o escanea el código de barras.'),
            backgroundColor: Color(0xFFFFB347),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<FoodSearchResult>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (result != null && mounted) {
      _showEditableGramsBottomSheet(result);
    }
  }

  void _showEditableGramsBottomSheet(FoodSearchResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditableGramsBottomSheet(
        result: result,
        meal: _selectedMeal,
        onConfirm: (grams, caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g) async {
          final factor = grams / 100;
          final entry = FoodEntry(
            name: result.name,
            calories: caloriesPer100g * factor,
            protein: proteinPer100g * factor,
            carbs: carbsPer100g * factor,
            fat: fatPer100g * factor,
            grams: grams,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            meal: _selectedMeal,
          );
          await context.read<NutritionProvider>().addFood(entry);
          if (mounted) {
            Navigator.pop(context); // bottom sheet
            Navigator.pop(context); // add food screen
          }
        },
      ),
    );
  }

  void _showGramsBottomSheet(FoodSearchResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GramsBottomSheet(
        result: result,
        meal: _selectedMeal,
        onConfirm: (grams) async {
          final factor = grams / 100;
          final entry = FoodEntry(
            name: result.name,
            calories: result.calories * factor,
            protein: result.protein * factor,
            carbs: result.carbs * factor,
            fat: result.fat * factor,
            grams: grams,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            meal: _selectedMeal,
          );
          await context.read<NutritionProvider>().addFood(entry);
          if (mounted) {
            Navigator.pop(context); // bottom sheet
            Navigator.pop(context); // add food screen
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('Añadir comida',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00D4AA)),
            onPressed: _openScanner,
            tooltip: 'Escanear código de barras',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(0xFF00D4AA),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00D4AA),
          tabs: const [
            Tab(text: 'Buscar alimento'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SearchTab(
            controller: _searchController,
            results: _results,
            searching: _searching,
            selectedMeal: _selectedMeal,
            meals: _meals,
            onMealChanged: (m) => setState(() => _selectedMeal = m),
            onSearch: _search,
            onSelectResult: (r) => _showGramsBottomSheet(r),
          ),
          _ManualTab(
            selectedMeal: _selectedMeal,
            meals: _meals,
            onMealChanged: (m) => setState(() => _selectedMeal = m),
            onSave: _saveManual,
          ),
        ],
      ),
    );
  }

  void _saveManual(FoodEntry entry) async {
    await context.read<NutritionProvider>().addFood(entry);
    if (mounted) Navigator.pop(context);
  }
}

// ─── Search Tab ─────────────────────────────────────────────────────────────

class _SearchTab extends StatelessWidget {
  final TextEditingController controller;
  final List<FoodSearchResult> results;
  final bool searching;
  final String selectedMeal;
  final List<String> meals;
  final Function(String) onMealChanged;
  final Function(String) onSearch;
  final Function(FoodSearchResult) onSelectResult;

  const _SearchTab({
    required this.controller,
    required this.results,
    required this.searching,
    required this.selectedMeal,
    required this.meals,
    required this.onMealChanged,
    required this.onSearch,
    required this.onSelectResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MealSelector(
                  selected: selectedMeal, meals: meals, onChanged: onMealChanged),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar alimento (ej: pollo pechuga)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                  suffixIcon: searching
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF00D4AA)),
                  )
                      : null,
                ),
                onSubmitted: onSearch,
                textInputAction: TextInputAction.search,
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 48,
                    color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text(
                  'No se encontraron alimentos',
                  style: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Usa el escáner 📷 o la pestaña "Manual"',
                  style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: results.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (_, i) {
              final r = results[i];
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                title: Text(r.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${r.calories.toStringAsFixed(0)} kcal  •  P:${r.protein.toStringAsFixed(1)}g  C:${r.carbs.toStringAsFixed(1)}g  G:${r.fat.toStringAsFixed(1)}g',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                trailing: const Icon(Icons.add_circle,
                    color: Color(0xFF00D4AA)),
                onTap: () => onSelectResult(r),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Manual Tab ─────────────────────────────────────────────────────────────

class _ManualTab extends StatefulWidget {
  final String selectedMeal;
  final List<String> meals;
  final Function(String) onMealChanged;
  final Function(FoodEntry) onSave;

  const _ManualTab({
    required this.selectedMeal,
    required this.meals,
    required this.onMealChanged,
    required this.onSave,
  });

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _grams = TextEditingController(text: '100');

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _grams.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MealSelector(
                selected: widget.selectedMeal,
                meals: widget.meals,
                onChanged: widget.onMealChanged),
            const SizedBox(height: 16),
            _Field(controller: _name, label: 'Nombre del alimento', required: true),
            const SizedBox(height: 10),
            _Field(
                controller: _grams,
                label: 'Cantidad (g / ml)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _Field(
                controller: _calories,
                label: 'Calorías (kcal)',
                keyboardType: TextInputType.number,
                required: true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _Field(
                        controller: _protein,
                        label: 'Proteína (g)',
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                    child: _Field(
                        controller: _carbs,
                        label: 'Carbs (g)',
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                    child: _Field(
                        controller: _fat,
                        label: 'Grasas (g)',
                        keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Añadir',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(FoodEntry(
      name: _name.text.trim(),
      calories: double.tryParse(_calories.text) ?? 0,
      protein: double.tryParse(_protein.text) ?? 0,
      carbs: double.tryParse(_carbs.text) ?? 0,
      fat: double.tryParse(_fat.text) ?? 0,
      grams: double.tryParse(_grams.text) ?? 100,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      meal: widget.selectedMeal,
    ));
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _MealSelector extends StatelessWidget {
  final String selected;
  final List<String> meals;
  final Function(String) onChanged;

  const _MealSelector(
      {required this.selected, required this.meals, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final m = meals[i];
          final active = m == selected;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                m,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight:
                  active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool required;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null
          : null,
    );
  }
}

class _GramsBottomSheet extends StatefulWidget {
  final FoodSearchResult result;
  final String meal;
  final Function(double) onConfirm;

  const _GramsBottomSheet({
    required this.result,
    required this.meal,
    required this.onConfirm,
  });

  @override
  State<_GramsBottomSheet> createState() => _GramsBottomSheetState();
}

class _GramsBottomSheetState extends State<_GramsBottomSheet> {
  double _grams = 100;
  final _controller = TextEditingController(text: '100');

  double get _factor => _grams / 100;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.result.name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2),
          const SizedBox(height: 4),
          Text(
            '${widget.meal}  •  por 100g: ${widget.result.calories.toStringAsFixed(0)} kcal',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Cantidad (g)',
                    labelStyle:
                    TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF252525),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _grams = double.tryParse(v) ?? 100);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroPreview(
                    label: 'Kcal',
                    value: (widget.result.calories * _factor).toStringAsFixed(0),
                    color: const Color(0xFF00D4AA)),
                _MacroPreview(
                    label: 'Prot',
                    value: '${(widget.result.protein * _factor).toStringAsFixed(1)}g',
                    color: const Color(0xFF00D4AA)),
                _MacroPreview(
                    label: 'Carbs',
                    value: '${(widget.result.carbs * _factor).toStringAsFixed(1)}g',
                    color: const Color(0xFFFFB347)),
                _MacroPreview(
                    label: 'Grasas',
                    value: '${(widget.result.fat * _factor).toStringAsFixed(1)}g',
                    color: const Color(0xFFFF6B6B)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onConfirm(_grams),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Añadir',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Editable Bottom Sheet con macros editables ─────────────────────────────

class _EditableGramsBottomSheet extends StatefulWidget {
  final FoodSearchResult result;
  final String meal;
  final Function(double, double, double, double, double) onConfirm;

  const _EditableGramsBottomSheet({
    required this.result,
    required this.meal,
    required this.onConfirm,
  });

  @override
  State<_EditableGramsBottomSheet> createState() => _EditableGramsBottomSheetState();
}

class _EditableGramsBottomSheetState extends State<_EditableGramsBottomSheet> {
  double _grams = 100;
  late double _caloriesPer100g;
  late double _proteinPer100g;
  late double _carbsPer100g;
  late double _fatPer100g;

  final _gramsController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _caloriesPer100g = widget.result.calories;
    _proteinPer100g = widget.result.protein;
    _carbsPer100g = widget.result.carbs;
    _fatPer100g = widget.result.fat;

    _caloriesController.text = _caloriesPer100g.toStringAsFixed(0);
    _proteinController.text = _proteinPer100g.toStringAsFixed(1);
    _carbsController.text = _carbsPer100g.toStringAsFixed(1);
    _fatController.text = _fatPer100g.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double get _factor => _grams / 100;

  double get _totalCalories => _caloriesPer100g * _factor;
  double get _totalProtein => _proteinPer100g * _factor;
  double get _totalCarbs => _carbsPer100g * _factor;
  double get _totalFat => _fatPer100g * _factor;

  void _updateMacros() {
    setState(() {
      _caloriesPer100g = double.tryParse(_caloriesController.text) ?? 0;
      _proteinPer100g = double.tryParse(_proteinController.text) ?? 0;
      _carbsPer100g = double.tryParse(_carbsController.text) ?? 0;
      _fatPer100g = double.tryParse(_fatController.text) ?? 0;
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
                  child: Text(widget.result.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 2),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00D4AA), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Puedes editar los valores si no son exactos'),
                        backgroundColor: Color(0xFFFFB347),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.meal}  •  Ajusta los valores si es necesario',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
            ),
            const SizedBox(height: 20),

            // Cantidad
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gramsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Cantidad (g)',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF252525),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() => _grams = double.tryParse(v) ?? 100);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Valores nutricionales editables
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Calorías
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department, color: Color(0xFF00D4AA), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Calorías (por 100g)',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => _updateMacros(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  // Proteína
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.fitness_center, color: Color(0xFF00D4AA), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Proteína (por 100g)',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => _updateMacros(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  // Carbohidratos
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.grain, color: Color(0xFFFFB347), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Carbohidratos (por 100g)',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => _updateMacros(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  // Grasas
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.opacity, color: Color(0xFFFF6B6B), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Grasas (por 100g)',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => _updateMacros(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Resumen total
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroPreview(
                      label: 'Total Kcal',
                      value: _totalCalories.toStringAsFixed(0),
                      color: const Color(0xFF00D4AA)),
                  _MacroPreview(
                      label: 'Prot',
                      value: '${_totalProtein.toStringAsFixed(1)}g',
                      color: const Color(0xFF00D4AA)),
                  _MacroPreview(
                      label: 'Carbs',
                      value: '${_totalCarbs.toStringAsFixed(1)}g',
                      color: const Color(0xFFFFB347)),
                  _MacroPreview(
                      label: 'Grasas',
                      value: '${_totalFat.toStringAsFixed(1)}g',
                      color: const Color(0xFFFF6B6B)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => widget.onConfirm(
                _grams,
                _caloriesPer100g,
                _proteinPer100g,
                _carbsPer100g,
                _fatPer100g,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Añadir',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
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
                color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}