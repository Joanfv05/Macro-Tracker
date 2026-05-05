import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodSearchResult {
  final String name;
  final String brand;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool isComplete;

  FoodSearchResult({
    required this.name,
    this.brand = '',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isComplete = true,
  });

  String get fullName => brand.isNotEmpty ? '$name ($brand)' : name;
}

class OpenFoodFactsService {
  static const String _base = 'https://world.openfoodfacts.org';
  static const String _baseEs = 'https://es.openfoodfacts.org';

  static const Map<String, String> _headers = {
    'User-Agent': 'MacroTracker/1.0 (Android; flutter)',
    'Accept': 'application/json',
  };

  // Buscar alimentos con mejores resultados
  Future<List<FoodSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Intentar primero en español
      List<FoodSearchResult> results = await _searchInLanguage(_baseEs, query);

      // Si no hay resultados, buscar en global
      if (results.isEmpty) {
        results = await _searchInLanguage(_base, query);
      }

      return results;
    } catch (e) {
      print('Error en búsqueda: $e');
      return [];
    }
  }

  Future<List<FoodSearchResult>> _searchInLanguage(String baseUrl, String query) async {
    try {
      final url = Uri.parse(
        '$baseUrl/cgi/search.pl'
            '?search_terms=${Uri.encodeComponent(query)}'
            '&search_simple=1'
            '&action=process'
            '&json=1'
            '&page_size=50'  // Más resultados
            '&fields=product_name,brands,nutriments,quantity',
      );

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];

      final results = <FoodSearchResult>[];
      for (final p in products) {
        final result = _parseProduct(p);
        if (result != null && result.calories > 0) {
          results.add(result);
        }
      }

      return results;
    } catch (e) {
      print('Error en búsqueda $_base: $e');
      return [];
    }
  }

  FoodSearchResult? _parseProduct(dynamic p) {
    final name = _safeName(p);
    if (name.isEmpty) return null;

    final brand = (p['brands'] ?? '').toString().trim();
    final n = p['nutriments'] as Map<String, dynamic>? ?? {};

    // Intentar obtener valores por 100g
    double cal = _getNutrient(n, 'energy-kcal_100g');
    if (cal <= 0) cal = _getNutrient(n, 'energy_100g') / 4.184;
    if (cal <= 0) cal = _getNutrient(n, 'energy-kcal');
    if (cal <= 0) cal = _getNutrient(n, 'energy') / 4.184;

    // Si no hay calorías, intentar calcular desde macros
    if (cal <= 0) {
      final protein = _getNutrient(n, 'proteins_100g');
      final carbs = _getNutrient(n, 'carbohydrates_100g');
      final fat = _getNutrient(n, 'fat_100g');
      if (protein > 0 || carbs > 0 || fat > 0) {
        cal = (protein * 4) + (carbs * 4) + (fat * 9);
      }
    }

    if (cal <= 0) return null;

    final protein = _getNutrient(n, 'proteins_100g');
    final carbs = _getNutrient(n, 'carbohydrates_100g');
    final fat = _getNutrient(n, 'fat_100g');

    // Verificar si los datos son completos
    final isComplete = protein > 0 && carbs > 0 && fat > 0;

    return FoodSearchResult(
      name: name,
      brand: brand,
      calories: cal,
      protein: protein > 0 ? protein : _estimateFromCalories(cal, 'protein'),
      carbs: carbs > 0 ? carbs : _estimateFromCalories(cal, 'carbs'),
      fat: fat > 0 ? fat : _estimateFromCalories(cal, 'fat'),
      isComplete: isComplete,
    );
  }

  double _getNutrient(Map<String, dynamic> n, String key) {
    final value = n[key];
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _estimateFromCalories(double calories, String macro) {
    // Estimación por defecto si faltan macros
    switch (macro) {
      case 'protein':
        return (calories * 0.20) / 4; // 20% proteína
      case 'carbs':
        return (calories * 0.50) / 4; // 50% carbs
      case 'fat':
        return (calories * 0.30) / 9; // 30% grasa
      default:
        return 0;
    }
  }

  Future<FoodSearchResult?> searchByBarcode(String barcode) async {
    try {
      // Intentar primero en español
      FoodSearchResult? result = await _searchBarcodeInLanguage(_baseEs, barcode);
      if (result == null) {
        result = await _searchBarcodeInLanguage(_base, barcode);
      }
      return result;
    } catch (e) {
      print('Error en búsqueda por código: $e');
      return null;
    }
  }

  Future<FoodSearchResult?> _searchBarcodeInLanguage(String baseUrl, String barcode) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/v0/product/$barcode.json'
            '?fields=product_name,brands,nutriments,quantity',
      );

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['status'] != 1) return null;

      final p = data['product'];
      return _parseProduct(p);
    } catch (e) {
      return null;
    }
  }

  String _safeName(dynamic p) {
    final name = (p['product_name'] ?? '').toString().trim();
    if (name.isEmpty) return '';
    return name;
  }
}