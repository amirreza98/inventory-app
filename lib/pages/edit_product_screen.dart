import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// EditProductScreen lets the user change the name, quantity, or minimum stock
// level of an existing product. Changes are saved directly to Firestore.
// The screen receives the current product data so the fields are pre-filled.
class EditProductScreen extends StatefulWidget {
  // The product map contains: id, name, quantity, minStockLevel
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // "late" controllers are initialized in initState with the current product values
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController minStockLevelController;

  // isSaving prevents the user from tapping Save multiple times while the request is in progress
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill each field with the existing product data.
    // TextEditingController(text: '...') sets the initial value of a TextField.
    nameController =
        TextEditingController(text: widget.product['name']?.toString() ?? '');
    quantityController = TextEditingController(
        text: widget.product['quantity']?.toString() ?? '');
    minStockLevelController = TextEditingController(
        text: widget.product['minStockLevel']?.toString() ?? '0');
  }

  @override
  void dispose() {
    // Free memory when this screen is removed from the navigation stack
    nameController.dispose();
    quantityController.dispose();
    minStockLevelController.dispose();
    super.dispose();
  }

  // saveChanges() validates the fields, updates Firestore, shows a confirmation,
  // then pops this screen to go back to the Product Detail screen.
  Future<void> saveChanges() async {
    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();
    final minStockLevel = minStockLevelController.text.trim();

    // Validate: none of the fields can be empty
    if (name.isEmpty || quantity.isEmpty || minStockLevel.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar() displays a temporary message
      // at the bottom of the screen without blocking the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Show the loading spinner on the Save button while the request is in flight
    setState(() => isSaving = true);

    // .doc(id).update() updates only the specified fields in the existing Firestore document.
    // Unlike .set(), it does not overwrite fields we don't mention.
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product['id'])
        .update({
      'name': name,
      'quantity': quantity,
      'minStockLevel': minStockLevel,
    });

    setState(() => isSaving = false);

    // context.mounted checks that the screen is still in the navigation stack
    // before showing a message or navigating — avoids errors on slow devices
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      // Navigator.pop() removes this screen and goes back to the Product Detail screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Flutter adds the back arrow automatically for pushed screens
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pre-filled TextField for the product name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
            ),
            const SizedBox(height: 16),

            // Pre-filled TextField for the quantity
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),

            // Pre-filled TextField for the minimum stock level
            TextField(
              controller: minStockLevelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Stock Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning_amber),
              ),
            ),

            // Spacer pushes the Save button to the bottom of the screen
            const Spacer(),

            // Save button — disabled and shows a spinner while saving
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Passing null to onPressed disables the button (greyed out)
                onPressed: isSaving ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSaving
                    // Show a spinner while the Firestore update is in progress
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
