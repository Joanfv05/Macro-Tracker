import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodSearchResult {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodSearchResult({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class OpenFoodFactsService {
  static const String _base = 'https://world.openfoodfacts.org';

  static const Map<String, String> _headers = {
    'User-Agent': 'MacroTracker/1.0 (Android; flutter)',
    'Accept': 'application/json',
  };

  Future<List<FoodSearchResult>> search(String query) async {
    try {
      final url = Uri.parse(
        '$_base/cgi/search.pl'
        '?search_terms=${Uri.encodeComponent(query)}'
        '&search_simple=1'
        '&action=process'
        '&json=1'
        '&page_size=25'
        '&fields=product_name,nutriments,brands',
      );

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];

      final results = <FoodSearchResult>[];
      for (final p in products) {
        final name = _safeName(p);
        if (name.isEmpty) continue;

        final n = p['nutriments'] as Map<String, dynamic>? ?? {};
        double cal = _safeDouble(n['energy-kcal_100g']);
        if (cal <= 0) cal = _safeDouble(n['energy-kcal']);
        if (cal <= 0) cal = _safeDouble(n['energy_100g']) / 4.184;
        if (cal <= 0) continue;

        results.add(FoodSearchResult(
          name: name,
          calories: cal,
          protein: _safeDouble(n['proteins_100g']),
          carbs: _safeDouble(n['carbohydrates_100g']),
          fat: _safeDouble(n['fat_100g']),
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<FoodSearchResult?> searchByBarcode(String barcode) async {
    try {
      final url = Uri.parse(
        '$_base/api/v0/product/$barcode.json'
        '?fields=product_name,nutriments,brands',
      );
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data['status'] != 1) return null;

      final p = data['product'];
      final name = _safeName(p);
      if (name.isEmpty) return null;

      final n = p['nutriments'] as Map<String, dynamic>? ?? {};
      double cal = _safeDouble(n['energy-kcal_100g']);
      if (cal <= 0) cal = _safeDouble(n['energy_100g']) / 4.184;
      if (cal <= 0) return null;

      return FoodSearchResult(
        name: name,
        calories: cal,
        protein: _safeDouble(n['proteins_100g']),
        carbs: _safeDouble(n['carbohydrates_100g']),
        fat: _safeDouble(n['fat_100g']),
      );
    } catch (_) {
      return null;
    }
  }

  String _safeName(dynamic p) {
    final name = (p['product_name'] ?? '').toString().trim();
    final brand = (p['brands'] ?? '').toString().trim();
    if (name.isEmpty) return '';
    if (brand.isNotEmpty && !name.toLowerCase().contains(brand.toLowerCase())) {
      return '$name ($brand)';
    }
    return name;
  }

  double _safeDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
}
