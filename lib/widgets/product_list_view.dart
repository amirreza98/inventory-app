import 'package:flutter/material.dart';

// ProductListView displays a scrollable list of product cards.
// It is a StatelessWidget — it only displays data passed to it from InventoryPage.
class ProductListView extends StatelessWidget {
  // Map<String, dynamic> means the map keys are strings but values can be any type
  // (strings, ints, etc.). We upgraded from Map<String, String> to support minStockLevel.
  final List<Map<String, dynamic>> products;

  // onTap is called when a product card is tapped.
  // The parent (InventoryPage) decides what to do — in this case, navigate to the detail screen.
  final Function(Map<String, dynamic>) onTap;

  const ProductListView({
    super.key,
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row: title on the left, item count chip on the right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products in Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text('${products.length} items'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Expanded tells the Column to give this widget all remaining vertical space
        Expanded(
          child: products.isEmpty
              // Empty state: shown when there are no products in Firestore yet
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No products yet.\nAdd your first product above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              // ListView.builder efficiently builds only the visible cards on screen
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        // onTap makes the entire card tappable.
                        // We pass the full product map so the detail screen gets all data.
                        onTap: () => onTap(product),

                        // Numbered avatar on the left
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          product['name']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Quantity: ${product['quantity']}'),

                        // Arrow icon hints to the user that this card is tappable.
                        // The delete button has moved to the Product Detail screen.
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
