import 'package:flutter/material.dart';

// ProductInputCard is a form widget that collects the details for a new product.
// It is a StatelessWidget because it doesn't manage its own data —
// the parent (InventoryPage) owns the controllers and the "add" logic.
class ProductInputCard extends StatelessWidget {
  // Controllers let the parent read whatever the user typed in each TextField
  final TextEditingController nameController;
  final TextEditingController quantityController;

  // New field: the minimum number of units before the product is flagged as "Low Stock"
  final TextEditingController minStockLevelController;

  // VoidCallback is shorthand for "a function that takes no arguments and returns nothing".
  // When the user taps Add Product, this calls addProduct() in InventoryPage.
  final VoidCallback onAdd;

  const ProductInputCard({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.minStockLevelController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Card gives the form a white surface with a subtle shadow
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Product',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // TextField for the product name
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

            // TextField for how many units are currently in stock
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
            const SizedBox(height: 12),

            // TextField for the low-stock threshold.
            // If quantity drops to or below this number, the detail screen shows "Low Stock".
            TextField(
              controller: minStockLevelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Stock Level',
                hintText: 'e.g. 5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning_amber),
              ),
            ),
            const SizedBox(height: 16),

            // Full-width button that calls onAdd() when tapped
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Product', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
