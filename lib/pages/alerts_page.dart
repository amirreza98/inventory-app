import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

// _AlertItem is a helper that holds the parsed fields for one alert.
// Alerts are not stored in Firestore — they are computed on the fly from
// the products collection every time a product document changes.
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

// AlertsPage streams the products collection and automatically surfaces every
// product that is either completely out of stock (qty == 0) or running low
// (qty > 0 AND qty <= minStockLevel AND minStockLevel > 0).
// There is no manual data entry — alerts appear and disappear as product
// quantities change anywhere in the app.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  // _filter controls which subset of alerts is shown
  String _filter = 'all'; // 'all' | 'low_stock' | 'out_of_stock'

  Color _stripeColor(bool isOutOfStock) =>
      isOutOfStock ? Colors.red : Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Filter chip row ─────────────────────────────────────────────
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

        // ── Live alerts list ────────────────────────────────────────────
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

              // ── Alert cards ──
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final alert = filtered[index];
                  final color = _stripeColor(alert.isOutOfStock);

                  return Card(
                    margin: const EdgeInsets.only(top: 10),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      // Tap card to open the product detail screen so the
                      // user can immediately edit the quantity to fix it.
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
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: color, width: 5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            alert.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                alert.isOutOfStock
                                    ? 'Stock: 0 — completely out of stock'
                                    : 'Stock: ${alert.qty} (min: ${alert.min})',
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(38),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  alert.isOutOfStock
                                      ? 'OUT OF STOCK'
                                      : 'LOW STOCK',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          // Chevron hints the card is tappable
                          trailing: const Icon(Icons.chevron_right),
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
