// Why we change from StatelessWidget to StatefulWidget
// List<Map<String, String>> — storing products as a list
// TextEditingController — reading what user typed
// setState() — the magic that redraws the screen
// ListView.builder — drawing one row per product
// The ternary operator condition ? a : b — show empty state or the list

import 'package:flutter/material.dart';

// Entry point (unchanged)
void main() {
  runApp(const MyApp());
}

// Root app (unchanged)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InventoryPage(),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// NEW: Converted from StatelessWidget → StatefulWidget
// WHY: because UI now depends on changing data (products list)
// ───────────────────────────────────────────────────────────────
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

// State class holds mutable data + logic
class _InventoryPageState extends State<InventoryPage> {

  // NEW: In-memory data store (very basic)
  // List of Map instead of proper model → OK for demo, not production
  List<Map<String, String>> products = [];

  // NEW: Controllers to read user input from TextFields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // NEW: Business logic → Add product
  void addProduct() {

    // Read and clean user input
    String name = nameController.text.trim();
    String quantity = quantityController.text.trim();

    // Guard clause → prevent invalid input
    if (name.isEmpty || quantity.isEmpty) return;

    // CRITICAL: setState triggers UI rebuild
    setState(() {
      products.add({
        'name': name,
        'quantity': quantity,
      });
    });

    // Reset input fields after action
    nameController.clear();
    quantityController.clear();
  }

  // NEW: Business logic → Remove product
  void removeProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Product Inventory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [

            // ── Input card (mostly same, but now CONNECTED) ──────────
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // NEW: connected to controller
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g. Laptop',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // NEW: connected + numeric keyboard
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'e.g. 10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        // NEW: wired to logic
                        onPressed: addProduct,

                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 16),
                        ),

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── NEW: Dynamic product count ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products in Stock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Chip shows live count
                Chip(
                  label: Text('${products.length} items'),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── NEW: Dynamic list rendering ──────────────────────────
            Expanded(
              // IMPORTANT: Expanded allows ListView to take remaining space
              child: products.isEmpty

                  // EMPTY STATE UI (good UX practice)
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No products yet.\nAdd your first product above!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )

                  // LIST STATE
                  : ListView.builder(
                      // Efficient rendering (lazy loading)
                      itemCount: products.length,

                      itemBuilder: (context, index) {

                        // Access current item
                        final product = products[index];

                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 8),

                          child: ListTile(
                            // LEFT: index badge
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,

                              child: Text(
                                '${index + 1}',

                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // MAIN CONTENT
                            title: Text(
                              product['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              'Quantity: ${product['quantity']}',
                            ),

                            // RIGHT: delete button
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              // NEW: remove logic connected
                              onPressed: () =>
                                  removeProduct(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}