import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_screen.dart';

// ProductDetailScreen shows full details for one product and lets the user
// edit or delete it. It receives the product as a Map so no extra Firestore
// read is needed just to display data.
class ProductDetailScreen extends StatelessWidget {
  // The full product map: id, name, quantity, minStockLevel
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  // _buildStatusBadge() computes the stock status and returns a colored label.
  // Green = In Stock, Yellow/Orange = Low Stock, Red = Out of Stock.
  Widget _buildStatusBadge() {
    // Parse quantity and minStockLevel as integers for comparison.
    // If parsing fails (e.g. empty string), default to 0.
    final quantity =
        int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final minStock =
        int.tryParse(product['minStockLevel']?.toString() ?? '0') ?? 0;

    Color bgColor;
    String label;

    if (quantity == 0) {
      bgColor = Colors.red;
      label = 'Out of Stock';
    } else if (quantity <= minStock) {
      // quantity is at or below the minimum threshold
      bgColor = Colors.orange;
      label = 'Low Stock';
    } else {
      bgColor = Colors.green;
      label = 'In Stock';
    }

    // Container with rounded corners and a colored background acts as a badge
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // _showDeleteDialog() pops up an AlertDialog asking the user to confirm.
  // Only if they tap "Delete" does the product actually get removed.
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content:
            const Text('Are you sure you want to delete this product?'),
        actions: [
          // Cancel: closes the dialog and does nothing
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),

          // Delete: closes the dialog, then deletes the document and navigates back
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // 1st pop: dismiss the AlertDialog
              Navigator.pop(dialogContext);

              // Delete the Firestore document using the product's ID.
              // The StreamBuilder in InventoryPage will automatically update.
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(product['id'])
                  .delete();

              // 2nd pop: dismiss the ProductDetailScreen and go back to the list.
              // context.mounted checks that this screen is still visible before navigating.
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,

        // iconTheme styles all icons in the AppBar, including the automatic back arrow
        iconTheme: const IconThemeData(color: Colors.white),

        // Flutter automatically adds a back arrow because this screen was pushed
        // with Navigator.push(). Tapping it calls Navigator.pop() for us.
        title: Text(
          product['name']?.toString() ?? 'Product',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          // Edit button opens the EditProductScreen on top of this screen
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit product',
            onPressed: () {
              // Navigator.push() slides the new screen in from the right.
              // When the user is done editing and pops, they return here.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info row: current quantity in stock
            _InfoRow(
              icon: Icons.inventory_2,
              label: 'Quantity',
              value: product['quantity']?.toString() ?? '0',
            ),
            const SizedBox(height: 12),

            // Info row: minimum stock level threshold
            _InfoRow(
              icon: Icons.warning_amber,
              label: 'Minimum Stock Level',
              value: product['minStockLevel']?.toString() ?? '0',
            ),
            const SizedBox(height: 12),

            // Status row with colored badge
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Danger Zone: clearly labeled destructive actions section
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),

            // OutlinedButton with a red border signals a destructive action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Delete Product',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _showDeleteDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _InfoRow is a reusable row that shows an icon, a label, and a value.
// It is private to this file (underscore prefix = not exported).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon on the left for quick visual scanning
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),

        // Label text in grey (secondary information)
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),

        // Spacer pushes the value to the far right
        const Spacer(),

        // Value text in bold (primary information)
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
