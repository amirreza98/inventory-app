import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ProductChartView displays a bar chart of product quantities.
// It receives pre-built bar data from InventoryPage so this widget stays simple.
class ProductChartView extends StatelessWidget {
  // Upgraded to Map<String, dynamic> to match the new product data model
  final List<Map<String, dynamic>> products;

  // BarChartGroupData is a fl_chart class that describes one bar in the chart
  final List<BarChartGroupData> barGroups;

  const ProductChartView({
    super.key,
    required this.products,
    required this.barGroups,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state: no products to chart yet
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Add products to see the chart!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Find the highest quantity so we can set the chart's Y axis maximum
    double maxQty = products
        .map((p) => double.tryParse(p['quantity']?.toString() ?? '0') ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Levels by Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Expanded gives the BarChart all remaining vertical space in its parent Column
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxQty + 5,
              barGroups: barGroups,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                // Bottom axis: product names (truncated if too long)
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= products.length) return const SizedBox();
                      String name = products[index]['name']?.toString() ?? '';
                      if (name.length > 8) name = '${name.substring(0, 7)}..';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(name, style: const TextStyle(fontSize: 11)),
                      );
                    },
                    reservedSize: 36,
                  ),
                ),
                // Left axis: quantity numbers
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Each bar = quantity of one product',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
