import 'dart:convert';

import 'package:http/http.dart' as http;

class SupplierService {
  static Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    final response = await http.get(
      Uri.parse(
        'https://restcountries.com/v3.1/region/europe'
        '?fields=name,capital,flags,currencies,population',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load suppliers (status ${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body);
    data.sort((a, b) =>
        (a['name']['common'] as String).compareTo(b['name']['common'] as String));

    return data.map<Map<String, dynamic>>((country) {
      final capital =
          (country['capital'] as List<dynamic>?)?.isNotEmpty == true
              ? country['capital'][0] as String
              : 'N/A';

      String currency = 'N/A';
      final currencies = country['currencies'] as Map<String, dynamic>?;
      if (currencies != null && currencies.isNotEmpty) {
        final firstCurrency = currencies.values.first as Map<String, dynamic>;
        currency = firstCurrency['name']?.toString() ?? 'N/A';
      }

      return {
        'name': country['name']['common'] as String,
        'capital': capital,
        'flagUrl': country['flags']['png'] as String? ?? '',
        'currency': currency,
        'population': country['population'] as int? ?? 0,
      };
    }).toList();
  }

  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
