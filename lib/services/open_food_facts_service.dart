// lib/services/open_food_facts_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

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
  static const String _base    = 'https://world.openfoodfacts.org';
  static const String _baseEs  = 'https://es.openfoodfacts.org';
  static const String _usdaBase = 'https://api.nal.usda.gov/fdc/v1';

  static const Map<String, String> _headers = {
    'User-Agent': 'MacroTracker/1.0 (Android; flutter)',
    'Accept': 'application/json',
  };

  static const Map<String, String> _usdaDict = {
    'pechuga de pollo': 'chicken breast',
    'pechuga': 'chicken breast',
    'muslo de pollo': 'chicken thigh',
    'carne picada': 'ground beef',
    'lomo de cerdo': 'pork loin',
    'clara de huevo': 'egg white',
    'claras': 'egg white',
    'yema de huevo': 'egg yolk',
    'aceite de oliva': 'olive oil',
    'mantequilla de cacahuete': 'peanut butter',
    'arroz integral': 'brown rice',
    'arroz blanco': 'white rice',
    'leche desnatada': 'skim milk',
    'leche entera': 'whole milk',
    'yogur griego': 'greek yogurt',
    'avena': 'oats',
    'copos de avena': 'rolled oats',
    'proteína de suero': 'whey protein',
    'atún en lata': 'canned tuna',
    'boniato': 'sweet potato',
  };

  // ── BÚSQUEDA PRINCIPAL ────────────────────────────────────────────────────

  Future<List<FoodSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    print('🔍 Buscando: "$query"');

    final queryLower = query.trim().toLowerCase();

    // 1. Open Food Facts España
    final offResults = await _searchInOpenFoodFacts(query);

    if (offResults.isNotEmpty) {
      // Ordenar por relevancia:
      // Nivel 1: el nombre EMPIEZA por la query (ej: "Huevos camperos L")
      // Nivel 2: el nombre CONTIENE la query (ej: "Huevos de gallina")
      // Nivel 3: el resto (ej: "Lasagne all'uovo")
      final level1 = offResults
          .where((r) => r.name.toLowerCase().startsWith(queryLower))
          .toList();
      final level2 = offResults
          .where((r) =>
      !r.name.toLowerCase().startsWith(queryLower) &&
          r.name.toLowerCase().contains(queryLower))
          .toList();
      final level3 = offResults
          .where((r) => !r.name.toLowerCase().contains(queryLower))
          .toList();

      final sorted = [...level1, ...level2, ...level3];

      print('✅ OFF: ${level1.length} exactos + ${level2.length} parciales + ${level3.length} secundarios');
      return sorted;
    }

    // 2. USDA como fallback
    print('⚠️ Sin resultados en OFF, probando USDA...');
    final englishQuery = _usdaDict[queryLower] ?? query;
    final usdaResults = await _searchInUSDA(englishQuery);
    if (usdaResults.isNotEmpty) {
      print('✅ USDA devolvió ${usdaResults.length} resultados');
      return usdaResults;
    }

    print('❌ No se encontraron resultados');
    return [];
  }

  // ── OPEN FOOD FACTS ───────────────────────────────────────────────────────

  Future<List<FoodSearchResult>> _searchInOpenFoodFacts(String query) async {
    try {
      List<FoodSearchResult> results = await _searchInLanguage(_baseEs, query);
      if (results.isEmpty) results = await _searchInLanguage(_base, query);
      return results;
    } catch (e) {
      print('Error en Open Food Facts: $e');
      return [];
    }
  }

  Future<List<FoodSearchResult>> _searchInLanguage(
      String baseUrl, String query) async {
    try {
      final url = Uri.parse(
        '$baseUrl/cgi/search.pl'
            '?search_terms=${Uri.encodeComponent(query)}'
            '&search_simple=1'
            '&action=process'
            '&json=1'
            '&page_size=50'
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
        if (result != null && result.calories > 0) results.add(result);
      }
      return results;
    } catch (e) {
      print('Error en búsqueda $baseUrl: $e');
      return [];
    }
  }

  FoodSearchResult? _parseProduct(dynamic p) {
    final name = (p['product_name'] ?? '').toString().trim();
    if (name.isEmpty) return null;

    final brand = (p['brands'] ?? '').toString().trim();
    final n = p['nutriments'] as Map<String, dynamic>? ?? {};

    double cal = _getNutrient(n, 'energy-kcal_100g');
    if (cal <= 0) cal = _getNutrient(n, 'energy_100g') / 4.184;
    if (cal <= 0) cal = _getNutrient(n, 'energy-kcal');
    if (cal <= 0) cal = _getNutrient(n, 'energy') / 4.184;

    if (cal <= 0) {
      final p2 = _getNutrient(n, 'proteins_100g');
      final c2 = _getNutrient(n, 'carbohydrates_100g');
      final f2 = _getNutrient(n, 'fat_100g');
      if (p2 > 0 || c2 > 0 || f2 > 0) cal = (p2 * 4) + (c2 * 4) + (f2 * 9);
    }

    if (cal <= 0) return null;

    final protein = _getNutrient(n, 'proteins_100g');
    final carbs   = _getNutrient(n, 'carbohydrates_100g');
    final fat     = _getNutrient(n, 'fat_100g');

    return FoodSearchResult(
      name: name,
      brand: brand,
      calories: cal,
      protein: protein > 0 ? protein : _estimateFromCalories(cal, 'protein'),
      carbs:   carbs   > 0 ? carbs   : _estimateFromCalories(cal, 'carbs'),
      fat:     fat     > 0 ? fat     : _estimateFromCalories(cal, 'fat'),
      isComplete: protein > 0 && carbs > 0 && fat > 0,
    );
  }

  // ── USDA (fallback) ───────────────────────────────────────────────────────

  Future<List<FoodSearchResult>> _searchInUSDA(String query) async {
    try {
      final url = Uri.parse(
        '$_usdaBase/foods/search'
            '?api_key=${ApiKeys.usda}'
            '&query=${Uri.encodeComponent(query)}'
            '&pageSize=10'
            '&dataType=Foundation,SRLegacy',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final foods = data['foods'] as List<dynamic>? ?? [];

      final results = <FoodSearchResult>[];
      for (final food in foods) {
        final parsed = _parseUSDAFood(food);
        if (parsed != null && parsed.calories > 0) results.add(parsed);
      }
      return results;
    } catch (e) {
      print('Error en USDA: $e');
      return [];
    }
  }

  FoodSearchResult? _parseUSDAFood(dynamic food) {
    final description = food['description'] as String?;
    if (description == null) return null;

    final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];
    double calories = 0, protein = 0, carbs = 0, fat = 0;

    for (final nutrient in nutrients) {
      final name  = nutrient['nutrientName'] as String?;
      final value = (nutrient['value'] as num?)?.toDouble() ?? 0.0;
      switch (name) {
        case 'Energy':                      calories = value; break;
        case 'Protein':                     protein  = value; break;
        case 'Carbohydrate, by difference': carbs    = value; break;
        case 'Total lipid (fat)':           fat      = value; break;
      }
    }

    if (calories <= 0) return null;

    return FoodSearchResult(
      name: description,
      brand: 'USDA',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      isComplete: protein > 0 && carbs > 0 && fat > 0,
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  double _getNutrient(Map<String, dynamic> n, String key) {
    final value = n[key];
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _estimateFromCalories(double calories, String macro) {
    switch (macro) {
      case 'protein': return (calories * 0.20) / 4;
      case 'carbs':   return (calories * 0.50) / 4;
      case 'fat':     return (calories * 0.30) / 9;
      default:        return 0;
    }
  }

  // ── CÓDIGO DE BARRAS ──────────────────────────────────────────────────────

  Future<FoodSearchResult?> searchByBarcode(String barcode) async {
    try {
      FoodSearchResult? result =
      await _searchBarcodeInLanguage(_baseEs, barcode);
      result ??= await _searchBarcodeInLanguage(_base, barcode);
      return result;
    } catch (e) {
      print('Error en búsqueda por código: $e');
      return null;
    }
  }

  Future<FoodSearchResult?> _searchBarcodeInLanguage(
      String baseUrl, String barcode) async {
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
      return _parseProduct(data['product']);
    } catch (e) {
      return null;
    }
  }
}