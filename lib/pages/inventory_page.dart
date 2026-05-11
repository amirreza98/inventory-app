import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_input_card.dart';
import '../widgets/product_list_view.dart';
import '../widgets/product_chart_view.dart';
import 'product_detail_screen.dart';

// InventoryPage shows the product list and bar chart.
// IMPORTANT: This widget does NOT have its own Scaffold.
// The parent (MainShell) provides the Scaffold and AppBar.
// InventoryPage just returns its content as a Column.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

// SingleTickerProviderStateMixin is required to animate the TabBar.
// A "ticker" is what Flutter uses to drive animations frame-by-frame.
class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  // Controllers for the three input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minStockLevelController = TextEditingController();

  // _collection is a reference to the "products" collection in Firestore.
  // Any changes to this collection are streamed to our StreamBuilder in real time.
  final _collection = FirebaseFirestore.instance.collection('products');

  // TabController drives both the TabBar indicator and TabBarView page switching.
  // "late" means we initialize it in initState instead of here.
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Create the tab controller with 2 tabs.
    // vsync: this means this State object drives the animation clock.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Always dispose controllers and animation resources to free memory
    _tabController.dispose();
    nameController.dispose();
    quantityController.dispose();
    minStockLevelController.dispose();
    super.dispose();
  }

  // addProduct() reads all three text fields and creates a new Firestore document.
  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();

    // Default minStockLevel to '0' if the user leaves it blank
    final minStock = minStockLevelController.text.trim().isEmpty
        ? '0'
        : minStockLevelController.text.trim();

    // Don't save if the name or quantity is missing
    if (name.isEmpty || quantity.isEmpty) return;

    // .add() creates a new document in Firestore with an auto-generated ID.
    // This triggers the StreamBuilder below to rebuild with the new product.
    await _collection.add({
      'name': name,
      'quantity': quantity,
      'minStockLevel': minStock,
    });

    // Clear all fields after adding so the form is ready for the next product
    nameController.clear();
    quantityController.clear();
    minStockLevelController.clear();
  }

  // buildBarGroups() converts Firestore documents into bar chart data for fl_chart.
  // Each document becomes one bar, with height equal to the product's quantity.
  List<BarChartGroupData> buildBarGroups(List<QueryDocumentSnapshot> docs) {
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
    // We return a Column — no Scaffold here.
    // MainShell's Scaffold wraps everything including this widget.
    return Column(
      children: [
        // Tab bar sits at the top, styled to match the primary color from the AppBar
        Material(
          color: Theme.of(context).colorScheme.primary,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.list, color: Colors.white), text: 'Inventory'),
              Tab(icon: Icon(Icons.bar_chart, color: Colors.white), text: 'Chart'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),

        // StreamBuilder listens to the Firestore "products" collection.
        // Every time a product is added, edited, or deleted, this builder is called
        // automatically and the UI updates without any manual refresh.
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _collection.snapshots(),
            builder: (context, snapshot) {
              // Show a spinner while the first data load is in progress
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              // Convert each Firestore document into a plain Dart Map.
              // We include the document ID ('id') so we can delete/update later.
              final products = docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                return <String, dynamic>{
                  'id': d.id,
                  'name': data['name']?.toString() ?? '',
                  'quantity': data['quantity']?.toString() ?? '0',
                  // Default to '0' for products added before this field existed
                  'minStockLevel': data['minStockLevel']?.toString() ?? '0',
                };
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // The input form (always visible, regardless of which tab is selected)
                    ProductInputCard(
                      nameController: nameController,
                      quantityController: quantityController,
                      minStockLevelController: minStockLevelController,
                      onAdd: addProduct,
                    ),
                    const SizedBox(height: 16),

                    // TabBarView switches content when the user taps a tab or swipes.
                    // It is connected to _tabController which is also connected to the TabBar above.
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 0 — Inventory list
                          ProductListView(
                            products: products,
                            // When a card is tapped, Navigator.push() slides in a new screen.
                            // The full product map is passed so the detail screen has all the data.
                            onTap: (product) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          ),

                          // Tab 1 — Bar chart
                          ProductChartView(
                            products: products,
                            barGroups: buildBarGroups(docs),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
