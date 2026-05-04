import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/product_input_card.dart';
import '../widgets/product_list_view.dart';
import '../widgets/product_chart_view.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, String>> products = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  int selectedTab = 0;

  void addProduct() {
    String name = nameController.text.trim();
    String quantity = quantityController.text.trim();
    if (name.isEmpty || quantity.isEmpty) return;
    setState(() {
      products.add({'name': name, 'quantity': quantity});
    });
    nameController.clear();
    quantityController.clear();
  }

  void removeProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  List<BarChartGroupData> buildBarGroups() {
    return products.asMap().entries.map((entry) {
      int index = entry.key;
      double qty = double.tryParse(entry.value['quantity'] ?? '0') ?? 0;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Product Inventory',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) => setState(() => selectedTab = index),
            tabs: const [
              Tab(icon: Icon(Icons.list, color: Colors.white), text: 'Inventory'),
              Tab(icon: Icon(Icons.bar_chart, color: Colors.white), text: 'Chart'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProductInputCard(
                nameController: nameController,
                quantityController: quantityController,
                onAdd: addProduct,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: selectedTab == 0
                    ? ProductListView(
                        products: products,
                        onRemove: removeProduct,
                      )
                    : ProductChartView(
                        products: products,
                        barGroups: buildBarGroups(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}