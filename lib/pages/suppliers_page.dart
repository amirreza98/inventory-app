import 'package:flutter/material.dart';
import '../services/supplier_service.dart';
import '../widgets/supplier_card.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  late Future<List<Map<String, dynamic>>> _suppliersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _suppliersFuture = SupplierService.fetchSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search suppliers...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _suppliersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

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

              final allSuppliers = snapshot.data ?? [];
              final suppliers = _searchQuery.isEmpty
                  ? allSuppliers
                  : allSuppliers
                      .where((s) => s['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

              if (suppliers.isEmpty) {
                return const Center(
                  child: Text(
                    'No suppliers found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return SupplierCard(
                    name: supplier['name'] as String,
                    capital: supplier['capital'] as String,
                    flagUrl: supplier['flagUrl'] as String,
                    currency: supplier['currency'] as String,
                    annualVolume: SupplierService.formatNumber(
                        supplier['population'] as int),
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
