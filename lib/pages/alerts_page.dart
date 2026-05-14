import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../widgets/alert_card.dart';

class _AlertItem {
  final DocumentSnapshot doc;
  final String name;
  final int qty;
  final int min;
  final bool isOutOfStock; // true = qty == 0,  false = low stock

  const _AlertItem({
    required this.doc,
    required this.name,
    required this.qty,
    required this.min,
    required this.isOutOfStock,
  });
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text(
                'Show: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == 'all',
                onSelected: (_) => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Low Stock'),
                selected: _filter == 'low_stock',
                onSelected: (_) => setState(() => _filter = 'low_stock'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Out of Stock'),
                selected: _filter == 'out_of_stock',
                onSelected: (_) => setState(() => _filter = 'out_of_stock'),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Compute alerts from product documents.
              // Out of stock: qty == 0
              // Low stock:    qty > 0 AND minStockLevel > 0 AND qty <= minStockLevel
              final alerts = <_AlertItem>[];
              for (final doc in snapshot.data?.docs ?? []) {
                final data = doc.data() as Map<String, dynamic>;
                final qty =
                    int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
                final min =
                    int.tryParse(data['minStockLevel']?.toString() ?? '0') ?? 0;
                final name = data['name']?.toString() ?? '';

                if (qty == 0) {
                  alerts.add(_AlertItem(
                    doc: doc,
                    name: name,
                    qty: qty,
                    min: min,
                    isOutOfStock: true,
                  ));
                } else if (min > 0 && qty <= min) {
                  alerts.add(_AlertItem(
                    doc: doc,
                    name: name,
                    qty: qty,
                    min: min,
                    isOutOfStock: false,
                  ));
                }
              }

              // Apply filter
              final filtered = switch (_filter) {
                'low_stock' => alerts.where((a) => !a.isOutOfStock).toList(),
                'out_of_stock' =>
                  alerts.where((a) => a.isOutOfStock).toList(),
                _ => alerts,
              };

              // ── Empty state ──
              if (filtered.isEmpty) {
                final message = switch (_filter) {
                  'low_stock' => 'No low-stock products.',
                  'out_of_stock' => 'No out-of-stock products.',
                  _ => 'All products are well stocked.',
                };
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final alert = filtered[index];
                  return AlertCard(
                    name: alert.name,
                    qty: alert.qty,
                    min: alert.min,
                    isOutOfStock: alert.isOutOfStock,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: {
                            'id': alert.doc.id,
                            'name': alert.name,
                            'quantity': alert.qty.toString(),
                            'minStockLevel': alert.min.toString(),
                          },
                        ),
                      ),
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
