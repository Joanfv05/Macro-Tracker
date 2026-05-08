import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/models.dart';
import '../services/food_api_service.dart';
import 'barcode_scanner_screen.dart';
import '../widgets/add_food/app_colors.dart';
import '../widgets/add_food/search_tab.dart';
import '../widgets/add_food/manual_tab.dart';
import '../widgets/add_food/food_bottom_sheet.dart';

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

  static const _meals = [
    'Desayuno', 'Almuerzo', 'Comida', 'Merienda', 'Cena', 'Snack',
  ];

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
    if (query.trim().isEmpty) { setState(() => _results = []); return; }
    setState(() => _searching = true);
    final results = await _api.search(query.trim());
    if (!mounted) return;
    setState(() { _results = results; _searching = false; });
    if (results.isEmpty) _showSnack('No se encontraron alimentos. Usa "Manual" o escanea el código de barras.');
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<FoodSearchResult>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result != null && mounted) _showFoodSheet(result, editable: true);
  }

  void _showFoodSheet(FoodSearchResult result, {bool editable = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FoodBottomSheet(
        result: result,
        meal: _selectedMeal,
        editable: editable,
        onConfirm: _saveAndPop,
      ),
    );
  }

  Future<void> _saveAndPop(FoodEntry entry) async {
    await context.read<NutritionProvider>().addFood(entry);
    if (mounted) { Navigator.pop(context); Navigator.pop(context); }
  }

  Future<void> _saveManual(FoodEntry entry) async {
    await context.read<NutritionProvider>().addFood(entry);
    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.orange, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Añadir comida',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.accent),
            onPressed: _openScanner,
            tooltip: 'Escanear código de barras',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.accent,
          tabs: const [Tab(text: 'Buscar alimento'), Tab(text: 'Manual')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          SearchTab(
            controller: _searchController,
            results: _results,
            searching: _searching,
            selectedMeal: _selectedMeal,
            meals: _meals,
            onMealChanged: (m) => setState(() => _selectedMeal = m),
            onSearch: _search,
            onSelectResult: (r) => _showFoodSheet(r),
          ),
          ManualTab(
            selectedMeal: _selectedMeal,
            meals: _meals,
            onMealChanged: (m) => setState(() => _selectedMeal = m),
            onSave: _saveManual,
          ),
        ],
      ),
    );
  }
}
