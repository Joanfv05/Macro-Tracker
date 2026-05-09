import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../config/api_keys.dart';
import 'open_food_facts_service.dart';

class FatSecretService {
  static const String _baseUrl = 'https://platform.fatsecret.com/rest/server.api';

  Future<List<FoodSearchResult>> search(String query, {String languageCode = 'es'}) async {
    if (query.trim().isEmpty) return [];

    try {
      final params = {
        'method': 'foods.search',
        'search_expression': query,
        'format': 'json',
        'max_results': '50',
        'language': languageCode,
        'region': 'ES',
      };

      final oauthParams = _buildOAuthParams();
      final allParams = {...params, ...oauthParams};
      final signature = _generateSignature('GET', _baseUrl, allParams);
      allParams['oauth_signature'] = signature;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: allParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        print('❌ Error FatSecret: ${data['error']}');
        return [];
      }

      final foods = data['foods']?['food'];
      if (foods == null) return [];

      // FatSecret devuelve Map en vez de List cuando hay 1 solo resultado
      final foodList = foods is List ? foods : [foods];

      final results = <FoodSearchResult>[];
      for (final food in foodList) {
        final result = _parseFatSecretFood(food);
        if (result != null && result.calories > 0) results.add(result);
      }

      // Primero los que contienen la query en el nombre
      final queryLower = query.toLowerCase();
      results.sort((a, b) {
        final aMatch = a.name.toLowerCase().contains(queryLower) ? 0 : 1;
        final bMatch = b.name.toLowerCase().contains(queryLower) ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });

      return results;
    } catch (e) {
      print('❌ Error en búsqueda FatSecret: $e');
      return [];
    }
  }

  Map<String, String> _buildOAuthParams() {
    return {
      'oauth_consumer_key': ApiKeys.fatSecretConsumerKey,
      'oauth_nonce': _generateNonce(),
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'oauth_version': '1.0',
    };
  }

  // Nonce solo con caracteres alfanuméricos — sin =, +, / que rompen la firma
  String _generateNonce() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateSignature(String method, String url, Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final paramString = sortedKeys
        .map((k) => '${_encode(k)}=${_encode(params[k]!)}')
        .join('&');
    final signatureBase = '${_encode(method)}&${_encode(url)}&${_encode(paramString)}';
    final signingKey = '${_encode(ApiKeys.fatSecretConsumerSecret)}&';
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmac.convert(utf8.encode(signatureBase));
    return base64.encode(digest.bytes);
  }

  // Encoding RFC 3986 (el que usa OAuth 1.0)
  String _encode(String value) => Uri.encodeComponent(value)
      .replaceAll('+', '%20')
      .replaceAll('*', '%2A')
      .replaceAll('%7E', '~');

  FoodSearchResult? _parseFatSecretFood(dynamic food) {
    final name = food['food_name'] as String?;
    if (name == null) return null;

    final description = food['food_description'] as String? ?? '';
    final calories = _parseNutrient(description, 'Calories');
    if (calories <= 0) return null;

    return FoodSearchResult(
      name: name,
      brand: 'FatSecret',
      calories: calories,
      protein: _parseNutrient(description, 'Protein'),
      carbs:   _parseNutrient(description, 'Carbs'),
      fat:     _parseNutrient(description, 'Fat'),
      isComplete: true,
    );
  }

  double _parseNutrient(String description, String nutrient) {
    final match = RegExp('$nutrient:\\s*([\\d.]+)').firstMatch(description);
    return double.tryParse(match?.group(1) ?? '0') ?? 0;
  }
}