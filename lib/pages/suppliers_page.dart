import 'dart:convert'; // jsonDecode: converts a raw JSON string into Dart objects

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http package for making API calls

// SuppliersPage fetches a list of European countries from a free public API
// and displays them as simulated suppliers. Each country represents a vendor:
//   country name     → company name
//   capital city     → headquarters
//   currency         → payment currency
//   population       → annual order volume
class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  // Future is a Dart type that represents a value arriving in the future.
  // Think of it like ordering food: you place the order now, the food arrives later.
  // _suppliersFuture holds the eventual result of our API call.
  late Future<List<Map<String, dynamic>>> _suppliersFuture;

  // _searchQuery is updated as the user types in the search bar.
  // setState() causes the list to re-filter on every keystroke.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Start the API call once when this screen first appears.
    // Storing it in a variable prevents it from re-firing on every rebuild.
    _suppliersFuture = fetchSuppliers();
  }

  // fetchSuppliers() sends an HTTP GET request to the REST Countries API
  // and returns a list of supplier maps that our UI can display.
  Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    // http.get() sends the request; "await" pauses this function until the response arrives.
    // While waiting, Flutter continues to run other things (like animations) — the UI never freezes.
    final response = await http.get(
      Uri.parse(
        'https://restcountries.com/v3.1/region/europe'
        '?fields=name,capital,flags,currencies,population',
      ),
    );

    // HTTP status 200 means "OK". Anything else is an error.
    if (response.statusCode != 200) {
      throw Exception('Failed to load suppliers (status ${response.statusCode})');
    }

    // response.body is a raw JSON string like: [{"name":{"common":"Germany"},...}, ...]
    // jsonDecode() parses it into a Dart List of Maps
    final List<dynamic> data = jsonDecode(response.body);

    // Sort alphabetically so the list is easier to scroll through
    data.sort((a, b) =>
        (a['name']['common'] as String).compareTo(b['name']['common'] as String));

    // Convert each country entry into a flat Map our widget tree can display directly
    return data.map<Map<String, dynamic>>((country) {
      // The capital field is a list because some countries have multiple capitals
      final capital =
          (country['capital'] as List<dynamic>?)?.isNotEmpty == true
              ? country['capital'][0] as String
              : 'N/A';

      // The currencies field is a nested Map: {"EUR": {"name": "Euro", "symbol": "€"}}
      // We extract just the currency name from the first entry
      String currency = 'N/A';
      final currencies = country['currencies'] as Map<String, dynamic>?;
      if (currencies != null && currencies.isNotEmpty) {
        final firstCurrency = currencies.values.first as Map<String, dynamic>;
        currency = firstCurrency['name']?.toString() ?? 'N/A';
      }

      return {
        'name': country['name']['common'] as String,
        'capital': capital,
        // flags.png is a URL pointing to an image we can load with Image.network()
        'flagUrl': country['flags']['png'] as String? ?? '',
        'currency': currency,
        'population': country['population'] as int? ?? 0,
      };
    }).toList();
  }

  // _formatNumber inserts commas into large numbers for readability.
  // Example: 83783942 → "83,783,942"
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    // We return a Column (no Scaffold) because MainShell provides the Scaffold
    return Column(
      children: [
        // Search bar at the top — filters the list in real time using setState
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search suppliers...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            // onChanged fires every time the user types or deletes a character
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        // FutureBuilder rebuilds its subtree whenever the Future's state changes.
        // State 1: waiting    → show a loading spinner
        // State 2: error      → show an error message
        // State 3: data ready → show the supplier list
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _suppliersFuture,
            builder: (context, snapshot) {
              // ConnectionState.waiting means the API call hasn't returned yet
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // snapshot.hasError is true if fetchSuppliers() threw an exception
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load suppliers.\n${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // snapshot.data contains the List returned by fetchSuppliers()
              final allSuppliers = snapshot.data ?? [];

              // Filter by the search query (case-insensitive)
              final suppliers = _searchQuery.isEmpty
                  ? allSuppliers
                  : allSuppliers
                      .where((s) => s['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

              // Empty state when the search matches nothing
              if (suppliers.isEmpty) {
                return const Center(
                  child: Text(
                    'No suppliers found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              // ListView.builder renders only the visible cards — efficient for long lists
              return ListView.builder(
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),

                      // Flag image loaded directly from the API's image URL.
                      // Image.network() downloads and caches the image automatically.
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          supplier['flagUrl'] as String,
                          width: 50,
                          height: 36,
                          fit: BoxFit.cover,
                          // loadingBuilder shows a small spinner while the image downloads
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 50,
                              height: 36,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            );
                          },
                          // errorBuilder shows a fallback icon if the image fails to load
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag, size: 36),
                        ),
                      ),

                      // Country name = company name
                      title: Text(
                        supplier['name'] as String,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      // Three lines of metadata about the supplier
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('HQ: ${supplier['capital']}'),
                          Text('Currency: ${supplier['currency']}'),
                          Text(
                              'Annual Volume: ${_formatNumber(supplier['population'] as int)}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
