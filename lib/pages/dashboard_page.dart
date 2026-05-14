import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_chart_view.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  List<BarChartGroupData> _buildBarGroups(List<QueryDocumentSnapshot> docs) {
    return docs.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value.data() as Map<String, dynamic>;
      final qty = double.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: qty,
            color: Colors.blue.shade400,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final products = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return <String, dynamic>{
            'id': d.id,
            'name': data['name']?.toString() ?? '',
            'quantity': data['quantity']?.toString() ?? '0',
            'minStockLevel': data['minStockLevel']?.toString() ?? '0',
          };
        }).toList();

        final lowStock = products.where((p) {
          final qty = int.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
          final min = int.tryParse(p['minStockLevel']?.toString() ?? '0') ?? 0;
          return qty > 0 && qty <= min;
        }).length;

        final outOfStock = products.where((p) {
          final qty = int.tryParse(p['quantity']?.toString() ?? '0') ?? 0;
          return qty == 0;
        }).length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      icon: Icons.inventory_2,
                      label: 'Total Products',
                      value: '${products.length}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      icon: Icons.warning_amber,
                      label: 'Low Stock',
                      value: '$lowStock',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      icon: Icons.remove_shopping_cart,
                      label: 'Out of Stock',
                      value: '$outOfStock',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ProductChartView(
                  products: products,
                  barGroups: _buildBarGroups(docs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
