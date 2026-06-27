import 'dart:convert';
import 'package:http/http.dart' as http;

enum HalalStatus { halal, haram, doubtful, unknown }

class IngredientResult {
  final String name;
  final HalalStatus status;
  final String reason;

  IngredientResult({
    required this.name,
    required this.status,
    required this.reason,
  });
}

class ProductResult {
  final String barcode;
  final String productName;
  final String brand;
  final String? imageUrl;
  final List<String> ingredients;
  final List<IngredientResult> flaggedIngredients;
  final HalalStatus overallStatus;

  ProductResult({
    required this.barcode,
    required this.productName,
    required this.brand,
    this.imageUrl,
    required this.ingredients,
    required this.flaggedIngredients,
    required this.overallStatus,
  });
}

class HalalCheckerService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  // Haram E-numbers — public for reference tab
  static const Map<String, String> haramENumbers = {
    'e120': 'Cochineal / Carmine — made from insects',
    'e441': 'Gelatine — pork/animal derived',
    'e542': 'Bone phosphate — animal bones',
    'e904': 'Shellac — insect secretion',
    'e901': 'Beeswax — may be haram in food',
    'e422': 'Glycerol — may be pork derived',
    'e470a': 'Sodium/potassium/calcium salts of fatty acids — may be pork',
    'e470b': 'Magnesium salts of fatty acids — may be pork',
    'e471': 'Mono & diglycerides of fatty acids — may be pork',
    'e472a': 'Acetic acid esters — may be pork',
    'e472b': 'Lactic acid esters — may be pork',
    'e472c': 'Citric acid esters — may be pork',
    'e472d': 'Tartaric acid esters — may be pork',
    'e472e': 'Mono & diacetyl tartaric acid esters — may be pork',
    'e472f': 'Mixed tartaric acetic citric acid esters — may be pork',
    'e473': 'Sucrose esters — may be pork',
    'e474': 'Sucroglycerides — may be pork',
    'e475': 'Polyglycerol esters — may be pork',
    'e476': 'Polyglycerol polyricinoleate — may be pork',
    'e477': 'Propylene glycol esters — may be pork',
    'e481': 'Sodium stearoyl-2-lactylate — may be pork',
    'e482': 'Calcium stearoyl-2-lactylate — may be pork',
    'e483': 'Stearyl tartrate — may be pork',
  };

  // Doubtful E-numbers — public for reference tab
  static const Map<String, String> doubtfulENumbers = {
    'e100': 'Curcumin — generally halal but verify source',
    'e101': 'Riboflavin — may be animal derived',
    'e160a': 'Alpha-carotene — verify source',
    'e161b': 'Lutein — verify source',
    'e161g': 'Canthaxanthin — verify source',
    'e252': 'Potassium nitrate — verify use',
    'e306': 'Tocopherol — verify source',
    'e322': 'Lecithin — may be animal derived',
    'e407': 'Carrageenan — generally halal',
    'e412': 'Guar gum — generally halal',
    'e430': 'Polyoxyethylene — may be pork',
    'e431': 'Polyoxyethylene — may be pork',
    'e433': 'Polysorbate 80 — may be pork',
    'e434': 'Polysorbate 40 — may be pork',
    'e435': 'Polysorbate 60 — may be pork',
    'e436': 'Polysorbate 65 — may be pork',
    'e570': 'Fatty acids — verify source',
    'e572': 'Magnesium stearate — may be animal',
    'e585': 'Ferrous lactate — verify source',
    'e920': 'L-cysteine — may be human hair or pig bristles',
  };

  // Haram keywords in ingredients
  static const List<String> _haramKeywords = [
    'pork', 'pig', 'swine', 'lard', 'bacon', 'ham', 'gelatin', 'gelatine',
    'carmine', 'cochineal', 'alcohol', 'ethanol', 'wine', 'beer', 'liquor',
    'rum', 'vodka', 'whiskey', 'brandy', 'mead', 'sake',
    'blood', 'rennet', 'pepsin', 'lipase', 'tallow',
    'shortening', 'mono and diglycerides',
  ];

  // Doubtful keywords
  static const List<String> _doubtfulKeywords = [
    'natural flavor', 'natural flavoring', 'natural flavours',
    'emulsifier', 'lecithin', 'glycerin', 'glycerol',
    'mono-diglycerides', 'whey', 'casein', 'L-cysteine',
    'shellac', 'confectioner\'s glaze',
  ];

  static Future<ProductResult?> checkBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$barcode.json'),
        headers: {
          'User-Agent': 'NoorApp/1.0 (Islamic Halal Checker)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data['status'] != 1) return null;

      final product = data['product'] as Map<String, dynamic>;

      final productName = product['product_name'] as String? ??
          product['product_name_en'] as String? ??
          'Unknown Product';
      final brand = product['brands'] as String? ?? 'Unknown Brand';
      final imageUrl = product['image_url'] as String?;

      // Get ingredients text
      final ingredientsText = (product['ingredients_text'] as String? ??
              product['ingredients_text_en'] as String? ??
              '')
          .toLowerCase();

      // Parse ingredient list
      final List<String> ingredientsList = [];
      if (product['ingredients'] != null) {
        for (final ing in (product['ingredients'] as List)) {
          final text = ing['text'] as String? ?? '';
          if (text.isNotEmpty) ingredientsList.add(text);
        }
      }

      final flagged = _analyzeIngredients(ingredientsText, ingredientsList);
      final overallStatus = _calculateOverallStatus(flagged);

      return ProductResult(
        barcode: barcode,
        productName: productName,
        brand: brand,
        imageUrl: imageUrl,
        ingredients: ingredientsList,
        flaggedIngredients: flagged,
        overallStatus: overallStatus,
      );
    } catch (_) {
      return null;
    }
  }

  static List<IngredientResult> _analyzeIngredients(
      String text, List<String> ingredients) {
    final List<IngredientResult> results = [];
    final seen = <String>{};

    // Check E-numbers in text
    final eNumberRegex = RegExp(r'e\d{3}[a-z]?', caseSensitive: false);
    for (final match in eNumberRegex.allMatches(text)) {
      final eNum = match.group(0)!.toLowerCase();
      if (seen.contains(eNum)) continue;
      seen.add(eNum);

      if (haramENumbers.containsKey(eNum)) {
        results.add(IngredientResult(
          name: eNum.toUpperCase(),
          status: HalalStatus.haram,
          reason: haramENumbers[eNum]!,
        ));
      } else if (doubtfulENumbers.containsKey(eNum)) {
        results.add(IngredientResult(
          name: eNum.toUpperCase(),
          status: HalalStatus.doubtful,
          reason: doubtfulENumbers[eNum]!,
        ));
      }
    }

    // Check haram keywords
    for (final keyword in _haramKeywords) {
      if (text.contains(keyword) && !seen.contains(keyword)) {
        seen.add(keyword);
        results.add(IngredientResult(
          name: keyword,
          status: HalalStatus.haram,
          reason: 'Contains haram ingredient: $keyword',
        ));
      }
    }

    // Check doubtful keywords
    for (final keyword in _doubtfulKeywords) {
      if (text.contains(keyword) && !seen.contains(keyword)) {
        seen.add(keyword);
        results.add(IngredientResult(
          name: keyword,
          status: HalalStatus.doubtful,
          reason: 'Doubtful — source needs verification: $keyword',
        ));
      }
    }

    return results;
  }

  static HalalStatus _calculateOverallStatus(List<IngredientResult> flagged) {
    if (flagged.isEmpty) return HalalStatus.halal;
    if (flagged.any((f) => f.status == HalalStatus.haram)) {
      return HalalStatus.haram;
    }
    if (flagged.any((f) => f.status == HalalStatus.doubtful)) {
      return HalalStatus.doubtful;
    }
    return HalalStatus.halal;
  }

  // Manual text check (user types ingredients)
  static ProductResult checkManualIngredients(String ingredientsText) {
    final text = ingredientsText.toLowerCase();
    final flagged = _analyzeIngredients(text, []);
    return ProductResult(
      barcode: 'manual',
      productName: 'Manual Check',
      brand: '',
      ingredients: ingredientsText.split(',').map((e) => e.trim()).toList(),
      flaggedIngredients: flagged,
      overallStatus: _calculateOverallStatus(flagged),
    );
  }
}
